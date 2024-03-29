% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/meta_proportion.R
\name{meta_proportion}
\alias{meta_proportion}
\title{Estimate meta-analytic difference in magnitude between two ind. groups}
\usage{
meta_proportion(
  data,
  cases,
  ns,
  labels = NULL,
  moderator = NULL,
  contrast = NULL,
  effect_label = "My effect",
  random_effects = TRUE,
  conf_level = 0.95
)
}
\arguments{
\item{data}{A dataframe or tibble}

\item{cases}{cases}

\item{ns}{comparison}

\item{labels}{labels}

\item{moderator}{mod}

\item{contrast}{contrast}

\item{effect_label}{effect_label}

\item{random_effects}{re}

\item{conf_level}{The confidence level for the confidence interval.  Given in
decimal form.  Defaults to 0.95.}
}
\value{
Returnsobject of class esci_estimate
}
\description{
\code{meta_proportion} returns
}
