#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Fetches the PDB information from RCSB and scores PDB structures.

doc: |-
  Fetches the PDB information from RCSB and scores PDB structures.

baseCommand: ['python3', '/score_pdb_structures.py']

hints:
  DockerRequirement:
    dockerPull: ndonyapour/score_pdb_structures

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

  min_row:
    label: The row min index
    doc: |-
      The row min inex
      Type: int
    type: int?
    format:
    - edam:format_2330
    inputBinding:
      prefix: --min_row

  max_row:
    label: The row max index
    doc: |-
      The row max inex
      Type: int
    type: int?
    format:
    - edam:format_2330
    inputBinding:
      prefix: --max_row

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

  timeout_duration:
    label: The maximum time in seconds to wait for a response from the API before timing out
    doc: |-
      The maximum time in seconds to wait for a response from the API before timing out
      Type: int
    type: int?
    format:
    - edam:format_2330
    inputBinding:
      prefix: --timeout_duration
    default: 10

  max_retries:
    label: The maximum number of times to retry the request in case of failure
    doc: |-
      The maximum number of times to retry the request in case of failure
      Type: int
    type: int?
    format:
    - edam:format_2330
    inputBinding:
      prefix: --max_retries
    default: 5

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
    type: 
      type: array
      items: string
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
          return lines[0].split(",").map(function(item) {return item.trim();});
        }

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl