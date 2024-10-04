#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Visualize ligands with their target protein using NGLView.

doc: |-
  Visualize ligands with their target protein using NGLView.

baseCommand: ["python3", "/visualize_protein_ligands.py"]

hints:
  DockerRequirement:
    dockerPull: ndonyapour/visualize_protein_ligands


inputs:
  pdb_file_path:
    label: The path to the PDB input file
    doc: |-
      The path to the PDB input file
      Type: string
      File type: input
      Accepted formats: pdb
    type: File
    format: 
    - edam:format_1476
    inputBinding:
      prefix: --pdb_file_path
      
  sdf_file_paths:
    label: The path to the SDF input files 
    doc: |-
      The path to the SDF input files
      Type: File[]
      File type: input
      Accepted formats: list[list[File]]
    type: {"type": "array", "items": "File"}
    format: 
    - edam:format_3814 #sdf
    inputBinding:
      prefix: --sdf_file_paths
    
  output_notebook_path:
    label: Path to the output Jupyter notebook file
    doc: |-
      Path to the output Jupyter notebook file
      Type: string
      File type: input
      Accepted formats: ipynb
    type: string
    format:
    - edam:format_2330
    inputBinding:
      prefix: --output_notebook_path 
    default: vis_notebook.ipynb

  output_html_path:
    label: Path to generated HTML file
    doc: |-
      Path to generated HTML file
      Type: string
      File type: output
      Accepted formats: html
    type: string
    format:
    - edam:format_2331
    inputBinding:
      prefix: --output_html_path 
    default: vis_notebook.html

outputs:
  output_notebook_path:
    label: Path to the output Jupyter notebook file
    doc: |-
      Path to theo utput Jupyter notebook file
    type: File
    outputBinding:
      glob: $(inputs.output_notebook_path)
    format: edam:format_2330    

  output_html_path:
    label: Path to generated HTML file
    doc: |-
      Path to generated HTML file
    type: File
    outputBinding:
      glob: $(inputs.output_html_path)
    format: edam:format_2331    


$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl