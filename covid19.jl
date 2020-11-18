#!/Applications/Julia-1.5.app/Contents/Resources/julia/bin/julia

# Generates file /tmp/covid.png
# On Mac, run this file as: "julia ./covid19.jl; open /tmp/covid.png"

using CSV;
using DataFrames;
using HTTP;
using JSON; 
using Plots;


function getPopulations()
   url = "https://api.census.gov/data/2014/pep/natstprc?get=STNAME,POP&for=state:*&DATE_=7";
   colnames = [:name,:pop];
   transposeDf(df) = DataFrame(collect.(eachrow(df[1:2,2:53])), colnames)
   pops = HTTP.request("GET", url; verbose=1).body |> String |> JSON.parse  |> DataFrame |> transposeDf;
   pops.pop = map(x->parse(Int,x), pops.pop);
   return pops;
end

function getStats(state)
   url = "https://api.covidtracking.com/v1/states/" * state *  "/daily.csv";
   df0 = CSV.File(
    HTTP.request("GET", url; verbose=1).body
   ) |> DataFrame;
end

function getDeathPerCapita(state, pop)
   df = getStats(state)
   perM = df[:deathIncrease] ./ (pop/(1000*1000));
   moving_average(vs,n) = [sum(@view vs[i:(i+n-1)])/n for i in 1:(length(vs)-(n-1))]
   smooth = moving_average(perM,5);
end

function getPopulation(state)
   pops = getPopulations();
   pop = pops[pops.name .== state,:pop][1]
end


function plotDeathsPerCapita((state, abbr))
   pop = getPopulation(state)
   smooth = getDeathPerCapita(abbr,pop);
   plot!(smooth, label = abbr)
end

plotDeathsPerCapita(("Minnesota","mn"))
plotDeathsPerCapita(("Massachusetts","ma"))
plotDeathsPerCapita(("California","ca"))

file = "/tmp/covid";
savefig(file);
println("File saved as " * file * ".png");
println("On Mac, view with \"open " * file * ".png;\"");
