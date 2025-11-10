#' USQ Expression Data - 533 High Quality Samples
#'
#' A processed gene expression matrix containing 16,818 genes across 533 high-quality 
#' urothelial carcinoma samples from the UROSCANSEQ Cohort 1 Version 2 dataset.
#'
#' @format An expression matrix with genes in rows and samples in columns:
#' \describe{
#'   \item{Rows}{16,818 protein-coding genes (Ensembl gene IDs)}
#'   \item{Columns}{533 high-quality UC index samples}
#'   \item{Values}{geTMM-normalized expression values (not log-transformed)}
#' }
#'
#' @details
#' ## Processing Pipeline
#' 
#' This dataset was generated through a comprehensive RNA-sequencing preprocessing 
#' pipeline designed to produce high-quality expression measurements suitable for 
#' both intrasample and intersample expression analysis.
#' 
#' ### Transcript Filtration
#' Starting from Gencode v44 annotations, transcripts were filtered to retain:
#' \itemize{
#'   \item Protein-coding, TR_C_gene, and IG_C_gene transcripts with HGNC symbols
#'   \item Transcripts with TSL 1-3, or TSL 4-5 with MANE tag
#'   \item Single-exon genes, TCR, and HLA genes (TSL:NA)
#'   \item Transcripts without low-quality tags (e.g., fragmented_locus, sequence_error)
#' }
#' 
#' Excluded were histone genes (H1-, H2A, H2B, H3, H4) and mitochondrial genes (MT-).
#' This yielded 44,446 transcripts mapping to 18,833 genes.
#' 
#' ### Count Generation and Normalization
#' \enumerate{
#'   \item STAR-Salmon quant.sf files imported via tximport
#'   \item Used countsFromAbundance="lengthScaledTPM" for length bias adjustment
#'   \item Filtered lowly expressed genes (n=2,015 removed) using edgeR::filterByExpr
#'   \item Applied ComBat-Seq to correct for sequencing center batch effects (CMD vs CTG)
#'   \item Length-normalized using geometric cohort mean of gene lengths (RPK)
#'   \item TMM normalization applied to generate final geTMM values
#' }
#' 
#' ### Data Characteristics
#' - **Not log-transformed**: Use `log2(usq_expr_set_533 + 1)` for log-scale analysis
#' - **Batch-corrected**: ComBat-Seq adjusted for CMD/CTG differences
#' - **High quality only**: Limited to 533 HQ UC index samples
#' - **Stable core genes**: 16,818 reliably measured protein-coding genes
#' 
#' ### Quality Validation
#' Classification on this processed data showed 98.3% agreement (651/662 samples) 
#' with previous TPM-based classifications at the 5-class level. The 11 discordant 
#' cases had low prediction confidence in both datasets.
#'
#' @section Usage:
#' ```
#' # Load the data
#' data(usq_expr_set_533)
#' 
#' # Log-transform for visualization or analysis
#' log_expr <- log2(usq_expr_set_533 + 1)
#' 
#' # Get matching metadata
#' metadata <- get_usq_metadata(category_group = "uc_index_high_quality")
#' ```
#'
#' @seealso 
#' \code{\link{usq_expr_set_662}} for the extended dataset including low-quality samples
#' \code{\link{expr_annotations}} for gene annotation details
#' \code{\link{get_usq_metadata}} for sample metadata retrieval
#'
#' @source UROSCANSEQ Cohort 1 Version 2
#' @references Gencode v44 annotations
#' 
"usq_expr_set_533"

