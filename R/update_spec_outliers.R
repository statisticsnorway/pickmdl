#' Update x13 spec with outliers 
#' 
#' Update an `x13_spec` output object with outliers from an `x13` output object.
#'
#' @param sa   An \code{\link{x13}} output object
#' @param spec An \code{\link{x13_spec}} output object 
#' @param day Day of month as character to be used in outlier coding 
#' @param verbose Printing information to console when `TRUE`.
#' @param input_output When `TRUE` output is a list of `x13_spec` parameters 
#'                     instead of an updated spec.     
#'
#' @return `update_spec_outliers` returns an updated `x13_spec` output object with
#'          new outliers and updated `outlier.from`.  
#'         `update_outliers` returns a data frame with outlier variables used to update. 
#' @export
#' @importFrom stats end frequency
#' @importFrom RJDemetra s_span s_preOut
#'
#' @note For special use, parameter `sa` to `update_outliers` can be a 
#'       data frame of outliers (as created by \code{\link{corona_outliers}}). 
#' 
#' @examples
#' myseries <- ipi_c_eu[, "FR"]
#' 
#' spec_1 <- x13_spec(spec = "RSA3", transform.function = "None", usrdef.outliersEnabled = TRUE, 
#'                    usrdef.outliersType = "AO", usrdef.outliersDate = "2007-03-01", 
#'                    outlier.usedefcv = FALSE, outlier.cv = 3)
#'                    
#' spec_2 <- x13_spec(spec_1, estimate.to = "2018-08-01")
#' 
#' a <- x13(myseries, spec_2)
#' 
#' update_outliers(a, spec_1)
#' 
#' spec_3 <- update_spec_outliers(a, spec_1)
#' 
#' s_span(spec_1)
#' s_span(spec_2)
#' s_span(spec_3)
#' 
#' s_preOut(spec_1)
#' s_preOut(spec_2)
#' s_preOut(spec_3)
#' 
#' update_spec_outliers(a)
update_spec_outliers <- function(sa, spec = NULL, day = "01", verbose = FALSE, input_output = is.null(spec)) {
  
  freq = frequency(sa$final$series)
  
  if (!(freq %in%  c(4, 12))) {
    stop("Only frequencies 4 and 12 implemented")
  }
  
  # sa$regarima$model$spec_rslt$T.span is "dangerous" hack
  # but general solution (s_span(sa) is not and end of series is not)
  end_span = strsplit(sa$regarima$model$spec_rslt$T.span, split="to ")[[1]][2]
  
  if (freq == 12) {
    end_span_integer <- rev(as.integer(strsplit(end_span, split = "-")[[1]]))
  } else { # freq == 4
    strsplit_end_span <- strsplit(end_span, split = "-")[[1]]
    end_span_integer <- c(as.integer(strsplit_end_span[2]), 
                          as.integer(factor(strsplit_end_span[1], levels = c("I", "II", "III", "IV"))))
  }
  
  new_from_integer = end(ts(1:2, start = end_span_integer, frequency = freq))
  
  if (freq == 4) {
    new_from_integer[2] <- 1 + (new_from_integer[2] - 1) * 3
  }
  
  from_ <- sub(".", "-", sprintf("%7.2f", (new_from_integer[1] + new_from_integer[2]/100)), fixed = TRUE)
  new_outlier.from <- paste(from_, day, sep = "-")
  
  if(!is.null(spec)){
    s_span_ <- s_span(spec)
    old_outlier.from <- s_span_[rownames(s_span_) == "outlier", "d0"]
    
    # as.character to avoid "‘<=’ not meaningful for factors" in old r versions 
    old_outlier.from <- as.character(old_outlier.from)   
  } else {
    old_outlier.from <- NA
  }
  
  if (is.na(old_outlier.from)){
    old_outlier.from <- "0000-00-00"  ## To be used in comparison below 
  }
  
  
  if (new_outlier.from <= old_outlier.from) {
    if(verbose) cat("outlier.from not updated:", old_outlier.from, "\n")
    if (input_output) {
      new_outlier.from <- old_outlier.from
    } else {
      return(spec)
    } 
  }
  
  if (!input_output) {
    spec <- x13_spec(spec, outlier.from = new_outlier.from)
  }
  
  if(verbose) cat("outlier.from updated:", new_outlier.from)
  
  updated <- update_outliers(sa = sa, spec = spec, day = day, null_when_no_new = !input_output, verbose = verbose)
  
  if (is.null(updated)) {
    return(spec)
  }
  
  if (input_output) {
    return(list(outlier.from = new_outlier.from, 
                 usrdef.outliersEnabled = TRUE, usrdef.outliersType = as.character(updated$type), usrdef.outliersDate = as.character(updated$date)))
  }
  
  # as.character for old r versions 
  x13_spec(spec, usrdef.outliersEnabled = TRUE, usrdef.outliersType = as.character(updated$type), usrdef.outliersDate = as.character(updated$date))
  
}

#' @rdname update_spec_outliers
#' @param null_when_no_new Whether to return `NULL` when no new outliers found. 
#' @export
update_outliers <- function(sa, spec, day = "01", null_when_no_new = TRUE, verbose = FALSE) {
  
  if(!is.null(spec)){
    pre <- s_preOut(spec)
  } else {
    pre <- NULL
  }

  if(is.data.frame(pre)){
    pre <- ForceCharacterDataFrame(pre) # for old r versions 
  }
  
  if (!length(nrow(pre))) {
    pre <- matrix(0, 0, 0)  # nrow is 0
  }
  
  if (!nrow(pre)) {  # when nrow is 0
    pre <- data.frame(type = character(0), date = character(0), stringsAsFactors = FALSE) # stringsAsFactors for old r versions 
  } else {
    pre <- pre[, c("type", "date")]
  }
  
  pre_date_mnd <- substr(pre$date, 1, 7)
  
  if (is.data.frame(sa)) {  # special use
    sa_o <- sa[!(sa$date %in% pre$date), , drop = FALSE]
    if (null_when_no_new & !nrow(sa_o)) {
      return(NULL)
    }
  } else {
    sa_o <- sa_out(sa)
    
    if (length(sa_o)) {
      sa_o <- sa_o[!(sa_o$date %in% substr(pre$date, 1, 7)), , drop = FALSE]
    } else {
      #sa_o <- matrix(0, 0, 0)  # nrow is 0
      sa_o <- data.frame(type = character(0), date = character(0), stringsAsFactors = FALSE) # Better when !null_when_no_new 
    }
    
    if (null_when_no_new & !nrow(sa_o)) {
      if(verbose) cat("  No new outliers.\n")
      return(NULL)
    }
    if(verbose) cat("  New outliers:", paste(sa_o$date, collapse = ", "), "\n")
    
    if (nrow(sa_o)) {
      sa_o$date <- paste(sa_o$date, day, sep = "-")
    }
  }
  
  rbind(pre, sa_o)
}


sa_out <- function(a) {
  
  s <- row.names(a$regarima$regression.coefficients)
  if (!length(s)) {
    return(character(0))
  }
  
  k <- strsplit(s, split = "[()-]")
  
  kis3 <- (sapply(k, length) == 3 & grepl("(", s, fixed = TRUE))
  
  if (!sum(kis3)) {
    return(data.frame(type = character(0), date = character(0), stringsAsFactors = FALSE)) # stringsAsFactors for old r versions 
  }
  k <- k[kis3]
  year <- as.integer(sapply(k, function(x) x[3]))
  #month <- as.integer(sapply(k, function(x) x[2]))
  k2 <- sapply(k, function(x) x[2])
  k2[k2 == "I"] <- "1"
  k2[k2 == "II"] <- "4"
  k2[k2 == "III"] <- "7"
  k2[k2 == "IV"] <- "10"
  month <- as.integer(k2)
  date_mnd <- sub(".", "-", sprintf("%7.2f", (year + month/100)), fixed = TRUE)
  
  type <- trimws(sapply(k, function(x) x[1]))
  
  data.frame(type = type, date = date_mnd, stringsAsFactors = FALSE) # stringsAsFactors for old r versions 
  
}



#SSBtools::ForceCharacterDataFrame
ForceCharacterDataFrame <- function(x) {
  for (i in seq_len(NCOL(x))) if (is.factor(x[, i, drop =TRUE])) 
    x[, i] <- as.character(x[, i, drop =TRUE])
  x
}






