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


# ~~~~~ RUN ~~~~~ #
./calculate_average_coverages.R
