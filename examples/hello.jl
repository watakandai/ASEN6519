using Statistics
using Distributions
using Plots

nx = 10
nline=3

x = 1:10; y = rand(10, 2) # 2 columns means two lines

p1 = plot(x, y) # Make a line plot
p2 = scatter(x, y) # Make a scatter plot
p3 = plot(x, y, xlabel = "This one is labelled", lw = 3, title = "Subtitle")
p4 = histogram(x, y) # Four histograms each with 10 points? Why not!
plot(p1, p2, p3, p4, layout = (2, 2), legend = false)


μ = 10
σ = 2

dist = Normal(μ, σ)


X = rand(dist, 1000000)
histogram(X, bin=100)
