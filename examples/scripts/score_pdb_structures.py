# pylint: disable=import-outside-toplevel,no-member
import sys
import requests
import argparse
import time 
from pathlib import Path
from typing import List, Dict, Any, Optional

import pandas as pd


def parse_arguments() -> argparse.Namespace:
    """ This function parses the arguments.

    Returns:
        argparse.Namespace: The command line arguments
    """
    parser = argparse.ArgumentParser()
    
    parser.add_argument('--input_pdbids', nargs='+', type=str)
    parser.add_argument('--output_txt_path', type=str)
    parser.add_argument('--min_row',  required=False, type=int, default=1)
    parser.add_argument('--max_row', required=False, type=int, default=-1)
    parser.add_argument('--timeout_duration', required=False, type=int, default=10)
    parser.add_argument('--max_retries', required=False, type=int, default=5)
    
    args = parser.parse_args()
    return args



def fetch_pdb_data(pdb_id: str, timeout_duration=10, max_retries=5) -> Optional[Dict[str, Any]]:
    """Retrieve information for a given PDB ID from the RCSB PDB API

    Args:
        pdb_id (str): The PDB ID of the protein structure.
        timeout_duration (int, optional): The maximum time in seconds to wait for a response from the API before timing out. Defaults to 10.
        max_retries (int, optional): The maximum number of times to retry the request in case of failures. Defaults to 5.
        
    Returns:
        Optional[Dict[str, Any]]: A dictionary containing the relevant data of the PDB entry, or None if the request fails.
    """
    url = f'https://data.rcsb.org/rest/v1/core/entry/{pdb_id}'
    retries = 0

    while retries < max_retries:
        try:
            response = requests.get(url, timeout=timeout_duration)
            
            if response.status_code == 200:
                data = response.json()
                
                # Extract relevant data from the JSON response
                resolution = data['rcsb_entry_info'].get('resolution_combined', [None])[0]
                experimental_method = data['exptl'][0].get('method', 'N/A')
                citations = len(data['rcsb_entry_container_identifiers'].get('related_pubmeds', []))
                
                # Extract r_free and r_work from the refine section
                r_free = 'N/A'
                r_work = 'N/A'
                if 'refine' in data:
                    refine_data = data['refine'][0]  # Assuming we're interested in the first refine entry
                    r_free = refine_data.get('ls_rfactor_rfree', 'N/A')
                    r_work = refine_data.get('ls_rfactor_rwork', 'N/A')
                
                return {
                    'PDB ID': pdb_id,
                    'Resolution': resolution,
                    'R-Free': r_free,
                    'R-Work': r_work,
                    'Experimental Method': experimental_method,
                    'Citations': citations
                }
            elif response.status_code == 429: # Too Many Requests
                # Exponential backoff
                wait_time = 2 ** retries
                print(f"Received status code 429. Retrying in {wait_time} seconds...")
                time.sleep(wait_time)
                retries += 1
            else:
                return None
        except requests.exceptions.Timeout:
            print(f"Request to {url} timed out after {timeout_duration} seconds.")
            return None
        except requests.exceptions.RequestException as e:
            print(f"An error occurred: {e}")
            return None

def score_pdb_entry(entry: Dict[str, Any]) ->float:
    """Calculate a score for a PDB entry based on multiple criteria.

    Args:
        entry (Dict[str, Any]): A dictionary containing the relevant data of the PDB entr

    Returns:
        float: The total score for the PDB entry.
    """
    # Define weights for each criterion
    weights = {
        'Resolution': 0.35,
        'R-Free': 0.25,
        'R-Work': 0.20,
        'Citations': 0.10,
        'Experimental Method': 0.10
    }
    
    # Normalize and compute the score for each criterion
    resolution_score = 1 / entry['Resolution'] if entry['Resolution'] else 0
    r_free_score = 1 / entry['R-Free'] if entry['R-Free'] != 'N/A' else 0
    r_work_score = 1 / entry['R-Work'] if entry['R-Work'] != 'N/A' else 0
    citations_score = entry['Citations']
    
    # Score the experimental method, giving preference to X-ray diffraction
    experimental_method_score = 1 if entry['Experimental Method'].lower() == 'x-ray diffraction' else 0
    
    # Combine scores with weights
    total_score = (
        weights['Resolution'] * resolution_score +
        weights['R-Free'] * r_free_score +
        weights['R-Work'] * r_work_score +
        weights['Citations'] * citations_score +
        weights['Experimental Method'] * experimental_method_score
    )
    
    return total_score

def filter_pdbs(pdb_ids: List[str], output_txt_path: str, min_row: int = 1, max_row: int = -1,
                timeout_duration=10, max_retries=5) -> None:
    """
    Filter, score, and sort PDB entries, then save the results to a txt file.
    Args:
        pdb_ids (List[str]): A list of PDB IDs to process.
        output_txt_path (str): The path to the output file to save the results.
        min_row (int, optional): min index of rows. Defaults to 1.
        max_row (int, optional): max index of rows. Defaults to -1.
        timeout_duration (int, optional): The maximum time in seconds to wait for a response from the API before timing out. Defaults to 10.
        max_retries (int, optional): The maximum number of times to retry the request in case of failures. Defaults to 5.

    Returns:
        None
    """
    pdb_info_list: str  = [] 
    
    for pdb_id in pdb_ids:
        pdb_info = fetch_pdb_data(pdb_id)
        if pdb_info is not None:
            pdb_info_list.append(pdb_info)

    # Score each PDB entry
    for entry in pdb_info_list:
        entry['Score'] = score_pdb_entry(entry)

    # Convert to DataFrame for easy viewing and sorting
    df = pd.DataFrame(pdb_info_list)
    df = df.sort_values(by='Score', ascending=False)
    print(df.shape)

    if int(min_row) != 1 or int(max_row) != -1:
        # We want to convert to zero-based indices and we also want
        # the upper index to be inclusive (i.e. <=) so -1 lower index.
        df = df[(int(min_row) - 1):int(max_row)]
        print(df)

    # Now restrict to the column we want
    with Path.open(Path(output_txt_path), mode='w', encoding='utf-8') as f:
        f.write(','.join(df["PDB ID"].dropna().to_list())+'\n')
    
def main() -> None:
    """
    Reads the command line arguments, loads the PDB information, and scores a list of PDB structures.
    """
    args = parse_arguments()
    if args.input_pdbids:
        filter_pdbs(args.input_pdbids, args.output_txt_path,
                    min_row=args.min_row, max_row=args.max_row, 
                    timeout_duration=args.timeout_duration, max_retries=args.max_retries)
    else:
        print("Error: No input is provided")
        sys.exit(1)


if __name__ == '__main__':
    main()
