#' Process and Standardize a Column in a Data Frame
#'
#' This helper function processes a specified column in a data frame, allowing for renaming, type 
#' conversion, factor level management, NA replacement, and logging of changes.
#'
#' @param data A data frame to operate on. Defaults to `metadata`.
#' @param column The name of the column to process (character).
#' @param new_name Optional new name for the column (character).
#' @param type Desired type for the column. Options: `"character"`, `"factor"`, `"numeric"`, 
#' `"double"`, `"integer"`, `"boolean"`, `"date"`. Defaults to `"character"`.
#' @param factor_levels Optional vector of factor levels (character).
#' @param factor_order Optional vector specifying the order of factor levels (character).
#' @param replace_na Optional vector of values to replace with `NA` (character).
#' @param rename_factors Optional named vector for renaming factor levels (named character).
#' @param boolean_map Optional list specifying values for `TRUE` and `FALSE` when type is `"boolean"`.
#' @param domain Optional domain/category for the column (character).
#' @param print_table Logical; if `TRUE`, prints a table of the column's values after processing. 
#' Default is `TRUE`.
#' @param log_changes Logical; if `TRUE`, logs the changes to the global `column_change_log` list. 
#' Default is `TRUE`.
#'
#' @return The updated data frame with the processed column.
#'
#' @details
#' - Renames the column if `new_name` is provided.
#' - Converts the column to the specified type.
#' - For factors, can set levels, rename levels, and set order.
#' - For booleans, requires a `boolean_map` list.
#' - Replaces specified values with `NA`.
#' - Logs changes to `column_change_log` if enabled.
#'
#' @examples
#' int_process_column(data = df, 
#'                    column = "old_col", 
#'                    new_name = "new_col", 
#'                    type = "factor", 
#'                    factor_levels = c("A", "B"))
#'
#' @export
#' 
int_process_column <- function(data = metadata, 
                               column, 
                               new_name = NULL, 
                               type = "character", 
                               factor_levels = NULL, 
                               factor_order = NULL, 
                               replace_na = NULL, 
                               rename_factors = NULL, 
                               boolean_map = NULL, 
                               domain = NULL, 
                               print_table = TRUE, 
                               log_changes = TRUE) {
  
  #ensure the column exists
  if (!column %in% names(data)) {
    stop(paste("Column", column, "does not exist in the data frame."))
  }
  
  #store the original column name for tracking
  original_column <- column
  
  #rename the column if a new name is provided
  if (!is.null(new_name)) {
    names(data)[names(data) == column] <- new_name
    column <- new_name
  }
  
  #set the type of the column
  if (!is.null(type)) {
    if (type == "factor") {
      
      #convert to factor and optionally set levels
      if (!is.null(factor_levels)) {
        data[[column]] <- factor(data[[column]], levels = factor_levels)
      } else {
        data[[column]] <- as.factor(data[[column]])
      }
      
      #rename factor levels if provided
      if (!is.null(rename_factors)) {
        levels(data[[column]]) <- plyr::mapvalues(levels(data[[column]]), 
                                                  from = names(rename_factors), 
                                                  to = rename_factors)
      }
      
      #reorder factor levels if provided (after renaming)
      if (!is.null(factor_order)) {
        data[[column]] <- factor(data[[column]], levels = factor_order, ordered = TRUE)
      }
      
    } else if (type == "character") {
      data[[column]] <- as.character(data[[column]])
    } else if (type == "numeric") {
      data[[column]] <- as.numeric(data[[column]])
    } else if (type == "double") {
      data[[column]] <- as.double(data[[column]])
    } else if (type == "integer") {
      data[[column]] <- as.integer(data[[column]])
    } else if (type == "boolean") {
      #handle boolean type with custom mapping
      if (is.null(boolean_map)) {
        stop("For boolean type, a boolean_map must be provided.")
      }
      data[[column]] <- ifelse(
        tolower(data[[column]]) %in% tolower(boolean_map$true), 
        TRUE, 
        ifelse(
          tolower(data[[column]]) %in% tolower(boolean_map$false), 
          FALSE, 
          NA
        )
      )
    } else if (type == "date") {
      #convert to Date type, default format is "%Y-%m-%d"
      data[[column]] <- as.Date(data[[column]], format = "%Y-%m-%d")
    } else {
      stop("Unsupported type specified.")
    }
  }
  
  #replace specific strings with NA for character columns
  if (!is.null(replace_na) && is.character(data[[column]])) {
    data[[column]][data[[column]] %in% replace_na] <- NA
  }
  
  #print a table of the column's values to the console
  if (print_table) {
    cat("\nTable of", column, ":\n")
    print(table(data[[column]], useNA = "ifany"))
  }
  
  #compile parameters used into a list
  parameters_used <- list(
    original_column = original_column,
    new_name = new_name,
    type = type,
    factor_levels = factor_levels,
    factor_order = factor_order,
    replace_na = replace_na,
    rename_factors = rename_factors,
    boolean_map = boolean_map,
    domain = domain
  )
  
  #log the changes if enabled
  if (log_changes) {
    global_log_entry <- list(
      changes = parameters_used,
      timestamp = Sys.time()
    )
    #use the original column name as the name for the log entry
    column_change_log[[original_column]] <<- global_log_entry
  }
  
  #return the updated data
  return(data)
}
