loonGrob_positions <- function(gtable, loon_grobs, layout_matrix, 
                               nrow = NULL, ncol = NULL) {
  l_className <- gtable$name
  class(l_className) <- l_className
  UseMethod("loonGrob_positions", l_className)
}

loonGrob_positions.default <- function(gtable, loon_grobs, layout_matrix, 
                                       nrow = NULL, ncol = NULL) {

  n <- length(loon_grobs)
  if (is.null(nrow) && !is.null(ncol)) {
    nrow <- ceiling(n/ncol)
  }
  if (is.null(ncol) && !is.null(nrow)) {
    ncol <- ceiling(n/nrow)
  }
  stopifnot(nrow * ncol >= n)
  if (is.null(nrow) && is.null(ncol)) {
    nm <- grDevices::n2mfrow(n)
    nrow <- nm[1]
    ncol <- nm[2]
  }
  if (is.null(layout_matrix)) {
    positions <- expand.grid(t = seq_len(nrow), l = seq_len(ncol))
    positions$b <- positions$t
    positions$r <- positions$l
    positions <- positions[order(positions$t), ]
  } else {
    cells <- sort(unique(as.vector(layout_matrix)))
    range_cell <- function(ii) {
      ind <- which(layout_matrix == ii, arr.ind = TRUE)
      c(l = min(ind[, "col"], na.rm = TRUE), r = max(ind[, "col"], na.rm = TRUE),
        t = min(ind[, "row"], na.rm = TRUE), b = max(ind[, "row"], na.rm = TRUE))
    }
    positions <- data.frame(do.call(rbind, lapply(cells, range_cell)))
    ncol <- max(positions$r)
    nrow <- max(positions$b)
    positions <- positions[seq_along(loon_grobs), ]
  }

  data.frame(
    l = (positions$l - 1)/ncol,
    r = positions$r/ncol,
    t = (positions$t - 1)/nrow,
    b = positions$b/nrow
  )
}

loonGrob_positions.l_facet_grid <- function(gtable, loon_grobs, layout_matrix, 
                                            nrow = NULL, ncol = NULL) {

  positions <- loonGrob_positions.default(gtable, loon_grobs, layout_matrix, 
                                          nrow, ncol)
  layout <- gtable$layout
  nrow <- nrow(gtable)
  ncol <- ncol(gtable)
  
  i <- which(vapply(gtable$grobs, is.gtable, logical(1L)))
  grobLayout <- layout[i, ]
  
  positions$t <- positions$t * (grobLayout$b - grobLayout$t + 1)/nrow + (grobLayout$t - 1)/nrow
  positions$b <- positions$b * (grobLayout$b - grobLayout$t + 1)/nrow + (grobLayout$t - 1)/nrow
  positions$l <- positions$l * (grobLayout$r - grobLayout$l + 1)/ncol + (grobLayout$l - 1)/ncol
  positions$r <- positions$r * (grobLayout$r - grobLayout$l + 1)/ncol + (grobLayout$l - 1)/ncol
  
  positions
}
