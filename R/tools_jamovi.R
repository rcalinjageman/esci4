jamovi_estimate_filler <- function(self, estimate, expand = FALSE) {

  for (e_table in names(estimate)) {
    if(is.data.frame(estimate[[e_table]])) {
      j_table <- self$results[[e_table]]
      if (!is.null(j_table)) {
        jamovi_table_filler(
          j_table,
          estimate[[e_table]],
          expand = TRUE
        )

        eprop <- paste(e_table, "_properties", sep = "")
        if (!is.null(estimate[[eprop]])) {

          if (!is.null(estimate[[eprop]]$denominator_name_html)) {
            j_table$getColumn("denominator")$setTitle(
              estimate[[eprop]]$denominator_name_html
            )
          }

          if (!is.null(estimate[[eprop]]$effect_size_name_html) & e_table == "es_smd") {
            j_table$getColumn("effect_size")$setTitle(
              estimate[[eprop]]$effect_size_name_html
            )

            to_replace <- '<sub>.biased</sub>'
            if (grepl("biased", estimate[[eprop]]$effect_size_name_html))
              to_replace <- ""

            j_table$getColumn("d_biased")$setTitle(
              paste(
                estimate[[eprop]]$effect_size_name_html,
                to_replace,
                sep = ""
              )
            )
          }


          if (!is.null(estimate[[eprop]]$message_html)) {
            j_table$setNote(
              key = "rtable",
              note = estimate[[eprop]]$message_html,
              init = FALSE
            )
          }
        }


      }

    }
  }

}


# This function takes a jamovi table and data frame and fills the jamovi table
# with the data frame data.
#
# For this to work, the column names in the data frame must be exactly the same
# as defined in the results file for the jamovi table (can be different) order.
# Can have columns in the result_table that are not in the jamovi table
jamovi_table_filler <- function(jmv_table = NULL, result_table, expand = FALSE) {
  # Loop through rows in dataframe
  if (is.null(jmv_table)) return(FALSE)
  if (is.null(result_table)) return(FALSE)

  if (!is.null(result_table$df)) {
    result_table$df_i <- result_table$df
  }

  if (!is.null(result_table$effect_size)) {
    result_table$effect_size_smd <- result_table$effect_size
  }

  if (!is.null(result_table$grouping_variable_name) & !is.null(result_table$grouping_variable_level)) {
    jmv_table$getColumn("grouping_variable_level")$setTitle(
      result_table$grouping_variable_name[[1]]
    )
  }

  if (!is.null(result_table$grouping_variable_name) & !is.null(result_table$effect)) {
    jmv_table$getColumn("effect")$setTitle(
      paste(result_table$grouping_variable_name[[1]], "<br>Effect")
    )
  }

  if (!is.null(result_table$comparison_mean) & !is.null(result_table$effect)) {
    cmean <- strsplit(result_table$effect, " / ")
    jmv_table$getColumn("comparison_mean")$setTitle(
      paste("<i>M</i><sub>", cmean[[1]][1], "</sub>", sep = "")
    )
    jmv_table$getColumn("reference_mean")$setTitle(
      paste("<i>M</i><sub>", cmean[[1]][2], "</sub>", sep = "")
    )
    jmv_table$getColumn("effect_size")$setTitle(
      paste(
        "<i>M</i><sub>", cmean[[1]][1], "</sub>",
        " / ",
        "<i>M</i><sub>", cmean[[1]][2], "</sub>",
        sep = ""
      )
    )

  }

  if (!is.null(result_table$comparison_median) & !is.null(result_table$effect)) {
    cmean <- strsplit(result_table$effect, " / ")
    jmv_table$getColumn("comparison_median")$setTitle(
      paste("<i>Mdn</i><sub>", cmean[[1]][1], "</sub>", sep = "")
    )
    jmv_table$getColumn("reference_median")$setTitle(
      paste("<i>Mdn</i><sub>", cmean[[1]][2], "</sub>", sep = "")
    )
    jmv_table$getColumn("effect_size")$setTitle(
      paste(
        "<i>Mdn</i><sub>", cmean[[1]][1], "</sub>",
        " / ",
        "<i>Mdn</i><sub>", cmean[[1]][2], "</sub>",
        sep = ""
      )
    )
  }


  for (x in 1:nrow(result_table)) {
    # Initialize a named list
    row_list <- list()

    # Now fill the named list with the column/values from the data frame
    for(mycol in names(result_table)) {
      if (is.na(result_table[x, mycol])) {

      } else {
        row_list[mycol] = result_table[x, mycol]
      }
    }

    # Save this data to the jamovi table
    if_set <- try(jmv_table$setRow(rowNo = x, values = row_list))
    if (class(if_set) == "try-error" & expand) {
      jmv_table$addRow(rowKey = x, values = row_list)
    }

  }

  # Return the filled table
  return(TRUE)

}


