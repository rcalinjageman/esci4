
# This file is a generated template, your changes will not be overwritten

jamovirmetarClass <- if (requireNamespace('jmvcore', quietly=TRUE)) R6::R6Class(
    "jamovirmetarClass",
    inherit = jamovirmetarBase,
    private = list(
        .init = function() {

            tbl_raw_data <- self$results$raw_data
            tbl_es_meta <- self$results$es_meta
            tbl_es_meta_difference <- self$results$es_meta_difference

            conf_level <- jamovi_sanitize(
                my_value = self$options$conf_level,
                return_value = 95,
                na_ok = FALSE,
                convert_to_number = TRUE
            )

            jamovi_set_confidence(tbl_raw_data, conf_level)
            jamovi_set_confidence(tbl_es_meta, conf_level)


            moderator <- !is.null(self$options$moderator)

            tbl_es_meta_difference$setVisible(moderator)
            tbl_es_meta$getColumn("moderator_variable_name")$setVisible(moderator)
            tbl_es_meta$getColumn("moderator_variable_level")$setVisible(moderator)
            tbl_raw_data$getColumn("moderator")$setVisible(moderator)

            meta_note <- if(self$options$random_effects)
                "Estimate is based on a random effects model."
            else
                "Estimate is based on a fixed effects model."

            tbl_es_meta$setNote(
                key = "meta_note",
                note = meta_note
            )


        },
        .run = function() {

            estimate <- jamovi_meta_r(self)


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


jamovi_meta_r <- function(self) {

    # Prelim -----------------------------------------------------
    notes <- c(NULL)

    # Step 1 - Check if analysis basics are defined ---------------
    args <- list()

    if (
        is.null(self$options$rs) |
        is.null(self$options$ns)
    ) return(NULL)


    # Step 2: Get analysis properties-----------------------------
    call <- esci4::meta_r

    args$effect_label <- jamovi_sanitize(
        self$options$effect_label,
        return_value = "My effect",
        na_ok = FALSE
    )

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


    for (element in args) {
        notes <- c(notes, names(element))
    }


    if (!is.null(self$options$moderator)) {
        args$moderator <- self$options$moderator
    }

    if (!is.null(self$options$labels)) {
        args$labels <- self$options$labels
    }

    args$data <- self$data
    args$rs <- self$options$rs
    args$ns <- self$options$ns

    args$random_effects <- self$options$random_effects



    # Do analysis, then post any notes that have emerged
    estimate <- try(do.call(what = call, args = args))
    estimate$raw_data$label <- as.character(estimate$raw_data$label)
    if (!is.null(self$options$moderator)) {
        estimate$raw_data$moderator <- as.character(estimate$raw_data$moderator)
    }


    if (!is(estimate, "try-error")) {
        if (length(estimate$warnings) > 0) {
            notes <- c(notes, estimate$warnings)
        }
    }

    self$results$help$setState(notes)

    return(estimate)
}
