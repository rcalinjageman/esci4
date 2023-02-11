#'
#' @export
plot_scatter <- function(
    estimate,
    show_line = FALSE,
    show_PI = FALSE,
    show_residuals = FALSE,
    predict_from_x = NULL,
    ggtheme = ggplot2::theme_classic()
) {

    # Check inputs ---------------------------
  # Needs to be of class estimate
  esci_assert_type(estimate, "is.estimate")

  # Check raw data available
  if (is.null(estimate$raw_data) | nrow(estimate$raw_data) == 0) {
    err_string <- stringr::str_interp(
      "This plot only works for estimates with raw data available."
    )
    stop(err_string)
  }

  warnings <- NULL

  plotting_groups <- !is.null(estimate$overview$grouping_variable_name)
  if (plotting_groups) {
    if (!is.null(predict_from_x)) {
      warning("Ignoring predict_from_x because the estimate passed is a difference in r; Not able to do predictions for that type of estimate yet.")
      predict_from_x <- NULL
    }
    if (show_PI){
      warning("Ignoring request to show prediction intervals (show_PI) because estimate passed is a difference in r; Not able to show prediction intervals for this type of estimate yet.")
      show_PI <- FALSE
    }
    if (show_residuals){
      warning("Ignoring request to show residuals (show_residuals) because estimate passed is a difference in r; Not able to show residuals for this type of estimate yet.")
      show_residuals <- FALSE
    }
  }

  rdata <- estimate$raw_data

  # predict_from_x
  if(!is.null(predict_from_x)) {

    if(!is.numeric(predict_from_x)) {
      predict_from_x <- NULL
      warning_string <- stringr::str_interp("'predict_from_x' ignored because it is not numeric, instead it is ${class(predict_from_x)}.")
      warnings <- c(warnings, warning_string)
      warning(warning_string)
    } else {
      if(predict_from_x > max(rdata$x, na.rm = TRUE)) {
        warning_string <- stringr::str_interp("'predict_from_x' ignored because it is out of range.  predict_from_x = ${predict_from_x}, but highest y value is $[.2f]{max(rdata$x, na.rm = TRUE)}.")
        warnings <- c(warnings, warning_string)
        warning(warning_string)
        predict_from_x <- NULL
      } else {
        if(predict_from_x < min(rdata$x, na.rm = TRUE)) {
          warning_string <- stringr::str_interp("'predict_from_x' ignored because it is out of range.  predict_from_x = ${predict_from_x}, but lowest x value is $[.2f]{min(rdata$x, na.rm = TRUE)}.")
          warnings <- c(warnings, warning_string)
          warning(warning_string)
          predict_from_x <- NULL

        }
      }
    }
  }


  # Prep for building graph ---------------------------
  ylab <- estimate$es_r$y_variable_name
  xlab <- estimate$es_r$x_variable_name

  if (!plotting_groups) {
    myslope <- estimate$regression$values[2]
    myintercept <- estimate$regression$values[1]
    rdata$predicted <- rdata$x * myslope + myintercept
  }


  # Build the plot

  # Points and regression line
  if (plotting_groups) {

    rdata$type <- "Unused"
    rdata[rdata$grouping_variable == estimate$es_r_difference$effect[[1]], ]$type <- "Comparison"
    rdata[rdata$grouping_variable == estimate$es_r_difference$effect[[2]], ]$type <- "Reference"
    my_labels <- c(
      paste(estimate$es_r_difference$effect[[2]], ": *r* = ", format( estimate$es_r_difference$effect_size[[2]], digits = 2), sep = ""),
      paste(estimate$es_r_difference$effect[[1]], ": *r* = ", format( estimate$es_r_difference$effect_size[[1]], digits = 2), sep = ""),
      if (nrow(estimate$es_r) > 2) "All others" else NULL
    )

    my_fills <- c(
      "Reference" =  "#008DF9",
      "Comparison" = "#009F81",
      "Unused" = "gray65"
    )
    my_shapes <- c(
      "Reference" =  "square filled",
      "Comparison" = "circle filled",
      "Unused" = "diamond filled"
    )
    my_colour <- c(
      "Reference" =  "black",
      "Comparison" = "black",
      "Unused" = "black"
    )
    my_alphas <- c(
      "Reference" =  0.75,
      "Comparison" = 0.75,
      "Unused" = .2
    )
    my_sizes <- c(
      "Reference" =  4,
      "Comparison" = 4,
      "Unused" = 1
    )


    # Base and theme
    myplot <- ggplot2::ggplot(
      data = rdata,
      ggplot2::aes(
        x = x,
        y = y,
        group = type
      )
    )

    myplot <- myplot + ggplot2::geom_point(
      ggplot2::aes(
        color = type,
        fill = type,
        alpha = type,
        size = type,
        shape = type
      )
    )
    myplot <- esci_plot_layers(myplot, "raw_point")

    myplot <- myplot + ggtheme
    myplot <- myplot + ggplot2::scale_color_manual(values = my_colour, labels = my_labels)
    myplot <- myplot + ggplot2::scale_fill_manual(values = my_fills, labels = my_labels)
    myplot <- myplot + ggplot2::scale_shape_manual(values = my_shapes, labels = my_labels)
    myplot <- myplot + ggplot2::scale_alpha_manual(values = my_alphas, labels = my_labels)
    myplot <- myplot + ggplot2::scale_size_manual(values = my_sizes, labels = my_labels)

    myplot$esci_scale_labels <- my_labels


    plot_levels <- c(
      "#008DF9" = "Reference",
      "#009F81" = "Comparison"
    )

    for (x in 1:length(plot_levels)) {
      next_up <- plot_levels[x]
      this_data <- rdata[rdata$type == next_up, ]
      if (nrow(this_data) > 0) {

        myplot <- myplot + ggplot2::geom_smooth(
          data = this_data,
          formula = y ~ x,
          method='lm',
          se = TRUE,
          level = estimate$properties$conf_level,
          color = names(plot_levels[x]),
          fill = names(plot_levels[x]),
          alpha = 0.25
        )
        myplot <- esci_plot_layers(myplot, paste("summary_", next_up, "_line", sep = ""))
      }
    }


  } else {
    # Base and theme
    myplot <- ggplot2::ggplot(
      data = rdata,
      ggplot2::aes(
        x = x,
        y = y
      )
    )
    myplot <- myplot + ggtheme


    # Regression line
    if (show_line) {
      myplot <- myplot + ggplot2::geom_smooth(
        data = rdata,
        formula = y ~ x,
        method='lm',
        se = TRUE,
        level = estimate$properties$conf_level,
        color = "black",
        fill = "blue",
        alpha = 0.25
      )
      myplot <- esci_plot_layers(myplot, "summary_Reference_line")
    }

    # Points
    myplot <- myplot + ggplot2::geom_point(
      shape = 21,
      fill = "NA",
      colour = "blue",
      size = 3
    )
    myplot <- esci_plot_layers(myplot, "raw_Reference_point")
  }


  # Prediction intervals
  if (show_PI) {
    myplot <- myplot + ggplot2::geom_line(
      data = rdata,
      ggplot2::aes(y=upr, x = x),
      color = "red",
      linetype = "dashed"
    )
    myplot <- esci_plot_layers(myplot, "prediction_interval_upper")

    myplot <- myplot + ggplot2::geom_line(
      data = rdata,
      ggplot2::aes(y=lwr, x = x),
      color = "red",
      linetype = "dashed"
    )
    myplot <- esci_plot_layers(myplot, "prediction_interval_lower")

  }


  # Residuals
  if (show_residuals) {
    myplot<- myplot + ggplot2::geom_segment(
      data = rdata,
      ggplot2::aes(
        x = x,
        xend = x,
        y = y,
        yend = predicted
      ),
      colour = "red"
    )
    myplot <- esci_plot_layers(myplot, "residuals")
  }


  # Style options
  if (!plotting_groups) {
    myplot <- myplot + theme(legend.position="none")
  } else {
    myplot <- myplot + ggplot2::guides(group=ggplot2::guide_legend(title=estimate$es_r$grouping_variable_name[[1]]))
  }
  myplot <- myplot + theme(axis.line = element_line(size = 1, linetype = "solid"))


  if(!is.null(predict_from_x)) {
    ny_min <- min(ggplot2::layer_scales(myplot)$y$range$range)
    ny_max <- max(ggplot2::layer_scales(myplot)$y$range$range)
    nx_min <- min(ggplot2::layer_scales(myplot)$x$range$range)
    nx_max <- max(ggplot2::layer_scales(myplot)$x$range$range)
    nxrange <- nx_max - nx_min

    ypr <- (predict_from_x * myslope) + myintercept
    yplabel <- paste("        Y' = ", format(ypr, digits = 2))
    myplot <- myplot + ggplot2::annotate("text", x = nx_min - 0.2*nxrange, y = ypr, label = yplabel, color = "red")
    myplot <- esci_plot_layers(myplot, "prediction_y_label")

    xlabel <- paste("X =", predict_from_x)
    y_half <- ny_min - (0.2* (ny_max - ny_min))
    myplot <- myplot + ggplot2::annotate("text", x = predict_from_x, y = y_half, label = xlabel, color = "red")
    myplot <- esci_plot_layers(myplot, "prediction_x_label")

    pi <- predict(estimate$properties$lm, interval = "prediction", newdata = data.frame(x = predict_from_x), level = estimate$properties$conf_level)
    xlab <- paste(xlab, "\n<br>At *X* =", predict_from_x, ": *Y*' =", format(ypr, digits = 2), ", ", format(estimate$properties$conf_level*100, digits=0), "% PI[", format(pi[1, "lwr"], digits=2), ",", format(pi[1, "upr"], digits=2), "]")
    myplot <- myplot + geom_segment(alpha = 0.1, size = 2, color = "red", aes(x = predict_from_x, xend = predict_from_x, y=pi[1, "lwr"], yend = pi[1, "upr"]))
    myplot <- esci_plot_layers(myplot, "prediction_prediction_interval")
    myplot <- myplot + geom_segment(linetype = "dotted", aes(x = predict_from_x, xend = predict_from_x, y = ny_min, yend = ypr), size = 2)
    myplot <- esci_plot_layers(myplot, "prediction_vertical_line")
    myplot <- myplot + geom_segment(linetype = "dotted", aes(x = nx_min, xend = predict_from_x, y = ypr, yend = ypr), size = 2)
    myplot <- esci_plot_layers(myplot, "prediction_horizontal_line")
    myplot <- myplot + annotate("point", x = predict_from_x, y = ypr, colour = "red", shape = 23, size=4, fill="white")
    myplot <- esci_plot_layers(myplot, "prediction_point")
  }

  # Default scale will be same z range for x and y
  y_min <- min(ggplot2::layer_scales(myplot)$y$range$range)
  y_max <- max(ggplot2::layer_scales(myplot)$y$range$range)
  x_min <- min(ggplot2::layer_scales(myplot)$x$range$range)
  x_max <- max(ggplot2::layer_scales(myplot)$x$range$range)
  y_mean <- mean(rdata$y, na.rm = TRUE)
  x_mean <- mean(rdata$x, na.rm = TRUE)
  y_s <- sd(rdata$y, na.rm = TRUE)
  x_s <- sd(rdata$x, na.rm = TRUE)

  y_zmin <- (y_min - y_mean) / y_s
  y_zmax <- (y_max - y_mean) / y_s
  x_zmin <- (x_min - x_mean) / x_s
  x_zmax <- (x_max - x_mean) / x_s

  if (y_zmin < x_min) {
    x_min <- (x_s * y_zmin) + x_mean
  } else {
    y_min <- (y_s * x_zmin) + y_mean
  }

  if (y_zmax > x_zmax) {
    x_max <- (x_s * y_zmax) + x_mean
  } else {
    y_max <- (y_s * x_zmax) + y_mean
  }

  myplot <- myplot + ggplot2::ylim(c(y_min, y_max))
  myplot <- myplot + ggplot2::xlim(c(x_min, x_max))


  myplot <- myplot + ylab(ylab) + xlab(xlab)


  myplot <- myplot + ggplot2::theme(
    axis.text.y = ggtext::element_markdown(),
    axis.title.y = ggtext::element_markdown(),
    axis.text.x = ggtext::element_markdown(),
    axis.title.x = ggtext::element_markdown(),
    legend.title = ggtext::element_markdown(),
    legend.text = ggtext::element_markdown()
  )

  myplot$warnings <- warnings

  return(myplot)
}
