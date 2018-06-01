# mathieu rajerison
# https://datagistips.hypotheses.org/

discs_from_points <- function(coords, radiuses) {

  lapply(1:nrow(coords), function(i) {
    disc <- rgeos::gBuffer(SpatialPoints(coords)[i, ], width=radiuses[i], byid=TRUE);
    disc <- sp::spChFIDs(disc, row.names(coords)[i])
    return(disc)
  }) -> out

  discs <- do.call("rbind", out)

  return(discs)

}
