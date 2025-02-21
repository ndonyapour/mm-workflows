import os
import argparse
import nbformat
import nglview as nv
import pytraj as pt
import numpy as np
from typing import List, Optional
import re


def parse_arguments() -> argparse.Namespace:
    """
    This function parses the command line arguments.

    Returns:
        argparse.Namespace: The command line arguments.
    """
    parser = argparse.ArgumentParser(description="Visualize PDB and SDF files in NGLView")
    parser.add_argument('--pdb_file_path', type=str, help="Path to the PDB file")
    parser.add_argument('--sdf_file_paths', type=str, nargs='+', help="List of SDF files")
    parser.add_argument('--output_notebook_path', type=str, required=False,
                        default="vis_notebook.ipynb", help="Path to save the generated Jupyter notebook")
    parser.add_argument('--output_html_path', type=str, required=False,
                        default="vis_notebook.html", help="Path to save the generated HTML file")

    return parser.parse_args()


def extract_rank_from_filename(filename):
    """Extracts the rank number from the filename for labeling."""
    match = re.search(r'rank(\d+)', filename)
    if match:
        return f"Rank {match.group(1)}"
    return ""


def extract_smiles_from_sdf(sdf_file: str) -> Optional[str]:
    """
    Extracts the SMILES string from an SDF file.

    Args:
        sdf_file (str): Path to the SDF file.

    Returns:
        Optional[str]: The extracted SMILES string if found, otherwise None.
    """
    with open(sdf_file, 'r') as file:
        lines = file.readlines()

        for i, line in enumerate(lines):
            if "<SMILES>" in line:
                if i + 1 < len(lines):
                    return lines[i + 1].strip()

    return None


def create_notebook(notebook_path: str, pdb_file: str, sdf_files: List[str]) -> None:
    """
    Creates a Jupyter notebook that visualizes PDB structures with multiple SDF ligands using nglview.

    Args:
        notebook_path (str): Path where the Jupyter notebook will be saved.
        pdb_file (str): Path to the PDB file (protein structure).
        sdf_files (List[str]): List of SDF file paths.
    """
    # Create cells with Markdown and code
    cells = [
        nbformat.v4.new_markdown_cell("# NGLView PDB and Multiple Ligands Visualization"),
        nbformat.v4.new_code_cell("""
import nglview as nv
import pytraj as pt
import numpy as np
import os
import re


def extract_rank_from_filename(filename):
    match = re.search(r'rank(\\d+)', filename)
    if match:
        return f"Rank{match.group(1)}"
    return ""

def visualize_protein_and_ligands(pdb_file, sdf_files):
    if not os.path.exists(pdb_file):
        print(f"Protein file not found: {pdb_file}")
        return
    
    # Load the protein structure
    traj = pt.load(pdb_file)
    view = nv.show_pytraj(traj)
    
    # Display the protein in cartoon representation
    view.add_representation('cartoon', selection='protein', color='blue')
    
    # Loop through the SDF files and add each as a ligand
    for sdf_file in sdf_files:
        if os.path.exists(sdf_file):
            ligand_traj = pt.load(sdf_file)
            
            # Add the ligand representation with a unique color
            view.add_trajectory(ligand_traj)
            
            # Get ligand atom coordinates to calculate centroid
            centroid = np.mean(ligand_traj.xyz[0], axis=0) + np.array([0.5, 0.5, 0.5])
            
            # Extract the rank from the file name
            label = extract_rank_from_filename(sdf_file)
            
            # Add a label at the centroid
            view.shape.add_label(centroid.tolist(), [0, 0, 0], 5, label)
            
            print(f"Ligand {label} loaded and labeled.")
        else:
            print(f"Ligand file not found: {sdf_file}")
    
    # Center the view to show all molecules
    view.center()
    view.control.zoom(0.2)
    display(view)
        """)
    ]

    # Add code to visualize the protein and ligands
    sdf_files_str = str(sdf_files).replace("'", '"')  # Convert to string to pass to the notebook
    cells.append(nbformat.v4.new_code_cell(f'visualize_protein_and_ligands("{pdb_file}", {sdf_files_str})'))

    # Create the notebook object
    nb = nbformat.v4.new_notebook()
    nb['cells'] = cells

    # Write the notebook to the specified file
    with open(notebook_path, 'w') as f:
        nbformat.write(nb, f)
    print(f"Notebook created: {notebook_path}")