# This helper function sets the lower, upper, and moe columns of a jamovi table
# based on the CI passed. Lower and upper are set with supertitles MoE is set by
# adjusting the name. All changes are wrapped in try statements, so if you pass
# a table without some of these columns, no errors will be thrown
jamovi_set_confidence <- function(jmv_table = NULL, CI) {

  if (is.null(jmv_table)) return(FALSE)

  CI_columns <- c(
    "mean_LL", "mean_UL", "median_LL", "median_UL",
    "LL", "UL",
    "P_LL", "P_UL",
    "I2_LL", "I2_UL",
    "diamond_ratio_LL", "diamond_ratio_UL"
  )
  # MoE_columns <- c(
  #
  # )

  for (column_name in CI_columns) {
    try(
      jmv_table$getColumn(column_name)$setSuperTitle(
        paste(CI, "% CI", sep = "")
      )
    )
  }

  # for (column_name in MoE_columns) {
  #   try(
  #     jmv_table$getColumn(column_name)$setTitle(
  #       paste(CI, "% <i>", jmv_table$getColumn(column_name)$title, "</i>", sep = "")
  #     )
  #   )
  # }

  return(TRUE)
}


# This helper function expands a jamovi table to the desired number of rows
#  and it also optionally creates groupings every breaks rows
jamovi_init_table <- function(jmv_table = NULL, desired_rows, breaks = NULL) {

  if (is.null(jmv_table)) return(FALSE)

  current_length <- length(jmv_table$rowKeys)
  if (current_length < desired_rows) {
    for (y in (current_length+1):desired_rows) {
      # Just a loop that adds rows
      jmv_table$addRow(rowKey = y)
    }
  }

  if (!is.null(breaks) & !is.null(jmv_table$rowKeys) & (length(jmv_table$rowKeys) > 0)) {
    # Create groups every breaks rows
    for (y in 1:length(jmv_table$rowKeys)) {
      if (y %% breaks == 1) {
        jmv_table$addFormat(rowNo = y, col = 1, jmvcore::Cell.BEGIN_GROUP)
      }
      if (y %% breaks == 0) {
        jmv_table$addFormat(rowNo = y, col = 1, jmvcore::Cell.END_GROUP)
      }
    }
  }
  return(TRUE)
}


