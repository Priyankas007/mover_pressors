#!/bin/bash

#SBATCH --job-name=filter_patient_meds  # Job name
#SBATCH --output=filter_patient_meds.out  # Output file
#SBATCH --error=filter_patient_meds.err  # Error file
#SBATCH --ntasks=1  # Number of tasks
#SBATCH --cpus-per-task=2  # Number of CPU cores per task
#SBATCH --mem=100G  # Total memory allocation (adjust based on your needs)
#SBATCH --time=5:00:00  # Time limit (hours:minutes:seconds)
#SBATCH --partition=normal  # Partition name

# Define the pressor medications you're interested in
pressors=("dopamine" "vasopressin" "dobutamine" "epinephrine" "norepinephrine")

# Create a pattern for grep from the pressors array
pattern=$(printf "|%s" "${pressors[@]}")
pattern=${pattern:1}

# Filter patient_medications.csv for rows containing pressor medications (case insensitive)
grep -iE "$pattern" EPIC_EMR/EMR/patient_medications.csv > pressors_temp.csv

# Extract the necessary columns from patient_information.csv
cut -d, -f LOG_ID,ICU_ADMIN_FLAG,SURGERY_DATE EPIC_EMR/EMR/patient_information.csv > patient_info_temp.csv

# Join the filtered pressors data with patient information based on LOG_ID
csvjoin -c LOG_ID pressors_temp.csv patient_info_temp.csv > pressors_icu_temp.csv

# Convert the SURGERY_DATE and START_DATE columns to Unix timestamps
awk -F, 'BEGIN {OFS=FS} NR==1 {print $0, "SURGERY_TIMESTAMP", "START_TIMESTAMP"} NR>1 {cmd="date -d \"" $NF "\" +%s"; cmd | getline surgery_ts; cmd="date -d \"" $(NF-1) "\" +%s"; cmd | getline start_ts; print $0, surgery_ts, start_ts}' pressors_icu_temp.csv > pressors_icu_timestamp.csv

# Filter rows where SURGERY_TIMESTAMP is before START_TIMESTAMP and ICU_ADMIN_FLAG is 'Yes'
awk -F, 'BEGIN {OFS=FS} NR==1 {print $0} NR>1 {if ($(NF-2) < $(NF-1) && $(NF-3) == "Yes") print $0}' pressors_icu_timestamp.csv > patient_meds_pressors.csv

# Cleanup temporary files
rm pressors_temp.csv patient_info_temp.csv pressors_icu_temp.csv pressors_icu_timestamp.csv

echo "Filtered data saved to patient_meds_pressors.csv"
