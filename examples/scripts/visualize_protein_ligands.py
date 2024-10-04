import nbformat
import subprocess
import os
import argparse
from typing import List

# Function to parse command line arguments
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


def run_notebook_to_html(notebook_path: str, output_html_path: str) -> None:
    """
    Runs a Jupyter notebook and converts the executed version to an HTML file.
    
    Args:
        notebook_path (str): Path to the original Jupyter notebook (.ipynb).
        output_html_path (str): Path where the HTML file will be saved.
    """
    try:
        # Execute the notebook using nbconvert and convert to HTML
        command = f"jupyter nbconvert --execute --to html {notebook_path} --output {output_html_path}"
        subprocess.run(command, shell=True, check=True)
        print(f"Notebook executed and converted to HTML: {output_html_path}")
    except subprocess.CalledProcessError as e:
        print(f"Error executing and converting notebook to HTML: {e}")


def main() -> None:
    """
    Generates a Jupyter notebook using nglview for visualizing the PDB and SDF files,
    then executes the generated notebook and converts it to an HTML file.
    """
    # Parse the arguments
    args = parse_arguments()
       
    # Create the notebook with nglview code and provided PDB files and ligands
    create_notebook(args.output_notebook_path, args.pdb_file_path, args.sdf_file_paths)
    
    # Run the notebook and convert to HTML
    run_notebook_to_html(args.output_notebook_path, args.output_html_path)


if __name__ == "__main__":
    main()
