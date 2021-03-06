#!/usr/bin/env Rscript

## USAGE: calculate_average_coverages.R 
## DESCRIPTION: This script will aggregate average coverages per sample from sns-wes pipeline output

# ~~~~~~~ FUNCTIONS ~~~~~~~ #
get_sampleID_from_filename <- function(filename){
    return(gsub(pattern = '.sample_interval_summary', replacement = '', x = filename))
}

build_all_coverages_df <- function(coverage_files){
    # empty df to hold all the coverages
    all_coverages_df <- data.frame()
    
    # load all the coverages into a single df 
    for(coverage_file in coverage_files){
        message(sprintf("Reading from coverage file: %s", coverage_file))
        
        sample_ID <- get_sampleID_from_filename(basename(coverage_file))
        
        # load the coverage data from the file
        coverage_df <- read.delim(file = coverage_file, header = TRUE, sep = ',')
        rownames(coverage_df) <- coverage_df[["Target"]]
        coverage_df <- coverage_df[5]
        colnames(coverage_df)[1] <- sample_ID
        
        # load the data into the overall df
        if(nrow(all_coverages_df) == 0){
            all_coverages_df <- coverage_df
        } else {
            all_coverages_df <- cbind(all_coverages_df, coverage_df)
        }
    }
    return(all_coverages_df)
}

chrom_regions2df <- function(regions){
    # split the regions into chrom coordinates for BED files
    # regions <- c("chr1:236998847-236998987", "chr1:237001714-237001899")
    regions_df <- as.data.frame(do.call(rbind, strsplit(regions, ':')))
    regions_df <- cbind(regions_df[1],
                        as.data.frame(do.call(rbind, strsplit(as.character(regions_df$V2), '-'))))
    colnames(regions_df) <- c("chrom", "start", "stop")
    return(regions_df)
}

write_BED <- function(df, output_file){
    write.table(x = df, file = output_file, quote = FALSE, sep = '\t', row.names = FALSE, col.names = FALSE)
}

try_to_save_BED <- function(df, output_file) {
    if(nrow(df) > 0){
        df_bed <- chrom_regions2df(rownames(df))
        message(sprintf("Writing regions to file: %s", output_file))
        write_BED(df = df_bed, output_file = output_file)
        
    } else {
        message(sprintf("No regions present, making empty file: %s", output_file))
        file.create(output_file)
    }
}

run_annotation_script <- function (bed_files) {
    bed_command <- paste(bed_files, collapse = ' ')
    # annotation_file <- gsub(pattern = ".bed", replacement = "_annotation.tsv", x = bed_file)
    annotation_command <- sprintf("Rscript annotate_peaks.R %s -b annotate-peaks/data/hg19/biomart_data.RData --suffix _annotation.tsv", bed_command)
    message(sprintf("pwd is:\n%s\n\n", getwd()))
    message(sprintf("Now running command:\n%s\n\n", annotation_command))
    system(annotation_command)
}


# ~~~~~ GET SCRIPT ARGS ~~~~~~~ #
args <- commandArgs(TRUE)

output_file_prefix <- args[1]
print("output prefix is:")
print(output_file_prefix)

# ~~~~~~~ FILE LOCATIONS ~~~~~~~ #
run_analysis_dir <- "run_analysis_output"
coverages_dir <- file.path(run_analysis_dir, "QC-coverage")

# get the coverage files
coverage_files <- dir(path = coverages_dir, pattern = "interval_summary", full.names = TRUE)


# ~~~~~~~ IMPORT AVERAGE COVERAGE PER REGION PER SAMPLE ~~~~~~~ #
all_coverages_df <- build_all_coverages_df(coverage_files)

avg_file = paste0(output_file_prefix, "_average_coverage_per_sample.tsv")
message(sprintf("Writing sample averages to file: %s", avg_file))
write.table(x = all_coverages_df, sep = '\t', quote = FALSE, row.names = TRUE, col.names = NA, 
            file = avg_file)


# ~~~~~~~ CALCULATE AVERAGE OF AVG'S PER REGION ~~~~~~~ #
region_coverages_df <- as.data.frame(rowMeans(all_coverages_df))
colnames(region_coverages_df) <- "average_coverage"

region_avg_file = paste0(output_file_prefix, "_average_coverage_per_region.tsv")
message(sprintf("Writing region averages to file: %s", region_avg_file))
write.table(x = region_coverages_df, sep = '\t', quote = FALSE, row.names = TRUE, col.names = FALSE, file = region_avg_file)


# ~~~~~~~ CREATE BED FOR REGIONS WITH LOW COVERAGE ~~~~~~~ #
# coverage < 50
# coverage = 0
low_cutoff <- 50

message(sprintf("Finding regions with coverage below %s", low_cutoff))
low_regions <- region_coverages_df[region_coverages_df["average_coverage"] < low_cutoff, , drop = FALSE]
message(sprintf("Number of regions found: %s", nrow(low_regions)))
low_BED_file <- sprintf("%s_regions_coverage_below_%s.bed", output_file_prefix, low_cutoff)
try_to_save_BED(df = low_regions, output_file = low_BED_file)

save.image("calculate_average_coverages.Rdata")

message("Finding regions with coverage below 0")
zero_regions <- region_coverages_df[region_coverages_df["average_coverage"] == 0, , drop = FALSE]
message(sprintf("Number of regions found: %s", nrow(zero_regions)))
zero_BED_file <- sprintf("%s_regions_with_coverage_0.bed", output_file_prefix)
try_to_save_BED(df = zero_regions, output_file = zero_BED_file)
save.image("calculate_average_coverages.Rdata")

# ~~~~~~ RUN THE ANNOTATION SCRIPT ~~~~~~~ # 
message("Running annotation script on low coverage BED files...")
BED_to_annotate <- c(low_BED_file, zero_BED_file)
run_annotation_script(BED_to_annotate)
