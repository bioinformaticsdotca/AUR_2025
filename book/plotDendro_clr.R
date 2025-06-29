#' dendrogram from unsupervised clustering
#'
#' @param M (matrix) data values
#' @param topVar (integer) top most-variable probes to show
#' @param pheno (data.frame) row order should match column order of M.
#' should contain column names for groupBy. Note that groupBy columns 
#' should be factors
#' @param groupPal (list) keys are columns in pheno by which data are to
#' be grouped. Values could be RColorBrewer palette names (char length 1)
#' or a vector of colours to use as the palette. In this case
#' the palette will follow the order of the variable levels
#' @param verbose (logical) print messages
#' @param ... parameters for squash::dendromat
#' @importFrom squash dendromat
#' @importFrom RColorBrewer brewer.pal
#' @export
#' @return No value. Side effect of printing a dendrogram)
plotDendro_clr <- function(M, pheno, groupPal, topVar = 10 * 1000L, verbose = TRUE,
             ttl = "", ...) {

  if (topVar > nrow(M)) stop("topVar should be <= nrow(M)")
  if (verbose) cat("* preparing colours\n")
  clrmat <- matrix(NA, nrow = length(groupPal), ncol = nrow(pheno))
  rownames(clrmat) <- names(groupPal)
  ctr <- 1

  for (gpCol in names(groupPal)) {
    gpLev <- levels(pheno[, gpCol])
    if (length(groupPal[[gpCol]]) == 1) {
      # palette name
      pal <- suppressWarnings(
        RColorBrewer::brewer.pal(
          name = groupPal[[gpCol]], n = max(3, length(gpLev)))
      )
    } else {
      pal <- groupPal[[gpCol]]
    }
    clrmat[ctr,] <- pal[as.integer(pheno[, gpCol])]
    ctr <- ctr + 1
  }
  clrmat <- clrmat[nrow(clrmat):1,, drop = FALSE]
  colnames(clrmat) <- colnames(M)

  var <- getVariance(M)
  M_top <- M[order(var, decreasing = TRUE)[1:topVar],]
  d <- as.dist(1 - cor(M_top))
  dendro <- hclust(d, method = "average")

  par(mar = c(6, 4, 4, 1), las = 1)
  squash::dendromat(dendro, t(clrmat), ...)
  title(sprintf("%s: top %i\n", ttl, topVar))
}

