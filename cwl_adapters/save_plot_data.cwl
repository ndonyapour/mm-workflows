#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: cat 
arguments: [$(inputs.output_txt_path)]

requirements:
  - class: InlineJavascriptRequirement
  # This enables staging input files and dynamically generating a file
  # containing the file paths on the fly.
  - class: InitialWorkDirRequirement 
    listing: |
      ${
        var dat_file_contents = "";
        var failed_count = 0
        for (var i = 0; i < inputs.pdbids.length; i++) {
            if (inputs.ys[i] == null ||  inputs.ys2[i] == null) {
                failed_count++;
                dat_file_contents += inputs.pdbids[i] +  "\tfailed" + "\n";
            }
            else{
                dat_file_contents += inputs.pdbids[i] + "\t" + inputs.xs[i].toString() + "\t" + inputs.ys[i].toString() + "\t" + inputs.ys2[i].toString() + "\n";
            }

         }
        for (var i = 0; i < inputs.original_pdbids.length; i++) {

          if (!inputs.pdbids.includes(inputs.original_pdbids[i])){

            dat_file_contents += inputs.original_pdbids[i] +  "\tfailed" + "\n";
          }


        }

        // Note: Uses https://www.commonwl.org/v1.0/CommandLineTool.html#Dirent
        // and https://www.commonwl.org/user_guide/topics/creating-files-at-runtime.html
        // "If the value is a string literal or an expression which evaluates to a string, 
        // a new file must be created with the string as the file contents."
        return ([{"entryname": inputs.output_txt_path, "entry": dat_file_contents}]);
      }

inputs:

  original_pdbids:
    label: The ids of the inputs
    type: string[]
    format: 
    - edam:format_2330

  pdbids:
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
   
  output_txt_path:
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
  output_txt_path:
    label: Path to the dat file
    doc: |-
      Path to the dat file
    type: File
    outputBinding:
      glob: $(inputs.output_txt_path)
    format: edam:format_2330

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl