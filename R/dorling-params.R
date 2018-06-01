# mathieu rajerison
# https://datagistips.hypotheses.org/

#' Compute center coordinates, circle radii and Dorling polygons from input polygons and values
#'
#' Pass in an equal area (not long-lat) projected `SpatialPolygonsDataFrame` and get
#' back what you need to plot a Doriling cargogram.
#'
#' @md
#' @note There is a significant limitation in that the polygons have to all be touching
#'       (i.e. this is why the README has an example w/o Alaska and Hawaii). If
#'       neighbors were computed separately or allowed to be passed in, this
#'       could be made more generic. PRs & Issues welcome.
#' @param polys `SpatialPolygonsDataFrame`
#' @param value values that correspond to the ordered polygons in `polys`
#' @param n_rescales,n_iter,tol tuning parameters for computing non-overlapping
#'        circle polygon radius values. Tweak only if the defaults do not work well.
#' @param quit if `TRUE` (default) do not show the scaling iterations
#' @author Mathieu Rajerison <https://datagistips.hypotheses.org/>
#' @return a `list` with `xy` coordinate matrix, `radius` vector, and disc `SpatialPolygons`
#' @export
dorling_from_sp <- function(polys, value, n_rescales=50, n_iter=50, tol=1000, quiet = TRUE) {

  if (grepl("proj=longlat", sp::proj4string(polys))) {
    warning("Using an unprojected map. Converting to equal area is recommended")
  }

  sqs <- seq(1, 0, length.out = n_rescales)

  for (ratio in sqs) {
    coords <- sp::coordinates(polys)
    row.names(coords) <- row.names(polys)
    radius <- dorling_radius(polys, value, ratio)

    for (iter in 1:n_iter) {
      overlap_ct <- 0

      for (i in 1:nrow(coords)) {
        for (j in 1:nrow(coords)) {
          if (j != i) {
            dx <- coords[i, 1] - coords[j, 1]
            dy <- coords[i, 2] - coords[j, 2]

            l <- sqrt(dx^2 + dy^2)
            d <- radius[i] + radius[j]

            prop <- (l - d) / l

            dx <- dx * prop
            dy <- dy * prop

            if (l < d) {
              if (abs(l - d) > tol) {
                overlap_ct <- overlap_ct + 1

                coords[i, 1] <- coords[i, 1] - dx
                coords[i, 2] <- coords[i, 2] - dy
              }
            }
          }
        }
      }
    }

    if (!quiet) cat("Scale factor of", ratio, "=>", "number of overlaps :", overlap_ct, "\n")

    if (overlap_ct == 0) break
  }

  discs <- discs_from_points(coords, radius)

  return(list(xy = coords, radius = radius, discs = discs))

}
