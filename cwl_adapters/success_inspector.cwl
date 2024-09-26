#!/usr/bin/env cwl-runner
cwlVersion: v1.2

class: CommandLineTool

label: Determines the success rate

doc: |-
  Determines the success rate

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
        var success_counts = 0;
        var fail_counts = 0;
        var unique_output_smiles = inputs.output_smiles.filter(function(item, index, arr) {
                                          return arr.indexOf(item) === index;});
        for (var i = 0; i < inputs.input_smiles.length; i++) {
            var smiles = inputs.input_smiles[i];
            if (unique_output_smiles.includes(smiles)){
              dat_file_contents += smiles + "\tSuccess" + "\n";
              success_counts++;
            }
            else{
              dat_file_contents += smiles + "\tFail" + "\n";
              fail_counts++;
            }
        }
        dat_file_contents += "\n \n";
        dat_file_contents += "Number of successful compounds:\t" + success_counts.toString() + "\n";
        dat_file_contents += "Number of failed compounds:\t" + fail_counts.toString() + "\n";
        dat_file_contents += "Success Rate:\t" + ((100 * success_counts)/inputs.input_smiles.length).toString() + "\n";
        // Note: Uses https://www.commonwl.org/v1.0/CommandLineTool.html#Dirent
        // and https://www.commonwl.org/user_guide/topics/creating-files-at-runtime.html
        // "If the value is a string literal or an expression which evaluates to a string, 
        // a new file must be created with the string as the file contents."
        return ([{"entryname": inputs.output_txt_path, "entry": dat_file_contents}]);
      }

inputs:
  input_smiles:
    label: The input SMILES 
    doc: |-
      List of input SMILES
      Type: string[]
      File type: input
      Accepted formats:string
    type: string[]
    format: edam:format_2330

  output_smiles:
    label: The output SMILES 
    doc: |-
      The output SMILES
      Type: string[]
      File type: input
      Accepted formats:string
    type: string[]
    format: edam:format_2330

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
