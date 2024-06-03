
#!/usr/bin/env cwl-runner
cwlVersion: v1.1

class: CommandLineTool

label: Duplicates a pdbqt file n times, where n is the length of another array.

doc: |-
  Duplicates a pdbqt file n times, where n is the length of another array.

baseCommand: python3

requirements:
  InlineJavascriptRequirement: {}

inputs:
  input_txt_path:
    label: Path to the text dataset file
    doc: |-
      Path to the text dataset file
      Type: File
      File type: input
      Accepted formats: txt
    type: File
    format: edam:format_2330
    loadContents: true  # requires cwlVersion: v1.1
    # See https://www.commonwl.org/v1.1/CommandLineTool.html#Changelog
    # Curiously, cwlVersion: v1.0 allows loadContents for outputs, but not inputs.

  input_smiles:
    label: The input smiles 
    doc: |-
      The input smiles 
      Type: string
    type: string
    format: edam:format_2330

outputs:
  smiles:
    label: Array of output smiles
    doc: |-
      Array of output smiles
    type: 
      type: array
      items: string
    outputBinding:
      outputEval: |
        ${
            var lines = inputs.input_txt_path.contents.split("\n");
            var smiles = [];
            for (var i = 0; i < lines.length; i++) {
                // The format of lines is NC1=NC=NN2C1=CC=C2[C@@]1(O[C@H](CO)[C@@H](O)[C@H]1O)C#N,7bf6,7qg7
                // The first item is smiles 
                var words = lines[i].split(",").map(function(item) {return item.trim();});
                if (words[0] == inputs.input_smiles) {
                  for (var j = 1; j < words.length; j++) {
                    smiles.push(inputs.input_smiles);
                  }
                }
           }
          return smiles;
        }

  pdb_ids:
    label: Array of output PDBIDs
    doc: |-
      Array of output PDBIDs
    type: string[]
    outputBinding:
      outputEval: |
        ${
            var lines = inputs.input_txt_path.contents.split("\n");
            var  pdbids = [];
            for (var i = 0; i < lines.length; i++) {
                // The format of lines is NC1=NC=NN2C1=CC=C2[C@@]1(O[C@H](CO)[C@@H](O)[C@H]1O)C#N,7bf6,7qg7
                // The first item is smiles 
                var words = lines[i].split(",").map(function(item) {return item.trim();});
                if (words[0] == inputs.input_smiles) {
                  for (var j = 1; j < words.length; j++) {
                      pdbids.push(words[j]);
                  }
                }
           }
          return pdbids;
        }

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
