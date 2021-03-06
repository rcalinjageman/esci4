
# This file is automatically generated, you probably don't want to edit this

jamovipdiffpairedOptions <- if (requireNamespace("jmvcore", quietly=TRUE)) R6::R6Class(
    "jamovipdiffpairedOptions",
    inherit = jmvcore::Options,
    public = list(
        initialize = function(
            switch = "from_raw",
            reference_measure = NULL,
            comparison_measure = NULL,
            cases_consistent = " ",
            cases_inconsistent = " ",
            not_cases_consistent = " ",
            not_cases_inconsistent = " ",
            case_label = "Sick",
            not_case_label = "Well",
            comparison_measure_name = "Pretest",
            reference_measure_name = "Posttest",
            conf_level = 95,
            show_details = FALSE, ...) {

            super$initialize(
                package="esci4",
                name="jamovipdiffpaired",
                requiresData=TRUE,
                ...)

            private$..switch <- jmvcore::OptionList$new(
                "switch",
                switch,
                default="from_raw",
                options=list(
                    "from_raw",
                    "from_summary"))
            private$..reference_measure <- jmvcore::OptionVariable$new(
                "reference_measure",
                reference_measure)
            private$..comparison_measure <- jmvcore::OptionVariable$new(
                "comparison_measure",
                comparison_measure)
            private$..cases_consistent <- jmvcore::OptionString$new(
                "cases_consistent",
                cases_consistent,
                default=" ")
            private$..cases_inconsistent <- jmvcore::OptionString$new(
                "cases_inconsistent",
                cases_inconsistent,
                default=" ")
            private$..not_cases_consistent <- jmvcore::OptionString$new(
                "not_cases_consistent",
                not_cases_consistent,
                default=" ")
            private$..not_cases_inconsistent <- jmvcore::OptionString$new(
                "not_cases_inconsistent",
                not_cases_inconsistent,
                default=" ")
            private$..case_label <- jmvcore::OptionString$new(
                "case_label",
                case_label,
                default="Sick")
            private$..not_case_label <- jmvcore::OptionString$new(
                "not_case_label",
                not_case_label,
                default="Well")
            private$..comparison_measure_name <- jmvcore::OptionString$new(
                "comparison_measure_name",
                comparison_measure_name,
                default="Pretest")
            private$..reference_measure_name <- jmvcore::OptionString$new(
                "reference_measure_name",
                reference_measure_name,
                default="Posttest")
            private$..conf_level <- jmvcore::OptionNumber$new(
                "conf_level",
                conf_level,
                min=1,
                max=99.999999,
                default=95)
            private$..show_details <- jmvcore::OptionBool$new(
                "show_details",
                show_details,
                default=FALSE)

            self$.addOption(private$..switch)
            self$.addOption(private$..reference_measure)
            self$.addOption(private$..comparison_measure)
            self$.addOption(private$..cases_consistent)
            self$.addOption(private$..cases_inconsistent)
            self$.addOption(private$..not_cases_consistent)
            self$.addOption(private$..not_cases_inconsistent)
            self$.addOption(private$..case_label)
            self$.addOption(private$..not_case_label)
            self$.addOption(private$..comparison_measure_name)
            self$.addOption(private$..reference_measure_name)
            self$.addOption(private$..conf_level)
            self$.addOption(private$..show_details)
        }),
    active = list(
        switch = function() private$..switch$value,
        reference_measure = function() private$..reference_measure$value,
        comparison_measure = function() private$..comparison_measure$value,
        cases_consistent = function() private$..cases_consistent$value,
        cases_inconsistent = function() private$..cases_inconsistent$value,
        not_cases_consistent = function() private$..not_cases_consistent$value,
        not_cases_inconsistent = function() private$..not_cases_inconsistent$value,
        case_label = function() private$..case_label$value,
        not_case_label = function() private$..not_case_label$value,
        comparison_measure_name = function() private$..comparison_measure_name$value,
        reference_measure_name = function() private$..reference_measure_name$value,
        conf_level = function() private$..conf_level$value,
        show_details = function() private$..show_details$value),
    private = list(
        ..switch = NA,
        ..reference_measure = NA,
        ..comparison_measure = NA,
        ..cases_consistent = NA,
        ..cases_inconsistent = NA,
        ..not_cases_consistent = NA,
        ..not_cases_inconsistent = NA,
        ..case_label = NA,
        ..not_case_label = NA,
        ..comparison_measure_name = NA,
        ..reference_measure_name = NA,
        ..conf_level = NA,
        ..show_details = NA)
)

