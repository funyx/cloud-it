FROM rocker/shiny:4

## for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

## preesed tzdata, update package index, upgrade packages and install needed software
RUN truncate -s0 /tmp/preseed.cfg; \
    echo "tzdata tzdata/Areas select Europe" >> /tmp/preseed.cfg; \
    echo "tzdata tzdata/Zones/Europe select Berlin" >> /tmp/preseed.cfg; \
    debconf-set-selections /tmp/preseed.cfg && \
    rm -f /etc/timezone /etc/localtime && \
    apt-get update && \
    apt-get install -y tzdata \
    libcurl4-gnutls-dev \
    libssl-dev \
    libmysqlclient-dev \
    unixodbc \
    unixodbc-dev \
    --install-suggests

## obdc mysql connector
WORKDIR /tmp
RUN wget http://dev.mysql.com/get/mysql-apt-config_0.8.19-1_all.deb
RUN apt install -y ./mysql-apt-config_0.8.19-1_all.deb
RUN apt-get update
RUN apt-get install -y mysql-connector-odbc

## cleanup of files from setup
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# COPY ./docker/shiny/odbc.ini /etc/odbc.ini

## install R packages required 
RUN R -e 'install.packages(c(\
    "shiny", \
    "remotes", \
    "ggplot2", \
    "RMySQL", \
    "DBI", \
    "odbc", \
    "config" \
    ))'

## install shiny repos
RUN R -e 'remotes::install_github(c(\
    "rstudio/leaflet", \
    "rstudio/sass", \
    "plotly/plotly.R", \
    "tidyverse/dplyr", \
    "tidyverse/dbplyr", \
    "Appsilon/shiny.router", \
    "Appsilon/shiny.react", \
    "Appsilon/shiny.fluent" \
    ))'

## copy the app directory into the image
COPY ./app/* /srv/shiny-server

## set wd
WORKDIR /srv/shiny-server

## run app
CMD ["/usr/bin/shiny-server"]