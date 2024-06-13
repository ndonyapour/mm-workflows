#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: cat 
arguments: ["output.dat"]

requirements:
  - class: InlineJavascriptRequirement
  # This enables staging input files and dynamically generating a file
  # containing the file paths on the fly.
  - class: InitialWorkDirRequirement 
    listing: |
      ${
        var dat_file_contents = "";
        var failed_count = 0
        for (var i = 0; i < inputs.labels.length; i++) {
            if (inputs.ys[i] == null ||  inputs.ys2[i] == null) {
                failed_count++;
                dat_file_contents += inputs.labels[i] + "\n";
            }
            else{
                dat_file_contents += inputs.labels[i] + "\t" + inputs.xs[i].toString() + "\t" + inputs.ys[i].toString()+ "\n";
            }

         }
        // Note: Uses https://www.commonwl.org/v1.0/CommandLineTool.html#Dirent
        // and https://www.commonwl.org/user_guide/topics/creating-files-at-runtime.html
        // "If the value is a string literal or an expression which evaluates to a string, 
        // a new file must be created with the string as the file contents."
        return ([{"entryname": "output.dat", "entry": dat_file_contents}]);
      }

inputs:

  labels:
    label: The ids of the inputs
    type: string[]
    format: 
    - edam:format_2330

  xs:
    label: The ids of the inputs
    type: ["null", {"type": "array", "items": ["null", "float"]}]
    # format: 
    # - edam:format_2330

  ys:
    label: The ids of the inputs
    type: ["null", {"type": "array", "items": ["null", "float"]}]
    # format: 
    # - edam:format_2330

  ys2:
    label: The ids of the inputs
    type: ["null", {"type": "array", "items": ["null", "float"]}]
    # format: 
    # - edam:format_2330
   
  output_path:
    label: Path to the dat file
    doc: |-
      Path to the dat file
      Type: string
      File type: output
      Accepted formats: DAT
    type: string
    format:
    - edam:format_2330
    default: output.dat

outputs:
  output_path:
    label: Path to the ouput file
    doc: |-
      Path to the output file
    type: File
    outputBinding:
      glob: output.dat
    format: edam:format_2330

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl