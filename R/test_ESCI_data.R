#' @export
test_ESCI_data <- function() {
  res <- list()

  res$describe <- data.frame(
    laptop_transcription = c(
      13.7	,
      21.1	,
      15.2	,
      30.4	,
      12.8	,
      9.6	,
      9.3	,
      17.7	,
      15.4	,
      8.7	,
      12.8	,
      10.6	,
      5.1	,
      16.7	,
      17.7	,
      8.7	,
      26.4	,
      18	,
      19	,
      16.9	,
      18.8	,
      8.5	,
      1.2	,
      11.5	,
      21.4	,
      10.3	,
      9	,
      12.8	,
      12	,
      34.7	,
      4.1
    )
  )

  res$data_two <- data.frame(
    transcription = c(
      12.1	,
      6.5	,
      8.1	,
      7.6	,
      12.2	,
      10.8	,
      1	,
      2.9	,
      14.4	,
      8.4	,
      17.7	,
      20.1	,
      2.1	,
      11.1	,
      11.2	,
      10.7	,
      1.9	,
      5.2	,
      9.7	,
      5.2	,
      2.4	,
      7.1	,
      8.7	,
      8	,
      11.3	,
      8.5	,
      9.1	,
      4.5	,
      9.2	,
      13.3	,
      18.3	,
      2.8	,
      5.1	,
      12.4	,
      13.7	,
      21.1	,
      15.2	,
      30.4	,
      12.8	,
      9.6	,
      9.3	,
      17.7	,
      15.4	,
      8.7	,
      12.8	,
      10.6	,
      5.1	,
      16.7	,
      17.7	,
      8.7	,
      26.4	,
      18	,
      19	,
      16.9	,
      18.8	,
      8.5	,
      1.2	,
      11.5	,
      21.4	,
      10.3	,
      9	,
      12.8	,
      12	,
      34.7	,
      4.1
    ),
    condition = c(
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Pen'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'	,
      'Laptop'
    )
  )

  res$summary_two <- list(
    laptop_m = 12.09,
    laptop_n = 103,
    laptop_s = 5.52,
    pen_m = 6.88,
    pen_n = 48,
    pen_s = 4.22
  )

  res$data_paired <- data.frame(
    pretest = c(
      13,
      12,
      12,
      9,
      14,
      17,
      14,
      9,
      6,
      7,
      11,
      15
    ),
    posttest = c(
      14,
      13,
      16,
      12,
      15,
      18,
      13,
      10,
      10,
      8,
      14,
      16
    )
  )


  pretest_m <- 12.88
  pretest_s <- 3.4
  posttest_m <- 14.25
  posttest_s <- 4.28
  N <- 16
  s_diff <- 2.13
  cor <- (pretest_s^2 + posttest_s^2 - s_diff^2) / (2*pretest_s*posttest_s)

  res$summary_paired <- list(
    pretest_m = pretest_m,
    pretest_s = pretest_s,
    posttest_m = posttest_m,
    posttest_s = posttest_m,
    N = N,
    s_diff = s_diff,
    cor = cor
  )

  return(res)
}