jamovi_arg_builder <- function(
  args,
  arg_name,
  my_value = NULL,
  return_value = NULL,
  na_ok = FALSE,
  convert_to_number = FALSE,
  lower = NULL,
  upper = NULL,
  lower_inclusive = FALSE,
  upper_inclusive = FALSE,
  my_value_name = NULL
) {


  if(is.null(my_value_name)) {
    my_value_name <- deparse(substitute(my_value))
    my_value_name <- gsub("self\\$options\\$", "", my_value_name)
    my_value_name <- gsub("_", " ", my_value_name)
  }

  # Lots of ways a jamovi input can be invalid
  #   Check for null, na, trims length of 0, or one of several
  #   text strings that shouldn't be passed on
  if(is.null(my_value)) {
    reason <- glue::glue(
      "{my_value_name} was null; replaced with: {return_value}"
    )
    args$warnings <- c(args$warnings, reason)
    args[[arg_name]] <- return_value
    return(args)
  }

  if(!na_ok & is.na(my_value)) {
    reason <- glue::glue(
      "{my_value_name} was NA/missing; replaced with: {return_value}"
    )
    args$warnings <- c(args$warnings, reason)
    args[[arg_name]] <- return_value
    return(args)
  }

  if(length(trimws(as.character(my_value))) == 0) {
    reason <- glue::glue(
      "{my_value_name} was empty string (''); replaced with: {return_value}"
    )
    args$warnings <- c(args$warnings, reason)
    args[[arg_name]] <- return_value
    return(args)
  }

  if(trimws(as.character(my_value)) %in% c("")) {
    reason <- glue::glue(
      "{my_value_name} was empty string (''); replaced with: {return_value}"
    )
    args$warnings <- c(args$warnings, reason)
    args[[arg_name]] <- return_value
    return(args)
  }

  if(trimws(as.character(my_value)) %in% c("auto", "Auto", "AUTO")) {
    args[[arg_name]] <- return_value
    return(args)
  }

  if(trimws(as.character(my_value))
     %in%
     c("NaN", "Na", "NA", "None")
  ) {
    if(na_ok) {
      return(NA)
    } else {
      reason <- glue::glue(
        "{my_value_name} was NaN/Na/NA/None; replaced with: {return_value}"
      )
      args$warnings <- c(args$warnings, reason)
      args[[arg_name]] <- return_value
      return(args)
    }
  }

  # Now, if specified, try to convert to a number
  fvalue <- if(convert_to_number) {
    as.numeric(my_value)
  } else {
    my_value
  }

  # If conversion didn't succeed, don't send the value back
  if (is.na(fvalue)) {
    if(na_ok) {
      reason <- glue::glue(
        "{my_value_name} conversion to number yielded Na/Missing;
        replaced with: {return_value}"
      )
      args$warnings <- c(args$warnings, reason)
      args[[arg_name]] <- NA
      return(args)
    } else {
      reason <- glue::glue(
        "{my_value_name} conversion to number yielded Na/Missing;
        replaced with: {return_value}"
      )
      args$warnings <- c(args$warnings, reason)
      args[[arg_name]] <- return_value
      return(args)
    }
  }

  # Check range of numeric parameter
  out_of_range <- NULL
  lower_symbol <- ifelse(lower_inclusive, ">=", ">")
  upper_symbol <- ifelse(upper_inclusive, "<=", "<")

  if(!is.null(lower)) {
    if(lower_inclusive) {
      if(fvalue < lower) out_of_range <- paste(lower_symbol, lower)
    } else {
      if(fvalue <= lower) out_of_range <- paste(lower_symbol, lower)
    }
  }

  if(!is.null(upper)) {
    if(upper_inclusive) {
      if(fvalue > upper) out_of_range <- paste(upper_symbol, upper)
    } else {
      if(fvalue >= upper) out_of_range <- paste(upper_symbol, upper)
    }
  }

  if(!is.null(out_of_range)) {
    reason <- glue::glue(
      "{my_value_name} is {fvalue} but must be {out_of_range};
        replaced with: {return_value}"
    )
    args$warnings <- c(args$warnings, reason)
    args[[arg_name]] <- return_value
    return(args)
  }

  args[[arg_name]] <- fvalue
  return(args)

}


# This function sanitizes an input from jamovi
# If the input is null, length is 0, all spaces, or NA, it returns return value
# Otherwise it returns the input value, converted to as.numeric if specified
jamovi_sanitize <- function(
  my_value = NULL,
  return_value = NULL,
  na_ok = FALSE,
  convert_to_number = FALSE,
  lower = NULL,
  upper = NULL,
  lower_inclusive = FALSE,
  upper_inclusive = FALSE,
  my_value_name = NULL
) {

  if(is.null(my_value_name)) {
    my_value_name <- deparse(substitute(my_value))
    my_value_name <- gsub("self\\$options\\$", "", my_value_name)
    my_value_name <- gsub("_", " ", my_value_name)
  }

  # Lots of ways a jamovi input can be invalid
  #   Check for null, na, trims length of 0, or one of several
  #   text strings that shouldn't be passed on
  if(is.null(my_value)) {
    reason <- glue::glue(
      "{my_value_name} was null; replaced with: {return_value}"
    )
    if(!is.null(return_value)) names(return_value) <- reason
    return(return_value)
  }

  if(!na_ok & is.na(my_value)) {
    reason <- glue::glue(
      "{my_value_name} was NA/missing; replaced with: {return_value}"
    )
    if(!is.null(return_value)) names(return_value) <- reason
    return(return_value)
  }

  if(length(trimws(as.character(my_value))) == 0) {
    reason <- glue::glue(
      "{my_value_name} was empty string (''); replaced with: {return_value}"
    )
    if(!is.null(return_value)) names(return_value) <- reason
    return(return_value)
  }

  if(trimws(as.character(my_value)) %in% c("")) {
    reason <- glue::glue(
      "{my_value_name} was empty string (''); replaced with: {return_value}"
    )
    if(!is.null(return_value)) names(return_value) <- reason
    return(return_value)
  }

  if(trimws(as.character(my_value)) %in% c("auto", "Auto", "AUTO")) {
    return(return_value)
  }

  if(trimws(as.character(my_value))
     %in%
     c("NaN", "Na", "NA", "None")
  ) {
    if(na_ok) {
      return(NA)
    } else {
      reason <- glue::glue(
        "{my_value_name} was NaN/Na/NA/None; replaced with: {return_value}"
      )
      if(!is.null(return_value)) names(return_value) <- reason
      return(return_value)
    }
  }

  # Now, if specified, try to convert to a number
  fvalue <- if(convert_to_number) {
    as.numeric(my_value)
  } else {
    my_value
  }

  # If conversion didn't succeed, don't send the value back
  if (is.na(fvalue)) {
    if(na_ok) {
      return(NA)
    } else {
      reason <- glue::glue(
        "{my_value_name} conversion to number yielded Na/Missing;
        replaced with: {return_value}"
      )
      if(!is.null(return_value)) names(return_value) <- reason
      return(return_value)
    }
  }

  # Check range of numeric parameter
  out_of_range <- NULL
  lower_symbol <- ifelse(lower_inclusive, ">=", ">")
  upper_symbol <- ifelse(upper_inclusive, "<=", "<")

  if(!is.null(lower)) {
    if(lower_inclusive) {
      if(fvalue < lower) out_of_range <- paste(lower_symbol, lower)
    } else {
      if(fvalue <= lower) out_of_range <- paste(lower_symbol, lower)
    }
  }

  if(!is.null(upper)) {
    if(upper_inclusive) {
      if(fvalue > upper) out_of_range <- paste(upper_symbol, upper)
    } else {
      if(fvalue >= upper) out_of_range <- paste(upper_symbol, upper)
    }
  }

  if(!is.null(out_of_range)) {
    reason <- glue::glue(
      "{my_value_name} is {fvalue} but must be {out_of_range};
        replaced with: {return_value}"
    )
    if(!is.null(return_value)) names(return_value) <- reason
    return(return_value)
  }


  return(fvalue)

}

jamovi_required_numeric <- function(
  my_value = NULL,
  integer_required = FALSE,
  lower = NULL,
  upper = NULL,
  lower_inclusive = FALSE,
  upper_inclusive = FALSE,
  my_value_name = NULL
) {

  if(is.null(my_value_name)) {
    my_value_name <- deparse(substitute(my_value))
    my_value_name <- gsub("self\\$options\\$", "", my_value_name)
    my_value_name <- gsub("_", " ", my_value_name)
  }

  return_value <- NA
  names(return_value) <- my_value_name


  # Lots of ways a jamovi input can be invalid
  #   Check for null, na, trims length of 0, or one of several
  #   text strings that shouldn't be passed on
  if(is.null(my_value)) {
    return(return_value)
  }

  if(is.na(my_value)) {
    return(return_value)
  }

  if(length(trimws(as.character(my_value))) == 0) {
    return(return_value)
  }

  if(trimws(as.character(my_value)) %in% c("")) {
    return(return_value)
  }


  if(trimws(as.character(my_value))
     %in%
     c("NaN", "Na", "NA", "None")
  ) {
    return(return_value)
  }

  # Now, if specified, try to convert to a number
  fvalue <- as.numeric(my_value)

  # If conversion didn't succeed, don't send the value back
  if (is.na(fvalue)) {
    return(return_value)
  }

  # Check range of numeric parameter
  out_of_range <- NULL
  lower_symbol <- ifelse(lower_inclusive, ">=", ">")
  upper_symbol <- ifelse(upper_inclusive, "<=", "<")

  if(!is.null(lower)) {
    if(lower_inclusive) {
      if(fvalue < lower) out_of_range <- paste(lower_symbol, lower)
    } else {
      if(fvalue <= lower) out_of_range <- paste(lower_symbol, lower)
    }
  }

  if (integer_required & !is.whole.number(fvalue)) {
    reason <- glue::glue(
      "Error: {my_value_name} is {fvalue} but must be an integer"
    )
    return(reason)
  }

  if(!is.null(upper)) {
    if(upper_inclusive) {
      if(fvalue > upper) out_of_range <- paste(upper_symbol, upper)
    } else {
      if(fvalue >= upper) out_of_range <- paste(upper_symbol, upper)
    }
  }

  if(!is.null(out_of_range)) {
    reason <- glue::glue(
      "Error: {my_value_name} is {fvalue} but must be {out_of_range}"
    )
    return(reason)
  }

  return(fvalue)

}


# This helper function checks if a contrast is valid
jamovi_check_contrast <- function(
  labels,
  valid_levels,
  level_source,
  group_type,
  error_string = NULL,
  sequential = FALSE
) {

  run_analysis <- TRUE

  if(nchar(labels)>1) {
    # Verify list of reference groups
    # Split by comma, then trim ws while also
    #  reducing the list returned by split to a vector
    refgs <- strsplit(
      as.character(labels), ","
    )
    refgs <- trimws(refgs[[1]], which = "both")


    # Now cycle through each item in the list to check it
    #   is a valid factor within the grouping variable

    for (tlevel in refgs) {
      if (!tlevel %in% valid_levels) {
        error_string <- paste(error_string, glue::glue(
          "<b>{group_type} error</b>:
The group {tlevel} does not exist in {level_source}.
Group labels in {level_source} are: {paste(valid_levels, collapse = ', ')}.
Use commas to separate labels.
"
        )
        )
        return(list(
          labels = NULL,
          run_analysis = FALSE,
          error_string = error_string
        )
        )
      }
    }
  } else {
    if (sequential) {
      error_string <- paste(error_string, glue::glue(
        "
<b>{group_type} subset</b>:
Do the same for this subset.  No group can belong to both subsets.
"
      ))
    } else {
      error_string <- paste(error_string, glue::glue(
        "
<b>{group_type} subset</b>:
Type one or more group labels, separated by commas,
to form the {group_type} subset.
Group labels in {level_source} are: {paste(valid_levels, collapse = ', ')}.
"
      ))
    }
    return(list(
      label = NULL,
      run_analysis = FALSE,
      error_string = error_string
    )
    )
  }


  return(list(
    label = refgs,
    run_analysis = TRUE,
    error_string = error_string
  )
  )
}


jamovi_create_contrast <- function(reference, comparison) {
  ref_n <- length(reference)
  comp_n <- length(comparison)
  ref_vector <- rep(-1/ref_n, times = ref_n)
  comp_vector <- rep(1/comp_n, times = comp_n)
  contrast <- c(ref_vector, comp_vector)
  names(contrast) <- c(reference, comparison)
  return(contrast)
}


jamovi_set_notes <- function(result_element) {
  notes <- result_element$state

  if(length(notes) > 0) {
    result_element$setContent(
      paste(
        "<div class='jmv-results-error-message' style='color:black'>",
        paste(
          "<li>",
          notes,
          "</li>",
          collapse = ""
        ),
        "</div>"
      )
    )
    result_element$setVisible(TRUE)
  } else {
    result_element$setContent("")
    result_element$setVisible(FALSE)
  }


}
