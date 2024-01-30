import sys
import argparse

import rdkit
from rdkit import Chem
from rdkit.Chem import AllChem


def parse_arguments() -> argparse.Namespace:
    """ This function parses the arguments.

    Returns:
        argparse.Namespace: The command line arguments
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('--input_sdf_path', type=str)
    parser.add_argument('--output_sdf_path', type=str)

    args = parser.parse_args()
    return args


def add_hydrogens(input_sdf_path: str, output_sdf_path: str) -> bool:
    """ Add hydrogens to the input SDF file 

    Args:
        input_sdf_path (str): The path to the input ligand SDF format structure
        output_sdf_path (str)): The path to the output ligand SDF format structure

    Returns:
        int: the calculated net charge
    """

    try:
        mol = list(Chem.SDMolSupplier(input_sdf_path, sanitize=False))[0]
    except Exception:
        return False

    if not mol:
        return False

    mol = Chem.AddHs(mol)
    AllChem.EmbedMolecule(mol)
    AllChem.MMFFOptimizeMolecule(mol)

    writer = Chem.SDWriter(output_sdf_path)
    writer.write(mol)
    writer.close()

    return True


def main() -> None:
    """ Reads the command line arguments to load a small molecule in SDF format, 
    adds hydrogens, and then saves the modified molecule in SDF format.
    """
    args = parse_arguments()

    if not add_hydrogens(args.input_sdf_path, args.output_sdf_path):
        print(f'Error: Can not add hydrogens to {args.input_sdf_path}')
        sys.exit(1)

if __name__ == '__main__':
    main()
