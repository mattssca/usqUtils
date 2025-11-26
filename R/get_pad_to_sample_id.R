#' Get Sample IDs from PAD IDs in Metadata
#'
#' This function returns the sample IDs corresponding to provided PAD IDs from a metadata data frame.
#' It filters for unique urothelial carcinoma (UC) samples of high or low quality.
#'
#' @param these_pad_ids Character vector of PAD IDs to match.
#' @param this_metadata Data frame containing metadata with columns \code{sample_id}, \code{tma_pad_id}, and \code{sample_category_group}.
#'
#' @return Character vector of sample IDs matching the requested PAD IDs and quality criteria.
#'
#' @examples
#' #get metadata
#' test_meta = usqUtils::get_usq_metadata(return_this = "full_meta")
#' 
#' #return sample IDs for the provided PAD IDs
#' get_pad_to_sample_id(these_pad_ids = c("PH_4222_20", "PM_7813_20"),
#'                      this_metadata = test_meta$usq_metadata_tidy)
#' 
#' @import dplyr
#'
#' @export
#' 
get_pad_to_sample_id = function(these_pad_ids = NULL,
                                this_metadata = NULL,
                                return_all = FALSE){
  
  #checks
  if(is.null(these_pad_ids)){
    stop("No sample IDs were provided...")
  }
  
  if(is.null(this_metadata)){
    stop("No incoming metadata provided, not sure what to convert...")
  }
  
  #subset metadata to required information
  meta_sub = this_metadata %>% 
    filter(tma_pad_id %in% these_pad_ids) %>% 
    select(sample_id, tma_pad_id, sample_category_group)
  
  #get unique sample IDs from the requested PADs
  n_samples = length(meta_sub$sample_id)
  
  #get n requested PADs
  n_pads = length(unique(these_pad_ids))
  
  #messages
  message(paste0("Number of samples matching the requested PAD ID(s): ", n_samples))
  message(paste0("Number of PADs requested: ", n_pads))
  
  #subset to only uc samples (avoid duplicated samples)
  if(!return_all){
    sample_ids = meta_sub %>% 
      filter(sample_category_group %in% c("uc_index_low_quality", "uc_index_high_quality")) %>% 
      pull(sample_id)

  }else{
    sample_ids = meta_sub
  }
  
  return(sample_ids)
  
}
