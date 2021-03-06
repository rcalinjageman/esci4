
# This file is a generated template, your changes will not be overwritten

jamoviproportionClass <- if (requireNamespace('jmvcore', quietly=TRUE)) R6::R6Class(
    "jamoviproportionClass",
    inherit = jamoviproportionBase,
    private = list(
        .init = function() {
          from_raw <- (self$options$switch == "from_raw")

          # Get a handle for each table
          tbl_overview <- self$results$overview

          # Prep output -------------------------------------------
          # Set CI and MoE columns to reflect confidence level
          conf_level <- jamovi_sanitize(
            my_value = self$options$conf_level,
            return_value = 95,
            na_ok = FALSE,
            convert_to_number = TRUE
          )

          jamovi_set_confidence(tbl_overview, conf_level)

        },
        .run = function() {

          estimate <- jamovi_proportion(self)

          # Print any notes that emerged from running the analysis
          jamovi_set_notes(self$results$help)

          # Check to see if the analysis ran
          #  If null, return
          #  If error, return the error
          if(is.null(estimate)) return(TRUE)
          if(is(estimate, "try-error")) stop(estimate[1])

          # Fill tables
          jamovi_estimate_filler(self, estimate, TRUE)


        })
)

jamovi_proportion <- function(self) {
  # Prelim -----------------------------------------------------
  from_raw <- (self$options$switch == "from_raw")
  notes <- c(NULL)

  # Step 1 - Check if analysis basics are defined ---------------
  args <- list()

  if(from_raw) {
    if (
      is.null(self$options$outcome_variable)
    ) return(NULL)
  } else {
    args$cases <- jamovi_required_numeric(
      self$options$cases,
      lower = 0,
      lower_inclusive = TRUE,
      integer_required = TRUE
    )
    args$observations <- jamovi_required_numeric(
      self$options$observations,
      integer_required = TRUE,
      lower = 0,
      lower_inclusive = FALSE
    )

    unfilled <- names(args[which(is.na(args))])

    for (element in args) {
      if (is.character(element)) {
        notes <- c(notes, element)
      }
    }

    if (length(unfilled) > 0) {
      notes <- c(
        paste(
          "For summary data, please specify: ",
          paste0(unfilled, collapse = ", ")
        ),
        notes
      )
    }

    if (length(notes) > 0) {
      self$results$help$setState(notes)
      return(NULL)
    }

    args$cases <- c(args$cases, args$observations - args$cases)
    args$observations <- NULL

  }


  # Step 2: Get analysis properties-----------------------------
  call <- esci4::estimate_proportion
  args$count_NA <- self$options$count_NA
  args$conf_level <- jamovi_sanitize(
    my_value = self$options$conf_level,
    return_value = 95,
    na_ok = FALSE,
    convert_to_number = TRUE,
    lower = 0,
    lower_inclusive = FALSE,
    upper = 100,
    upper_inclusive = FALSE,
    my_value_name = "Confidence level"
  )/100


  if(from_raw) {
    args$data <- self$data
    args$outcome_variable <- unname(self$options$outcome_variable)
  } else {
    args$case_label <- jamovi_sanitize(
      self$options$case_label,
      return_value = "Affected",
      na_ok = FALSE
    )
    args$not_case_label <- jamovi_sanitize(
      self$options$not_case_label,
      return_value = "Not affected",
      na_ok = FALSE
    )
    args$outcome_variable_name <- jamovi_sanitize(
      self$options$outcome_variable_name,
      return_value = "My outcome variable",
      na_ok = FALSE
    )

    for (element in args) {
      notes <- c(notes, names(element))
    }

    args$outcome_variable_levels <- c(
      args$case_label,
      args$not_case_label
    )

    args$case_label <- NULL
    args$not_case_label <- NULL

  }


  # Do analysis, then post any notes that have emerged
  estimate <- try(do.call(what = call, args = args))

  if (!is(estimate, "try-error")) {
    if (length(estimate$warnings) > 0) {
      notes <- c(notes, estimate$warnings)
    }
  }

  self$results$help$setState(notes)

  return(estimate)
}
