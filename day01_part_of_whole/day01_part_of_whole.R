library(ggplot2)
library(dplyr)
library(tidyr)
library(ggfx) # add inner and outer glow to charts!
library(ggtext) # color the title

sysfonts::font_add_google(name = "Prata", "Prata")
showtext::showtext_auto()

#data from:
#https://unstats-undesa.opendata.arcgis.com/datasets/indicator-10-6-1-proportion-of-voting-rights-of-developing-countries-in-international-organizations-by-organization-percent-5
#Indicator 10.6.1: Proportion of members and voting rights 
# of developing countries in international organizations

df <- read.csv("C:/Richard/R and Python/Datasets/UN_Proportion_of_voting_rights.csv") %>%
  select(nameOfInternationalInstitution1,
         geoAreaName, ISO3,
         value_2010,value_2015,value_2019)

df_long <- df %>%
  group_by(nameOfInternationalInstitution1) %>%
  summarise(n=n(),
    developing_2010=sum(value_2010,na.rm=TRUE),
    developed_2010 = 100 - developing_2010,
    developing_2019 = sum(value_2019, na.rm = TRUE),
    developed_2019 = 100 - developing_2019
    ) %>%
  filter(n>100) %>%
  tidyr::pivot_longer(cols=3:6) %>%
  tidyr::separate(col = name, into = c("type","year"))
  


ggplot(data=df_long,aes(x = "", y = value, fill = type )) + 
  with_outer_glow(
    geom_bar(stat = "identity", position = position_fill()),
    id="bars"
  )+
  with_inner_glow(
    "bars", colour = "white", sigma = 5
  ) + 
  geom_text(aes(label = round(value)), position = position_fill(vjust = 0.5),
            family = "Prata", col = "midnightblue") +
  coord_polar(theta = "y") +
  facet_grid(year ~ stringr::str_wrap(nameOfInternationalInstitution1,12))  +
  scale_fill_manual(values=c("grey70","goldenrod2"))+
  labs(title="Proportion of voting rights of <span style='color:goldenrod;'>developing countries</span> <br>in international organizations by organization",
       caption = "Data: UN Stats (Sustainable Development Goal 10: Reduce Inequality within and among countries)") +
  theme(legend.position="none",
        panel.grid = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        plot.title = element_markdown(size=20,family="Prata", colour = "midnightblue"),
        strip.text = element_text(size = 12, family="Prata", colour = "midnightblue"),
        plot.caption = element_text(family = "Prata", size=8, colour = "midnightblue"))
