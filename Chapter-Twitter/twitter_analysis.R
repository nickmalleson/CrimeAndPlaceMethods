# This is all adapted from the excellent 'Earth Data Analytics Online' lessons 'Work With Twitter Social Media Data in R - An Introduction'
# https://www.earthdatascience.org/courses/earth-analytics/get-data-using-apis/intro-to-social-media-text-mining-r/
# and the documentation for the `rtweet` package
# https://github.com/ropensci/rtweet

# Load twitter library - the rtweet library is recommended now over twitteR
# Library documentaiton is at: https://cran.r-project.org/web/packages/rtweet/index.html
library(rtweet)

# Plotting and pipes - tidyverse!
library(ggplot2)
library(dplyr)
library(tidyr)

# Working with JSON
library(rjson)
library(jsonlite)

# For reading the Washington shapefile
library(rgdal)
library(sf)

# Set the working directory to be the same directory that this script is stored in. For me this is:
setwd("/Users/nick/gp/CrimeAndPlaceMethods/Chapter-Twitter")

# Now you need to enter the details about the Twitter 'app' you have created to allow you access to the Twitter APIs.
# See the chapter for details

# whatever name you assigned to your created app
appname <- ""

# Details provided when you set up the app
consumer.key <- ""
consumer.secret <- ""
access.token <- ""
access.token.secret <- ""

# create token named "twitter_token"
twitter_token <- create_token(
  app = appname,
  consumer_key = consumer.key,
  consumer_secret = consumer.secret,
  access_token = access.token,
  access_secret = access.token.secret
  )

### Search for some tweets sent from the US
#rt <- search_tweets(
#  "lang:en", geocode = lookup_coords("usa"), n = 1000
#)

# Search from some tweets 10miles around Washington DC
rt <- search_tweets(
  "lang:en", geocode = "38.89511,-77.03637,10mi", n = 10000
)

# Create lat/lng variables using all available tweet and profile geo-location data
rt <- lat_lng(rt)

# Drop any lines without coordinates
rt <- rt[!(is.na(rt$lat) | is.na(rt$lng)),]

# Create a SpatialPoints dataframe for the tweets
tweets.sp <- SpatialPointsDataFrame(coords=cbind(rt$lng, rt$lat), data=rt, proj4string = CRS("+init=epsg:4326"))

# Read the area boundaries for the study area
# ** NOTE: you need to unzip the' 'wash_dc_block_groups.zip' first **
shape <- readOGR(dsn = "../WashingtonDC_Data/wash_dc_block_groups/", layer = "wash_dc_block_groups")

# Project the tweets to the same coordinate reference system to that of the study area
tweets.sp <- spTransform(tweets.sp, CRS(proj4string(shape)))

# Plot!
plot(shape)
points(tweets.sp, pch="+", col="blue", cex=2)
