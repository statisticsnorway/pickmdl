
#' x13 with PICKMDL and partial concurrent possibilities  
#' 
#' \code{\link{x13}} can be run as usual (automdl) or with a PICKMDL specification.
#' The ARIMA model, outliers and filters can be identified at a certain date and then held fixed (with a new outlier-span).
#' 
#' @param series `x13` parameter
#' @param spec An \code{\link{x13_spec}} output object or a list of several objects as outputted from \code{\link{x13_spec_pickmdl}}. 
#'             In the case of a single object and when `automdl.enabled` is `FALSE`, `spec` will be converted internally 
#'             by `x13_spec_pickmdl` with default five arima model specifications. 
#' @param ... Further `x13` parameters (currently only parameter `userdefined` is additional parameter to `x13`).
#' @param pickmdl_method \code{\link{crit_selection}} parameter
#' @param star           \code{\link{crit_selection}} parameter
#' @param when_star      \code{\link{crit_selection}} parameter
#' @param identification_end To shorten the series before runs used to identify (arima) parameters.
#'            That is, the series is shortened by `window(series,` `end = identification_end)`.
#' @param identification_estimate.to   To set \code{\link{x13_spec}} parameter `estimate.to` before runs used to identify (arima) parameters.  
#'            This is an alternative to  `identification_end`.
#' @param identify_t_filter When `TRUE`, Henderson trend filter is identified by the shortened (see above) series.
#' @param identify_s_filter When `TRUE`, Seasonal moving average filter is identified by the shortened series.
#' @param identify_outliers When `TRUE`, Outliers are identified by the shortened series.
#' @param automdl.enabled When `TRUE`, automdl is performed instead of pickmdl. 
#'            If `spec` is a list of several objects as outputted from `x13_spec_pickmdl`, only first object is used.
#' @param verbose Printing information to console when `TRUE`. 
#' @param output One of `"sa"` (default), `"spec"` (final spec), `"sa_spec"` (both) and `"all"`. See examples.        
#'
#' @return By default an `x13` output object, or otherwise a list as specified by parameter `output`.
#' @export
#' @importFrom stats window
#'
#' @examples
#' myseries <- pickmdl_data("myseries")
#' 
#' spec_a  <- x13_spec(spec = "RSA3", transform.function = "Log")
#' 
#' a <- x13_pickmdl(myseries, spec_a, verbose = TRUE)
#' a$regarima
#' 
#' a2 <- x13_pickmdl(myseries, spec_a, identification_end = c(2014, 2))
#' a2$regarima
#' 
#' # As above, another way
#' a3 <- x13_pickmdl(myseries, spec_a, identification_estimate.to = "2014-03-01")
#' a3$regarima
#' 
#' a4 <- x13_automdl(myseries, spec_a, identification_end = c(2014, 2))
#' a4$regarima
#' 
#' # As above, another way
#' spec_a_single  <- x13_spec(spec = "RSA3", transform.function = "Log")
#' a5 <- x13_automdl(myseries, spec_a_single, identification_estimate.to = "2014-03-01")
#' a5$regarima
#' 
#' allvar <- pickmdl_data("allvar")
#' 
#' spec_b <- x13_spec(
#'             spec = "RSA3", transform.function = "Log",
#'             usrdef.varEnabled = TRUE, 
#'             usrdef.varType = c("Calendar", "Calendar"), 
#'             usrdef.var = allvar, 
#'             outlier.enabled = FALSE, 
#'             usrdef.outliersEnabled = TRUE,
#'             usrdef.outliersType = rep("LS", 20), 
#'             usrdef.outliersDate = c("2009-01-01", "2016-01-01", 
#'                                     "2020-03-01", "2020-04-01", "2020-05-01", 
#'                                     "2020-06-01", "2020-07-01", "2020-08-01", 
#'                                     "2020-09-01", "2020-10-01", "2020-11-01", 
#'                                     "2020-12-01", "2021-01-01", "2021-02-01",
#'                                     "2021-03-01", "2021-04-01", "2021-05-01",
#'                                     "2021-06-01", "2021-07-01", "2021-08-01"))
#' b <- x13_pickmdl(myseries, spec_b, identification_end = c(2020, 2))                                     
#' b$regarima
#' 
#' # automdl instead  
#' b1 <- x13_automdl(myseries, spec_b, identification_end = c(2020, 2))
#' b1$regarima
#' 
#' # effect of identify_t_filter and identify_s_filter
#' set.seed(1)
#' rndseries <- ts(rep(1:12, 20) + (1 + (1:240)/20) * runif(240) + 0.5 * c(rep(1, 120), (1:120)^2), 
#'                 frequency = 12, start = c(2000, 1))
#' spec_c <- x13_spec(outlier.enabled = FALSE)               
#' c1 <- x13_automdl(rndseries, spec_c, identification_end = c(2009, 12))    
#' c1$decomposition
#' c2 <- x13_automdl(rndseries, spec_c, identification_end = c(2009, 12), identify_t_filter = TRUE) 
#' c2$decomposition
#' c3 <- x13_automdl(rndseries, spec_c, identification_end = c(2009, 12), identify_t_filter = TRUE, 
#'                   identify_s_filter = TRUE)     
#' c3$decomposition                       
#' 
#' 
#' # Warning when transform.function = "None"
#' spec_d  <- x13_spec(spec = "RSA3", transform.function = "None")
#' d <- x13_pickmdl(myseries, spec_d, verbose = TRUE)
#' 
#' # Warning avoided (when_star) and 2nd (star) model selected 
#' d2 <- x13_pickmdl(myseries, spec_d, star = 2, when_star = NULL, verbose = TRUE)
#' 
#' 
#' # As a2, with output = "all"
#' k <- x13_pickmdl(myseries, spec_b, identification_end = c(2010, 2), output = "all")
#' k$sa$decomposition  # As a2$decomposition 
#' k$mdl_nr            # index of selected model used to identify parameters
#' k$sa_mult[[k$mdl_nr]]$decomposition  # decomposition for model to identify
#' k$crit_tab          # Table of criteria 
#' 
#' 
#' # Effect of identify_outliers
#' q1 <- x13_pickmdl(myseries, x13_spec("RSA3", outlier.usedefcv = FALSE, outlier.cv = 3), 
#'                   identification_end = c(2010, 2))
#' q2 <- x13_pickmdl(myseries, x13_spec("RSA3", outlier.usedefcv = FALSE, outlier.cv = 3), 
#'                   identification_end = c(2010, 2), identify_outliers = TRUE, 
#'                   verbose = TRUE, output = "all")
#' q3 <- x13_pickmdl(myseries, q2$spec, identification_end = c(2018, 2), identify_outliers = TRUE, 
#'                   verbose = TRUE)
#' 
#' q1$regarima
#' q2$sa$regarima
#' q3$regarima
x13_pickmdl <- function(series, spec, ..., 
                        pickmdl_method = "first", star = 1, when_star = warning,
                        identification_end = NULL, identification_estimate.to = NULL, 
                        identify_t_filter = FALSE, identify_s_filter = FALSE, 
                        identify_outliers = FALSE,
                        automdl.enabled = FALSE,
                        verbose = FALSE,
                        output = "sa") {
  
  
  if(!(output %in% c("sa", "spec", "sa_spec", "all")))
    stop('Allowed values of parameter output are "sa", "spec", "sa_spec" and "all".')
  
  automdl.enabled <- isTRUE(automdl.enabled)
  
  if (!all(apply(sapply(spec, class), 1, unique) == c("SA_spec", "X13"))) {
    if (!all(class(spec) == c("SA_spec", "X13"))) {
      stop("Wrong `spec` input")
    }
    if (automdl.enabled) {
      spec <- list(spec)
    } else {
      spec <- x13_spec_pickmdl(spec)
    }
  }
  
  if (automdl.enabled) {
    spec <- spec[1]
    spec[[1]] <- x13_spec(spec[[1]], automdl.enabled = TRUE)
  }
  
  if (is.null(identification_estimate.to)) {
    sa_mult <- x13_multi(series = window(series, end = identification_end), spec = spec, ...)
  } else {
    sa_mult <- x13_multi(series = window(series, end = identification_end), 
                         spec = lapply(spec, x13_spec, estimate.to = identification_estimate.to), ...)
  }
  
  if (automdl.enabled) {
    arma <- sa_mult[[1]]$regarima$arma  # as.numeric remove names, as.numeric needed? can be factors?  
    spec[[1]] <- x13_spec(spec[[1]], 
                          arima.p = as.numeric(arma["p"]), 
                          arima.d = as.numeric(arma["d"]), 
                          arima.q = as.numeric(arma["q"]), 
                          arima.bp = as.numeric(arma["bp"]), 
                          arima.bd = as.numeric(arma["bd"]), 
                          arima.bq = as.numeric(arma["bq"]),
                          automdl.enabled = FALSE)
    crit_tab <- NULL
    mdl_nr <- 1
  } else {
    crit_tab <- crit_table(sa_mult)
    
    mdl_nr <- crit_selection(crit_tab, pickmdl_method = pickmdl_method, star = star, when_star = when_star)
  }
  
  if(verbose){
    print(sa_mult[[mdl_nr]]$regarima$arma)
  }
  
  spec <- spec[[mdl_nr]] 
  

  
  if (identify_t_filter | identify_s_filter) {
    filters <- filter_input(sa_mult[[mdl_nr]])
    if (identify_t_filter) {
      spec <- x13_spec(spec, x11.trendAuto = FALSE, x11.trendma = filters[["x11.trendma"]])
    }
    if (identify_s_filter) {
      spec <- x13_spec(spec, x11.seasonalma = filters[["x11.seasonalma"]])
    }
    if (verbose) {
      print(unlist(filters)[c(identify_t_filter, identify_s_filter)], quote = FALSE)
    }
  }
  
  if (identify_outliers) {
      spec <- update_spec_outliers(spec, sa_mult[[mdl_nr]], verbose = verbose)
  }
  
  if(output == "spec"){
    return(spec)
  }
  
  sa <- x13(series = series, spec = spec, ...)
  
  
  if(output == "sa_spec"){
    return(list(sa = sa, spec = spec))
  }
  
  if(output == "all"){
    return(list(sa = sa, spec = spec, mdl_nr = mdl_nr, crit_tab = crit_tab, sa_mult = sa_mult))
  }
  
  sa
}

#' @rdname x13_pickmdl
#' @export
x13_automdl <- function(..., automdl.enabled = TRUE){
  x13_pickmdl(..., automdl.enabled = automdl.enabled)
}


