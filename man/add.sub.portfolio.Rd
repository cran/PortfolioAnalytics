% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mult.layer.portfolio.R
\name{add.sub.portfolio}
\alias{add.sub.portfolio}
\title{Add sub-portfolio}
\usage{
add.sub.portfolio(mult.portfolio, portfolio, optimize_method = c("DEoptim",
  "random", "ROI", "pso", "GenSA"), search_size = 20000, rp = NULL,
  rebalance_on = NULL, training_period = NULL, trailing_periods = NULL,
  ..., indexnum = NULL)
}
\arguments{
\item{mult.portfolio}{a \code{mult.portfolio.spec} object}

\item{portfolio}{a \code{portfolio} object to add as a sub portfolio.}

\item{optimize_method}{optimization method for the sub portfolio}

\item{search_size}{integer, how many portfolios to test, default 20,000}

\item{rp}{matrix of random portfolio weights, default NULL, mostly for automated use by rebalancing optimization or repeated tests on same portfolios}

\item{rebalance_on}{haracter string of period to rebalance on. See 
\code{\link[xts]{endpoints}} for valid names.}

\item{training_period}{an integer of the number of periods to use as 
a training data in the front of the returns data}

\item{trailing_periods}{an integer with the number of periods to roll over
(i.e. width of the moving or rolling window), the default is NULL will 
run using the returns data from inception}

\item{\dots}{additonal passthrough parameters to \code{\link{optimize.portfolio.rebalancing}}}

\item{indexnum}{the index number of the sub portfolio. If \code{indexnum=NULL}
(the default), then the sub portfolio object is appended to the list of 
sub portfolios in the \code{mult.portfolio} object. If \code{indexnum} is 
specified, the portfolio in that index number is overwritten.}
}
\description{
Add a sub-portfolio to a multiple layer portfolio specification object
}
\seealso{
\code{\link{mult.portfolio.spec}} \code{\link{portfolio.spec}} \code{\link{optimize.portfolio}} \code{\link{optimize.portfolio.rebalancing}}
}
\author{
Ross Bennett
}