#' USQ Expression Data - 662 Complete Sample Set
#'
#' A processed gene expression matrix containing 16,818 genes across all 662 
#' urothelial carcinoma samples (533 high-quality + 129 low-quality) from the 
#' UROSCANSEQ Cohort 1 Version 2 dataset.
#'
#' @format An expression matrix with genes in rows and samples in columns:
#' \describe{
#'   \item{Rows}{16,818 protein-coding genes (Ensembl gene IDs)}
#'   \item{Columns}{662 UC index samples (533 HQ + 129 LQ)}
#'   \item{Values}{geTMM-normalized expression values (not log-transformed)}
#' }
#'
#' @details
#' ## Processing Pipeline
#' 
#' This dataset was generated through the same comprehensive RNA-sequencing 
#' preprocessing pipeline as \code{\link{usq_expr_set_533}}, but includes both 
#' high-quality and low-quality samples.
#' 
#' ### Transcript Filtration
#' Starting from Gencode v44 annotations, transcripts were filtered to retain:
#' \itemize{
#'   \item Protein-coding, TR_C_gene, and IG_C_gene transcripts with HGNC symbols
#'   \item Transcripts with TSL 1-3, or TSL 4-5 with MANE tag
#'   \item Single-exon genes, TCR, and HLA genes (TSL:NA)
#'   \item Transcripts without low-quality tags (e.g., fragmented_locus, sequence_error)
#' }
#' 
#' Excluded were histone genes (H1-, H2A, H2B, H3, H4) and mitochondrial genes (MT-).
#' This yielded 44,446 transcripts mapping to 18,833 genes.
#' 
#' ### Count Generation and Normalization
#' \enumerate{
#'   \item STAR-Salmon quant.sf files imported via tximport
#'   \item Used countsFromAbundance="lengthScaledTPM" for length bias adjustment
#'   \item Filtered lowly expressed genes (n=2,015 removed) using edgeR::filterByExpr
#'   \item Applied ComBat-Seq to correct for sequencing center batch effects (CMD vs CTG)
#'   \item Length-normalized using geometric cohort mean of gene lengths (RPK)
#'   \item TMM normalization applied to generate final geTMM values
#' }
#' 
#' ### Data Characteristics
#' - **Not log-transformed**: Use `log2(usq_expr_set_662 + 1)` for log-scale analysis
#' - **Batch-corrected**: ComBat-Seq adjusted for CMD/CTG differences
#' - **Complete cohort**: Includes all 662 UC index samples (HQ + LQ)
#' - **Stable core genes**: 16,818 reliably measured protein-coding genes
#' - **Validated preprocessing**: HQ+LQ preprocessed samples show excellent 
#'   correlation with HQ-only preprocessed samples and TPM data
#' 
#' ### Quality Validation
#' The inclusion of low-quality samples did not strongly affect preprocessing. 
#' Classification on this data showed 98.3% agreement (651/662 samples) with 
#' previous TPM-based classifications at the 5-class level. The 11 discordant 
#' cases had low prediction confidence in both datasets.
#' 
#' ### HQ vs LQ Considerations
#' Low-quality samples may exhibit:
#' \itemize{
#'   \item RNA degradation effects (reduced RIN scores)
#'   \item Uneven transcript coverage (5' bias)
#'   \item Altered fragment length distributions
#'   \item Reduced library complexity
#' }
#' 
#' While ComBat-Seq batch correction was effective, users may choose to filter or 
#' downweight LQ samples in certain analyses. Use \code{get_usq_metadata()} with 
#' \code{category_group = "uc_index_high_quality"} to work exclusively with HQ samples.
#'
#' @section Usage:
#' ```
#' # Load the data
#' data(usq_expr_set_662)
#' 
#' # Log-transform for visualization or analysis
#' log_expr <- log2(usq_expr_set_662 + 1)
#' 
#' # Get all metadata
#' metadata_all <- get_usq_metadata(category_group = "none")
#' 
#' # Get only HQ metadata
#' metadata_hq <- get_usq_metadata(category_group = "uc_index_high_quality")
#' 
#' # Get only LQ metadata
#' metadata_lq <- get_usq_metadata(category_group = "uc_index_low_quality")
#' ```
#'
#' @seealso 
#' \code{\link{usq_expr_set_533}} for the high-quality only dataset
#' \code{\link{expr_annotations}} for gene annotation details
#' \code{\link{get_usq_metadata}} for sample metadata retrieval
#'
#' @source UROSCANSEQ Cohort 1 Version 2
#' @references Gencode v44 annotations
#' 
"usq_expr_set_662"

