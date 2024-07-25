import sys
import requests
from pathlib import Path
from typing import Union
import subprocess
import argparse

def parse_arguments() -> argparse.Namespace:
    """ This function parses the command line arguments.

    Returns:
        argparse.Namespace: The command line arguments
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('--input_pdbids', type=str, nargs='+', required=True, help='List of PDB IDs to process')
    parser.add_argument('--oligomeric_states', type=str, nargs='+', help='Oligomeric state of the protein')
    parser.add_argument('--output_txt_path', type=str, help='Path to save the output text file')
 
    args = parser.parse_args()
    return args

def get_biological_assembly_info(pdb_id: str, timeout_duration=10, max_retries=5) -> tuple[str, list[str]]:
    """Fetches the biological assembly information for a given PDB ID.

    Args:
        pdb_id (str): The PDB ID of the structure to fetch.

    Returns:
        tuple[str, list[str]]: Oligomeric state and list of chains or error message.
    """
    url = f"https://data.rcsb.org/rest/v1/core/assembly/{pdb_id}/1"
    retries = 0
        
    while retries < max_retries:
        try:
            response = requests.get(url, timeout=timeout_duration)

            if response.status_code == 200:
                assembly_info = response.json()
                # Attempt to extract details using process_rcsb_struct_symmetry first
                oligomeric_state, chains = process_rcsb_struct_symmetry(assembly_info)
                if oligomeric_state:
                    return oligomeric_state, chains
                
                # Fallback to extract_oligomeric_state_and_chains if no details found in rcsb_struct_symmetry
                oligomeric_state, chains = extract_oligomeric_state_and_chains(assembly_info)
                if oligomeric_state:
                    return oligomeric_state, chains
                
                return "None", []
            elif response.status_code == 429: # Too Many Requests
                # Exponential backoff
                wait_time = 2 ** retries
                print(f"Received status code 429. Retrying in {wait_time} seconds...")
                time.sleep(wait_time)
                retries += 1
            else:
                return  "None", []
        except requests.exceptions.Timeout:
            print(f"Request to {url} timed out after {timeout_duration} seconds.")
            return  "None", []
        except requests.exceptions.RequestException as e:
            print(f"An error occurred: {e}")
            return  "None", []

def process_rcsb_struct_symmetry(assembly_info: dict) -> tuple[str, list[str]]:
    """
    Processes the RCSB structural symmetry information to determine the oligomeric state and chains.

    Parameters:
    assembly_info (dict): The assembly information from the RCSB API.

    Returns:
    tuple[str, list[str]]: A tuple containing the oligomeric state and a list of chain IDs.
    """
    details = assembly_info.get('rcsb_struct_symmetry')
    if details:
        for detail in details:
            stoichiometries = detail.get('stoichiometry')
            oligomeric_state = detail.get('oligomeric_state', '')
            return interpret_stoichiometry_and_chains(stoichiometries, oligomeric_state, detail)
    
    return "None", []

def extract_oligomeric_state_and_chains(assembly_info: dict) -> tuple[str, list[str]]:
    """Extracts oligomeric state and chains from the biological assembly information.

    Args:
        assembly_info (dict): The biological assembly information.

    Returns:
        tuple[str, list[str]]: Oligomeric state and list of chains or empty.
    """
    pdbx_assembly = assembly_info.get('pdbx_struct_assembly', {})
    pdbx_assembly_gen = assembly_info.get('pdbx_struct_assembly_gen', [])
    
    if pdbx_assembly:
        oligomeric_state = pdbx_assembly.get('oligomeric_details', '')
        stoichiometries = pdbx_assembly.get('stoichiometry', [])
        return interpret_stoichiometry_and_chains(stoichiometries, oligomeric_state, pdbx_assembly_gen)
    
    return '', []

def interpret_stoichiometry_and_chains(stoichiometries: Union[list[str], str], oligomeric_state: str, detail: Union[dict, list[dict]]) -> tuple[str, list[str]]:
    """Interprets the stoichiometry and chains from the provided details.

    Args:
        stoichiometries (list[str] | str): The stoichiometries of the structure.
        oligomeric_state (str): The oligomeric state of the structure.
        detail (dict | list[dict]): Additional details for chain extraction.

    Returns:
        tuple[str, list[str]]: Oligomeric state and list of chains.
    """
    chains = []
    if isinstance(detail, list):
        for assembly_gen in detail:
            chains.extend(assembly_gen.get('asym_id_list', []))
    elif detail.get('clusters'):
        for cluster in detail['clusters']:
            for member in cluster['members']:
                chains.append(member['asym_id'])
    
    if isinstance(stoichiometries, list):
        stoichiometry = stoichiometries[0] if stoichiometries else ''
    else:
        stoichiometry = stoichiometries
    
    if oligomeric_state.lower() == 'monomer':
        return "monomer", chains
    elif oligomeric_state.lower() == 'dimer':
        return "dimer", chains
    elif oligomeric_state.lower() == 'trimer':
        return "trimer", chains
    elif oligomeric_state.lower() == 'tetramer':
        return "tetramer", chains
    elif oligomeric_state.lower().startswith('oligomer'):
        return "oligomer", chains
    else:
        return f"{oligomeric_state.lower()}", chains


def filter_data(pdb_ids: list[str], oligomeric_states: list[str], output_txt_path: str) -> None:
    """Filters the PDB IDs based on the specified oligomeric state and writes the results to the output text file.

    Args:
        pdb_ids (list[str]): List of PDB IDs to process.
        oligomeric_state (list[str]): The oligomeric states to filter by.
        output_txt_path (str): The path to save the output text file.
    """
    results = []
    for oligomeric_state in oligomeric_states:
        for pdb_id in pdb_ids:
            state, chains = get_biological_assembly_info(pdb_id)
            if state.lower() == oligomeric_state.lower():
                results.append(f"{pdb_id},{state},{chains}")

 
    with Path.open(Path(output_txt_path), mode='w', encoding='utf-8')as output_file:
        for result in results:
            output_file.write(result + '\n')

if __name__ == "__main__":
    """Prase the arguments and filter PDB IDs based on the specified oligomeric state."""
    args = parse_arguments()
    if args.input_pdbids:
        filter_data(args.input_pdbids, args.oligomeric_states, args.output_txt_path)
    else:
        print("Error: No input is provided")
        sys.exit(1)
    
