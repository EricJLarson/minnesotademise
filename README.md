Data Analysis of Covid-19 and Climate
===========
![Image of MN]
(https://icons.iconarchive.com/icons/wikipedia/flags/128/US-MN-Minnesota-Flag-icon.png)

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
