% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/estimate_pdiff_ind_contrast.R
\name{estimate_pdiff_ind_contrast}
\alias{estimate_pdiff_ind_contrast}
\title{Estimate the magnitude of difference for an independent groups contrast.}
\usage{
estimate_pdiff_ind_contrast(
  data = NULL,
  outcome_variable = NULL,
  grouping_variable = NULL,
  cases = NULL,
  ns = NULL,
  contrast = NULL,
  case_label = 1,
  grouping_variable_levels = NULL,
  outcome_variable_name = "My outcome variable",
  grouping_variable_name = "My grouping variable",
  conf_level = 0.95,
  count_NA = FALSE
)
}
\arguments{
\item{data}{For raw data - a dataframe or tibble}

\item{outcome_variable}{For raw data - The column name of the outcome
variable, or a vector of numeric data}

\item{grouping_variable}{For raw data - The column name of the grouping
variable, or a vector of group names}

\item{cases}{For summary data - A vector of 2 or more event counts,
each an integer >= 0}

\item{ns}{For summary data - A vector of sample sizes, same length as counts,
each an integer >= correspond event count}

\item{contrast}{A vector of group weights}

\item{case_label}{An optional numeric or character label
For summary data, used as the label and defaults to 'Affected'.  For raw
data, used to specify the level used for the proportion.}

\item{grouping_variable_levels}{For summary data - An optional vector of
group labels, same length as means}

\item{outcome_variable_name}{Optional friendly name for the outcome variable.
Defaults to 'My outcome variable' or the outcome variable column name if a
data frame is passed.}

\item{grouping_variable_name}{Optional friendly name for the grouping
variable.  Defaults to 'My grouping variable' or the grouping variable
column name if a data.frame is passed.}

\item{conf_level}{The confidence level for the confidence interval.  Given in
decimal form.  Defaults to 0.95.}

\item{count_NA}{Logical to count NAs (TRUE) in total N or not (FALSE)}
}
\value{
Returns object of class esci_estimate
}
\description{
\loadmathjax
\code{estimate_mdiff_ind_contrast} returns the point estimate and
confidence interval for the proportion difference in a linear contrast.
}
\examples{
# From Summary Data ------------------------------------

estimate_pdiff_ind_contrast(
  cases = c(26, 24, 38),
  ns = c(60, 60, 60),
  contrast = c(1/2, 1/2, -1),
  grouping_variable_levels = c("Therapy", "Drug", "Control")
)

}