jamovipdiffpairedResults <- if (requireNamespace("jmvcore", quietly=TRUE)) R6::R6Class(
    "jamovipdiffpairedResults",
    inherit = jmvcore::Group,
    active = list(
        debug = function() private$.items[["debug"]],
        help = function() private$.items[["help"]],
        overview = function() private$.items[["overview"]],
        es_proportion_difference = function() private$.items[["es_proportion_difference"]],
        es_phi = function() private$.items[["es_phi"]]),
    private = list(),
    public=list(
        initialize=function(options) {
            super$initialize(
                options=options,
                name="",
                title="Pdiff - Paired")
            self$add(jmvcore::Preformatted$new(
                options=options,
                name="debug",
                visible=TRUE))
            self$add(jmvcore::Html$new(
                options=options,
                name="help",
                visible=FALSE))
            self$add(jmvcore::Table$new(
                options=options,
                name="overview",
                title="Overview",
                rows=4,
                columns=list(
                    list(
                        `name`="outcome_variable_name", 
                        `title`="Outcome variable name", 
                        `type`="text", 
                        `combineBelow`=TRUE),
                    list(
                        `name`="outcome_variable_level", 
                        `title`="Level", 
                        `type`="text", 
                        `combineBelow`=TRUE),
                    list(
                        `name`="cases", 
                        `title`="Cases", 
                        `type`="integer"),
                    list(
                        `name`="n", 
                        `title`="<i>N</i>", 
                        `type`="integer"),
                    list(
                        `name`="P", 
                        `title`="<i>P</i>", 
                        `type`="number"),
                    list(
                        `name`="P_LL", 
                        `title`="LL", 
                        `type`="number"),
                    list(
                        `name`="P_UL", 
                        `title`="UL", 
                        `type`="number"),
                    list(
                        `name`="P_SE", 
                        `type`="number", 
                        `title`="<i>SE<sub>P</sub></i>", 
                        `visible`="(show_details)"))))
            self$add(jmvcore::Table$new(
                options=options,
                name="es_proportion_difference",
                title="Proportion difference",
                rows=3,
                columns=list(
                    list(
                        `name`="comparison_measure_name", 
                        `title`="Comparison measure", 
                        `type`="text", 
                        `combineBelow`=TRUE),
                    list(
                        `name`="reference_measure_name", 
                        `title`="Reference measure", 
                        `type`="text", 
                        `combineBelow`=TRUE),
                    list(
                        `name`="effect", 
                        `title`="Effect", 
                        `type`="text"),
                    list(
                        `name`="effect_size", 
                        `type`="number", 
                        `title`="<i>P</i>"),
                    list(
                        `name`="LL", 
                        `title`="LL", 
                        `type`="number"),
                    list(
                        `name`="UL", 
                        `title`="UL", 
                        `type`="number"),
                    list(
                        `name`="SE", 
                        `title`="<i>SE</i>", 
                        `type`="number", 
                        `visible`="(show_details)"))))
            self$add(jmvcore::Table$new(
                options=options,
                name="es_phi",
                title="Association",
                rows=1,
                columns=list(
                    list(
                        `name`="outcome_variable_1", 
                        `title`="Outcome variable 1", 
                        `type`="text", 
                        `combineBelow`=TRUE),
                    list(
                        `name`="outcome_variable_2", 
                        `title`="Outcome variable 2", 
                        `type`="text"),
                    list(
                        `name`="effect", 
                        `title`="Effect", 
                        `type`="text"),
                    list(
                        `name`="effect_size", 
                        `type`="number", 
                        `title`="<i>Phi</i>"),
                    list(
                        `name`="LL", 
                        `title`="LL", 
                        `type`="number"),
                    list(
                        `name`="UL", 
                        `title`="UL", 
                        `type`="number"))))}))

