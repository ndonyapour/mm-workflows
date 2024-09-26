#!/usr/bin/env cwl-runner
cwlVersion: v1.2

class: CommandLineTool

label: Extract SMILES from SDF files

doc: |-
  Extract SMILES from SDF files

baseCommand: cat
requirements:
  InlineJavascriptRequirement: {}
 
inputs:
  sdf_file_path:
    label: SDF files
    doc: |-
      SDF files
      Type: File
      File type: input
      Accepted formats: File
    type: File
    format: edam:format_3814
    loadContents: true

outputs:
  output_smiles:
    label: SMILES of the SDF file
    doc: |-
      SMILES of the SDF file
    type: string
    outputBinding:
      outputEval: |
        ${
          var lines = inputs.sdf_file_path.contents.split("\n");
          var smiles = null;
          for (var i = 0; i < lines.length; i++) {
              if (lines[i].indexOf('<SMILES>') !== -1) {
                  // The SMILES string is in the next line
                  smiles = lines[i + 1].trim();
                  break;
              }
          }
          return smiles;
        }

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
