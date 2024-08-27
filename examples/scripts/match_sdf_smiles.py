# pylint: disable=import-outside-toplevel,no-member
import sys
import argparse
from rdkit import Chem
import os
from pathlib import Path
from typing import List, Dict


def parse_arguments() -> argparse.Namespace:
    """ This function parses the arguments.

    Returns:
        argparse.Namespace: The command line arguments
    """
    parser = argparse.ArgumentParser()
    
    parser.add_argument('--input_sdf_paths', nargs='+', type=str)
    parser.add_argument('--smiles', type=str)
    parser.add_argument('--output_txt_path', type=str)
    #parser.add_argument('--output_sdf_path', type=str)
    args = parser.parse_args()
    return args


def sdf_to_canonical_smiles(sdf_file: str) -> str:
    """
    Converts a molecule from an SDF file to its canonical SMILES representation.

    Args:
        sdf_file (str): The path to the SDF file containing the molecule.

    Returns:
        str: The canonical SMILES string of the molecule.
        Returns an empty string if the file does not exist or if the molecule cannot be read.
    """
    if not os.path.exists(sdf_file):
        print(f"File {sdf_file} does not exist.")
        return ""

    # Read the molecule from the SDF file
    suppl = Chem.SDMolSupplier(sdf_file)
    molecule = suppl[0]  # Assume the SDF file contains only one molecule

    if molecule is None:
        print(f"Failed to read molecule from {sdf_file}.")
        return ""

    # Convert to canonical SMILES
    smiles = Chem.MolToSmiles(molecule, canonical=True)

    return smiles


def get_canonical_smiles(smiles) -> str:
    """
    Convert a SMILES string to its canonical form using RDKit.
    Args:
        smiles: SMILES string
    Returns: Canonical SMILES string
    """
    mol = Chem.MolFromSmiles(smiles)
    if mol is None:
        raise ValueError(f"Invalid SMILES string: {smiles}")
    return Chem.MolToSmiles(mol)


def math_sdf_smiles(input_sdf_path: list[str], smiles: str, output_txt_path: str) -> None:
    
    canonical_smiles = get_canonical_smiles(smiles)
    selected_files: list[str] = []
    for sdf_file_path in input_sdf_paths:
        sdf_smiles = sdf_to_canonical_smiles(sdf_file_path)
        if sdf_smiles == canonical_smiles:
            selected_files.append(sdf_file_path)
    
    # Write the SDF file names to a txt file
    with Path.open(Path(output_txt_path), mode='w', encoding='utf-8') as f:
        f.write('\n'.join(selected_files))        

if __name__ == '__main__':
    """ Reads the command line arguments, and returns the SDF file that corresponds 
        to the given SMILES
    """
    args = parse_arguments()
    math_sdf_smiles(args.input_sdf_paths, args.smiles, args.output_txt_path)
