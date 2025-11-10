#' Get USQ Expression Data
#'
#' Retrieves processed gene expression data from the UROSCANSEQ cohort with options
#' for dataset selection and gene identifier format.
#'
#' @param this_sample_set Character string specifying which dataset to load. Options:
#'   \itemize{
#'     \item "USQ-HQ" - High-quality samples only (n=533, default)
#'     \item "USQ-ALL" - Complete dataset including low-quality samples (n=662)
#'   }
#' @param gene_symbol Character string specifying gene identifier format. Options:
#'   \itemize{
#'     \item "hgnc" - HGNC gene symbols (default, n=16,805 genes)
#'     \item "ensembl" - Ensembl gene IDs (n=16,818 genes)
#'   }
#' @param verbose Logical. Whether to print dataset information and summary statistics.
#'   Default is TRUE.
#'
#' @return A numeric matrix with genes in rows and samples in columns containing
#'   geTMM-normalized expression values (NOT log-transformed).
#'
#' @details
#' ## Expression Data Format
#' 
#' The returned expression data is:
#' \itemize{
#'   \item **geTMM normalized**: Geometric mean TMM normalization
#'   \item **ComBat-Seq corrected**: Batch effects adjusted for sequencing center
#'   \item **NOT log-transformed**: Use \code{log2(expr + 1)} for log-scale analysis
#'   \item **Ready for analysis**: Suitable for limma, LundTaxR, and other tools
#' }
#' 
#' ## Dataset Options
#' 
#' ### USQ-HQ (n=533)
#' High-quality urothelial carcinoma samples with:
#' - High RNA integrity (RIN scores)
#' - Consistent library quality metrics
#' - Recommended for primary analyses
#' 
#' ### USQ-ALL (n=662)
#' Complete UC index cohort including:
#' - All 533 high-quality samples
#' - Additional 129 low-quality samples
#' - Useful for sensitivity analyses and maximizing sample size
#' 
#' ## Gene Identifier Formats
#' 
#' ### HGNC Symbols (n=16,805)
#' - Human-readable gene names (e.g., "TP53", "EGFR")
#' - 13 fewer genes than Ensembl version
#' - X/Y PAR genes averaged (same symbol, different Ensembl IDs)
#' - Recommended for visualization and interpretation
#' 
#' ### Ensembl IDs (n=16,818)
#' - Unique identifiers (e.g., "ENSG00000141510")
#' - Includes separate entries for X/Y PAR genes
#' - Recommended for maximum gene resolution
#' - Use \code{\link{expr_annotations}} to map to gene symbols
#' 
#' ## Data Processing Pipeline
#' 
#' Expression data was generated through:
#' \enumerate{
#'   \item Transcript filtering from Gencode v44 (44,446 transcripts → 18,833 genes)
#'   \item STAR-Salmon quantification with countsFromAbundance="lengthScaledTPM"
#'   \item Filtering of lowly expressed genes (2,015 genes removed)
#'   \item ComBat-Seq batch correction for sequencing center effects
#'   \item Length normalization (geometric mean of gene lengths)
#'   \item TMM normalization to produce final geTMM values
#' }
#'
#' @section Important Notes:
#' \itemize{
#'   \item **Not log-transformed**: Apply \code{log2(x + 1)} transformation if needed
#'   \item **Gene count difference**: HGNC has 13 fewer genes due to X/Y PAR averaging
#'   \item **Matching metadata**: Use \code{\link{get_usq_metadata}} to retrieve sample information
#'   \item **Quality differences**: LQ samples in USQ-ALL may have RNA degradation effects
#' }
#'
#' @examples
#' \dontrun{
#' #load high-quality samples with HGNC symbols (default)
#' expr_hq <- get_usq_expression(this_sample_set = "USQ-HQ", gene_symbol = "hgnc")
#' 
#' #load complete dataset with Ensembl IDs
#' expr_all <- get_usq_expression(this_sample_set = "USQ-ALL", gene_symbol = "ensembl")
#' 
#' #log-transform for visualization
#' expr_log <- log2(expr_hq + 1)
#' }
#'
#' @export
get_usq_expression = function(this_sample_set = "USQ-HQ",
                              gene_symbol = "hgnc_symbol",
                              verbose = TRUE){
  
  #print expression information
  if(verbose) {
    message("\n############################################")
    message("######### EXPRESSION DATA SUMMARY ##########")
    message("############################################\n")
    message("geTMM (geometric mean TMM) normalized")
    message("Data is not log transformed!")
    message("Based on Gencode v44 annotations")
    message("UROSCANSEQ Cohort 1 Version 2\n")
  }
  
  #check parameters
  acceptable_sample_sets = c("USQ-HQ", "USQ-ALL")
  if(!this_sample_set %in% acceptable_sample_sets){
    stop(paste0(
      "this_sample_set must be one of the following: ",
      paste(acceptable_sample_sets, collapse = ", ")
    ))
  }
  
  acceptable_gene_symbols = c("hgnc_symbol", "ensembl_gene_id.")
  if(!gene_symbol %in% acceptable_gene_symbols){
    stop(paste0(
      "gene_symbol must be one of the following: ",
      paste(acceptable_gene_symbols, collapse = ", ")
    ))
  }
  
  
  #load the requested expression data
  if(this_sample_set == "USQ-HQ") {
    expr_data <- usq_expr_set_533
    
    if(gene_symbol == "hgnc_symbol") {
      expr_data <- expr_data$usq_expr_set_533_hgnc
      if(verbose) message("HGNC symbols selected")
    } else {
      expr_data <- expr_data$usq_expr_set_533_ensembl
      if(verbose) message("ENSEMBL IDs selected")
    }
    
    if(verbose) message("Loading USQ-HQ dataset (n=533 high-quality samples)")
    
  } else if (this_sample_set == "USQ-ALL") {
    expr_data <- usq_expr_set_662
    
    if(gene_symbol == "hgnc_symbol") {
      expr_data <- expr_data$usq_expr_set_662_hgnc
      if(verbose) message("HGNC symbols selected")
    } else {
      expr_data <- expr_data$usq_expr_set_662_ensembl
      if(verbose) message("ENSEMBL IDs selected")
    }

    if(verbose) message("Loading USQ-ALL dataset (n=662 all UC samples, HQ + LQ)")
  }
  
  #subset to selected gene symbol
  
  #print sample/gene summary
  if(verbose) {
    n_genes = nrow(expr_data)
    n_samples = ncol(expr_data)
    
    message(paste("Number of samples:", n_samples))
    message(paste("Number of genes:", n_genes))
    cat("\n")
  }
  
  return(expr_data)
}
