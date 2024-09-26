#!/usr/bin/env cwl-runner
# cwlVersion: v1.2

# class: CommandLineTool

# label: Determines the success rate

# doc: |-
#   Determines the success rate

# baseCommand: cat
# arguments: [$(inputs.output_txt_path)]
cwlVersion: "v1.2"
class: CommandLineTool
baseCommand: echo
requirements:
  InlineJavascriptRequirement: {}

# requirements:
#   - class: InlineJavascriptRequirement
#   # This enables staging input files and dynamically generating a file
#   # containing the file paths on the fly.
#   - class: InitialWorkDirRequirement 
#     listing: |
#       ${
#         var dat_file_contents = "";
#         var failed_count = 0
#         for (var i = 0; i < inputs.sdf_files.length; i++) {
#             var ligand_sdfs = inputs.sdf_files[i];
#             if (ligand_sdfs != null) {
#                 failed_count++;                  
#                   // Split the content by lines
#                   var lines = ligand_sdfs.contents;

#                   // // Iterate through the lines to find the SMILES string
#                   // var smiles = null;
#                   // for (var i = 0; i < lines.length; i++) {
#                   //     if (lines[i].indexOf('<SMILES>') !== -1) {
#                   //         // The SMILES string is in the next line
#                   //         smiles = lines[i + 1].trim();
#                   //         break;
#                   //     }
#                   // }
#                 dat_file_contents += lines + "\tSuccess" + "\n";
#               }
#         }

#         // Note: Uses https://www.commonwl.org/v1.0/CommandLineTool.html#Dirent
#         // and https://www.commonwl.org/user_guide/topics/creating-files-at-runtime.html
#         // "If the value is a string literal or an expression which evaluates to a string, 
#         // a new file must be created with the string as the file contents."
#         return ([{"entryname": inputs.output_txt_path, "entry": dat_file_contents}]);
#       }

inputs:
  smiles:
    label: The input SMILES 
    doc: |-
      List of input SMILES
      Type: string[]
      File type: input
      Accepted formats:string
    type: string[]
    format: edam:format_2330
  sdf_files:
    # label: SDF files
    # doc: |-
    #   SDF files
    #   Type: File[]
    #   File type: input
    #   Accepted formats: list[File]
    # type: File[]
    # format: edam:format_3814 #sdf
    type:
      type: array
      items: File
    loadContents: true
    inputBinding:
      valueFrom: |
        ${
          return JSON.stringify({
            "data": inputs.files.map(item => parseInt(item.contents))
          });
        }
    # format: 
    # - edam:format_3814 #sdf
      # inputBinding:
    #loadContents: true
    #inputBinding: { loadContents: true }
     
  output_txt_path:
    label: Path to the dat file
    doc: |-
      Path to the dat file
      Type: string
      File type: output
      Accepted formats: DAT
    type: string
    format:
    - edam:format_2330
    default: output.dat

outputs:
  output_txt_path:
    label: Path to the dat file
    doc: |-
      Path to the dat file
    type: File
    outputBinding:
      glob: $(inputs.output_txt_path)
    format: edam:format_2330

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
