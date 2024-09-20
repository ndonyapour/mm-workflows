#!/usr/bin/env cwl-runner
cwlVersion: v1.2

class: CommandLineTool

label: Generate an SDF molecule from the SMILES.

doc: |-
  Generate an SDF molecule from the SMILES.  

baseCommand: ["timeout", "60", "obabel"]
#Usage:
#obabel[-i<input-type>] <infilename> [-o<output-type>] -O<outfilename> [Options]
#...
#Options, other than -i -o -O -m, must come after the input files.
arguments: [$("-:" + inputs.smiles), "-O", $(inputs.output_sdf_path), "--gen3d", "--minimize", "--ff", 
            $(inputs.forcefield), "--steps", $(inputs.num_steps)]

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_chemistry:4.0.0--pyhdfd78af_1

requirements:
  InlineJavascriptRequirement: {}

inputs:
  smiles:
    label: List of input SMILES  
    doc: |-
      List of input SMILES
      Type: string
      File type: input
      Accepted formats:string
    type: string
    format: edam:format_2330

  forcefield:
    label: The force field to use for minimization (e.g., MMFF94, UFF, GAFF)
    doc: |-
      The force field to use for minimization (e.g., MMFF94, UFF, GAFF)
      Type: string
      File type: input
      Accepted formats: string
    type: string
    format: edam:format_2330
    default: GAFF

  num_steps:
    label: The number of minimization steps
    doc: |-
      The number of minimization steps
      Type: int
    type: int
    format: edam:format_2330
    default: 1000

  output_sdf_path:
    label: Path to the output file
    doc: |-
      Path to the output file
    type: string
    format:
    - edam:format_3814 # sdf

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
