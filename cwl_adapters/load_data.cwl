cwlVersion: v1.0
class: CommandLineTool

label: Read File and Generate JSON Object

doc: |
  This tool reads the contents of a file and generates a JSON object
  in the format `{"smiles": [values]}`, saved as `cwl.output.json`.

baseCommand: ["bash", "-c"]
arguments:
  - |
    echo '{"smiles": [' > cwl.output.json
    paste -sd ',' - < $(inputs.input_file.path) | sed 's/^/"/;s/$/"/;s/,/","/g' >> cwl.output.json
    echo ']}' >> cwl.output.json

inputs:
  input_file:
    type: File
    inputBinding:
      position: 1

outputs:
  smiles:
    type: string[]

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
