using ASEN6519
using Plots


function tank1_func(x, t, λ, μ₁, μ₂)
    dx = zeros(size(x)[1])
    dx[1] =  λ - μ₁
    dx[2] =  - μ₂
    return dx
end


function tank2_func(x, t, λ, μ₁, μ₂)
    dx = zeros(size(x)[1])
    dx[1] =  - μ₁
    dx[2] =  λ - μ₂
    return dx
end

λ = 3/4
μ₁ = 1/2
μ₂ = 1/2
h₁ = 0
h₂ = 0

h = HybridSystem()
add_node(h, 1, (x, t) -> tank1_func(x, t, λ, μ₁, μ₂))
add_node(h, 2, (x, t) -> tank2_func(x, t, λ, μ₁, μ₂))
add_edge(h, 1, 2, x -> x[2] <= h₂)
add_edge(h, 2, 1, x -> x[1] <= h₂)

q1 = 1
x1 = [0, 1]
init_state = HybridState(q1, x1)
time, S = simulate(h, init_state, 0, 3.5, 0.001)

X = [s.x for s in S]
Q = [s.q for s in S]

X = hcat(X...)
X = X'

state_labels = ["Tank1" "Tank2"]
ps = plot_hybrid_state(time, X, Q, state_labels)
plot(ps[1], ps[2])
savefig("HW1_Q3.png")
