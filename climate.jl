# Analyze climate history of Minnesota
#
# Tested on Julia 1.5

using HTTP;
using JSON;
using DataFrames;
using Plots;

function getWebForm()
   d0 = Dict{String,Any}(
        "sdate" => "1873-01-01",
        "edate" => "2019-12-31",
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

params = getWebForm();
body = getData(params);
df = toDf(body);

df.high = map(x->parse(Int,x[1]), df.high);

plot(df.high, label = "high")
file = "/tmp/climate";
savefig(file);
println("File saved as " * file * ".png");
println("On Mac, view with \"open " * file * ".png;\"");
