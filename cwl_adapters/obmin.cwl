#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Run a Bash script

doc: |
  Run a Bash script

baseCommand: bash

hints:
  DockerRequirement:
    dockerPull: ndonyapour/openbabel

inputs:
  script:
    type: string
    inputBinding:
      position: 1

  input_mol2_path:
    type: File
    format:
    - edam:format_3816
    inputBinding:
      position: 2

  output_mol2_path:
    type: string
    format:
    - edam:format_3816
    inputBinding:
       position: 3
    default: system.mol2

outputs:
  output_mol2_path:
    type: File
    format: edam:format_3816 # 'Textual format'
    streamable: true
    outputBinding:
      glob: $(inputs.output_mol2_path)

  stderr:
    type: File
    outputBinding:
      glob: stderr

stderr: stderr


$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