#' Gene Expression Annotations
#'
#' Comprehensive gene annotation data for the 16,818 genes included in the USQ 
#' expression datasets, sourced from Ensembl 110 via biomaRt.
#'
#' @format A data frame with 16,818 rows (genes) and 10 columns:
#' \describe{
#'   \item{gene_id}{Ensembl gene ID (character)}
#'   \item{included_transcripts}{Pipe-separated list of Ensembl transcript IDs 
#'     that passed quality filters (character)}
#'   \item{gene_name}{HGNC gene symbol (character)}
#'   \item{chr}{Chromosome (character, e.g., "chr1", "chrX")}
#'   \item{median_pos}{Median genomic position across all transcripts (numeric)}
#'   \item{start_position}{Transcript start position in base pairs (integer)}
#'   \item{end_position}{Transcript end position in base pairs (integer)}
#'   \item{band}{Cytogenetic band location (character, e.g., "p36.33")}
#'   \item{chromosome_band}{Combined chromosome and band (character, e.g., "chr1 p36.33")}
#'   \item{Retain}{Logical flag indicating gene passed all quality filters (logical)}
#' }
#'
#' @details
#' ## Annotation Pipeline
#' 
#' This annotation file was created during the transcript filtration process from 
#' Gencode v44 annotations and enhanced with genomic position data from Ensembl 110.
#' 
#' ### Transcript Selection Criteria
#' Transcripts were retained based on:
#' \itemize{
#'   \item **Transcript type**: protein_coding, TR_C_gene, or IG_C_gene
#'   \item **Gene symbol**: Must have HGNC symbol
#'   \item **Support level**: TSL 1-3, or TSL 4-5 with MANE tag
#'   \item **Special cases**: Single-exon genes, TCR, HLA genes (TSL:NA with TSL:NA tag)
#'   \item **Quality**: Exclude transcripts with low-quality tags
#' }
#' 
#' Low-quality tags excluded:
#' - cds_start_NF, cds_end_NF
#' - fragmented_locus
#' - inferred_exon_combination
#' - low_sequence_quality
#' - non_canonical_genome_sequence_error
#' - non_canonical_TEC
#' - not_best_in_genome_evidence
#' - not_organism_supported
#' - reference_genome_error
#' - sequence_error
#' 
#' Transcripts with MANE tag were retained regardless of quality flags.
#' 
#' ### Excluded Genes
#' - Histone genes: H1-, H2A, H2B, H3, H4
#' - Mitochondrial genes: MT-
#' - One duplicate PINX1 transcript (ENST00000554914.1)
#' 
#' ### Gene Mapping
#' - **Total transcripts**: 44,446 high-quality transcripts
#' - **Total genes**: 18,833 Ensembl gene IDs
#' - **HGNC symbols**: 18,818 unique symbols
#'   - 15 X/Y PAR genes have unique Ensembl IDs but shared HGNC symbols
#' 
#' ### Genomic Positions
#' Genomic coordinates were retrieved from Ensembl 110 via biomaRt and include:
#' - Chromosome location
#' - Start/end positions for transcript boundaries
#' - Median position across all included transcripts
#' - Cytogenetic band annotations
#'
#' @section Usage:
#' ```
#' # Load annotations
#' data(expr_annotations)
#' 
#' # Get genes on specific chromosome
#' chr1_genes <- expr_annotations[expr_annotations$chr == "chr1", ]
#' 
#' # Map Ensembl IDs to gene symbols
#' gene_map <- setNames(expr_annotations$gene_name, expr_annotations$gene_id)
#' 
#' # Find genes in specific cytogenetic band
#' p_arm_genes <- expr_annotations[grepl("^p", expr_annotations$band), ]
#' 
#' # Get transcript information
#' multi_transcript <- expr_annotations[grepl("\\|", expr_annotations$included_transcripts), ]
#' ```
#'
#' @seealso 
#' \code{\link{usq_expr_set_533}} for expression data using these annotations
#' \code{\link{usq_expr_set_662}} for complete expression dataset
#'
#' @source 
#' - Gencode v44 annotations (transcript filtering)
#' - Ensembl 110 via biomaRt (genomic positions)
#' 
"expr_annotations"

