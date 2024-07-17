#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: flatten a 2D array to 1D array
doc: |-
  flatten a 2D array to 1D array

baseCommand: python3

requirements:
  InlineJavascriptRequirement: {}


inputs:
  input_2D_array:
    label: Input 2D array # type: 
    doc: |-
      Input 2D array
      Type: string[][]
      File type: input
      Accepted formats: list[list[string]]
    type: ["null", {"type": "array", "items": {"type": "array", "items": "string"}}]
    format: edam:format_2330

outputs:
  output_1D_array:
    label: Output 1D array
    doc: |-
      Output 1D array
    type: 
      type: array
      items: string
    outputBinding:
      outputEval: |
        ${
          var pdbids_2d = [];
          for (var i = 0; i < inputs.input_2D_array.length; i++) {
            var pdbids_1d = inputs.input_2D_array[i];
            for (var j = 0; j < pdbids_1d.length; j++){
              pdbids_2d.push(pdbids_1d[j]);
            }
          }
        return pdbids_2d;
        }

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl