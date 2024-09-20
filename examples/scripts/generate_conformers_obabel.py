import argparse
from typing import Optional
from openbabel import pybel, openbabel


def parse_arguments() -> argparse.Namespace:
    """
    Parses the command line arguments.

    Returns:
        argparse.Namespace: The command line arguments, including SMILES string, output file path, forcefield, and minimization steps.
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('--smiles', type=str, required=True)
    parser.add_argument('--output_sdf_path', type=str, required=True)
    parser.add_argument('--forcefield', type=str, default="GAFF")
    parser.add_argument('--num_steps', type=int, default=500)
    parser.add_argument('--num_conformers', type=int, default=10, help="Number of conformers to generate")

    return parser.parse_args()

def validate_smiles(smiles: str) -> Optional[pybel.Molecule]:
    """
    Validates the SMILES string by attempting to convert it to a molecule object.

    Args:
        smiles (str): The SMILES string to validate.

    Returns:
        pybel.Molecule or None: Returns a pybel molecule object if valid, otherwise returns None.
    """
    try:
        mol = pybel.readstring("smi", smiles)
        return mol
    except Exception as e:
        print(f"Invalid SMILES: {e}")
        return None

def generate_conformers(molecule: pybel.Molecule, num_conformers: int=10, forcefield: str="GAFF", steps: int=1000):
    """
    Generates conformers for a molecule, optimizes them, and returns the molecule with generated conformers.

    Args:
        molecule (pybel.Molecule): The molecule object to generate conformers for.
        num_conformers (int): The number of conformers to generate.
        forcefield (str): The forcefield to use for minimization.
        steps (int): The number of minimization steps.

    Returns:
        pybel.Molecule: Molecule with generated conformers.
    """
    obmol = molecule.OBMol
    ff = openbabel.OBForceField.FindForceField(forcefield)
    molecule.OBMol.AddHydrogens()
    molecule.make3D(forcefield=forcefield)
    if not ff.Setup(obmol):
        print("Forcefield setup failed.")
        return None

    # The weighted rotor search is effective for finding stable conformers in 
    # docking or binding studies and for exploring low-energy conformers.
    ff.WeightedRotorSearch(num_conformers, steps)

    # The best conformer is set in obmol
    ff.GetConformers(obmol)
    return obmol


def save_molecule_as_sdf(obmol: openbabel.OBMol, output_sdf_path: str) -> None:
    """
    Saves an OBMol molecule object to an SDF file.

    Args:
        obmol (openbabel.OBMol): The OBMol object to save.
        output_sdf_path (str): The file path to save the SDF file.
    """
    # Convert OBMol to Pybel Molecule
    pybel_mol = pybel.Molecule(obmol)

    # Save the molecule in SDF format
    pybel_mol.write("sdf", output_sdf_path, overwrite=True)
    print(f"Saved molecule as {output_sdf_path}")


def main() -> None:
    """
    Main function to read the command line arguments, validate the SMILES string, generate conformers, and save them.
    """
    args = parse_arguments()
    molecule = validate_smiles(args.smiles)
    
    if molecule is not None:
        # Generate conformers
        conformer_molecule = generate_conformers(molecule, args.num_conformers, args.forcefield, args.num_steps)
        
        if conformer_molecule:
            save_molecule_as_sdf(conformer_molecule, args.output_sdf_path)
    else:
        print("Failed to create molecule from SMILES.")

if __name__ == '__main__':
    main()
