#!/bin/bash

## USAGE: run.sh "<project_ID>" "<results_dirname>"
## EXAMPLE: run.sh "NS17-03" "RUN_4"
## DESCRIPTION: This script will set up and run the coverage analysis for the WES pipeline

# ~~~~~ CHECK SCRIPT ARGS ~~~~~ #
if (( "$#" != "2" )); then
    echo "ERROR: Wrong number of arguments supplied"
    grep '^##' $0
    exit
fi

# ~~~~~ GET SCRIPT ARGS ~~~~~ #
project_ID="$1" # ex: NS17-03/RUN_4
results_ID="$2"
output_prefix="${project_ID}_${results_ID}"

# ~~~~~ RUN ~~~~~ #
./calculate_average_coverages.R "$output_prefix"

ln -fs "${output_prefix}_average_coverage_per_sample.tsv" "average_coverage_per_sample.tsv"
ln -fs "${output_prefix}_average_coverage_per_region.tsv" "average_coverage_per_region.tsv"
ln -fs "${output_prefix}_regions_coverage_below_50.bed" "regions_coverage_below_50.bed"
ln -fs "${output_prefix}_regions_with_coverage_0.bed" "regions_with_coverage_0.bed"

ln -fs "${output_prefix}_regions_coverage_below_50_annotation.tsv" "regions_coverage_below_50_annotation.tsv"
ln -fs "${output_prefix}_regions_with_coverage_0_annotation.tsv" "regions_with_coverage_0_annotation.tsv"