def make_view_html(output_html_path: str, pdb_file: str, sdf_files: List[str]) -> None:
    """
    Generates an HTML file with an NGLView visualization on the right 
    and extracted SMILES strings on the left.

    Args:
        base_dir (str): Directory where files are stored.
        pdb_file (str): Name of the PDB file.
        sdf_files (List[str]): List of SDF file names.

    """
    if not os.path.exists(pdb_file):
        print(f"Protein file not found: {pdb_file}")
        return None

    # Load and visualize protein
    traj = pt.load(pdb_file)
    view = nv.show_pytraj(traj)
    view.add_representation('cartoon', selection='protein', color='blue')

    # Collect SMILES and add ligands
    smiles_list = []

    for sdf_file in sdf_files:
        if os.path.exists(sdf_file):
            ligand_traj = pt.load(sdf_file)
            view.add_trajectory(ligand_traj)

            # Extract SMILES
            smiles = extract_smiles_from_sdf(sdf_file)
            if smiles:
                smiles_list.append(smiles)

            # Add label to ligand
            centroid = np.mean(ligand_traj.xyz[0], axis=0) + np.array([0.5, 0.5, 0.5])
            label = extract_rank_from_filename(sdf_file)
            view.shape.add_label(centroid.tolist(), [0, 0, 0], 5, label)
            print(f"Ligand {label} loaded with SMILES: {smiles if smiles else 'N/A'}")
        else:
            print(f"Ligand file not found: {sdf_file}")

    view.center()
    view.control.zoom(0.2)

    # Save NGLView visualization as a separate file
    nv.write_html("ngl_view.html", [view])

    # Read the generated NGLView HTML file
    with open("ngl_view.html", "r") as f:
        ngl_html = f.read()

    # If all SMILES correspond to the same small molecule, keep only one
    if len(set(smiles_list)) == 1:
        smiles_list = smiles_list[:1]

    # Generate the final HTML file with the SMILES sidebar
    final_html = f"""
    <html>
    <head>
        <title>Molecular Visualization</title>
        <style>
            body {{
                display: flex;
                font-family: Arial, sans-serif;
                margin: 0;
                padding: 0;
            }}
            #smiles-container {{
                width: 30%;
                padding: 20px;
                background-color: #f4f4f4;
                border-right: 2px solid #ddd;
                overflow-y: auto;
            }}
            #viewer-container {{
                flex-grow: 1;
                padding: 20px;
            }}
            .smiles-entry {{
                margin-bottom: 10px;
                padding: 10px;
                border-bottom: 1px solid #ccc;
                background: white;
            }}
        </style>
    </head>
    <body>
        <div id="smiles-container">
            <h3>SMILES</h3>
            {"".join(f'<div class="smiles-entry">{sm}</div>' for sm in smiles_list)}
        </div>
        <div id="viewer-container">
            {ngl_html}
        </div>
    </body>
    </html>
    """

    # Save the final HTML file
    with open(output_html_path, "w") as f:
        f.write(final_html)

    print(f"HTML visualization saved at: {output_html_path}")

# def run_notebook_to_html(notebook_path: str, output_html_path: str) -> None:
#     """
#     Runs a Jupyter notebook and converts the executed version to an HTML file.

#     Args:
#         notebook_path (str): Path to the original Jupyter notebook (.ipynb).
#         output_html_path (str): Path where the HTML file will be saved.
#     """
#     try:
#         # Execute the notebook using nbconvert and convert to HTML
#         command = f"jupyter nbconvert --execute --to html {notebook_path} --output {output_html_path}"
#         subprocess.run(command, shell=True, check=True)
#         print(f"Notebook executed and converted to HTML: {output_html_path}")
#     except subprocess.CalledProcessError as e:
#         print(f"Error executing and converting notebook to HTML: {e}")


def main() -> None:
    """
    Generates a Jupyter notebook using nglview for visualizing the PDB and SDF files,
    then executes the generated notebook and converts it to an HTML file.
    """
    # Parse the arguments
    args = parse_arguments()

    # Create the notebook with nglview code and provided PDB files and ligands
    create_notebook(args.output_notebook_path, args.pdb_file_path, args.sdf_file_paths)

    # Create HTML file
    make_view_html(args.output_html_path, args.pdb_file_path, args.sdf_file_paths)


if __name__ == "__main__":
    main()
