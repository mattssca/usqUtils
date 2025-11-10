#' Get USQ Metadata with Optional Subtype Predictions
#'
#' Retrieves USQ metadata in various formats with optional filtering and LundTaxR 
#' subtype predictions. This function provides flexible access to the USQ database
#' metadata and associated expression data.
#'
#' @param return_this Character string specifying the return format. Options:
#'   \itemize{
#'     \item "tidy" - Tidy format metadata (default)
#'     \item "raw" - Raw format metadata
#'     \item "pub" - Publication ready with sensitive information removed
#'     \item "change_log" - Returns only the change log
#'     \item "full_meta" - Full metadata object without filters
#'     \item "everything" - Complete bundle with metadata, expression data, and predictions
#'     \item "only_expressions" - Expression data only for selected samples
#'   }
#' @param run_LundTaxR Logical. Whether to run LundTaxR subtype predictions. 
#'   Default is FALSE. Automatically set to TRUE when return_this = "everything".
#' @param category_group Character string specifying sample category group for filtering.
#'   Options: "uc_index_high_quality" (default), "uc_index_low_quality", 
#'   "non_uc_high_quality", "non_uc_low_quality", "recurrence_high_quality", 
#'   "replicate_high_quality", "replicate_low_quality", "none" (no filtering).
#' @param these_sample_ids Character vector of specific sample IDs to include. 
#'   When provided, overrides category_group filtering. Default is NULL.
#' @param gene_id Character string specifying gene identifier format for LundTaxR.
#'   Default is "hgnc_symbol".
#' @param threshold_progression Numeric threshold for progression classification in LundTaxR.
#'   Default is 0.58.
#' @param adjust Logical. Whether to apply adjustment to expression data for LundTaxR.
#'   Default is TRUE.
#' @param adj_factor Numeric adjustment factor for expression data normalization.
#'   Default is 5.1431.
#' @param impute Logical. Whether to perform imputation for missing values in LundTaxR.
#'   Default is TRUE.
#' @param impute_reject Numeric threshold for imputation rejection in LundTaxR.
#'   Default is 0.67.
#' @param impute_kNN Integer specifying number of k-nearest neighbors for imputation.
#'   Default is 5.
#' @param verbose Logical. Whether to print processing messages and summaries.
#'   Default is TRUE.
#'
#' @return Depends on return_this parameter:
#'   \itemize{
#'     \item "tidy" - Data frame with tidy metadata, optionally with LundTaxR predictions
#'     \item "raw" - Data frame with raw metadata format, optionally with predictions
#'     \item "change_log" - Change log object
#'     \item "full_meta" - Complete metadata object (list)
#'     \item "everything" - List containing metadata, expression data, and all predictions
#'     \item "only_expressions" - Expression matrix for selected samples
#'   }
#'
#' @details
#' This function provides comprehensive access to USQ metadata with several key features:
#' \itemize{
#'   \item Flexible filtering by sample categories or specific sample IDs
#'   \item Optional integration with LundTaxR for molecular subtype predictions
#'   \item Multiple return formats to suit different analysis needs
#'   \item Automatic parameter validation and informative error messages
#'   \item Detailed logging of filtering effects and subtype distributions
#' }
#' 
#' When run_LundTaxR = TRUE, the function adds subtype predictions including:
#' 5-class and 7-class predictions, prediction scores for each subtype, and 
#' signature scores from the LundTaxR classifier.
#' 
#' Sample category groups represent different quality and type classifications:
#' UC (urothelial carcinoma) index samples with high/low quality, non-UC samples,
#' recurrence samples, and replicate samples.
#'
#' @seealso \code{\link[LundTaxR]{classify_samples}} for LundTaxR subtype classification
#'
#' @export
#' 
#' @import LundTaxR dplyr tibble stringr tidyr
#' 
get_usq_metadata = function(return_this = "tidy",
                            run_LundTaxR = FALSE,
                            category_group = "uc_index_high_quality",
                            these_sample_ids = NULL,
                            gene_id = "hgnc_symbol",
                            verbose = TRUE,
                            threshold_progression = 0.58, #LundTaxR parameters
                            adjust = TRUE, #LundTaxR parameters
                            adj_factor = 5.1431, #LundTaxR parameters
                            impute = TRUE, #LundTaxR parameters
                            impute_reject = 0.67, #LundTaxR parameters
                            impute_kNN = 5){  #LundTaxR parameters
  
  if(!return_this %in% c("only_expressions", "change_log")){
    #print any warnings
    message("\n############################################")
    message("################## WARNINGS ################")
    message("############################################\n")
    
    if(!return_this %in% c("tidy", "raw", "pub")){
      
      #handle nonsense parameter combination
      if(return_this == "everything"){
        if(!run_LundTaxR){
          message("You have requested 'everything' back, but run_LundTaxR is set to FALSE")
          message("The function will overwrite this to TRUE to honor the requested return type...")
          run_LundTaxR = TRUE
        }
      }else if(return_this == "full_meta"){
        message("Returning full metadata data object - No filters and sample subset applied, prediction calling performed...")
        category_group = "none"
      }
    }else{
      if(!is.null(these_sample_ids)){
        message("Sample IDs are provided, the return will be restricted to these samples, regardless of any category_group filters...")
        category_group = "none"
      } 
    }
    
    #print the version
    if(verbose){
      message("\n############################################")
      message("############## METADATA VERSION ############")
      message("############################################\n")
      message(paste0("Metadata Version: ", usq_metadata$metadata_version))
    }
  }else{
    
    if(return_this == "change_log"){
      category_group = "none"
      
    }
    
    if(!is.null(these_sample_ids)){
      message("Sample IDs are provided, the return will be restricted to these samples, regardless of any category_group filters...")
      category_group = "none"
    } 
  }
  
  #check parameters
  acceptable_formats = c("tidy", "raw", "pub", "change_log", "full_meta", "everything", "only_expressions")

  if(!return_this %in% acceptable_formats){
    stop(paste0(
      "return_this must be one of the following: ",
      paste(acceptable_formats, collapse = ", ")
    ))
  }

  category_groups = c("non_uc_high_quality", "non_uc_low_quality",
                      "recurrence_high_quality", "replicate_high_quality",
                      "replicate_low_quality", "uc_index_high_quality", "uc_index_low_quality", "none")

  if(!category_group %in% category_groups){
    stop(paste0(
      "sample_category_group must be one of the following: ",
      paste(category_groups, collapse = ", ")
    ))
  }

  #conversion map for raw data
  raw_category_map = c(
    "non_uc_high_quality" = "Non_UC_High_Quality",
    "non_uc_low_quality" = "Non_UC_Low_Quality",
    "recurrence_high_quality" = "Recurrence_High_Quality",
    "replicate_high_quality" = "Replicate_High_Quality",
    "replicate_low_quality" = "Replicate_Low_Quality",
    "uc_index_high_quality" = "UC_index_High_Quality",
    "uc_index_low_quality" = "Uc_index_Low_Quality",
    "none" = "none"
  )
  
  #get the raw version in any case
  raw_group = raw_category_map[[category_group]]

  if(verbose){
    message("\n############################################")
    message("################# SUMMARY ##################")
    message("############################################\n")
    message(paste0("Return Format: ", return_this))
    message(paste0("Sample Category Group: ", category_group))
  }

  #deal with selected return
  if(return_this == "raw"){
    
    #get total n samples
    total_samples = nrow(usq_metadata$usq_metadata_raw)
    
    if(!is.null(these_sample_ids)){
      this_metadata = usq_metadata$usq_metadata_raw %>% 
        filter(XRNA_cohort_name %in% these_sample_ids)
    }else{
      if(category_group == "none"){
        this_metadata = usq_metadata$usq_metadata_raw
      }else{
        #subset metadata
        this_metadata = usq_metadata$usq_metadata_raw %>%
          filter(CategoryGroup == raw_group) 
      }
    }

    #get sample IDs for the subset
    sample_ids = this_metadata$XRNA_cohort_name

  }else if(return_this == "change_log"){
    message("Returning change log...")
    change_log = usq_metadata$usq_change_log
    return(change_log)
  }else if(return_this == "full_meta"){
    message("Returning full metadata...")
    return(usq_metadata)
  }else{
    if(return_this %in% c("tidy", "everything")){
      
      #get total n samples
      total_samples = nrow(usq_metadata$usq_metadata_tidy)
      
      #if sample IDs are provided, subset the data to these samples and disregard any category group filters
      if(!is.null(these_sample_ids)){
        this_metadata = usq_metadata$usq_metadata_tidy %>% 
          filter(sample_id %in% these_sample_ids)
      }else{
        if(category_group == "none"){
          this_metadata = usq_metadata$usq_metadata_tidy
        }else{
          #subset metadata
          this_metadata = usq_metadata$usq_metadata_tidy %>%
            filter(sample_category_group == category_group)
        } 
      }
      
    }else if(return_this %in% c("pub", "only_expressions")){
      
      #get total n samples
      total_samples = nrow(usq_metadata$usq_metadata_pub)
      
      #if sample IDs are provided, subset the data to these samples and disregard any category group filters
      if(!is.null(these_sample_ids)){
        this_metadata = usq_metadata$usq_metadata_pub %>% 
          filter(sample_id %in% these_sample_ids)
      }else{
        if(category_group == "none"){
          this_metadata = usq_metadata$usq_metadata_pub
        }else{
          #subset metadata
          this_metadata = usq_metadata$usq_metadata_pub %>%
            filter(sample_category_group == category_group)
        } 
      }
      
    }

    #get sample IDs for the subset
    sample_ids = this_metadata$sample_id
  }

  #calculate filtering effect
  n_kept = nrow(this_metadata)
  n_removed = total_samples - n_kept

  if(verbose){
    message(paste0(n_kept, " Samples kept in the metadata"))
    message(paste0(n_removed, " Samples removed in the filtering process"))
  }

  ##################################################################################################
  #optionally, return only expression data
  if(return_this == "only_expressions"){
    #get expressions
    if(category_group == "uc_index_high_quality"){
      usq_expressions = get_usq_expression(this_sample_set = "USQ-HQ", 
                                           gene_symbol = gene_id)
    }else{
      usq_expressions = get_usq_expression(this_sample_set = "USQ-ALL", 
                                           gene_symbol = gene_id)
    }
    
    #susbet expression matrix to the selected samples
    usq_expressions = usq_expressions %>%
      dplyr::select(any_of(sample_ids))
    
    #check if the samples are matching
    expression_samples = colnames(usq_expressions)
    
    #find samples in metadata but not in expression data
    missing_in_expression = setdiff(sample_ids, expression_samples)
    missing_in_metadata = setdiff(expression_samples, sample_ids)
    
    #notify user about potential discrepancies
    if(length(missing_in_expression) > 0) {
      cat("Samples in metadata but not in expression data:\n")
      print(missing_in_expression)
    }
    
    if(length(missing_in_metadata) > 0) {
      cat("Samples in expression data but not in metadata:\n")
      print(missing_in_metadata)
    }
    
    return(usq_expressions)
  }


  if(run_LundTaxR){
    if(category_group == "uc_index_high_quality"){
      usq_expressions = get_usq_expression(this_sample_set = "USQ-HQ", 
                                           gene_symbol = gene_id)
    }else{
      usq_expressions = get_usq_expression(this_sample_set = "USQ-ALL", 
                                           gene_symbol = gene_id)
    }
    
    if(verbose){
      message("\n############################################")
      message("########### PREDICTING SUBTYPES ############")
      message("############################################\n")
    }
    
    #susbet expression matrix to the selected samples
    usq_expressions = usq_expressions %>%
      dplyr::select(any_of(sample_ids))
    
    #check if the samples are matching
    expression_samples = colnames(usq_expressions)
    
    #find samples in metadata but not in expression data
    missing_in_expression = setdiff(sample_ids, expression_samples)
    missing_in_metadata = setdiff(expression_samples, sample_ids)
    
    #notify user about potential discrepancies
    if(length(missing_in_expression) > 0) {
      cat("Samples in metadata but not in expression data:\n")
      print(missing_in_expression)
    }
    
    if(length(missing_in_metadata) > 0) {
      cat("Samples in expression data but not in metadata:\n")
      print(missing_in_metadata)
    }

    #run LundTaxR
    predicted = LundTaxR::classify_samples(this_data = usq_expressions,
                                           log_transform = TRUE, #the incoming data is always non-log transformed
                                           adjust = adjust,
                                           impute = impute,
                                           include_data = FALSE,
                                           gene_id = gene_id,
                                           threshold_progression = threshold_progression,
                                           adj_factor = adj_factor,
                                           impute_reject = impute_reject,
                                           impute_kNN = impute_kNN,
                                           include_pred_scores = TRUE,
                                           verbose = FALSE)

    #wrangle prediction return
    #5 class
    these_subtypes_5 = as.data.frame(predicted$predictions_5classes) %>%
      rownames_to_column("sample_id") %>%
      rename(subtype_5_class = 2) %>%
      mutate(subtype_5_class = factor(subtype_5_class, 
                                      levels = c("Uro", "GU", "BaSq", "Mes", "ScNE")))

    #7 class
    these_subtypes_7 = as.data.frame(predicted$predictions_7classes) %>%
      rownames_to_column("sample_id") %>%
      rename(subtype_7_class = 2) %>%
      mutate(subtype_7_class = factor(subtype_7_class, 
                                      levels = c("UroA", "UroB", "UroC", "GU", "BaSq", "Mes", "ScNE")))

    #subtype scores
    subtype_scores = as.data.frame(predicted$subtype_scores) %>%
      rownames_to_column("sample_id") %>%
      rename(uro_prediction_score = Uro, uroa_prediction_score = UroA,
             urob_prediction_score = UroB, uroc_prediction_score = UroC,
             gu_prediction_score = GU, basq_prediction_score = BaSq,
             mes_prediction_score = Mes, scne_prediction_score = ScNE)

    #signature scores
    signature_scores = predicted$scores %>%
      rownames_to_column("sample_id") %>%
      mutate(progression_risk = factor(progression_risk, levels = c("LR", "HR"))) %>% 
      mutate(molecular_grade_who_2022 = factor(molecular_grade_who_2022, levels = c("LG", "HG"))) %>% 
      mutate(molecular_grade_who_1999 = factor(molecular_grade_who_1999, levels = c("G1_G2", "G3"))) 
      
    #combine the return
    lundtax_return = these_subtypes_5 %>%
      left_join(these_subtypes_7, by = "sample_id") %>%
      left_join(subtype_scores, by = "sample_id") %>%
      left_join(signature_scores, by = "sample_id")

    if(verbose){
      message("Subtype predictions done!")
      subtype_counts <- table(predicted$predictions_5classes)
      subtype_order <- c("Uro", "GU", "BaSq", "Mes", "ScNE")
      cat("\nSubtype distribution (n):\n")
      for (subtype in subtype_order) {
        count <- if(subtype %in% names(subtype_counts)) subtype_counts[[subtype]] else 0
        if(count > 0) {  # Only show subtypes that are present
          cat(sprintf("  %-6s: %d\n", subtype, count))
        }
      }
      cat("\n")
    }
    
    if(return_this == "everything"){
      
      #compile parameters used into a list
      parameters_used <- list(
        return_this = return_this,
        run_LundTaxR = run_LundTaxR,
        category_group = category_group,
        these_sample_ids = these_sample_ids,
        gene_id = gene_id,
        verbose = verbose,
        threshold_progression = threshold_progression,
        adjust = adjust,
        adj_factor = adj_factor,
        impute = impute,
        impute_reject = impute_reject,
        impute_kNN = impute_kNN
      )
      
      this_data = list(usq_metadata = this_metadata,
                       usq_expression = usq_expressions,
                       prediction_5_class = these_subtypes_5,
                       prediction_7_class = these_subtypes_7,
                       subtype_scores = subtype_scores,
                       signature_scores = signature_scores,
                       parameters_used = parameters_used
      )
      return(this_data)
    }

    if(return_this == "tidy"){
      this_metadata = this_metadata %>%
        left_join(lundtax_return, by = "sample_id")
    }else if(return_this == "raw"){
      lundtax_return = lundtax_return %>%
        rename(XRNA_cohort_name = 1)

      this_metadata = this_metadata %>%
        left_join(lundtax_return, by = "XRNA_cohort_name")
    }
  }

  #return
  if(verbose){
    message("\n############################################")
    message("############# PROCESS COMPLETE! ############")
    message("############################################\n")
  }
  return(this_metadata)
}

#' @rdname get_usq_metadata
#' @export
get_usq_data <- get_usq_metadata
