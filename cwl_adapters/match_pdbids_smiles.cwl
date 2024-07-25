#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Returns a list of SMILES associated with the PDBIDs 
doc: |-
    Returns a list of SMILES associated with the PDBIDs 

baseCommand: python3

requirements:
  InlineJavascriptRequirement: {}


inputs:
  filtered_pdbids:
    label: Input filtered PDBIDs 
    doc: |-
      Input filtered PDBIDs 
      Type: string[]
      File type: input
      Accepted formats: list[list[string]]
    type: ["null", {"type": "array", "items": "string"}]
    format: edam:format_2330

  pdbids:
    label: PDB ID arrays
    doc: |-
      PDB ID arrays
      Type: string[][]
      File type: input
      Accepted formats: list[list[string]]
    type: ["null", {"type": "array", "items": {"type": "array", "items": "string"}}]
    format: edam:format_2330

  smiles:
    label: Compounds SMILES
    doc: |-
      Compounds SMILES
      Type: string[]
      File type: input
      Accepted formats: list[list[string]]
    type: ["null",  {"type": "array", "items": "string"}]
    format: edam:format_2330
  

outputs:
  filtered_smiles:
    label: Output matched SMILES of input filtered PDBIDs 
    doc: |-
      Output matched SMILES of input filtered PDBIDs
    type: 
      type: array
      items: string
    outputBinding:
      outputEval: |
        ${
          var smiles = [];
          if (inputs.filtered_pdbids == null){
            return null;
          }

          for (var i = 0; i < inputs.filtered_pdbids.length; i++) {
            var pdbid = inputs.filtered_pdbids[i];
            for (var j = 0; j < inputs.pdbids.length; j++) {
              var pdbids = inputs.pdbids[j];
              if (pdbids.includes(pdbid)){
                smiles.push(inputs.smiles[j]);  
              }
            }
          }  
        return smiles;
        }

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl