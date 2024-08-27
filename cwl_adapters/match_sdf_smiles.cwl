#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Returns the SDF file that corresponds to the given SMILES

doc: |-
  Returns the SDF file that corresponds to the given SMILES

baseCommand: ['python3', '/match_sdf_smiles.py']

hints:
  DockerRequirement:
    dockerPull: ndonyapour/match_sdf_smiles

requirements:
  InlineJavascriptRequirement: {}


inputs:
  input_sdf_paths:
    label: List of input SDF files
    doc: |-
      List of input SDF files
      Type: File[]
      File type: input
      Accepted formats: sdf
    type: File[]
    format: edam:format_3814
    inputBinding:
      prefix: --input_sdf_paths

  smiles:
    label: SMILES of the small molecule to match
    doc: |-
      SMILES of the small molecule to match
      Type: string
      File type: input
      Accepted formats: txt
    type: string
    format:
    - edam:format_2330
    inputBinding:
      prefix: --smiles

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

  # timeout_duration:
  #   label: The maximum time in seconds to wait for a response from the API before timing out
  #   doc: |-
  #     The maximum time in seconds to wait for a response from the API before timing out
  #     Type: int
  #   type: int?
  #   format:
  #   - edam:format_2330
  #   inputBinding:
  #     prefix: --timeout_duration
  #   default: 10

  # max_retries:
  #   label: The maximum number of times to retry the request in case of failure
  #   doc: |-
  #     The maximum number of times to retry the request in case of failure
  #     Type: int
  #   type: int?
  #   format:
  #   - edam:format_2330
  #   inputBinding:
  #     prefix: --max_retries
  #   default: 5

outputs:
  output_txt_path:
    label: Path to the txt file
    doc: |-
      Path to the txt file
    type: File
    outputBinding:
      glob: $(inputs.output_txt_path)
    format: edam:format_2330

  # output_sdf_paths:
  #   label: The SDF file paths
  #   doc: |-
  #     The SDF file paths
  #   type: ["null", {"type": "array", "items": "File"}]
  #   outputBinding:
  #     glob: $(inputs.output_txt_path)
  #     loadContents: true
  #     outputEval: |
  #       ${
  #         // check if self[0] exists
  #         if (!self[0]) {
  #           return null;
  #         }
  #         var lines = self[0].contents.split("\n");
  #         // remove black lines
  #         lines = lines.filter(function(line) {return line.trim() !== '';});

  #         var sdfs = [];
  #         for (var i = 0; i < lines.length; i++) {
  #           var sdfpath = lines[i].split(",").map(function(item) {return item.trim();})[0];
  #           var sdffile = {"class": "File", "path": sdfpath};
  #           sdfs.push(sdffile);
  #         }
  #         return sdfs;
  #       }

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl