#'
#' @export
plot_magnitude <- function(
  estimate,
  effect_size = c("mean", "median"),
  data_layout = c("random", "swarm", "none"),
  data_spread = 0.25,
  error_layout = c("halfeye", "eye", "gradient", "none"),
  error_scale = 0.3,
  error_nudge = 0.35,
  error_normalize = c("groups", "all", "panels"),
  ggtheme = NULL
) {

  # Input checks ---------------------------------------------------------------
  warnings <- NULL

  esci_assert_type(estimate, "is.estimate")
  effect_size <- match.arg(effect_size)
  if (effect_size == "median" & is.null(estimate$es_median)) {
    stop("effect_size parameter is 'median' but no median-based effect size available to plot")
  }
  data_layout <- match.arg(data_layout)
  error_layout <- match.arg(error_layout)
  error_normalize <- match.arg(error_normalize)
  if (is.null(data_spread) | !is.numeric(data_spread) | data_spread < 0) {
    warnings <- c(
      warnings,
      glue::glue(
        "data_spread = {data_spread} but this is invalid; replaced with 0.25"
      )
    )
    data_spread <- 0.25
  }
  if (is.null(error_scale) | !is.numeric(error_scale) | error_scale < 0) {
    warnings <- c(
      warnings,
      glue::glue(
        "error_scale = {error_scale} but this is invalid; replaced with 0.3"
      )
    )
    error_scale = 0.3
  }
  if (is.null(error_nudge) | !is.numeric(error_nudge) | error_nudge < 0) {
    warnings <- c(
      warnings,
      glue::glue(
        "error_nudge = {error_nudge} but this is invalid; replaced with 0.25"
      )
    )
    error_nudge <- 0.25
  }
  if(is.null(ggtheme)) { ggtheme <- ggplot2::theme_classic()}


  # Data prep --------------------------------------
  conf_level <- estimate$properties$conf_level

  # Raw data
  plot_raw <- !is.null(estimate$raw_data) & data_layout != "none"
  nudge <- if(plot_raw) error_nudge else 0

  # Group data
  if (effect_size == "mean") {
    gdata <- estimate$es_mean
  } else {
    gdata <- estimate$es_median
  }
  gdata$type <- as.factor("summary")
  gdata$x_label <- gdata$outcome_variable_name
  gdata$y_value <- gdata$effect_size
  gdata$x_value <- seq(from = 1, to = nrow(gdata), by = 1)
  gdata$nudge <- nudge
  if (nrow(gdata[gdata$SE <= 0, ]) > 0) {
    gdata[gdata$SE <= 0, ]$SE <- .Machine$double.xmin
  }

  # Raw data
  if (plot_raw) {
    rdata <- estimate$raw_data
    rdata$type <- as.factor("raw")
    rdata$x_label <- rdata$grouping_variable
    rdata$y_value <- rdata$outcome_variable
    rdata$x_value <- gdata[match(rdata$x_label, gdata$x_label), "x_value"]
    rdata$nudge <- 0
    nudge <- error_nudge
  } else {
    nudge <- 0
  }


  # Build plot ------------------------------------
  # Base plot
  myplot <- ggplot2::ggplot() + ggtheme

  # Group data
  error_glue <-esci_plot_group_data(effect_size)
  error_call <- esci_plot_error_layouts(error_layout)
  error_expression <- parse(text = glue::glue(error_glue))
  myplot <- try(eval(error_expression))

  # Raw data
  if (plot_raw) {
    raw_expression <- esci_plot_raw_data(myplot, data_layout, data_spread)
    myplot <- try(eval(raw_expression))
  }

  # Customize plot -------------------------------
  # Default aesthetics
  myplot <- esci_plot_simple_aesthetics(myplot, use_ggdist = (effect_size == "mean"))

  # X axis
  myplot <- myplot + ggplot2::scale_x_continuous(
    breaks = gdata$x_value + (gdata$nudge*.5),
    labels = gdata$x_label
  )
  myplot <- myplot + ggplot2::coord_cartesian(
    xlim = c(min(gdata$x_value)-0.5, max(gdata$x_value)+0.5)
  )

  # Labels -----------------------------
  vnames <- paste(estimate$es_mean$outcome_variable_name, collapse = ", ")
  ylab <- glue::glue("{vnames}\n{if (plot_raw) 'Data, ' else ''}{effect_size} and {conf_level*100}% confidence interval")
  xlab <- NULL
  myplot <- myplot + ggplot2::xlab(xlab) + ggplot2::ylab(ylab)


  # Attach warnings and return    -------------------
  myplot$warnings <- c(myplot$warnings, warnings)

  return(myplot)

}


#' @export
plot_correlation <- function(
  estimate,
  error_layout = c("halfeye", "eye", "gradient", "none"),
  error_scale = 0.3,
  error_normalize = c("groups", "all", "panels"),
  ggtheme = NULL
) {

  # Input checks ---------------------------------------------------------------
  warnings <- NULL

  esci_assert_type(estimate, "is.estimate")
  error_layout <- match.arg(error_layout)
  error_normalize <- match.arg(error_normalize)
  if (is.null(error_scale) | !is.numeric(error_scale) | error_scale < 0) {
    warnings <- c(
      warnings,
      glue::glue(
        "error_scale = {error_scale} but this is invalid; replaced with 0.3"
      )
    )
    error_scale = 0.3
  }
  if(is.null(ggtheme)) { ggtheme <- ggplot2::theme_classic()}

  # Data prep --------------------------------------
  conf_level <- estimate$properties$conf_level
  effect_size <- "r"
  nudge <- 0

  gdata <- estimate$es_r
  gdata$type <- as.factor("summary")
  gdata$x_label <- gdata$effect
  gdata$y_value <- gdata$effect_size
  gdata$x_value <- seq(from = 1, to = nrow(gdata), by = 1)
  gdata$nudge <- nudge


  # Build plot ------------------------------------
  # Build plot ------------------------------------
  # Base plot
  myplot <- ggplot2::ggplot() + ggtheme

  # Group data
  error_glue <- esci_plot_group_data(effect_size = effect_size)
  error_call <- esci_plot_error_layouts(error_layout)
  error_expression <- parse(text = glue::glue(error_glue))
  myplot <- try(eval(error_expression))


  # Customize plot ------------------------------
  # Default look
  myplot <- esci_plot_simple_aesthetics(myplot, use_ggdist = TRUE)

  # X axis
  myplot <- myplot + ggplot2::scale_x_continuous(
    breaks = gdata$x_value + gdata$nudge,
    labels = gdata$x_label,
  )

  myplot <- myplot + ggplot2::coord_cartesian(
    xlim = c(min(gdata$x_value)-0.5, max(gdata$x_value)+0.5)
  )

  #Labels
  ylab <- glue::glue("Pearson's r and {conf_level*100}% confidence interval")
  xlab <- NULL
  myplot <- myplot + ggplot2::xlab(xlab) + ggplot2::ylab(ylab)

  # Limits
  myplot <- myplot + ylim(-1, 1)

  # Attach warnings and return    -------------------
  myplot$warnings <- c(myplot$warnings, warnings)

  return(myplot)

}


#' @export
plot_proportion <- function(
  estimate,
  error_layout = c("halfeye", "eye", "gradient", "none"),
  error_scale = 0.3,
  error_normalize = c("groups", "all", "panels"),
  ggtheme = NULL
) {

  # Input checks ---------------------------------------------------------------
  warnings <- NULL

  esci_assert_type(estimate, "is.estimate")
  error_layout <- match.arg(error_layout)
  error_normalize <- match.arg(error_normalize)
  if (is.null(error_scale) | !is.numeric(error_scale) | error_scale < 0) {
    warnings <- c(
      warnings,
      glue::glue(
        "error_scale = {error_scale} but this is invalid; replaced with 0.3"
      )
    )
    error_scale = 0.3
  }
  if(is.null(ggtheme)) { ggtheme <- ggplot2::theme_classic()}


  # Data prep --------------------------------------
  conf_level <- estimate$properties$conf_level
  nudge <- 0
  effect_size <- "P"

  gdata <- estimate$overview
  gdata$type <- as.factor("summary")
  gdata$x_label <- gdata$outcome_variable_level
  gdata$y_value <- gdata$P
  gdata$x_value <- seq(from = 1, to = nrow(gdata), by = 1)
  gdata$nudge <- nudge
  gdata$LL <- gdata$P_LL
  gdata$UL <- gdata$P_UL


  # Build plot ------------------------------------
  # Base plot
  myplot <- ggplot2::ggplot() + ggtheme

  # Group data
  error_glue <- esci_plot_group_data(effect_size = effect_size)
  error_call <- esci_plot_error_layouts(error_layout)
  error_expression <- parse(text = glue::glue(error_glue))
  myplot <- try(eval(error_expression))


  # Customize ----------------------------
  # Default look
  myplot <- esci_plot_simple_aesthetics(myplot, use_ggdist = FALSE)

  # X axis
  myplot <- myplot + ggplot2::scale_x_continuous(
    breaks = gdata$x_value + gdata$nudge,
    labels = gdata$x_label
  )

  myplot <- myplot + ggplot2::coord_cartesian(
    xlim = c(min(gdata$x_value)-0.5, max(gdata$x_value)+0.5)
  )


  # Labels
  ylab <- glue::glue("Proportion and {conf_level*100}% confidence interval")
  xlab <- gdata$outcome_variable_name[[1]]
  myplot <- myplot + ggplot2::xlab(xlab) + ggplot2::ylab(ylab)

  # Limits
  myplot <- myplot + ylim(0, 1)

  return(myplot)

}



esci_trans_r_to_z <- function(r) {
  return ( log((1 + r)/(1 - r))/2 )
}

esci_trans_rse_to_sez <- function(n) {
  return(sqrt(1/((n - 3))))
}

esci_trans_z_to_r <- function(x) {
  return ( (exp(2*x) - 1)/(exp(2*x) + 1) )
}

esci_trans_P <- function(x) {
  x[which(x < 0)] <- 0
  x[which(x > 1)] <- 1
  return(x)
}

esci_trans_identity <- function(x) {
  return(x)
}

rtrans <- function(x) {
  return ( log((1 + x)/(1 - x))/2 )
}

rback <- function(x) {
  return ( (exp(2*x) - 1)/(exp(2*x) + 1) )
}


dist_P <- function(mu = 0, sigma = 1, f, n){
  mu <- vec_cast(mu, double())
  sigma <- vec_cast(sigma, double())
  if(any(sigma[!is.na(sigma)] < 0)){
    abort("Standard deviation of a normal distribution must be non-negative")
  }
  new_dist(mu = mu, sigma = sigma, f = f, n = n, class = "dist_normal")
}


