using ASEN6519
using Plots


function f1(x, t)
    θ = x[1]
    ω = x[2]
    u = -ω*cos(θ) / (1 + abs(ω))

    dx = zeros(size(x)[1])
    dx[1] = ω
    dx[2] = sin(θ) - u*cos(θ)
    return dx
end


function f3(x, t)
    θ = x[1]
    ω = x[2]
    u = ω*cos(θ) / (1 + abs(ω))
    dx = zeros(size(x)[1])
    dx[1] = ω
    dx[2] = sin(θ) - u*cos(θ)
    return dx
end


function f2(x, t)
    θ = x[1]
    ω = x[2]
    u = 0
    dx = zeros(size(x)[1])
    dx[1] = ω
    dx[2] = sin(θ) - u*cos(θ)
    return dx
end


function f4(x, t)
    θ = x[1]
    ω = x[2]
    u = (2*ω + θ + sin(θ)) / cos(θ)
    dx = zeros(size(x)[1])
    dx[1] = ω
    dx[2] = sin(θ) - u*cos(θ)
    return dx
end


function energy(x)
    θ = x[1]
    ω = x[2]
    return 1.0 / 2.0 * ω^2 + (cos(θ) - 1)
end


function distance(x)
    θ = x[1]

    θ = θ % (2*π)
    θ = (θ + (2*π)) % (2*π)
    if θ > π
        θ -= (2*π)
    end

    return θ
end


ϵ = 0.005
δ = 0.1
h = HybridSystem()
add_node(h, 1, f1)
add_node(h, 2, f2)
add_node(h, 3, f3)
add_node(h, 4, f4)
add_edge(h, 1, 2, x -> energy(x) > -ϵ)
add_edge(h, 2, 1, x -> energy(x) <= -ϵ)
add_edge(h, 3, 2, x -> energy(x) < ϵ)
add_edge(h, 2, 3, x -> energy(x) >= ϵ)
add_edge(h, 2, 4, x -> -δ <= distance(x) && distance(x) <= δ)
add_edge(h, 4, 2, x -> distance(x) <= -δ || δ <= distance(x))

q1 = 1
# (i)
# x1 = [π/2.0, 0]

# (ii)
q1 = 3
x1 = [π/12.0, 3/5]

# (iii)
# x1 = [π, 0]

init_state = HybridState(q1, x1)
time, S = simulate(h, init_state, 0, 20, 0.001)

X = [s.x .* 180/π for s in S]
Q = [s.q for s in S]
E = [energy(s.x) for s in S]

X = hcat(X...)
X = X'

state_labels = ["θ" "ω"]
ps = plot_hybrid_state(time, X, Q, state_labels)
p2 = plot(time, E, lw=3, label="Energy")
plot(ps[1], ps[2], p2, layout=(1, 3), size=(900, 400))
savefig("HW1_Q1_$(x1).png")
