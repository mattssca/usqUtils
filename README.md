# usqUtils

<img src="man/figures/logo.png" align="right" height="280" alt="usqUtils logo" />

<!-- R Package Badges -->

![R](https://img.shields.io/badge/R-%E2%89%A54.0.0-blue)
![License](https://img.shields.io/badge/license-GPL%20(%E2%89%A5%202)-blue)
![Version](https://img.shields.io/badge/version-2.0.0-blue)
![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen)

<!-- Domain Badges -->

![Bioinformatics](https://img.shields.io/badge/domain-bioinformatics-purple)
![Cancer Research](https://img.shields.io/badge/application-cancer%20research-red)

> **Streamlined metadata management and sample annotation for USQ bladder cancer cohorts**

usqUtils provides a comprehensive suite of functions for organizing, processing, and annotating USQ cohort metadata. The package enables efficient data tidying, sample categorization, and integration of molecular subtype predictions, supporting reproducible analysis workflows in bladder cancer research.

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

## Metadata Contents (tidy format)

Here's a detailed explenation of the columns returned with `return_this = "tidy"`.

| Column Name                        | Description                                                        |
| ---------------------------------- | ------------------------------------------------------------------ |
| sample_id                          | Unique sample identifier                                           |
| pad_id                             | Patient or pathology ID                                            |
| tma_pad_id                         | Tissue microarray ID (may be NA if not applicable)                 |
| qc_comment                         | Quality control comment (e.g., batch quality)                      |
| sample_category                    | Sample category (e.g., non-urothelial, recurrence, etc.)           |
| sample_category_group              | Grouped sample category (e.g., high quality, recurrence group)     |
| is_in_set_tma                      | Logical: included in TMA set                                       |
| is_in_set_rna_tma                  | Logical: included in RNA TMA set                                   |
| is_in_set_eau_risk                 | Logical: included in EAU risk set. **Note only applies to NMIBC** |
| is_in_set_progression_biological   | Logical: included in biological progression set                    |
| is_in_set_progression_clinical     | Logical: included in clinical progression set                      |
| is_in_set_progression_fu           | Logical: included in follow-up progression set                     |
| is_in_set_bcg_any                  | Logical: received any BCG treatment                                |
| is_in_set_bcg_adequate             | Logical: received adequate BCG treatment                           |
| is_in_set_gem_mmc                  | Logical: received gemcitabine/MMC treatment                        |
| sample_date                        | Date of sample collection                                          |
| age                                | Age at sample collection                                           |
| eau_risk_is_over_70                | Logical: EAU risk age over 70                                      |
| eau_risk_tumor_status              | Tumor status (primary or recurrence)                               |
| eau_risk_n_tumors                  | Number of tumors (single or multiple)                              |
| eau_risk_tumor_size                | Tumor size category (below or above 3cm)                           |
| eau_risk_tumor_stage               | Tumor stage (Ta or T1)                                             |
| eau_risk_is_cis                    | Logical: presence of CIS                                           |
| eau_risk_grade_who_1973            | WHO 1973 grade (G1, G2, G3)                                        |
| eau_risk_variant_hist              | Variant histology (e.g., glandular, micropapillary)                |
| eau_risk_prostatic_urethra         | Prostatic urethra involvement                                      |
| eau_risk_is_lvi                    | Logical: lymphovascular invasion                                   |
| eau_risk_is_very_high_risk_upgrade | Logical: upgraded to very high risk                                |
| eau_risk_score                     | EAU risk score                                                     |
| eau_risk_category                  | EAU risk category (low, intermediate, high, very high)             |
| gender                             | Gender (female or male)                                            |
| smoker                             | Smoking status (no, yes, previous, unknown)                        |
| primary_recurrence                 | Primary or recurrence status                                       |
| is_palliative                      | Logical: palliative case                                           |
| turb_date                          | Date of TURB (transurethral resection of bladder tumor)            |
| urine_cytology_pre_turb            | Pre-TURB urine cytology result                                     |
| stage                              | Pathological stage (Tx, T0, cis, Ta, T1, etc.)                     |
| node                               | Nodal status (Nx, N0, N1, etc.)                                    |
| met                                | Metastasis status (Mx, M0, M1a, etc.)                              |
| grade                              | Tumor grade (G1, G2, G3, etc.)                                     |
| tnm                                | TNM classification                                                 |
| cystectomy_date                    | Date of cystectomy                                                 |
| neoadjuvant_induction              | Type of neoadjuvant induction therapy                              |
| type_preoperative_chemo            | Type of preoperative chemotherapy                                  |
| n_chemo_doses                      | Number of chemotherapy doses                                       |
| is_returb                          | Logical: returb performed                                          |
| returb_date                        | Date of returb                                                     |
| returb_stage                       | Stage at returb                                                    |
| is_cis_primary_returb              | Logical: CIS at primary returb                                     |
| prostatic_urethra                  | Prostatic urethra status                                           |
| tumor_n                            | Number of tumors (categorical)                                     |
| tumor_size                         | Tumor size (<3cm or >=3cm)                                         |
| is_lvi                             | Logical: lymphovascular invasion                                   |
| invaision_depth_t1                 | Depth of T1 invasion                                               |
| bcg_instillations                  | Number of BCG instillations                                        |
| is_only_palliative                 | Logical: only palliative treatment                                 |
| recidive_date                      | Date of recurrence                                                 |
| progression_date                   | Date of progression                                                |
| death_other_cause_date             | Date of death (other cause)                                        |
| death_bladder_date                 | Date of death (bladder cancer)                                     |
| last_follow_up_date                | Date of last follow-up                                             |
| tma_grade_who2022                  | TMA grade (WHO 2022)                                               |
| nmibc_vs_mibc                      | Stage classification (NMIBC or MIBC)                               |
| progression_biological_event       | Biological progression event                                       |
| progression_biological_time        | Time to biological progression                                     |
| progression_clinical_event         | Clinical progression event                                         |
| progression_clinical_time          | Time to clinical progression                                       |
| progression_fu_event               | Progression event at follow-up                                     |
| progression_fu_time                | Time to progression at follow-up                                   |
| bcg_any_event                      | Any BCG event                                                      |
| bcg_any_time                       | Time to any BCG event                                              |
| bcg_adequate_event                 | Adequate BCG event                                                 |
| bcg_adequate_time                  | Time to adequate BCG event                                         |
| gem_mmc_event                      | Gemcitabine/MMC event                                              |
| gem_mmc_time                       | Time to gemcitabine/MMC event                                      |
| recurrence_event                   | Recurrence event                                                   |
| recurrence_time                    | Time to recurrence                                                 |
| primpath_sq_diff                   | Logical: squamous differentiation (primary pathology)              |
| primpath_sarcomatoid               | Logical: sarcomatoid differentiation                               |
| primpath_neuroendocrine            | Logical: neuroendocrine differentiation                            |
| primpath_micropapilary             | Logical: micropapillary differentiation                            |
| primpath_gland_diff                | Logical: glandular differentiation                                 |
| primpath_clear_cell                | Logical: clear cell differentiation                                |
| primpath_plasmacytoid              | Logical: plasmacytoid differentiation                              |
| primpath_giant_cell                | Logical: giant cell differentiation                                |
| primpath_nested                    | Logical: nested variant differentiation                            |
| primpath_tubular                   | Logical: tubular differentiation                                   |
| sq_metaplasia                      | Logical: squamous metaplasia                                       |
| dna_nanodrop_ng_ul                 | DNA concentration (ng/ul, Nanodrop)                                |
| dna_260_280                        | DNA purity ratio (260/280)                                         |
| dna_260_230                        | DNA purity ratio (260/230)                                         |
| rna_nanodrop_ng_ul                 | RNA concentration (ng/ul, Nanodrop)                                |
| rna_260_280                        | RNA purity ratio (260/280)                                         |
| rna_260_230                        | RNA purity ratio (260/230)                                         |
| rin_value                          | RNA integrity number                                               |
| seq_batch                          | Sequencing batch                                                   |
| seq_facility                       | Sequencing facility                                                |
| seq_instrument                     | Sequencing instrument                                              |
| run_number                         | Sequencing run number                                              |
| flowcell_id                        | Flowcell identifier                                                |
| subtype_5_class                    | Molecular subtype (5-class)                                        |
| subtype_7_class                    | Molecular subtype (7-class)                                        |
| uro_prediction_score               | Urothelial prediction score                                        |
| uroa_prediction_score              | UroA prediction score                                              |
| urob_prediction_score              | UroB prediction score                                              |
| uroc_prediction_score              | UroC prediction score                                              |
| gu_prediction_score                | GU prediction score                                                |
| basq_prediction_score              | BaSq prediction score                                              |
| mes_prediction_score               | Mesenchymal prediction score                                       |
| scne_prediction_score              | Small cell neuroendocrine prediction score                         |
| prediction_delta                   | Difference between top two prediction scores                       |
| proliferation_score                | Proliferation signature score                                      |
| progression_score                  | Progression signature score                                        |
| progression_risk                   | Progression risk (low/high)                                        |
| molecular_grade_who_2022_score     | Molecular grade score (WHO 2022)                                   |
| molecular_grade_who_2022           | Molecular grade (WHO 2022)                                         |
| molecular_grade_who_1999_score     | Molecular grade score (WHO 1999)                                   |
| molecular_grade_who_1999           | Molecular grade (WHO 1999)                                         |
| stromal141_up                      | Stromal signature score                                            |
| immune141_up                       | Immune signature score                                             |
| b_cells                            | B cell signature score                                             |
| b_cells_proportion                 | B cell proportion                                                  |
| t_cells                            | T cell signature score                                             |
| t_cells_proportion                 | T cell proportion                                                  |
| t_cells_cd8                        | CD8+ T cell signature score                                        |
| t_cells_cd8_proportion             | CD8+ T cell proportion                                             |
| nk_cells                           | NK cell signature score                                            |
| nk_cells_proportion                | NK cell proportion                                                 |
| cytotoxicity_score                 | Cytotoxicity signature score                                       |
| cytotoxicity_score_proportion      | Cytotoxicity score proportion                                      |
| neutrophils                        | Neutrophil signature score                                         |
| neutrophils_proportion             | Neutrophil proportion                                              |
| monocytic_lineage                  | Monocytic lineage signature score                                  |
| monocytic_lineage_proportion       | Monocytic lineage proportion                                       |
| macrophages                        | Macrophage signature score                                         |
| macrophages_proportion             | Macrophage proportion                                              |
| m2_macrophage                      | M2 macrophage signature score                                      |
| m2_macrophage_proportion           | M2 macrophage proportion                                           |
| myeloid_dendritic_cells            | Myeloid dendritic cell signature score                             |
| myeloid_dendritic_cells_proportion | Myeloid dendritic cell proportion                                  |
| endothelial_cells                  | Endothelial cell signature score                                   |
| endothelial_cells_proportion       | Endothelial cell proportion                                        |
| fibroblasts                        | Fibroblast signature score                                         |
| fibroblasts_proportion             | Fibroblast proportion                                              |
| smooth_muscle                      | Smooth muscle signature score                                      |
| smooth_muscle_proportion           | Smooth muscle proportion                                           |

## Notes

- Ensure all required data files are placed in the correct directories (`data/`, `data-raw/`).
- For updates, pull the latest changes from the repository and repeat the installation step.

## Support

For questions or issues, open an issue on GitHub or contact the maintainer.
