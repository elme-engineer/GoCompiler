#!/bin/bash

# Define folders
test_folder=./Comp2019/meta2
output_folder=./temp_outputs

# Ensure output folder exists
mkdir -p "$output_folder"

# List of test files
files=(
    "blocks.dgo"
    "braces.dgo"
    "circle.dgo"
    "eof.dgo"
    "eof1.dgo"
    "errors.dgo"
    "error_unbalanced_par.dgo"
    "expressionHard.dgo"
    "expressions_2.dgo"
    "expressions.dgo"
    "factorial.dgo"
    "funcParams.dgo"
    "multiple_funcdecl_blocks.dgo"
    "precedence.dgo"
    "smallest.dgo"
    "statements.dgo"
    "sum.dgo"
    "syntax_errors_stmt.dgo"
    "testeErros.dgo"
    "varfuncdecl.dgo"
    "variable_func_declarations.dgo"
)

# List of files that passed the check
passed_files=()

# Loop over each file
for file in "${files[@]}"; do
    # Set input and output file paths
    input_file="$test_folder/$file"
    output_file="$output_folder/${file%.dgo}.out"
    
    # Run the command and capture output
    output=$(./gocompiler -t < "$input_file")

    # Write the output to the output file
    echo "$output" > "$output_file"
    
    # Check if the output is non-empty and the file name doesn't contain "error" or "Erro"
    if [[ -n "$output" ]] && [[ ! "$file" == *"error"* ]] && [[ ! "$file" == *"Erro"* ]]; then
        passed_files+=("$file")
        echo "The $output_file has passed the check"
    fi
done

# Clean up old .txt files that aren't in the passed_files list
for txt_file in "$output_folder"/*.txt; do
    if [ -f "$txt_file" ]; then  # Check if file exists
        # Get just the filename without path
        filename=$(basename "$txt_file")
        # Check if this file is not in our passed_files list
        should_keep=false
        for passed_file in "${passed_files[@]}"; do
            if [ "$filename" == "$passed_file.txt" ]; then
                should_keep=true
                break
            fi
        done
        if [ "$should_keep" = false ]; then
            rm "$txt_file"
            echo "Removed old file: $txt_file"
        fi
    fi
done

# Run the build_test.sh script
./build_test.sh

# Run the gocompiler for each file that passed the check
for file in "${passed_files[@]}"; do
    input_file="$test_folder/$file"
    output_file="$output_folder/$file.txt"
    echo "Debugging for $file"
    ./gocompiler_test -t < "$input_file" &> "$output_file"
done