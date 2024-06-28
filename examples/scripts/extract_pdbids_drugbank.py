from pathlib import Path
import pandas as pd
import collections
from typing import Optional
import xml.etree.ElementTree as ET
import argparse

from rdkit import Chem


def parse_arguments() -> argparse.Namespace:
    """ This function parses the arguments.

    Returns:
        argparse.Namespace: The command line arguments
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('--drugbank_xml_file_path', type=str)
    parser.add_argument('--output_txt_path', type=str)
    parser.add_argument('--smiles', nargs="*", type=str, default=[])
    parser.add_argument('--inchi', nargs="*", type=str, default=[])
    parser.add_argument('--inchi_keys', nargs="*", type=str, default=[])

    args = parser.parse_args()
    return args

# The code is adapted from https://github.com/dhimmel/drugbank/blob/gh-pages/parse.ipynb


def parse_drugbank_xml(drugbank_xml_path: str) -> pd.DataFrame:
    """Parse the DrugBank XML file into a data frame

    Args:
        drugbank_xml_path (str): The path to the drugbank xml file

    Returns:
        pd.DataFrame: The proccesd Drugbank
    """
    ns = '{http://www.drugbank.ca}'
    inchikey_template = f"{ns}calculated-properties/{ns}property[{ns}kind='InChIKey']/{ns}value"
    inchi_template = f"{ns}calculated-properties/{ns}property[{ns}kind='InChI']/{ns}value"
    smiles_template = f"{ns}calculated-properties/{ns}property[{ns}kind='SMILES']/{ns}value"

    xtree = ET.parse(drugbank_xml_path)
    root = xtree.getroot()
    rows = list()
    for drug in root:
        row = collections.OrderedDict()

        row['name'] = drug.findtext(f"{ns}name")
        row['type'] = drug.get('type')
        row['drugbank_id'] = drug.findtext(ns + "drugbank-id[@primary='true']")
        row['groups'] = [group.text for group in drug.findall(f"{ns}groups/{ns}group")]
        row['inchi'] = drug.findtext(inchi_template)
        row['inchikey'] = drug.findtext(inchikey_template)
        row['smiles'] = drug.findtext(smiles_template)

        pdb_ids = drug.find(f"{ns}pdb-entries")
        if pdb_ids is not None:
            target_ids = []
            for pdb_id in pdb_ids:
                target_ids.append(str(pdb_id.text))

            row['pdb_entries'] = ','.join(target_ids)

        rows.append(row)

    columns = ['drugbank_id', 'name', 'type', 'groups', 'inchi', 'inchikey', 'smiles', 'pdb_entries']
    drugbank_df = pd.DataFrame.from_dict(rows)[columns]

    drugbank_df = drugbank_df[
        drugbank_df.smiles.map(lambda x: x is not None) &
        drugbank_df.type.map(lambda x: x == 'small molecule')
    ]
    # drugbank_df.to_csv('./drugbank/slim_drugbank.csv', sep=',', index=False)
    return drugbank_df


def smiles_to_inchi(smiles: str) -> Optional[str]:
    """Converts SMILES to InChI

    Args:
        smiles (str): The SMILES of small molecules

    Returns:
        str: The InChi key
    """
    # Convert SMILES to RDKit molecule object
    mol = Chem.MolFromSmiles(smiles)
    if mol is None:
        print(f"Error: Invalid SMILES string: {smiles}")
        return None
    # Convert molecule to InChI
    inchi = Chem.MolToInchi(mol)

    return inchi


def extract_pdbids_drugbank(drugbank_xml_file_path: str, smiles: list[str], inchi: list[str], inchi_keys: list[str], output_txt_path: str) -> None:
    """ Filter DrugBank based on a list of small molecules

    Args:
        drugbank_xml_path (str): The path to the Drugbank xml file
        smiles (list[str]): The list of SMILES of small molecules 
        inchi (list[str]): The list of InChI of small molecules 
        inchi_keys (list[str]): The list of InChI key of small molecules 
        output_log_path (str): The path to the output log file
    """

    drugbank = parse_drugbank_xml(drugbank_xml_file_path)

    if smiles:
        inchi_ids = [
            smiles_to_inchi(sm) for sm in smiles
        ]  # smiles can be in different formats
        inchi_ids = [inchi_id for inchi_id in inchi_ids if inchi_id is not None]
        filtered_df = drugbank[drugbank["inchi"].isin(inchi_ids)]

    elif inchi:
        filtered_df = drugbank[drugbank["inchi"].isin(inchi)]

    elif inchi_keys:
        filtered_df = drugbank[drugbank["inchikey"].isin(inchi_keys)]

    with Path.open(Path(output_txt_path), mode="w", encoding="utf-8") as f:
        for _, row in filtered_df.iterrows():
            if row["pdb_entries"]:
                f.write(f"{row['smiles']},{row['pdb_entries']}\n")


if __name__ == "__main__":

    args = parse_arguments()
    extract_pdbids_drugbank(args.drugbank_xml_file_path, args.smiles, args.inchi, args.inchi_keys, args.output_txt_path)
