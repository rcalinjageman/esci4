#' @export
test_mdiff <- function(
    estimate,
    effect_size = c("mean", "median"),
    rope = c(0, 0),
    rope_units = c("raw", "sd"),
    output_html = FALSE
)

{


  # Input Checks ---------------------
  # This function expects:
  #   estimate should be of class estimate
  #   effect_size = "mean" | "median"
  #   rope_lower <= 0
  #   rope_upper >= 0
  #   If rope_lower and rope_upper = 0, only traditional nil test returned
  #   0 < alpha < 1
  #   rope_units = "sd" | "raw"
  esci_assert_type(estimate, "is.estimate")
  effect_size <- match.arg(effect_size)
  if (length(rope) < 1) rope[[2]] <- rope[[1]]
  rope_lower <- rope[[1]]
  rope_upper <- rope[[2]]
  esci_assert_range(
    var = rope_lower,
    upper = 0,
    upper_inclusive = TRUE
  )
  esci_assert_range(
    var = rope_upper,
    lower = 0,
    lower_inclusive = TRUE
  )

  rope_units <- match.arg(rope_units)

  if (effect_size == "median" & is.null(estimate$es_median_difference)) {
    stop("Effect size is median, but estimate object passed doesn't have a median difference table.")
  }

  if (effect_size == "median" & is.null(estimate$es_mean_difference)) {
    stop("Effect size is mean, but estimate object passed doesn't have a mean difference table.")
  }

  if (rope_units == "sd" & is.null(estimate$es_smd)) {
    stop("Units are sd, but estimate object passed doesn't have a standardized-mean difference table.")

  }

  # Prep ------------------------------------------
  etable <- if(effect_size == "mean") "es_mean_difference" else "es_median_difference"

  reference_value <- 0
  effect_is_difference <- TRUE
  if (is.na(estimate[[etable]][2, "LL"])) {
    reference_value <- estimate[[etable]][2, "effect_size"]
    effect_is_difference <- FALSE
  }

  if (effect_is_difference) {
    if (output_html) {
      statistic <- if(effect_size == "mean") "<i>M</i><sub>diff</sub>" else "<i>Mdn</i><sub>diff</sub>"
      parameter <- if(effect_size == "mean") "<i>&mu;</i><sub>diff</sub>" else "<i>&eta;</i><sub>diff</sub>"
      p_symbol <- "<i>p</i>"
    } else {
      statistic <- if(effect_size == "mean") "M_diff" else "Mdn_diff"
      parameter <- if(effect_size == "mean") "\U003BC_diff" else "\U003B7_diff"
      p_symbol <- "p"
    }

  } else {
    if (output_html) {
      statistic <- if(effect_size == "mean") "<i>M</i>" else "<i>Mdn</i>"
      parameter <- if(effect_size == "mean") "<i>&mu;</i>" else "<i>&eta;</i>"
      p_symbol <- "<i>p</i>"
    } else {
      statistic <- if(effect_size == "mean") "M" else "Mdn"
      parameter <- if(effect_size == "mean") "\U003BC" else "\U003B7"
      p_symbol <- "p"
    }

  }

  alpha <- 1 - estimate$properties$conf_level
  confidence <- estimate$properties$conf_level*100
  confidence_2alpha <- (1 - 2*alpha)*100

  interval_null <- if (rope_lower != rope_upper) TRUE else FALSE

  # Reduce down to differences
  effect_sizes <- estimate[[etable]][
    estimate[[etable]]$type == "Difference",
  ]


  res <- list()
  res$properties <- list(
    effect_size_name = effect_size,
    alpha = alpha,
    interval_null = interval_null,
    rope = rope,
    rope_units = rope_units
  )

  # Loop through all effect sizes
  for (my_row in 1:nrow(effect_sizes)) {

    # Get single effect size and contrast to work with
    es <- as.list(effect_sizes[my_row, ])

    #### Set rope limits
    if (rope_units == "sd") {
      sd <- estimate$es_smd[[my_row, "denominator"]]
      this_rope_upper <- rope_upper * sd
      this_rope_lower <- rope_lower * sd
    } else {
      this_rope_upper <- rope_upper
      this_rope_lower <- rope_lower
    }


    # Nil hypothesis test ------------------------------
    if (effect_size == "mean") {
      df <- es$df
      t <- es$effect_size / es$SE
      if (is.na(df))
        p <- 2*pnorm(-abs(t))
      else
        p <- 2*pt(-abs(t), df=df)
      significant <- p < alpha
    } else {
      df <- NA
      t <- NA
      p <- NA
      significant <- (0 < es$LL | 0 > es$UL)
    }

    # null_words <- glue::glue("{parameter} is exactly 0")
    null_words <- glue::glue("{format(reference_value, nsmall=2)}")

    rope_words <- glue::glue("[{format(reference_value, nsmall=2)}, {format(reference_value, nsmall=2)}]")

    CI <- glue::glue("{confidence}% CI [{format(es$LL+reference_value, nsmall = 2)}, {format(es$UL+reference_value, nsmall = 2)}]")

    # CI_compare <- if (significant)
    #   glue::glue("The {confidence}% CI does not include 0")
    # else
    #   glue::glue("The {confidence}% CI includes 0")

    CI_compare <- if (significant)
      glue::glue("No")
    else
      glue::glue("Yes")

    p_result <- if (significant)
      glue::glue("{p_symbol} < {alpha}")
    else
      glue::glue("{p_symbol} \U002265 {alpha}")

    conclusion <- if (significant)
      glue::glue("At \U03B1 = {alpha}, conclude {parameter} is not exactly {format(reference_value, nsmall=2)}")
    else
      glue::glue("At \U03B1 = {alpha}, cannot rule out {format(reference_value, nsmall=2)} as a compatible value of {parameter}")

    nil_result <- list(
      test_type = "Nil Hypothesis Test",
      outcome_variable_name = es$outcome_variable_name,
      effect = es$effect,
      null_words = null_words,
      confidence = confidence,
      LL = es$LL,
      UL = es$UL,
      CI = CI,
      CI_compare = CI_compare,
      t = t,
      df = df,
      p = p,
      p_result = p_result,
      conclusion = conclusion,
      significant = significant
    )

    if (is.null(nil_result$outcome_variable_name)) {
      nil_result$outcome_variable_name <- paste(
        es$comparison_measure_name,
        es$reference_measure_name,
        sep = " - "
      )
    }

    res$point_null <- rbind(
      res$point_null,
      as.data.frame(nil_result)
    )

    if (!(this_rope_lower == 0 & this_rope_upper == 0)) {
      eq_significant <- (es$ta_LL > this_rope_lower & es$ta_UL < this_rope_upper)
      me_significant <- (es$LL >= this_rope_upper | es$UL <= this_rope_lower)

      significant <- (eq_significant | me_significant)

      null_words <- glue::glue("[{format(this_rope_lower+reference_value, nsmall = 2)}, {format(this_rope_upper+reference_value, nsmall = 2)}]")


      if(output_html) {
          CI <- glue::glue("
        {confidence}% CI [{format(es$LL+reference_value, nsmall = 2)}, {format(es$UL+reference_value, nsmall = 2)}]
        </br>
        {confidence_2alpha}% CI [{format(es$ta_LL+reference_value, nsmall = 2)}, {format(es$ta_UL+reference_value, nsmall = 2)}]
        ")

      } else {
        CI <- glue::glue("
        {confidence}% CI [{format(es$LL+reference_value, nsmall = 2)}, {format(es$UL+reference_value, nsmall = 2)}]
        {confidence_2alpha}% CI [{format(es$ta_LL+reference_value, nsmall = 2)}, {format(es$ta_UL+reference_value, nsmall = 2)}]
        ")

      }


      CI_compare <- if (me_significant)
        glue::glue("{confidence}% CI fully outside the ROPE")
      else
        glue::glue("{confidence}% CI has values inside and outside the ROPE")

      if (eq_significant) {
        CI_compare <- glue::glue("{confidence_2alpha}% CI fully inside the ROPE")
      }

      p_result <- if (me_significant | eq_significant)
        glue::glue("{p_symbol} < {alpha}")
      else
        glue::glue("{p_symbol} \U002265 {alpha}")


      conclusion <- if (me_significant)
        glue::glue("At \U03B1 = {alpha}, conclude {parameter} is substantive")
      else
        glue::glue("At \U03B1 = {alpha}, this is an ambiguous result")

      if (eq_significant) {
        conclusion <- glue::glue("At \U03B1 = {alpha}, conclude {parameter} is negligible")
      }

      interval_result <- list(
        test_type = "Practical significance test",
        outcome_variable_name = es$outcome_variable_name,
        effect = es$effect,
        rope = null_words,
        confidence = confidence,
        CI = CI,
        rope_compare = CI_compare,
        p_result = p_result,
        conclusion = conclusion,
        significant = significant
      )


      if (is.null(interval_result$outcome_variable_name)) {
        interval_result$outcome_variable_name <- paste(
          es$comparison_measure_name,
          es$reference_measure_name,
          sep = " - "
        )
      }


      res$interval_null <- rbind(
        res$interval_null,
        as.data.frame(interval_result)
      )
    } # End interval tests

  } # Continue looping through effects


  return(res)

}

#'
#' plot_htest <- function(
    #'     test_result,
#'     ggtheme = NULL
#' ) {
#'
#'   if(is.null(ggtheme)) { ggtheme <- ggplot2::theme_classic()}
#'
#'
#'   myplot <- ggplot2::ggplot(
#'     data = test_result$test_plot,
#'     ggplot2::aes(
#'       y = 1,
#'       x = effect_size
#'     )
#'   )
#'
#'   # Apply theme
#'   myplot <- myplot + ggtheme
#'
#'   myplot <- myplot + ggplot2::theme(
#'     axis.text.x = ggplot2::element_blank(), #remove x axis labels
#'     axis.ticks.x = ggplot2::element_blank(), #remove x axis ticks
#'     axis.text.y = ggplot2::element_blank(),  #remove y axis labels
#'     axis.ticks.y = ggplot2::element_blank()  #remove y axis ticks
#'   )
#'
#'   myplot <- myplot + ggplot2::facet_grid(
#'     rows = ggplot2::vars(outcome_variable_name)
#'   )
#'
#'
#'   # Apply 2-alpha error bar
#'   myplot <- myplot + ggplot2::geom_errorbar(
#'     ggplot2::aes(
#'       xmin = ta_LL,
#'       xmax = ta_UL
#'     ),
#'     width = 0,
#'     size = 3
#'   )
#'
#'   # Apply 1-alpha error bar
#'   myplot <- myplot + ggplot2::geom_errorbar(
#'     ggplot2::aes(
#'       xmin = LL,
#'       xmax = UL
#'     ),
#'     width = 0,
#'     size = 1
#'   )
#'
#'   # Mark the effect_size
#'   myplot <- myplot + ggplot2::geom_point(
#'     shape = "triangle filled",
#'     size = 4,
#'     fill = "white"
#'   )
#'
#'   # Mark 0 effect
#'   myplot <- myplot + ggplot2::geom_vline(
#'     xintercept = 0,
#'     linetype = "dotted"
#'   )
#'
#'   # If testing an interval null, mark the interval
#'   if (test_result$properties$interval_null) {
#'       myplot <- myplot + ggplot2::geom_rect(
#'         ggplot2::aes(
#'           xmin = rope_lower,
#'           xmax = rope_upper,
#'           ymin = -Inf,
#'           ymax = Inf
#'         ),
#'         alpha = 0.07,
#'         fill = 'black'
#'       )
#'   }
#'
#'   myplot <- myplot + ggplot2::ylab(NULL)
#'
#'   if (test_result$properties$effect_size_name == "mean") {
#'     ename <- "Mean difference"
#'   } else {
#'     ename <- "Median difference"
#'   }
#'
#'   confidence <- 1 - test_result$properties$alpha
#'   confidence_ta <- 1 - 2*test_result$properties$alpha
#'   xlab <- glue::glue(
#'     "{ename} with {confidence*100}% (thin bar) and {confidence_ta*100}% (thick bar) CIs."
#'   )
#'
#'   if (test_result$properties$interval_null) {
#'     xlab <- paste(
#'       xlab,
#'       "\n",
#'       "The gray shaded area represents the null interval."
#'     )
#'   }
#'
#'   myplot <- myplot + ggplot2::xlab(
#'     xlab
#'   )
#'
#'   return(myplot)
#'
#' }