#' USQ Study Metadata
#'
#' Comprehensive metadata for the UROSCANSEQ Cohort 1 Version 2 dataset, including 
#' clinical, pathological, and technical information for 754 bladder cancer samples.
#'
#' @format A list containing multiple metadata objects and documentation:
#' \describe{
#'   \item{metadata_version}{Version identifier (character)}
#'   \item{usq_metadata_tidy}{Tidy format metadata with standardized variable names (data frame)}
#'   \item{usq_metadata_raw}{Raw format metadata preserving original variable names (data frame)}
#'   \item{usq_metadata_pub}{Publication-ready metadata with sensitive information removed (data frame)}
#'   \item{usq_change_log}{Documentation of changes and data provenance (object)}
#' }
#'
#' @details
#' ## Sample Composition
#' 
#' The complete dataset includes 754 samples across multiple categories:
#' 
#' ### UC Index Samples (662 total)
#' - **High Quality (533)**: Primary analysis cohort with high RNA integrity
#' - **Low Quality (129)**: Samples with RNA degradation but still processable
#' 
#' ### Additional Sample Types
#' - **Non-UC samples**: Non-urothelial carcinoma controls
#' - **Recurrence samples**: Follow-up samples from patients with recurrent disease
#' - **Replicate samples**: Technical/biological replicates for quality control
#' 
#' Each category has high-quality and low-quality subsets based on RNA integrity 
#' and sequencing metrics.
#' 
#' ## Metadata Formats
#' 
#' ### Tidy Format (`usq_metadata_tidy`)
#' Standardized variable names following tidy data principles:
#' - snake_case variable naming
#' - Consistent data types
#' - Explicit factor levels
#' - Suitable for tidyverse workflows
#' 
#' ### Raw Format (`usq_metadata_raw`)
#' Preserves original variable names and structure:
#' - Original column names (e.g., "XRNA_cohort_name")
#' - Direct mapping to source data
#' - Useful for legacy code compatibility
#' 
#' ### Publication Format (`usq_metadata_pub`)
#' De-identified version for sharing:
#' - Sensitive patient information removed
#' - Geographic identifiers masked
#' - Dates generalized to protect privacy
#' - Suitable for public data sharing
#' 
#' ## Sample Categories
#' 
#' The `sample_category_group` variable classifies samples:
#' - `"uc_index_high_quality"`: Primary HQ UC samples (n=533)
#' - `"uc_index_low_quality"`: Primary LQ UC samples (n=129)
#' - `"non_uc_high_quality"`: HQ non-UC controls
#' - `"non_uc_low_quality"`: LQ non-UC controls
#' - `"recurrence_high_quality"`: HQ recurrence samples
#' - `"replicate_high_quality"`: HQ technical replicates
#' - `"replicate_low_quality"`: LQ technical replicates
#' 
#' ## Quality Metrics
#' 
#' Sample quality assessment is based on:
#' - RNA Integrity Number (RIN)
#' - Sequencing depth and coverage
#' - 5' to 3' bias measurements
#' - Fragment length distributions
#' - Library complexity metrics
#'
#' @section Usage:
#' Access metadata using the \code{\link{get_usq_metadata}} function:
#' 
#' ```
#' # Get high-quality UC samples in tidy format
#' hq_metadata <- get_usq_metadata(
#'   return_this = "tidy",
#'   category_group = "uc_index_high_quality"
#' )
#' 
#' # Get raw format with all samples
#' all_metadata <- get_usq_metadata(
#'   return_this = "raw",
#'   category_group = "none"
#' )
#' 
#' # Get specific samples
#' selected_metadata <- get_usq_metadata(
#'   these_sample_ids = c("sample1", "sample2", "sample3")
#' )
#' 
#' # Get full metadata object
#' full_meta <- get_usq_metadata(return_this = "full_meta")
#' 
#' # Check version and change log
#' full_meta$metadata_version
#' changelog <- get_usq_metadata(return_this = "change_log")
#' ```
#'
#' @seealso 
#' \code{\link{get_usq_metadata}} for metadata retrieval with filtering options
#' \code{\link{usq_expr_set_533}} for matched expression data (HQ samples)
#' \code{\link{usq_expr_set_662}} for matched expression data (all UC samples)
#'
#' @source UROSCANSEQ Cohort 1 Version 2
#' 
"usq_metadata"