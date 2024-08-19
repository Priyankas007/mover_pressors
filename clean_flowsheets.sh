#!/bin/bash
#SBATCH --job-name=clean_flowsheets   # Job name
#SBATCH --output=clean_flowsheets_%A.out    # Output file
#SBATCH --error=clean_flowsheets_%A.err     # Error file
#SBATCH --ntasks=1                    # Number of tasks (usually 1)
#SBATCH --cpus-per-task=1             # Number of CPU cores per task
#SBATCH --mem=1G                      # Memory per node (adjust if necessary)
#SBATCH --time=01:00:00               # Time limit hrs:min:sec (adjust if necessary)
#SBATCH --mail-type=ALL               # Send email on all events (BEGIN, END, FAIL)
#SBATCH --mail-user=shrestp@stanford.edu # Replace with your email address

# Directory containing the CSV files
input_dir="path_to_your_csv_files"
# Output directory for filtered CSV files
output_dir="path_to_output_directory"

# Create output directory if it doesn't exist
mkdir -p $output_dir

# Iterate over each CSV file in the input directory
for csv_file in "$input_dir"/*.csv; do
    # Extract the base name of the file
    base_name=$(basename "$csv_file")
    
    # Filter the CSV file using awk and grep
    awk -F',' 'NR==1 || ($0 ~ /MAP \(mmHg\)/ && $0 ~ /POST-OP/)' "$csv_file" > "$output_dir/$base_name"
done

echo "Filtering completed for all CSV files in $input_dir"
