#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Download the PDBbind refined database

doc: |-
  Download the PDBbind refined database

baseCommand: ["python3", "/extract_pdbids_drugbank.py"]

hints:
  DockerRequirement:
    dockerPull: ndonyapour/extract_pdbids_drugbank

requirements:
  InlineJavascriptRequirement: {}
  # Enabling InitialWorkDirRequirement will stage the input Drugbank xml file
  InitialWorkDirRequirement:
    listing:
    - $(inputs.drugbank_xml_file_path)

inputs:
  drugbank_xml_file_path:
    label: Path to the Drugbank xml file
    doc: |-
      Path to the Drugbank xml file
    type: File
    format: edam:format_2332
    inputBinding:
      prefix: --drugbank_xml_file_path

  smiles:
    label: List of input SMILES  # type: 
    doc: |-
      List of input SMILES
      Type: string[]
      File type: input
      Accepted formats: list[string]
    type: ["null", {"type": "array", "items": "string"}]
    format: edam:format_2330
    inputBinding:
      prefix: --smiles
    default: []

  inchi:
    label: List of input SMILES  # type: 
    doc: |-
      List of input SMILES
      Type: string[]
      File type: input
      Accepted formats: list[string]
    type: ["null", {"type": "array", "items": "string"}]
    format:
    - edam:format_2330
    inputBinding:
      prefix: --inchi
    default: []

  inchi_keys:
    label: List of input SMILES  # type: 
    doc: |-
      List of input SMILES
      Type: string[]
      File type: input
      Accepted formats: list[string]
    type: ["null", {"type": "array", "items": "string"}]
    format:
    - edam:format_2330
    inputBinding:
      prefix: --inchi_keys
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

outputs:
  output_txt_path:
    label: Path to the txt file
    doc: |-
      Path to the txt file
    type: File
    outputBinding:
      glob: $(inputs.output_txt_path)
    format: edam:format_2330

  output_smiles:
    label: The Smiles of small molecules
    doc: |-
      The Smiles of small molecules
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
            var smiles = [];
            for (var i = 0; i < lines.length; i++) {
              // The format of the lines is as follows: NC1=NC=NN2C1=CC=C2[C@@]1(O[C@H](CO)[C@@H](O)[C@H]1O)C#N,7bf6,7qg7
              // The first item is the SMILES notation. We need to duplicate it, so each SMILES string 
              // corresponds to a PDB ID in the PDB IDs array. 
                var words = lines[i].split(",").map(function(item) {return item.trim();});
                for (var j = 1; j < words.length; j++) {
                      smiles.push(words[0]);
                }
              }
            return smiles;
        }

  output_pdb_ids:
    label: The PDB IDs of target structures
    doc: |-
      The Smiles of small molecules
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
            var pdbids = [];
            for (var i = 0; i < lines.length; i++) {
              // The format of the lines is as follows: NC1=NC=NN2C1=CC=C2[C@@]1(O[C@H](CO)[C@@H](O)[C@H]1O)C#N,7bf6,7qg7
              // The first item is the SMILES notation and the rest are the target structure PDB IDs.
                var words = lines[i].split(",").map(function(item) {return item.trim();});
                for (var j = 1; j < words.length; j++) {
                      pdbids.push(words[j]);
                }
              }
            return pdbids;
        }

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl