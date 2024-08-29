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
  input_sdf_paths:
    label: Input 2D array # type: 
    doc: |-
      Input 2D array
      Type: File[][]
      File type: input
      Accepted formats: list[list[File]]
    type: ["null", {"type": "array", "items": ["null", {"type": "array", "items": "File"}]}]
    format: edam:format_3814

outputs:
  sdf_cnts:
    label: Number of structures that have one ligand
    doc: |-
       Number of structures that have one ligand
    type: int
    outputBinding:
      outputEval: |
        ${
          var sdf_cnts = 0;
          if (inputs.input_sdf_paths == null){
            return null;
          }
          for (var i = 0; i < inputs.input_sdf_paths.length; i++) {
            var sdfs = inputs.input_sdf_paths[i];
            if (sdfs != null) {
              if (sdfs.length == 1){
                sdf_cnts = sdf_cnts + 1;
              }
            }
          }
        return sdf_cnts; //.toString();
        }

  sdf_files:
    label: Number of structures that have one ligand
    doc: |-
       Number of structures that have one ligand
    type:  ["null", {"type": "array", "items": "File"}]
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
              if (sdfs.length == 1){
                output_sdfs.push(sdfs[0]);
              }
            }
          }
        return output_sdfs; //.toString();
        }
    format: edam:format_3814


  pdb_ids:
    label: Number of structures that have one ligand
    doc: |-
       Number of structures that have one ligand
    type:  ["null", {"type": "array", "items": "string"}]
    outputBinding:
      outputEval: |
        ${
          if (inputs.input_sdf_paths == null){
            return [];
          }
          var pdbids = [];
          for (var i = 0; i < inputs.input_sdf_paths.length; i++) {
            var sdfs = inputs.input_sdf_paths[i];
            if (sdfs != null) {
              if (sdfs.length == 1){
                pdbids.push(sdfs[0].basename.substring(0, 4));
              }
            }
          }
        return pdbids; //.toString();
        }


$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl