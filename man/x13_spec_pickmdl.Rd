% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/x13_spec_pickmdl.R
\name{x13_spec_pickmdl}
\alias{x13_spec_pickmdl}
\title{Multiple X-13ARIMA model specifications}
\usage{
x13_spec_pickmdl(
  ...,
  arima.p = c(0, 0, 2, 0, 2),
  arima.d = c(1, 1, 1, 2, 1),
  arima.q = c(1, 2, 0, 2, 2),
  arima.bp = 0,
  arima.bd = 1,
  arima.bq = 1,
  automdl.enabled = FALSE
)
}
\arguments{
\item{...}{\code{x13_spec} parameters}

\item{arima.p}{\code{x13_spec} parameter as vector}

\item{arima.d}{\code{x13_spec} parameter as vector}

\item{arima.q}{\code{x13_spec} parameter as vector}

\item{arima.bp}{\code{x13_spec} parameter, possibly as vector}

\item{arima.bd}{\code{x13_spec} parameter, possibly as vector}

\item{arima.bq}{\code{x13_spec} parameter, possibly as vector}

\item{automdl.enabled}{\code{x13_spec} parameter}
}
\value{
List of several \code{x13_spec} output objects
}
\description{
\code{\link{x13_spec}} is run multiple times with input for multiple arima models.
}
\details{
This function behaves like \code{x13_spec} except that some of the parameters may be vectors.
These vectors must be the same length.
}
\examples{
spec5 <- x13_spec_pickmdl(spec = "RSA3", transform.function = "Log")

}
