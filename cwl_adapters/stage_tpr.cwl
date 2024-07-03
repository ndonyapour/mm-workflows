#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Wrapper of the GROMACS mdrun module with GPUs.

doc: |-
  MDRun is the main computational chemistry engine within GROMACS. It performs Molecular Dynamics simulations, but it can also perform Stochastic Dynamics, Energy Minimization, test particle insertion or (re)calculation of energies.

baseCommand: ls

requirements:
  InlineJavascriptRequirement: {}
  # Enabling InitialWorkDirRequirement will stage the input Drugbank xml file
  InitialWorkDirRequirement:
    listing:
    - $(inputs.input_tpr_path1)
    - $(inputs.input_tpr_path2)

inputs:
  input_tpr_path1:
    label: Path to the portable binary run input file TPR
    doc: |-
      Path to the portable binary run input file TPR
      Type: string
      File type: input
      Accepted formats: tpr
      Example file: https://github.com/bioexcel/biobb_md/raw/master/biobb_md/test/data/gromacs/mdrun.tpr
    type: File
    format:
    - edam:format_2333

  input_tpr_path2:
    label: Path to the portable binary run input file TPR
    doc: |-
      Path to the portable binary run input file TPR
      Type: string
      File type: input
      Accepted formats: tpr
      Example file: https://github.com/bioexcel/biobb_md/raw/master/biobb_md/test/data/gromacs/mdrun.tpr
    type: File
    format:
    - edam:format_2333

outputs:
  output_tpr_paths:
    label: Path to the input file
    doc: |-
      Path to the input file
      Type: string
      File type: input
      Accepted formats: tpr 
    type: File[]
    outputBinding:
      outputEval: |
        ${
          var files = [];
          for (var i = 0; i < 5; i++) {
              files.push(inputs.input_tpr_path2);
          }
          files.push(inputs.input_tpr_path1);

          for (var i = 0; i < 5; i++) {
              files.push(inputs.input_tpr_path2);
          }
          return files;
        }
      # glob: ./*.tpr
    format: edam:format_2333


$namespaces:
  edam: https://edamontology.org/
  cwltool: http://commonwl.org/cwltool#

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl