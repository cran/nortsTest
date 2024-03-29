#' Automatically create a ggplot for time series objects.
#'
#' \code{autoplot} takes an object of type \code{ts} or \code{mts} and creates
#' a ggplot object suitable for usage with \code{stat_forecast}.
#'
#' \code{fortify.ts} takes a \code{ts} object and converts it into a data frame
#' (for usage with ggplot2).
#'
#' @param object Object of class \dQuote{\code{ts}} or \dQuote{\code{mts}}.
#' @param series Identifies the time series with a colour, which integrates well
#' with the functionality of \link{geom_forecast}.
#' @param xlab a string with the plot's x axis label. By default a NULL value.
#' @param ylab a string with the plot's y axis label. By default a counts" value.
#' @param main a string with the plot's title.
#' @param facets If TRUE, multiple time series will be faceted (and unless
#' specified, colour is set to FALSE). If FALSE, each series will be assigned a
#' colour.
#' @param colour If TRUE, the time series will be assigned a colour aesthetic.
#' @param model Object of class \dQuote{\code{ts}} to be converted to
#' \dQuote{\code{data.frame}}.
#' @param data Not used (required for \link{fortify} method).
#' @param ... Other plotting parameters to affect the plot.
#'
#'
#' @return None. Function produces a ggplot2 graph.
#'
#' @author Mitchell O'Hara-Wild
#'
#' @seealso \code{\link[stats]{plot.ts}}, \code{\link[ggplot2]{fortify}}
#'
#' @examples
#'
#' library(ggplot2)
#' autoplot(USAccDeaths)
#'
#' lungDeaths <- cbind(mdeaths, fdeaths)
#' autoplot(lungDeaths)
#' autoplot(lungDeaths, facets=TRUE)
#'
#' @importFrom forecast autoplot
#' @export
#'
autoplot.ts <- function(object, series=NULL, xlab = "Time", ylab = deparse(substitute(object)),
                        main = NULL,facets = FALSE,colour = TRUE, ...) {
  if (!is.ts(object))
    stop("autoplot.ts requires a ts object, use object=object")

  # Create data frame with time as a column labelled x
  # and time series as a column labelled y.
  data <- data.frame(y = as.numeric(object), x = as.numeric(time(object)))
  if (!is.null(series)) {
    data <- transform(data, series = series)
  }

  # Initialise ggplot object
  p <- ggplot2::ggplot(ggplot2::aes_(y = ~y, x = ~x), data = data)

  # Add data
  if (!is.null(series)) {
    p <- p + ggplot2::geom_line(ggplot2::aes_(group = ~series, colour = ~series), na.rm = TRUE, ...)
  }
  else {
    p <- p + ggplot2::geom_line(na.rm = TRUE, ...)
  }

  # Add labels
  p <- p + ggplot2::labs(x = xlab, y = ylab, title = main)

  # Make x axis contain only whole numbers (e.g., years)
  p <- p + ggplot2::scale_x_continuous(breaks = ggtsbreaks)
   return(p)
}
#'
#' @rdname autoplot.ts
#' @export
#'
autoplot.numeric <-function(object, series=NULL, xlab = "Time", ylab = deparse(substitute(object)),
                            main = NULL,  ...) {
  if(is.numeric(object))
    y = ts(object)
  g = autoplot.ts(y,series=NULL, xlab = "Time", ylab = deparse(substitute(object)),
                  main = NULL,  ...)
  return(g)
}
#'
#' @rdname autoplot.ts
#' @importFrom zoo as.Date
#' @export
#'
fortify.ts <- function(model, data, ...) {
  # Use ggfortify version if it is loaded
  # to prevent cran errors
  if (exists("ggfreqplot")) {
    tsp <- attr(model, which = "tsp")
    dtindex <- time(model)
    if (any(tsp[3] == c(4, 12))) {
      dtindex <- zoo::as.Date.yearmon(dtindex)
    }
    model <- data.frame(Index = dtindex, Data = as.numeric(model))
    return(ggplot2::fortify(model))
  }
  else {
    model <- cbind(x = as.numeric(time(model)), y = as.numeric(model))
    as.data.frame(model)
  }
}
#' @importFrom ggplot2 autoplot
#' @export
ggplot2::autoplot
#'
#'
ggAddExtras <- function(xlab=NA, ylab=NA, main=NA) {
  dots <- eval.parent(quote(list(...)))
  extras <- list()
  if ("xlab" %in% names(dots) || is.null(xlab) || any(!is.na(xlab))) {
    if ("xlab" %in% names(dots)) {
      extras[[length(extras) + 1]] <- ggplot2::xlab(dots$xlab)
    }
    else {
      extras[[length(extras) + 1]] <- ggplot2::xlab(paste0(xlab[!is.na(xlab)], collapse = " "))
    }
  }
  if ("ylab" %in% names(dots) || is.null(ylab) || any(!is.na(ylab))) {
    if ("ylab" %in% names(dots)) {
      extras[[length(extras) + 1]] <- ggplot2::ylab(dots$ylab)
    }
    else {
      extras[[length(extras) + 1]] <- ggplot2::ylab(paste0(ylab[!is.na(ylab)], collapse = " "))
    }
  }
  if ("main" %in% names(dots) || is.null(main) || any(!is.na(main))) {
    if ("main" %in% names(dots)) {
      extras[[length(extras) + 1]] <- ggplot2::ggtitle(dots$main)
    }
    else {
      extras[[length(extras) + 1]] <- ggplot2::ggtitle(paste0(main[!is.na(main)], collapse = " "))
    }
  }
  if ("xlim" %in% names(dots)) {
    extras[[length(extras) + 1]] <- ggplot2::xlim(dots$xlim)
  }
  if ("ylim" %in% names(dots)) {
    extras[[length(extras) + 1]] <- ggplot2::ylim(dots$ylim)
  }
  return(extras)
}
#'
#' @noRd
#'
ggtsbreaks <- function(x) {
  # Make x axis contain only whole numbers (e.g., years)
  return(unique(round(pretty(floor(x[1]):ceiling(x[2])))))
}
#' Histogram with optional normal density functions.
#'
#' Plots a histogram and density estimates using ggplot.
#'
#'
#' @param y a numeric vector or an object of the \code{ts} class containing a stationary time series.
#' @param title a string with the plot's title.
#' @param xlab a string with the plot's x axis label. By default a NULL value.
#' @param ylab a string with the plot's y axis label. By default a "counts" value.
#' @param add.normal a boolean value. Add a normal density function for comparison,
#' by default \code{add.normal = TRUE}.
#' @param bins the number of bins to use for the histogram. Selected by default
#' using the Friedman-Diaconis rule.
#'
#' @return None.
#'
#' @author Rob J Hyndman
#'
#' @importFrom grDevices nclass.FD
#' @importFrom stats dnorm
#' @export
#'
#' @examples
#' x = rnorm(100)
#' gghist(x,add.normal = TRUE)
#'
gghist = function(y,title = NULL,xlab = NULL,ylab = "counts",bins,add.normal = TRUE){

  if (!is.ts(y) && !is.numeric(y))
    stop("gghist requires a ts or numeric object")

  if (missing(bins))
    bins = min(grDevices::nclass.FD(na.exclude(y)),500)

  xlab1 = xlab
  if(is.null(xlab))
    xlab1 =  deparse(substitute(y))

  data = data.frame(y = as.numeric(c(y)))
  # Initialise ggplot object and plot histogram

  boundary=0
  binwidth = (max(y, na.rm = TRUE) - min(y, na.rm = TRUE)) / bins

  p = ggplot2::ggplot() +
    ggplot2::geom_histogram(ggplot2::aes(y),data = data,
                            binwidth = binwidth, boundary = boundary)

  if (add.normal) {
    xmin  = min(y, na.rm = TRUE)
    xmax  = max(y, na.rm = TRUE)
    xmean = mean(y, na.rm = TRUE)
    xsd   = sd(y, na.rm = TRUE)
    xmin  = min(xmin, xmean - 3 * xsd)
    xmax  = max(xmax, xmean + 3 * xsd)
  }
  xgrid  =  seq(xmin, xmax, length.out = 512)

  if (add.normal) {
    df = data.frame(x = xgrid, y = length(y)*binwidth*stats::dnorm(xgrid, xmean, xsd))
    p = p + ggplot2::geom_line(ggplot2::aes(df$x, df$y), col = "blue")
  }

  p = p + ggplot2::labs(title = title,x = xlab1 ,y = ylab)

  return(p)

}
#' \code{qqplot} with normal \code{qqline}
#'
#' Plot the quantile-quantile plot and quantile-quantile line using ggplot.
#'
#' @param y a numeric vector or an object of the \code{ts} class containing a stationary time series.
#' @param add.normal Add a normal density function for comparison.
#' @param title a string with the plot's title.
#'
#' @return None.
#'
#' @author Asael Alonzo Matamoros
#'
#' @import ggplot2
#' @export
#'
#' @examples
#' x = rnorm(100)
#' ggnorm(x)
#'
ggnorm = function(y,title = NULL,add.normal = TRUE){

  if (!is.ts(y) && !is.numeric(y))
    stop("gghist requires a ts or numeric object")

  df = data.frame(y = as.numeric(y))

  p = ggplot2::ggplot(data = df,ggplot2::aes(sample = y)) + ggplot2::stat_qq() +
    ggplot2::labs(title = title)

  if(add.normal)
    p = p + ggplot2::stat_qq_line(color = "blue")

  return(p)
}
#' \code{acf} plot.
#'
#' Plot of the auto-correlation function for a univariate time series.
#'
#' @param y a numeric vector or an object of the \code{ts} class containing a stationary time series.
#' @param title a string with the plot's title.
#'
#' @return None.
#'
#' @author Asael Alonzo Matamoros
#'
#' @import forecast
#' @export
#'
#' @examples
#' x = rnorm(100)
#' ggacf(x)
#'
ggacf = function(y,title = NULL){
  if (!is.ts(y) && !is.numeric(y))
    stop("gghist requires a ts or numeric object")

  p = forecast::ggAcf(x = y) + ggplot2::labs(title = title)

  return(p)
}
#' \code{pacf} plot.
#'
#' Plot of the partial autocorrelation function for a univariate time series.
#'
#' @param y a numeric vector or an object of the \code{ts} class containing a stationary time series.
#' @param title a string with the plot's title.
#'
#' @return None.
#'
#' @author Mitchell O'Hara-Wild and Asael Alonzo Matamoros
#'
#' @import forecast
#' @export
#'
#' @examples
#' x = rnorm(100)
#' ggpacf(x)
#'
ggpacf = function(y,title = NULL){
  if (!is.ts(y) && !is.numeric(y))
    stop("gghist requires a ts or numeric object")

  p = forecast::ggPacf(x = y) + ggplot2::labs(title = title)

  return(p)
}
#'
#' @export
#'
check_plot<- function(y,...) {
  UseMethod("check_plot")
}
#' Generic function for a visual check of residuals in time series models.
#'
#' Generic function for a visual check of residuals in time series models, these methods are inspired in
#' the \code{check.residuals} function provided by the \code{forecast} package.
#'
#' @aliases check_plot check_plot.ts check_plot.arima0 check_plot.Arima check_plot.fGarch
#' check_plot.numeric check_plot.lm  check_plot.HoltWinters check_plot.ets check_plot.forecast
#'
#' @rdname check_plot
#'
#' @param y a numeric vector or an object of the \code{ts} class containing a stationary time series.
#' @param model A string with the model name.
#' @param ... Other plotting parameters to affect the plot.
#'
#' @return A graph object from ggplot2.
#'
#' @author Asael Alonzo Matamoros.
#'
#' @seealso \code{check_residuals}
#'
#' @importFrom cowplot plot_grid
#' @method check_plot ts
#' @export
#'
#' @examples
#' y = arima.sim(100,model = list(ar = 0.3))
#' check_plot(y)
#'
#'
check_plot.ts = function(y,model = " ",...){

  if( !is(y,class2 = "ts") )
    stop("The object y is not a time series")

  lay = matrix(c(1,1,2,3,4,5),nrow = 3,ncol = 2,byrow = TRUE)
  tit = paste0("check residuals: ",model)

  p1 = nortsTest::autoplot(y, main = tit, ...)

  p2 = gghist(y = y,add.normal = TRUE)
  p3 = ggnorm(y = y,add.normal = TRUE)
  p4 = ggacf(y = y)
  p5 = ggpacf(y = y)
  p6 = cowplot::plot_grid(p2, p3, p4, p5, nrow = 2, ncol = 2)
  cowplot::plot_grid(p1, p6, nrow = 2)
}
#'
#' @method check_plot numeric
#' @export
#'
check_plot.numeric = function(y,model = " ",...){
  if( !is.numeric(y) )
    stop("The object y is not a numeric array")

  g = check_plot.ts(ts(y),model = model,...)
  return(g)
}
#' @method check_plot arima0
#' @export
#'
check_plot.arima0 = function(y,model = " ",...){
  if( !is(y,class2 = "arima0") )
    stop("The object y is not an arima0 class")

  g = check_plot.ts(y$residuals,model = model,...)
  return(g)
}
#'
#' @method check_plot Arima
#' @export
#'
check_plot.Arima = function(y,model = " ",...){
  if( !is(y,class2 = "Arima") )
    stop("The object y is not a Arima class")

  g = check_plot.ts(y$residuals,model = model,...)
  return(g)
}
#'
#' @method check_plot fGARCH
#' @export
#'
check_plot.fGARCH = function(y,model = " ",...){
  if( !is(y,class2 = "fGARCH") )
    stop("The object y is not a fGARCH class")

  g = check_plot.numeric(y@residuals,model = model,...)
  return(g)
}
#'
#' @method check_plot lm
#' @export
#'
check_plot.lm = function(y,model = " ",...){
  if( !is(y,class2 = "lm") )
    stop("The object y is not a lm class")

  g = check_plot.numeric(y$residuals,model = model,...)
  return(g)
}
#' @method check_plot HoltWinters
#' @export
#'
check_plot.HoltWinters = function(y,model = " ",...){
  if( !is(y,class2 = "HoltWinters") )
    stop("The object y is not an HoltWinters class")

  y1 = residuals(y)

  g = check_plot.ts(y1,model = model,...)
  return(g)
}
#'
#' @method check_plot ets
#' @export
#'
check_plot.ets = function(y,model = " ",...){
  if( !is(y,class2 = "ets") )
    stop("The object y is not a ets class")

  g = check_plot.ts(y$residuals,model = model,...)
  return(g)
}
#'
#' @method check_plot forecast
#' @export
#'
check_plot.forecast = function(y,model = " ",...){
  if( !is(y,class2 = "forecast") )
    stop("The object y is not a forecast class")

  g = check_plot.ts(y$residuals,model = model,...)
  return(g)
}
