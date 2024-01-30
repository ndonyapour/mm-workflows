#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: A tool that prepares ligand for AutoDock

doc: |-
  A tool that fixes structural issues in proteins

baseCommand: ['mk_prepare_ligand.py', '--merge_these_atom_types']
#arguments: []

hints:
  DockerRequirement:
    dockerPull: ndonyapour/meeko

inputs:
  input_path:
    type: File
    format:
    #- edam:format_2330 # 'Textual format'
    - edam:format_3816 # mol2
    - edam:format_3814 # sdf
    inputBinding:
      prefix: -i

  output_pdbqt_path:
    label: Path to the output file
    doc: |-
      Path to the output file
    type: string
    format:
    - edam:format_1476 # pdb
    inputBinding:
      prefix: -o

outputs:
  output_pdbqt_path:
    label: Path to the output file
    doc: |-
      Path to the output file
    type: File
    format: edam:format_1476 # pdb
    outputBinding:
      glob: $(inputs.output_pdbqt_path)

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl