# sns-wes-coverage-analysis
A quick analysis of low coverage regions from the SNS Whole Exome Sequencing analysis pipeline output. 

This script will aggregate results found in all of the `QC-coverage/*.interval_summary` files from the SNS output. It will then generate the average coverage per region across all samples, find regions with low or 0 coverage, and annotate them. 

# Usage

- First, run the SNS WES pipeline: https://github.com/igordot/sns

- Enter the directory you ran the SNS pipeline in 

```
cd sns-output-dir
```

- Clone this repository and enter the directory

```bash
git clone --recursive https://github.com/stevekm/sns-wes-coverage-analysis.git
cd sns-wes-coverage-analysis
```

- Run 

```bash
./run.sh "<project_ID>" "<results_dirname>"
```

Example:

```
$ ./run.sh SuperEnhancer_variant_calling all_samples_all_regions
```

# Output

- `average_coverage_per_sample.tsv` : The average coverage per region per sample in the analysis

- `average_coverage_per_region.tsv` : The average coverage per region (average of all per-sample averages per region)

- `regions_coverage_below_50.bed`, `regions_coverage_below_50_annotation.tsv` : Regions which had an average coverage < 50 (this value can be changed in the script), and its annotations

- `regions_with_coverage_0.bed`, `regions_with_coverage_0_annotation.tsv`: Regions which had exactly 0 coverage, and their annotations

# Notes
To maintain compatibility with other software, these scripts will output empty BED and annotation files if no low coverage regions were found. Downstream analysis scripts that utilize this package's output should check the number of lines on the output first before trying to use it. 

# Software Requirements

- R version 3.3.0, with the following packages:
  - ChIPpeakAnno
  - biomaRt
