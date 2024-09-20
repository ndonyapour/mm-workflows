#!/usr/bin/env cwl-runner
cwlVersion: v1.2

class: CommandLineTool

label: Generates conformers for a given SMILES and selects the best one. 

doc: |-
  Generates conformers for a given SMILES and selects the best one.  

baseCommand: ['python3', '/generate_conformers_obabel.py']

hints:
  DockerRequirement:
    dockerPull: ndonyapour/generate_conformers_obabel

requirements:
  InlineJavascriptRequirement: {}

inputs:
  smiles:
    label: The input SMILES 
    doc: |-
      List of input SMILES
      Type: string
      File type: input
      Accepted formats:string
    type: string
    format: edam:format_2330
    inputBinding:
      prefix: --smiles
      # itemSeparator: " "
      # separate: false

  forcefield:
    label: The force field to use for minimization (e.g., MMFF94, UFF, GAFF)
    doc: |-
      The force field to use for minimization (e.g., MMFF94, UFF, GAFF)
      Type: string
      File type: input
      Accepted formats: string
    type: string
    format: edam:format_2330
    inputBinding:
      prefix: --forcefield
    default: GAFF

  num_steps:
    label: The number of minimization steps
    doc: |-
      The number of minimization steps
      Type: int
    type: int
    format: edam:format_2330
    inputBinding:
      prefix: --num_steps   
    default: 500

  num_conformers:
    label: Number of conformers to generate
    doc: |-
      Number of conformers to generates
      Type: int
    type: int
    format: edam:format_2330
    inputBinding:
      prefix: --num_conformers
    default: 10

  output_sdf_path:
    label: Path to the output file
    doc: |-
      Path to the output file
    type: string
    format:
    - edam:format_3814 # sdf
    inputBinding:
      prefix: --output_sdf_path
      
outputs:
  output_sdf_path:
    label: Path to the output file
    doc: |-
      Path to the output file
    type: File
    format: edam:format_3814 # sdf
    outputBinding:
      glob: $(inputs.output_sdf_path)

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
