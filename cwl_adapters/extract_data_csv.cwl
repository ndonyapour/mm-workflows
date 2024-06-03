#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Download the PDBbind refined database

doc: |-
  Download the PDBbind refined database

baseCommand: ['python3', '/extract_data_csv.py']

hints:
  DockerRequirement:
    dockerPull: ndonyapour/extract_data_csv

requirements:
  InlineJavascriptRequirement: {}
  # Enabling InitialWorkDirRequirement will stage the input Drugbank xml file
  InitialWorkDirRequirement:
    listing:
    - $(inputs.input_csv_path)

inputs:
  input_csv_path:
    label: Path to the input csv file
    doc: |-
      Path to the input csv file
      Type: string
      File type: input
      Accepted formats: csv
    type: File
    format: edam:format_3752
    inputBinding:
      prefix: --input_csv_path

  query:
    label: query str to search the dataset
    doc: |-
      query str to search the dataset
      Type: string
      File type: input
      Accepted formats: txt
    type: string?
    format:
    - edam:format_2330
    inputBinding:
      prefix: --query

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

  column_name:
    label: The name of the column to output data 
    doc: |-
      The name of the column to output data
      Type: string
      File type: input
      Accepted formats: txt
    type: string
    format:
    - edam:format_2330
    inputBinding:
      prefix: --column_name

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

outputs:
  output_txt_path:
    label: Path to the txt file
    doc: |-
      Path to the txt file
    type: File
    outputBinding:
      glob: $(inputs.output_txt_path)
    format: edam:format_2330

  output_data:
    label: The output data
    doc: |-
      The output data
    type: 
      type: array
      items: string
    outputBinding:
      glob: $(inputs.output_txt_path)
      loadContents: true
      outputEval: |
        ${
            var lines = self[0].contents.split("\n");
            // remove black lines
            lines = lines.filter(function(line) {return line.trim() !== '';});
            var data = [];
            for (var i = 0; i < lines.length; i++) {
              // The format of the lines is as follows: data 
                var words = lines[i].split(",").map(function(item) {return item.trim();});
                data.push(words[0]);

              }
            return data;
        }
  #  format: edam:format_2330


$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl