
chart.Weight.pso <- function(object, ..., neighbors = NULL, main="Weights", las = 3, xlab=NULL, cex.lab = 1, element.color = "darkgray", cex.axis=0.8, colorset=NULL, legend.loc="topright", cex.legend=0.8, plot.type="line"){
  
  if(!inherits(object, "optimize.portfolio.pso")) stop("object must be of class 'optimize.portfolio.pso'")
  
  if(plot.type %in% c("bar", "barplot")){
    barplotWeights(object=object, ..., main=main, las=las, xlab=xlab, cex.lab=cex.lab, element.color=element.color, cex.axis=cex.axis, legend.loc=legend.loc, cex.legend=cex.legend, colorset=colorset)
  } else if(plot.type == "line"){
    
    columnnames = names(object$weights)
    numassets = length(columnnames)
    
    constraints <- get_constraints(object$portfolio)
    
    if(is.null(xlab))
      minmargin = 3
    else
      minmargin = 5
    if(main=="") topmargin=1 else topmargin=4
    if(las > 1) {# set the bottom border to accommodate labels
      bottommargin = max(c(minmargin, (strwidth(columnnames,units="in"))/par("cin")[1])) * cex.lab
      if(bottommargin > 10 ) {
        bottommargin<-10
        columnnames<-substr(columnnames,1,19)
        # par(srt=45) #TODO figure out how to use text() and srt to rotate long labels
      }
    }
    else {
      bottommargin = minmargin
    }
    par(mar = c(bottommargin, 4, topmargin, 2) +.1)
    if(any(is.infinite(constraints$max)) | any(is.infinite(constraints$min))){
      # set ylim based on weights if box constraints contain Inf or -Inf
      ylim <- range(object$weights)
    } else {
      # set ylim based on the range of box constraints min and max
      ylim <- range(c(constraints$min, constraints$max))
    }
    plot(object$weights, type="b", col="blue", axes=FALSE, xlab='', ylim=ylim, ylab="Weights", main=main, pch=16, ...)
    if(!any(is.infinite(constraints$min))){
      points(constraints$min, type="b", col="darkgray", lty="solid", lwd=2, pch=24)
    }
    if(!any(is.infinite(constraints$max))){
      points(constraints$max, type="b", col="darkgray", lty="solid", lwd=2, pch=25)
    }
    #     if(!is.null(neighbors)){ 
    #         if(is.vector(neighbors)){
    #             xtract=extractStats(ROI)
    #             weightcols<-grep('w\\.',colnames(xtract)) #need \\. to get the dot 
    #             if(length(neighbors)==1){
    #                 # overplot nearby portfolios defined by 'out'
    #                 orderx = order(xtract[,"out"])
    #                 subsetx = head(xtract[orderx,], n=neighbors)
    #                 for(i in 1:neighbors) points(subsetx[i,weightcols], type="b", col="lightblue")
    #             } else{
    #                 # assume we have a vector of portfolio numbers
    #                 subsetx = xtract[neighbors,weightcols]
    #                 for(i in 1:length(neighbors)) points(subsetx[i,], type="b", col="lightblue")
    #             }      
    #         }
    #         if(is.matrix(neighbors) | is.data.frame(neighbors)){
    #             # the user has likely passed in a matrix containing calculated values for risk.col and return.col
    #             nbweights<-grep('w\\.',colnames(neighbors)) #need \\. to get the dot
    #             for(i in 1:nrow(neighbors)) points(as.numeric(neighbors[i,nbweights]), type="b", col="lightblue")
    #             # note that here we need to get weight cols separately from the matrix, not from xtract
    #             # also note the need for as.numeric.  points() doesn't like matrix inputs
    #         }
    #     }
    #     points(ROI$weights, type="b", col="blue", pch=16)
    axis(2, cex.axis = cex.axis, col = element.color)
    axis(1, labels=columnnames, at=1:numassets, las=las, cex.axis = cex.axis, col = element.color)
    box(col = element.color)
  }
}

#' @rdname chart.Weights
#' @method chart.Weights optimize.portfolio.pso
#' @export
chart.Weights.optimize.portfolio.pso <- chart.Weight.pso

chart.Scatter.pso <- function(object, ..., neighbors=NULL, return.col="mean", risk.col="ES", chart.assets=FALSE, element.color = "darkgray", cex.axis=0.8, xlim=NULL, ylim=NULL){
  if(!inherits(object, "optimize.portfolio.pso")) stop("object must be of class 'optimize.portfolio.pso'")
  
  R <- object$R
  if(is.null(R)) stop("Returns object not detected, must run optimize.portfolio with trace=TRUE")
  # portfolio <- object$portfolio
  xtract = extractStats(object)
  columnnames = colnames(xtract)
  #return.column = grep(paste("objective_measures",return.col,sep='.'),columnnames)
  return.column = pmatch(return.col,columnnames)
  if(is.na(return.column)) {
    return.col = paste(return.col,return.col,sep='.')
    return.column = pmatch(return.col,columnnames)
  }
  #risk.column = grep(paste("objective_measures",risk.col,sep='.'),columnnames)
  risk.column = pmatch(risk.col,columnnames)
  if(is.na(risk.column)) {
    risk.col = paste(risk.col,risk.col,sep='.')
    risk.column = pmatch(risk.col,columnnames)
  }
  
  # if(is.na(return.column) | is.na(risk.column)) stop(return.col,' or ',risk.col, ' do not match extractStats output')
  
  # If the user has passed in return.col or risk.col that does not match extractStats output
  # This will give the flexibility of passing in return or risk metrics that are not
  # objective measures in the optimization. This may cause issues with the "neighbors"
  # functionality since that is based on the "out" column
  if(is.na(return.column) | is.na(risk.column)){
    return.col <- gsub("\\..*", "", return.col)
    risk.col <- gsub("\\..*", "", risk.col)
    warning(return.col,' or ', risk.col, ' do  not match extractStats output of $objective_measures slot')
    # Get the matrix of weights for applyFUN
    wts_index <- grep("w.", columnnames)
    wts <- xtract[, wts_index]
    if(is.na(return.column)){
      tmpret <- applyFUN(R=R, weights=wts, FUN=return.col)
      xtract <- cbind(tmpret, xtract)
      colnames(xtract)[which(colnames(xtract) == "tmpret")] <- return.col
    }
    if(is.na(risk.column)){
      tmprisk <- applyFUN(R=R, weights=wts, FUN=risk.col)
      xtract <- cbind(tmprisk, xtract)
      colnames(xtract)[which(colnames(xtract) == "tmprisk")] <- risk.col
    }
    columnnames = colnames(xtract)
    return.column = pmatch(return.col,columnnames)
    if(is.na(return.column)) {
      return.col = paste(return.col,return.col,sep='.')
      return.column = pmatch(return.col,columnnames)
    }
    risk.column = pmatch(risk.col,columnnames)
    if(is.na(risk.column)) {
      risk.col = paste(risk.col,risk.col,sep='.')
      risk.column = pmatch(risk.col,columnnames)
    }
  }
  if(chart.assets){
    # Get the arguments from the optimize.portfolio$portfolio object
    # to calculate the risk and return metrics for the scatter plot. 
    # (e.g. arguments=list(p=0.925, clean="boudt")
    arguments <- NULL # maybe an option to let the user pass in an arguments list?
    if(is.null(arguments)){
      tmp.args <- unlist(lapply(object$portfolio$objectives, function(x) x$arguments), recursive=FALSE)
      tmp.args <- tmp.args[!duplicated(names(tmp.args))]
      if(!is.null(tmp.args$portfolio_method)) tmp.args$portfolio_method <- "single"
      arguments <- tmp.args
    }
    # Include risk reward scatter of asset returns
    asset_ret <- scatterFUN(R=R, FUN=return.col, arguments)
    asset_risk <- scatterFUN(R=R, FUN=risk.col, arguments)
    xlim <- range(c(xtract[,risk.column], asset_risk))
    ylim <- range(c(xtract[,return.column], asset_ret))
  } else {
    asset_ret <- NULL
    asset_risk <- NULL
  }
  
  # plot the portfolios from PSOoutput
  plot(xtract[,risk.column],xtract[,return.column], xlab=risk.col, ylab=return.col, col="darkgray", axes=FALSE, xlim=xlim, ylim=ylim, ...)
  
  ## @TODO: Generalize this to find column containing the "risk" metric
  if(length(names(object)[which(names(object)=='constrained_objective')])) {
    result.slot<-'constrained_objective'
  } else {
    result.slot<-'objective_measures'
  }
  objcols<-unlist(object[[result.slot]])
  names(objcols)<-name.replace(names(objcols))
  return.column = pmatch(return.col,names(objcols))
  if(is.na(return.column)) {
    return.col = paste(return.col,return.col,sep='.')
    return.column = pmatch(return.col,names(objcols))
  }
  risk.column = pmatch(risk.col,names(objcols))
  if(is.na(risk.column)) {
    risk.col = paste(risk.col,risk.col,sep='.')
    risk.column = pmatch(risk.col,names(objcols))
  }
  # risk and return metrics for the optimal weights if the RP object does not
  # contain the metrics specified by return.col or risk.col
  if(is.na(return.column) | is.na(risk.column)){
    return.col <- gsub("\\..*", "", return.col)
    risk.col <- gsub("\\..*", "", risk.col)
    # warning(return.col,' or ', risk.col, ' do  not match extractStats output of $objective_measures slot')
    opt_weights <- object$weights
    ret <- as.numeric(applyFUN(R=R, weights=opt_weights, FUN=return.col))
    risk <- as.numeric(applyFUN(R=R, weights=opt_weights, FUN=risk.col))
    points(risk, ret, col="blue", pch=16) #optimal
    text(x=risk, y=ret, labels="Optimal",col="blue", pos=4, cex=0.8)
  } else {
    points(objcols[risk.column], objcols[return.column], col="blue", pch=16) # optimal
    text(x=objcols[risk.column], y=objcols[return.column], labels="Optimal",col="blue", pos=4, cex=0.8)
  }

  # plot the risk-reward scatter of the assets
  if(chart.assets){
    points(x=asset_risk, y=asset_ret)
    text(x=asset_risk, y=asset_ret, labels=colnames(R), pos=4, cex=0.8)
  }
  
  axis(1, cex.axis = cex.axis, col = element.color)
  axis(2, cex.axis = cex.axis, col = element.color)
  box(col = element.color)
}

#' @rdname chart.RiskReward
#' @method chart.RiskReward optimize.portfolio.pso
#' @export
chart.RiskReward.optimize.portfolio.pso <- chart.Scatter.pso


charts.pso <- function(pso, return.col="mean", risk.col="ES", chart.assets=FALSE, cex.axis=0.8, element.color="darkgray", neighbors=NULL, main="PSO.Portfolios", xlim=NULL, ylim=NULL, ...){
  # Specific to the output of the optimize_method=pso
  op <- par(no.readonly=TRUE)
  layout(matrix(c(1,2)),heights=c(2,2),widths=1)
  par(mar=c(4,4,4,2))
  chart.Scatter.pso(object=pso, return.col=return.col, risk.col=risk.col, chart.assets=chart.assets, element.color=element.color, cex.axis=cex.axis, main=main, xlim=xlim, ylim=ylim, ...=...)
  par(mar=c(2,4,0,2))
  chart.Weight.pso(object=pso, neighbors=neighbors, las=3, xlab=NULL, cex.lab=1, element.color=element.color, cex.axis=cex.axis, ...=..., main="")
  par(op)
}


#' @rdname plot
#' @method plot optimize.portfolio.pso
#' @export
plot.optimize.portfolio.pso <- function(x, ..., return.col="mean", risk.col="ES", chart.assets=FALSE, cex.axis=0.8, element.color="darkgray", neighbors=NULL, main="PSO.Portfolios", xlim=NULL, ylim=NULL){
  charts.pso(pso=x, return.col=return.col, risk.col=risk.col, chart.assets=FALSE, cex.axis=cex.axis, element.color=element.color, neighbors=neighbors, main=main, xlim=xlim, ylim=ylim, ...=...)
}


###############################################################################
# R (https://r-project.org/) Numeric Methods for Optimization of Portfolios
#
# Copyright (c) 2004-2021 Brian G. Peterson, Peter Carl, Ross Bennett, Kris Boudt
#
# This library is distributed under the terms of the GNU Public License (GPL)
# for full details see the file COPYING
#
# $Id$
#
###############################################################################
