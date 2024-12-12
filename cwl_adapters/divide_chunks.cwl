#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

label: Select the structures that have one ligand 

doc: |-
  Select the structures that have one ligand and divide input files into chunks of a specified size.

baseCommand: cat

requirements:
  InlineJavascriptRequirement: {}

inputs:
  input_pdb_paths:
    label: The path of input pdb files
    type: ["null", {"type": "array", "items": ["null", "File"]}]
    format: edam:format_1476 # PDB

  chunk_size:
    label: The size of the chunk
    type: int
    default: 10

outputs:
  output_pdb_paths:
    label: Chunks of input PDB files
    doc: |-
      Array of arrays where each sub-array contains input PDB files grouped into chunks of the specified size.
    type: {"type": "array", "items": {"type": "array", "items": "File"}}
    outputBinding:
      outputEval: |
        ${
          if (inputs.input_pdb_paths == null) {
            return [];
          }

          var chunkSize = inputs.chunk_size; // Default chunk size
          var pdbPaths = inputs.input_pdb_paths.filter(function(x) {
            return x !== null;
          });
          var chunks = [];

          for (var i = 0; i < pdbPaths.length; i += chunkSize) {
            chunks.push(pdbPaths.slice(i, i + chunkSize));
          }

          return chunks;
        }
    #format: edam:format_1476

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
