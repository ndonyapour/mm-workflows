
#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Duplicates a pdbqt file once for each entry of another array.

doc: |-
  Duplicates a pdbqt file once for each entry of another array.

baseCommand: python3

requirements:
  InlineJavascriptRequirement: {}

inputs:
  input_array:
    label: Input array 
    doc: |-
      Input array
      Type: File
      File type: input
    type: File[]
    format:
    - edam:format_1476

  num_duplicates:
    label: The number of duplicates
    doc: |-
      The number of duplicates
      Type: int
      File type: input
    type: int
    format:
    - edam:format_2330

outputs:
  output_array:
    label: Output 2D array
    doc: |-
      Output 2D array
    type: {"type": "array", "items": {"type": "array", "items": "File"}}
    outputBinding:
      outputEval: |
        ${
          var out2d = [];
          for (var i = 0; i < inputs.num_duplicates; i++) {
            var out1d = [];
            for (var j = 0; j < inputs.input_array.length; j++) {
              out1d.push(inputs.input_array[j]);
            }
            out2d.push(out1d);
          }
          return out2d;
        }
#   format: edam:format_2330

#stdout: stdout

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
