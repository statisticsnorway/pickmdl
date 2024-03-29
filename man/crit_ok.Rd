% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/crit_ok.R
\name{crit_ok}
\alias{crit_ok}
\title{PICKMDL "first" check}
\usage{
crit_ok(sa)
}
\arguments{
\item{sa}{A \code{\link{x13}} output object}
}
\value{
\code{TRUE} or \code{FALSE}
}
\description{
Check whether \code{\link{x13}} output is ok according to
the  PICKMDL "first" method
}
\details{
Unlike \code{\link{ok}}, this function does the actual calculations.
}
\examples{
myseries <- pickmdl_data("myseries")

a <- x13(myseries, x13_spec(spec = "RSA3", transform.function = "Log"))
b <- x13(myseries, x13_spec(spec = "RSA3", transform.function = "None"))

crit_ok(a)
crit_ok(b)

}
\seealso{
\code{\link{crit_selection}}
}
