#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Select the structures that have one ligand 

doc: |-
  Select the structures that have one ligand

baseCommand: cat

requirements:
  InlineJavascriptRequirement: {}


inputs:
  input_sdf_files:
    label: Input 2D array # type: 
    doc: |-
      Input 2D array
      Type: File[][]
      File type: input
      Accepted formats: list[list[File]]
    type: ["null", {"type": "array", "items": ["null", {"type": "array", "items": "File"}]}]
    format: edam:format_3814 #sdf

outputs:
  # sdf_cnts:
  #   label: Number of structures that have one ligand
  #   doc: |-
  #      Number of structures that have one ligand
  #   type: int
  #   outputBinding:
  #     outputEval: |
  #       ${
  #         var sdf_cnts = 0;
  #         if (inputs.input_sdf_paths == null){
  #           return null;
  #         }
  #         for (var i = 0; i < inputs.input_sdf_paths.length; i++) {
  #           var sdfs = inputs.input_sdf_paths[i];
  #           if (sdfs != null) {
  #             if (sdfs.length == 1){
  #               sdf_cnts = sdf_cnts + 1;
  #             }
  #           }
  #         }
  #       return sdf_cnts; //.toString();
  #       }

  output_sdf_files:
    label: Number of structures that have one ligand
    doc: |-
       Number of structures that have one ligand
    type: {"type": "array", "items": "File"}
    outputBinding:
      outputEval: |
        ${
          if (inputs.input_sdf_paths == null){
            return [];
          }
          var output_sdfs = [];
          for (var i = 0; i < inputs.input_sdf_paths.length; i++) {
            var sdfs = inputs.input_sdf_paths[i];
            if (sdfs != null) {
              for (var j = 0; j < sdfs.length; j++) {
                  output_sdfs.push(sdfs[j]);
              }
            }
          }
        return output_sdfs;
        }
    format: edam:format_3814

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl