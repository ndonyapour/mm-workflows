#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: A tool that prepares ligand for AutoDock

doc: |-
  A tool that fixes structural issues in proteins

baseCommand: ['python', '/add_hydrogens_sdf.py']
#arguments: []

hints:
  DockerRequirement:
    dockerPull: ndonyapour/add_hydrogens_sdf

inputs:
  input_sdf_path:
    type: File
    format:
    - edam:format_3814 # sdf
    inputBinding:
      prefix: --input_sdf_path

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