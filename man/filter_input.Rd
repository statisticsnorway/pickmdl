% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/filter_input.R
\name{filter_input}
\alias{filter_input}
\title{x13 output filters to x13 input filters}
\usage{
filter_input(sa)
}
\arguments{
\item{sa}{A \code{\link{x13}} output object}
}
\value{
list of \code{x11.trendma} (numeric) and \code{x11.seasonalma} (character)
}
\description{
Elements \code{t_filter} and \code{s_filter} are transformed to input parameters \code{x11.trendma} and \code{x11.seasonalma}
}
\examples{
myseries <- pickmdl_data("myseries")

a <- x13(myseries, spec = "RSA3")

a$decomposition$t_filter
a$decomposition$s_filter
filter_input(a)

spec_b <- x13_spec(spec = "RSA3", x11.trendma = 13, x11.seasonalma = "Stable", 
                   x11.trendAuto = FALSE)
b <- x13(myseries, spec = spec_b)

b$decomposition$t_filter
b$decomposition$s_filter
filter_input(b)
}
