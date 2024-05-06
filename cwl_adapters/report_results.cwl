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
        var false_count = 0;
        var true_count = 0; 
        var failed_count = 0; 
        for (var i = 0; i < inputs.results.length; i++) {
          if (inputs.results[i] == true  || inputs.results[i] ==false) {
          dat_file_contents += inputs.ids[i] + ": " + inputs.results[i].toString() + "\n"}
          else {
          dat_file_contents += inputs.ids[i] + ": " + inputs.results[i] + "\n";}
          if (inputs.results[i] == true) {
              true_count++;
          }
          else if (inputs.results[i] == false) {
              false_count++;
          }
          else if (inputs.results[i] == null) {
              failed_count++;
          }

        }
        dat_file_contents += "__________________________________________________\n"
        dat_file_contents += "Topology Not Changed: " +  false_count.toString() + "\n";
        dat_file_contents += "Topology Changed: " +  true_count.toString() + "\n";
        dat_file_contents += "Failed: " +  failed_count.toString() + "\n";
        // Note: Uses https://www.commonwl.org/v1.0/CommandLineTool.html#Dirent
        // and https://www.commonwl.org/user_guide/topics/creating-files-at-runtime.html
        // "If the value is a string literal or an expression which evaluates to a string, 
        // a new file must be created with the string as the file contents."
        return ([{"entryname": "output.dat", "entry": dat_file_contents}]);
      }

inputs:
  results:
    label: The results of compares
    type:  ["null", {"type": "array", "items": ["null", "boolean"]}]
    format: 
    - edam:format_2330

  ids:
    label: The ids of the inputs
    type: string[]
    format: 
    - edam:format_2330
   
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