jamovipdiffpairedBase <- if (requireNamespace("jmvcore", quietly=TRUE)) R6::R6Class(
    "jamovipdiffpairedBase",
    inherit = jmvcore::Analysis,
    public = list(
        initialize = function(options, data=NULL, datasetId="", analysisId="", revision=0) {
            super$initialize(
                package = "esci4",
                name = "jamovipdiffpaired",
                version = c(1,0,0),
                options = options,
                results = jamovipdiffpairedResults$new(options=options),
                data = data,
                datasetId = datasetId,
                analysisId = analysisId,
                revision = revision,
                pause = NULL,
                completeWhenFilled = FALSE,
                requiresMissings = FALSE)
        }))

#' Paired
#'
#' 
#' @param switch .
#' @param data .
#' @param reference_measure .
#' @param comparison_measure .
#' @param cases_consistent .
#' @param cases_inconsistent .
#' @param not_cases_consistent .
#' @param not_cases_inconsistent .
#' @param case_label .
#' @param not_case_label .
#' @param comparison_measure_name .
#' @param reference_measure_name .
#' @param conf_level .
#' @param show_details .
#' @return A results object containing:
#' \tabular{llllll}{
#'   \code{results$debug} \tab \tab \tab \tab \tab a preformatted \cr
#'   \code{results$help} \tab \tab \tab \tab \tab a html \cr
#'   \code{results$overview} \tab \tab \tab \tab \tab a table \cr
#'   \code{results$es_proportion_difference} \tab \tab \tab \tab \tab a table \cr
#'   \code{results$es_phi} \tab \tab \tab \tab \tab a table \cr
#' }
#'
#' Tables can be converted to data frames with \code{asDF} or \code{\link{as.data.frame}}. For example:
#'
#' \code{results$overview$asDF}
#'
#' \code{as.data.frame(results$overview)}
#'
#' @export
jamovipdiffpaired <- function(
    switch = "from_raw",
    data,
    reference_measure,
    comparison_measure,
    cases_consistent = " ",
    cases_inconsistent = " ",
    not_cases_consistent = " ",
    not_cases_inconsistent = " ",
    case_label = "Sick",
    not_case_label = "Well",
    comparison_measure_name = "Pretest",
    reference_measure_name = "Posttest",
    conf_level = 95,
    show_details = FALSE) {

    if ( ! requireNamespace("jmvcore", quietly=TRUE))
        stop("jamovipdiffpaired requires jmvcore to be installed (restart may be required)")

    if ( ! missing(reference_measure)) reference_measure <- jmvcore::resolveQuo(jmvcore::enquo(reference_measure))
    if ( ! missing(comparison_measure)) comparison_measure <- jmvcore::resolveQuo(jmvcore::enquo(comparison_measure))
    if (missing(data))
        data <- jmvcore::marshalData(
            parent.frame(),
            `if`( ! missing(reference_measure), reference_measure, NULL),
            `if`( ! missing(comparison_measure), comparison_measure, NULL))


    options <- jamovipdiffpairedOptions$new(
        switch = switch,
        reference_measure = reference_measure,
        comparison_measure = comparison_measure,
        cases_consistent = cases_consistent,
        cases_inconsistent = cases_inconsistent,
        not_cases_consistent = not_cases_consistent,
        not_cases_inconsistent = not_cases_inconsistent,
        case_label = case_label,
        not_case_label = not_case_label,
        comparison_measure_name = comparison_measure_name,
        reference_measure_name = reference_measure_name,
        conf_level = conf_level,
        show_details = show_details)

    analysis <- jamovipdiffpairedClass$new(
        options = options,
        data = data)

    analysis$run()

    analysis$results
}

