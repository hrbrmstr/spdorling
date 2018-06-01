# mathieu rajerison
# https://datagistips.hypotheses.org/

dorling_radius <- function(polys, values, ratio) {

  neighbors_list <- spdep::poly2nb(polys)

  cum_dist <- cum_radius <- 0

  for (i in 1:length(neighbors_list)) {
    if (!is.null(neighbors_list[[i]])) {
      neighs <- neighbors_list[[i]][which(neighbors_list[[i]] < i)]

      for (j in neighs) {
        l <- point_distance(coordinates(polys)[i, ], coordinates(polys)[j, ])
        d <- sqrt(values[i] / pi) + sqrt(values[j] / pi)

        cum_dist <- cum_dist + l
        cum_radius <- cum_radius + d
      }
    }
  }

  scale <- cum_dist / cum_radius

  radiuses <- sqrt(values / pi) * scale * ratio

  return(radiuses)

}
