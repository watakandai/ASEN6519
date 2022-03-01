using ASEN6519
using Plots
using LinearAlgebra


function plot_xys(Xs)
    count = 0
    plot()
    # plot(Xs[1][:, 1], Xs[1][:, 2], lw=3, label="T$(count)")
    for X in Xs
        plot!(X[1, :], X[2, :], lw=3, label="T$(count)", arrow=(:closed, 2.0), xlabel="X1", ylabel="X2")
        count += 1
    end
end

function simulate_runs(qs, xs)
    ndata = length(qs)
    Xs = []
    for i in 1:ndata
        q = qs[i]
        x = xs[i]
        init_state = HybridState(q, x)
        time, S = simulate(h, init_state, 0, 3, 0.01)

        X = [s.x for s in S]
        Q = [s.q for s in S]

        X = hcat(X...)
        # X = X'

        push!(Xs, X)
    end

    return Xs
end

# Question a
h = HybridSystem()
A1 = [[-1, -100] [10, -1]]
A2 = [[-1, -10] [100, -1]]
A3 = 1/2 * A1 + 1/2 * A2
@show A1
@show A2
@show A3
val, vec = eigen(A3)
@show val

f1(x, t) = A1 * x
f2(x, t) = A2 * x
g1(x) = x[1]*x[2] <= 0
g2(x) = x[1]*x[2] >= 0
add_node(h, 1, f1)
add_node(h, 2, f2)
add_edge(h, 1, 2, g1)
add_edge(h, 2, 1, g2)

Xs = simulate_runs([1, 1, 1, 1], [[1, 1], [1, 2], [2, 1], [2, 2],])
plot_xys(Xs)
savefig("examples/HW2/Q4a.png")


# Question b
val, vec = eigen(A1)
println(val) # prints out [-1.0 - 31.62i, -1.0 + 31.62i] => A1 is asymptotically stable
# Plot shows that the equalibirium point is x=[0,0]
h = HybridSystem()
add_node(h, 1, f1)
Xs = simulate_runs([1, 1, 1, 1], [[1, 1], [1, 2], [2, 1], [2, 2],])
plot_xys(Xs)
savefig("examples/HW2/Q4b1.png")

val, vec = eigen(A2)
println(val) # prints out [-1.0 - 31.62i, -1.0 + 31.62i] => A2 is asymptotically stable
# Plot shows that the equalibirium point is x=[0,0]
h = HybridSystem()
add_node(h, 1, f2)
Xs = simulate_runs([1, 1, 1, 1], [[1, 1], [1, 2], [2, 1], [2, 2],])
plot_xys(Xs)
savefig("examples/HW2/Q4b2.png")


println("Done!")
