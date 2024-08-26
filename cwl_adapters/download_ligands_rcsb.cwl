#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Downloads SDF files for ligands of a given PDB entry ID.

doc: |-
  Downloads SDF files for ligands of a given PDB entry ID.

baseCommand: ['python3', '/download_ligands_rcsb.py']

hints:
  DockerRequirement:
    dockerPull: ndonyapour/download_ligands_rcsb

requirements:
  InlineJavascriptRequirement: {}


inputs:
  pdbid:
    label: List of input PDBIDs to score 
    doc: |-
      List of input PDBIDs to score
      Type: string
      File type: input
      Accepted formats: string
    type: string?
    format: edam:format_2330
    inputBinding:
      prefix: --pdbid

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

  output_sdf_paths:
    label: The SDF file paths
    doc: |-
      The SDF file paths
    type: ["null", {"type": "array", "items": "File"}]
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

          var sdfs = [];
          for (var i = 0; i < lines.length; i++) {
            var sdfpath = lines[i].split(",").map(function(item) {return item.trim();})[0];
            var sdffile = {"class": "File", "path": sdfpath};
            sdfs.push(sdffile);
          }
          return sdfs;
        }

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl