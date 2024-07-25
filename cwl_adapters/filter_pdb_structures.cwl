#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Filter PDB IDs based on the specified oligomeric state

doc: |-
  Filter PDB IDs based on the specified oligomeric state

baseCommand: ['python3', '/filter_pdb_structures.py']

hints:
  DockerRequirement:
    dockerPull: ndonyapour/filter_pdb_structures

requirements:
  InlineJavascriptRequirement: {}


inputs:
  input_pdbids:
    label: List of input PDBIDs to score 
    doc: |-
      List of input PDBIDs to score
      Type: string[]
      File type: input
      Accepted formats: list[string]
    type: ["null", {"type": "array", "items": "string"}]
    format: edam:format_2330
    inputBinding:
      prefix: --input_pdbids
    default: []

  output_txt_path:
    label: Path to the text dataset file
    doc: |-
      Path to the text dataset file
      Type: string
      File type: output
      Accepted formats: txt
    type: string
    format:
    - edam:format_2330
    inputBinding:
      prefix: --output_txt_path
    default: system.log


  oligomeric_states:
    label: Oligomeric state of the protein
    doc: |-
      Oligomeric state of the protein
      Type: string
      File type: output
      Accepted formats: txt
    type: string[]
    format:
    - edam:format_2330
    inputBinding:
      prefix: --oligomeric_states
    default: [monomer]

outputs:
  output_txt_path:
    label: Path to the txt file
    doc: |-
      Path to the txt file
    type: File
    outputBinding:
      glob: $(inputs.output_txt_path)
    format: edam:format_2330

  output_pdbids:
    label: The selected PDB IDs
    doc: |-
      The selected PDB IDs
    type: ["null", {"type": "array", "items": "string"}]
    outputBinding:
      glob: $(inputs.output_txt_path)
      loadContents: true
      outputEval: |
        ${
          // check if self[0] exists
          if (!self[0]) {
            return null;
          }
          var lines = self[0].contents.split("\n");
          // remove black lines
          lines = lines.filter(function(line) {return line.trim() !== '';});
          // The outpus file has one line 
          // The format of the line is as follows: 6x7z,4yo7,5fyr,6ktl,4rxm,4irx,3v16,6b5z,4mio,7d5n
          if (lines.length == 0){
            return null;
          }
          var pdb_ids = [];
          for (var i = 0; i < lines.length; i++) {
            var words = lines[i].split(",").map(function(item) {return item.trim();});
            pdb_ids.push(words[0]);
          }
          return pdb_ids;
        }

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl