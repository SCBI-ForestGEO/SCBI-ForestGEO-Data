
library(data.table)
library(sf)
library(ggplot2)

load("tree_main_census/data/scbi.stem3.rdata")
quad <- read_sf("spatial_data/shapefiles/20m_grid.shp")

setDT(scbi.stem3)


M <- scbi.stem3[StemTag > 1]
M <- M[, .SD[1], by = tag]

sort(table(M$quadrat))

quad$N_multiple <- as.vector(table(M$quadrat)[ifelse(nchar(quad$PLOT) ==3, paste0("0", quad$PLOT), quad$PLOT) ])
quad$N_multiple[is.na(quad$N_multiple)] <- 0

quad$N_multiple <- factor(ifelse(quad$N_multiple <5, quad$N_multiple, "5+"))



rows <- annotate("text", x = seq(747350, 747365, length.out = 32), y = seq(4309125, 4308505, length.out = 32), label = sprintf("%02d", 32:1), size = 3, color = "black")

cols <- annotate("text", x = seq(747390, 747765, length.out = 20), y = seq(4308495, 4308505, length.out = 20), label = sprintf("%02d", 1:20), size = 2.8, color = "black")


ggplot(quad) +
  geom_sf(aes(fill = N_multiple)) +
  cols +
  rows +
  labs() +
  scale_fill_grey(start = 1, end = .5)  +
  theme(plot.title = element_text(vjust=0.1),
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.background= element_blank())

ggplot_test <- ggplot() +
  geom_path(data = quad, aes(x = long, y = lat, group = group)) +
  geom_path(data = roads_df, aes(x = long, y = lat, group = group), color = "#993300",
            linetype = 2, size = 0.8) +
  geom_path(data=streams_df, aes(x=long, y=lat, group=group), color = "blue", size=0.5) +
  labs() +
  geom_path(data = deer_df, aes(x = long, y = lat, group = group), size = .7) +
  geom_path(data = contour_10m_df, aes(x = long, y = lat, group = group), color = "gray", linetype = 1) +
  scale_colour_gradientn(colours=rainbow(3)) +
  theme(plot.title = element_text(vjust=0.1),
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank()) +
  coord_sf(crs = "crs = +proj=merc", xlim = c(747350, 747800), ylim = c(4308500, 4309125)) +
  theme(panel.grid.major = element_line(colour = 'transparent')) +
  theme(legend.position = "bottom", legend.box = "horizontal") +
  theme(panel.background = element_rect(fill = "gray98")) +
  ggtitle("SCBI ForestGEO Plot") +
  rows +
  cols
