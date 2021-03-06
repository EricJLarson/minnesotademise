# Analyze climate history of Minnesota
#
# Tested on Julia 1.5

using HTTP;
using JSON;
using DataFrames;
using Plots;
using SingularSpectrumAnalysis;
using GLM;

function getWebForm()
   d0 = Dict{String,Any}(
        "sdate" => "1873-01-01",
        "edate" => "2020-10-31",
        "sid"   => "mspthr",
        "elems" => Any[
          Dict{String,Any}("duration" => "dly","name" => "maxt","add" => "t","interval" => "dly"),
          Dict{String,Any}("duration" => "dly","name" => "mint","add" => "t","interval" => "dly"),
          Dict{String,Any}("duration" => "dly","name" => "pcpn","add" => "t","interval" => "dly"),
          Dict{String,Any}("duration" => "dly","name" => "snow","add" => "t","interval" => "dly"),
          Dict{String,Any}("duration" => "dly","name" => "snwd","add" => "t","interval" => "dly")
      ]
   )
   json0 = JSON.json(d0);
   strEnc = HTTP.escapeuri(json0);
   params = "params=" * strEnc;
end

function getData(params)
   resp = HTTP.request("POST", "https://data.rcc-acis.org/StnData", ["Content-Type" => "application/x-www-form-urlencoded"], params) 
   bodystr = String(resp.body);
   body = JSON.parse(bodystr);
end

function toDf(body::Dict{String,Any})
   colnames = [:date,:high,:low,:rain,:snow,:x];
   transposeDf(df) = DataFrame(collect.(eachrow(df)), colnames)
   df = body["data"] |> DataFrame |> transposeDf;
end

function getHighs()
   params = getWebForm();
   body = getData(params);
   df = toDf(body);
   df.high = map(x->parse(Float64,x[1]), df.high);
end

function plotHighs(high)
   plot(high, label = "high")
   file = "/tmp/climate";
   savefig(file);
   println("File saved as " * file * ".png");
   println("On Mac, view with \"open " * file * ".png;\"");
end

function getTrend(high10)
   yt, ys = analyze(high10, 365, robust=true) 
   dfyt = DataFrame(temp = yt)
   seq0 = [1:size(dfyt)[1]][1]
   insert!(dfyt,2,seq0,:day) 
   return dfyt
end 

function getLinearRegression(dfyt)
   ols = lm(@formula(temp ~ day), dfyt)
   fit = predict(ols)
end

function plotRegression(fit, temp)
   plot(fit,label="fit")
   ytrounded = map(x->round(x,digits=3), temp)
   plot!(ytrounded,label="trend")
   file = "/tmp/climatetrend";
   savefig(file);
   return file;
end

println("Requesting data")
@time high = getHighs()
println("Spectrum analysis")
@time trend = getTrend(high)
println("Generating regression")
@time fit = getLinearRegression(trend)   
println("Plotting")
@time file = plotRegression(fit, trend.temp) 
println("\nFile saved as " * file * ".png");
println("On Mac, view with \"open " * file * ".png;\"");

delta = last(fit) - first(fit)
deltar= round(delta, digits=3)
println("\nTemp increased $deltar F")
