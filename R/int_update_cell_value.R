#' Update a Single Cell Value in a Data Frame
#'
#' This helper function updates a specific cell value in a data frame with validation,
#' type checking, and change logging. Row identification is done via a specified sample ID column.
#' Changes are logged to the global `column_change_log` list used by `process_column()`.
#'
#' @param data A data frame to operate on. Defaults to `metadata`.
#' @param sample_id The sample identifier value to match in the sample ID column (character).
#' @param column The name of the column to update (character).
#' @param new_value The new value to set in the specified cell.
#' @param sample_id_col The name of the column containing sample IDs. Defaults to `"sample_id"`.
#' @param validate_type Logical; if `TRUE`, validates that the new value matches the column type.
#'   Default is `TRUE`.
#' @param log_changes Logical; if `TRUE`, logs the change to the global `column_change_log` list.
#'   Default is `TRUE`.
#' @param reason Optional; reason for the change (character). Default is `NULL`.
#'
#' @return The updated data frame with the modified cell value.
#'
#' @details
#' - Identifies rows using the specified sample ID column (default: `"sample_id"`)
#' - Validates that the row and column exist
#' - Checks that the new value is compatible with the column's data type
#' - For factors, checks if the new value is a valid level
#' - For booleans, accepts logical values or strings like "TRUE"/"FALSE"
#' - Logs changes with old value, new value, and timestamp to `column_change_log`
#' - Cell-level changes are stored under a "cell_updates" key within `column_change_log`
#'
#' @examples
#' # Update a boolean value (using default sample_id column)
#' metadata <- update_cell_value(
#'   data = metadata,
#'   sample_id = "19KFU0046",
#'   column = "sq_metaplasia",
#'   new_value = TRUE,
#'   reason = "Correction based on pathology review"
#' )
#'
#' # Update using a custom sample ID column name
#' metadata <- update_cell_value(
#'   data = metadata,
#'   sample_id = "X18KFU0001",
#'   column = "grade",
#'   new_value = "G2",
#'   sample_id_col = "patient_id"
#' )
#'
#' @export
int_update_cell_value <- function(data = metadata,
                                  sample_id,
                                  column,
                                  new_value,
                                  sample_id_col = "sample_id",
                                  validate_type = TRUE,
                                  log_changes = TRUE,
                                  reason = NULL) {
  
  # Check if sample_id_col exists
  if (!sample_id_col %in% names(data)) {
    stop(paste("Column", sample_id_col, "does not exist in the data frame."))
  }
  
  # Check if column exists
  if (!column %in% names(data)) {
    stop(paste("Column", column, "does not exist in the data frame."))
  }
  
  # Find the row index by matching sample_id
  row_index <- which(data[[sample_id_col]] == sample_id)
  
  if (length(row_index) == 0) {
    stop(paste("Sample ID", sample_id, "does not exist in the", sample_id_col, "column."))
  }
  
  if (length(row_index) > 1) {
    warning(paste("Multiple rows found for sample ID", sample_id, ". Updating all matching rows."))
  }
  
  # Store the old value(s) for logging
  old_value <- data[row_index, column]
  
  # Validate type compatibility if enabled
  if (validate_type) {
    column_class <- class(data[[column]])[1]
    
    if (column_class == "factor") {
      # For factors, convert value to character and check if it's a valid level
      new_value_char <- as.character(new_value)
      if (!new_value_char %in% levels(data[[column]]) && !is.na(new_value)) {
        stop(paste0(
          "Value '", new_value_char, "' is not a valid level for factor column '", 
          column, "'.\nValid levels: ", paste(levels(data[[column]]), collapse = ", ")
        ))
      }
      new_value <- factor(new_value_char, levels = levels(data[[column]]))
      
    } else if (column_class == "logical") {
      # For logical, accept TRUE/FALSE or strings
      if (is.character(new_value)) {
        new_value <- as.logical(toupper(new_value))
      } else if (!is.logical(new_value) && !is.na(new_value)) {
        stop(paste("Column", column, "is logical. New value must be TRUE, FALSE, or NA."))
      }
      
    } else if (column_class %in% c("numeric", "double")) {
      if (!is.numeric(new_value) && !is.na(new_value)) {
        tryCatch({
          new_value <- as.numeric(new_value)
        }, error = function(e) {
          stop(paste("Column", column, "is numeric. Cannot convert new value to numeric."))
        })
      }
      
    } else if (column_class == "integer") {
      if (!is.integer(new_value) && !is.na(new_value)) {
        tryCatch({
          new_value <- as.integer(new_value)
        }, error = function(e) {
          stop(paste("Column", column, "is integer. Cannot convert new value to integer."))
        })
      }
      
    } else if (column_class == "character") {
      new_value <- as.character(new_value)
      
    } else if (column_class == "Date") {
      if (!inherits(new_value, "Date") && !is.na(new_value)) {
        tryCatch({
          new_value <- as.Date(new_value)
        }, error = function(e) {
          stop(paste("Column", column, "is Date. Cannot convert new value to Date."))
        })
      }
    }
  }
  
  # Update the cell value(s)
  data[row_index, column] <- new_value
  
  # Log the change if enabled
  if (log_changes) {
    # Initialize the column_change_log if it doesn't exist
    if (!exists("column_change_log", envir = .GlobalEnv)) {
      column_change_log <<- list()
    }
    
    # Initialize cell_updates within column_change_log if it doesn't exist
    if (!"cell_updates" %in% names(column_change_log)) {
      column_change_log[["cell_updates"]] <<- list()
    }
    
    # Create a unique key for this change
    log_key <- paste0(sample_id, "_", column, "_", format(Sys.time(), "%Y%m%d_%H%M%S"))
    
    log_entry <- list(
      sample_id = sample_id,
      sample_id_col = sample_id_col,
      row_index = row_index,
      column = column,
      old_value = old_value,
      new_value = new_value,
      reason = reason,
      timestamp = Sys.time()
    )
    
    # Add to cell_updates sub-list
    column_change_log[["cell_updates"]][[log_key]] <<- log_entry
    
    # Print confirmation message
    cat(paste0(
      "\n✓ Updated ", sample_id, " - ", column, 
      "\n  Old value: ", paste(old_value, collapse = ", "), 
      "\n  New value: ", new_value,
      if (!is.null(reason)) paste0("\n  Reason: ", reason) else "",
      "\n"
    ))
  }
  
  return(data)
}
