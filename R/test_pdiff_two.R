test_pdiff_two <- function() {

  estimate_pdiff_two(
    comparison_cases = 10,
    comparison_n = 20,
    reference_cases = 78,
    reference_n = 252,
    conf_level = 0.95
  )

  estimate_pdiff_two(
    comparison_cases = 10,
    comparison_n = 20,
    reference_cases = 78,
    reference_n = 252,
    case_label = "Depressed",
    not_case_label = "Anxious",
    grouping_variable_levels = c("Original", "Replication"),
    outcome_variable_name = "Eval",
    grouping_variable_name = "Study",
    conf_level = 0.95
  )


  psych_status <- as.factor(
    sample(
      x = c("Depressed", "Anxious"),
      size = 300,
      replace = TRUE
    )
  )

  treatment <- as.factor(
    sample(
      x = c("Control", "Treated", "Other"),
      size = 300,
      replace = TRUE
    )
  )

  my_proportion_data <- data.frame(
    psych_stat = psych_status,
    treat = treatment
  )

  estimate_pdiff_two(
    outcome_variable = psych_status,
    grouping_variable = treatment
  )

  estimate_pdiff_two(
    outcome_variable = psych_status,
    grouping_variable = treatment,
    case_label = 2
  )

  estimate_pdiff_two(
    outcome_variable = psych_status,
    grouping_variable = treatment,
    case_label = "Depressed"
  )

  estimate_pdiff_two(
    my_proportion_data,
    psych_stat,
    treat,
    case_label = "Depressed"
  )


  estimate_pdiff_two(
    my_proportion_data,
    psych_stat,
    treat,
    case_label = "Anxious"
  )


}