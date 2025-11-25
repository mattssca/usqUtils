# usqUtils

<img src="man/figures/logo.png" align="right" height="280" alt="LundTaxR logo" />

## Overview

usqUtils is an R package for working with USQ metadata and column processing utilities. This guide will help you set up and use the package.

## Getting Started

### 1. Clone the Repository

Clone the repository to your local machine:

```bash
git clone https://github.com/mattssca/usqUtils.git
```

### 2. Access the Data Folder in LUBox

- Log in to LU Box and locate the associated data folder for usqUtils `(/Git/data/usqUtils)`.
- Download the contents of the LU Box data folder.
- Replace the `data` and `data-raw` folders in your cloned repo wioth the downloaded folders from LU Box.

### 3. Install the Package

Open R (or RStudio) and set your working directory to the cloned repo:

```R
setwd("/path/to/usqUtils")
```

Install the package using:

```R
# If devtools is not installed, first run:
# install.packages("devtools")
devtools::install_local()
```

### 4. Load the Package

```R
library(usqUtils)
```

## Usage

Refer to the function documentation in the `man/` folder or use R's help system:

```R
#load packages
library(usqUtils)

#EXAMPLES
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

## Notes

- Ensure all required data files are placed in the correct directories (`data/`, `data-raw/`).
- For updates, pull the latest changes from the repository and repeat the installation step.

## Support

For questions or issues, open an issue on GitHub or contact the maintainer.
