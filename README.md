Demise of Minnesota: Data Analysis of Covid-19 and Climate
===========
![alt text](https://github.com/EricJLarson/minnesotademise/blob/master/US-MN-Minnesota-Flag-icon.png?raw=true)

This code pulls in data from the Internet, then generates a graphical report.

# User Guide

This has only been tested with Julia 1.5.

## Covid Data
To run, run the script, then open the resulting PNG file.   On Mac:
``` julia ./covid19.jl; ```

``` open /tmp/covid.png; ```

## Climate Data

This graphs Minnesota climate data.

``` julia climate.jl; ```

``` open /tmp/climate.png; ```
