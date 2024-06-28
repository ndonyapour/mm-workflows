from pathlib import Path
import argparse
import pandas


def parse_arguments() -> argparse.Namespace:
    """ This function parses the arguments.

    Returns:
        argparse.Namespace: The command line arguments
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('--input_csv_path', type=str)
    parser.add_argument('--output_txt_path', type=str)
    parser.add_argument('--query', required=False, type=str, )
    parser.add_argument('--min_row', required=False, type=int, default=1)
    parser.add_argument('--max_row', required=False, type=int, default=-1)
    parser.add_argument('--column_name', type=str)

    args = parser.parse_args()
    return args


def load_data(input_csv_path: str, query: str, column_name: str, output_txt_path: str,
              min_row: int = 1, max_row: int = -1) -> None:
    """ Reads SMILES strings and numerical binding affinity data from the given Excel spreadsheet using a Pandas query

    Args:
        input_cvs_path: (str): Path to the input csv file
        query (str): The Query to perform
        min_row (int): min index of rows. Defaults to 1.
        max_row (int): max index of rows. Defaults to -1.
        column_name(str): The name of smiles column
        output_txt_path (str): The output text file
    """

    df = pandas.read_csv(input_csv_path)

    print(df.shape)
    print(df.columns)

    if query:
        df = df.query(query)
        print(df)

    # Perform row slicing (if any)
    if int(min_row) != 1 or int(max_row) != -1:
        # We want to convert to zero-based indices and we also want
        # the upper index to be inclusive (i.e. <=) so -1 lower index.
        df = df[(int(min_row) - 1):int(max_row)]
        print(df)

    # Now restrict to the column we want
    with Path.open(Path(output_txt_path), mode='w', encoding='utf-8') as f:
        f.write('\n'.join(df[column_name].dropna().to_list()))


def main() -> None:
    """ Reads the command line arguments and loads an CSV database of small molecules,
    and performs a query to extract the SMILES
    """
    args = parse_arguments()

    load_data(args.input_csv_path, args.query, args.column_name, args.output_txt_path,
              args.min_row, args.max_row)


if __name__ == '__main__':
    main()
