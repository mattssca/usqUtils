---
output:
  word_document: default
  html_document: default
  pdf_document: default
---
# usqUtils

## Overview

usqUtils is an R package for working with USQ metadata and column processing utilities. This guide will help you set up and use the package.

## Getting Started

### 1. Downlaod folder

Download the complete folder from LU Box `(Git/usqUtils)`

### 2. Install the Package and Dependencies

usqUtils also depends on the [LundTaxR](https://github.com/mattssca/LundTaxR). To install LundTaxR, Open R (or RStudio) and run:

```R
# Install devtools if you haven't already
if (!require(devtools)) install.packages("devtools")

# Install LundTaxR
devtools::install_github("mattssca/LundTaxR")
```

Next, set your working path to the recently cloned repo:

```R
setwd("/path/to/usqUtils")
```

Install the package using:

```R
devtools::install_local()
```

### 3. Load the Package

```R
library(usqUtils)
```

## Usage

Here are some examples on how to use the main funciton to return metadata in various formats.

```R
#load packages
library(LundTaxR)

#most straightforward way, enabling default parameters of the function (tidy format, only metadata, subset to UC high quality samples)
usq_metadata_default = usqUtils::get_usq_metadata()

#provide some sample IDs and restrict the return to this data
my_samples = head(usq_metadata$usq_metadata_tidy$sample_id)
usq_metadata_samples = usqUtils::get_usq_metadata(these_sample_ids = my_samples)

#return tidy metadata for all samples (category_group = "none")
usq_meta_tidy = usqUtils::get_usq_metadata(return_this = "tidy", category_group = "none")

#return tidy metadata for UC index/high quality tumors + add LundTaxR results (subtypes, prediction scores, signature scores)
usq_meta_tidy_predicted = usqUtils::get_usq_metadata(return_this = "tidy", category_group = "uc_index_high_quality", run_LundTaxR = TRUE)

#return raw metadata for all UC high tumors
usq_meta_raw_uc_high = usqUtils::get_usq_metadata(return_this = "raw", category_group = "uc_index_high_quality")

#return everything (the bundled object, with tidy/raw meta, expression data, changelog, + all LundTaxR results)
usq_everything_all = usqUtils::get_usq_metadata(return_this = "everything", category_group = "uc_index_high_quality", run_LundTaxR = TRUE)

#return full meta object (raw, tidy, changelog) - Bypass any filter criterias
usq_full_meta = usqUtils::get_usq_metadata(return_this = "full_meta")

#return only expression data for the selected sample subet (UC index high quality)
usq_expr = usqUtils::get_usq_metadata(return_this = "only_expressions", category_group = "uc_index_high_quality")

#return the changelog, and nothing else
usq_changelog = usqUtils::get_usq_metadata(return_this = "change_log")
```

## Support

For questions or issues, open an issue on GitHub or contact the maintainer.
