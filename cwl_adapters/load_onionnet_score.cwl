cwlVersion: v1.0
class: CommandLineTool

label: Extract and Calculate dG Values from Multiple CSV Files

doc: |
  This tool reads multiple CSV-like files, extracts the second column (float values),
  calculates `dG` for each value using the provided formulas, and outputs the results
  as a JSON array of `dG` values.

baseCommand: ["python3", "-c"]
arguments:
  - |
    import csv, json, math, sys, os

    # Constants
    IDEAL_GAS_CONSTANT = 8.31446261815324  # J/(Mol*K)
    KCAL_PER_JOULE = 4184
    TEMPERATURE = 298  # Room temperature in Kelvin
    RT = (IDEAL_GAS_CONSTANT / KCAL_PER_JOULE) * TEMPERATURE
    STANDARD_CONCENTRATION = 1  # Assumed standard concentration

    # Input and output
    input_files = $(inputs.input_score_files)
    output_file = "cwl.output.json"

    # Process each input file
    dG_values = []
    for input_file in input_files:
        with open(input_file["path"], 'r') as f:
            reader = csv.reader(f)
            next(reader)  # Skip header row
            for row in reader:
                if len(row) < 2 or not row[1].strip():
                    continue
                value = float(row[1])
                Kd = 10 ** -value
                dG = RT * math.log(Kd / STANDARD_CONCENTRATION)
                dG_values.append(dG)

    # Write all results to JSON
    with open(output_file, 'w') as f:
      json.dump({"dG_values": dG_values}, f, indent=2)

inputs:
  input_score_files:
    type: {"type": "array", "items": "File"}
    inputBinding:
      position: 1
    format: edam:format_3752

outputs:
  dG_values:
    type: float[]

hints:
  DockerRequirement:
    dockerPull: python:3.9-slim

$namespaces:
  edam: https://edamontology.org/

$schemas:
- https://raw.githubusercontent.com/edamontology/edamontology/master/EDAM_dev.owl
