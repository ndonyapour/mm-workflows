# pylint: disable=import-outside-toplevel,no-member
import sys
import requests
import argparse
import json
import time 
from pathlib import Path
from typing import List, Dict


def parse_arguments() -> argparse.Namespace:
    """ This function parses the arguments.

    Returns:
        argparse.Namespace: The command line arguments
    """
    parser = argparse.ArgumentParser()
    
    parser.add_argument('--pdbid', type=str)
    parser.add_argument('--output_txt_path', type=str)
    # parser.add_argument("--timeout_duration", required=False, type=int, default=10)
    # parser.add_argument("--max_retries", required=False, type=int, default=5)
    args = parser.parse_args()
    return args


# The code has been adapted from https://bioinformatics.stackexchange.com/questions/8583/retrieve-id-ligand-from-pdb-file
def download_ligands(pdbid: str, output_txt_path: str) -> None:
    """
    Downloads SDF files for ligands of a given PDB entry ID.

    Args:
        pdbid (str): The PDB entry ID to fetch ligand data for.
        output_txt_path (str): The path to the output text file that contains the SDF names.
    """
    parsed_lig_dict: Dict[str, List] = {}
    
    # Fetch entry details
    response = requests.get(f"https://data.rcsb.org/rest/v1/core/entry/{pdbid}/")
    parsed = json.loads(response.content.decode())

    # Extract non-polymer entity IDs
    parsed_lig = parsed["rcsb_entry_container_identifiers"]["non_polymer_entity_ids"]

    # Loop through each ligand ID
    for lig in parsed_lig:
        response = requests.get(f"https://data.rcsb.org/rest/v1/core/nonpolymer_entity/{pdbid}/{lig}")
        parsed = json.loads(response.content.decode())

        # Extract component ID and asymmetric IDs
        comp_id: str = parsed["pdbx_entity_nonpoly"]["comp_id"]
        asym_ids: List[str] = parsed["rcsb_nonpolymer_entity_container_identifiers"]["asym_ids"]

        # Initialize dictionary with component ID and asymmetric IDs
        parsed_lig_dict[lig] = [comp_id, dict.fromkeys(asym_ids)]

    # Fetching instance details for each ligand and chain
    for lig in parsed_lig_dict:
        for chain in parsed_lig_dict[lig][1]:
            response = requests.get(f"https://data.rcsb.org/rest/v1/core/nonpolymer_entity_instance/{pdbid}/{chain}")
            parsed = json.loads(response.content.decode())
            auth_seq_id: str = parsed["rcsb_nonpolymer_entity_instance_container_identifiers"]["auth_seq_id"]
            parsed_lig_dict[lig][1][chain] = auth_seq_id

    # Download SDF files
    cnt: int = 1
    sdf_file_names: list[str] = []
    for lig in parsed_lig_dict:
        for chain in parsed_lig_dict[lig][1]:
            seq_id: str = parsed_lig_dict[lig][1][chain]
            comp_id: str = parsed_lig_dict[lig][0]
            
            # Construct URL for SDF download
            sdf_url: str = f"https://models.rcsb.org/v1/{pdbid}/ligand?auth_seq_id={seq_id}&label_asym_id={chain}&encoding=sdf"
            
            # Request SDF file
            response = requests.get(sdf_url, allow_redirects=True)
            
            if response.status_code == 200:
                filename: str = f"lig_{comp_id}_{chain}_{seq_id}_{cnt}.sdf"
                with open(filename, 'wb') as file:
                    file.write(response.content)
                print(f"Downloaded: {filename}")
                sdf_file_names.append(filename)
            else:
                print(f"Failed to download SDF for ligand {comp_id} chain {chain} seq_id {seq_id}")
            
            cnt += 1

    # Write the SDF file names to a txt file
    with Path.open(Path(output_txt_path), mode='w', encoding='utf-8') as f:
        f.write('\n'.join(sdf_file_names))

if __name__ == '__main__':
    """ Reads the command line arguments and downloads SDF files for ligands of a given PDB entry ID.
    """
    args = parse_arguments()
    download_ligands(args.pdbid, args.output_txt_path)