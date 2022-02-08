using DifferentialEquations
using Plots
using DataStructures

NodeName = String
EdgeName = String


mutable struct Node
    f::Function
    attr::Dict
    successors::Vector
    predecessors::Vector
    Node(f) = new(f, Dict(), [], [])
end

mutable struct Edge
    guard::Function
    attr::Dict
    Edge(guard) = new(guard, Dict())
end

struct HybridState
    q::Any
    x::Any
end


mutable struct HybridSystem
    nodes::Dict{Any, Node}
    edges::DefaultDict{Any, Dict{Any, Edge}}
    init::HybridState
    HybridSystem() = new(Dict(), DefaultDict{AbstractString, Dict}(Dict()))
end


function add_node(h::HybridSystem, node_name::Any, f:: Function, attr::Dict = Dict())
    h.nodes[node_name] = Node(f)
    # merge!(h.nodes[node_name].attr, attr)
end


function add_edge(h::HybridSystem, source::Any, target::Any, guard::Function, attr::Dict = Dict())
    if !haskey(h.nodes, source)
        throw(Error("$(source) is not in the node list"))
    end

    if !haskey(h.nodes, target)
        throw(Error("$(target) is not in the node list"))
    end

    h.edges[source][target] = Edge(guard)
    push!(h.nodes[source].successors, target)
    # merge!(h.edges[source][target].attr, attr)
end


function set_init_state(h::HybridSystem, init::HybridState)
    h.init = init
end


function rungekutta(f, y0, t)
    n = length(t)
    y = zeros((n, length(y0)))
    y[1,:] = y0
    for i in 1:n-1
        h = t[i+1] - t[i]
        k1 = f(y[i,:], t[i])
        k2 = f(y[i,:] + k1 * h/2, t[i] + h/2)
        k3 = f(y[i,:] + k2 * h/2, t[i] + h/2)
        k4 = f(y[i,:] + k3 * h, t[i] + h)
        y[i+1,:] = y[i,:] + (h/6) * (k1 + 2*k2 + 2*k3 + k4)
    end
    return y
end


function find_valid_successor(h, q, x)
    successors = h.nodes[q].successors
    valid_successors = []

    for successor in successors
        valid = h.edges[q][successor].guard(x)

        if valid
            push!(valid_successors, successor)
        end
    end

    # TODO: pick one just for now
    if size(valid_successors)[1] != 0
        return valid_successors[1]
    end

    return Nothing()
end


function step(h::HybridSystem, state::HybridState, t::Float64, dt::Float64)
    q = state.q
    x = state.x

    X = rungekutta(h.nodes[state.q].f, x, (t, t+dt))
    x = X[2, :]

    next_q = find_valid_successor(h, q, x)

    if next_q != Nothing()
        q = next_q
    end

    return HybridState(q, x)
end


function simulate(
    h::HybridSystem,
    init::HybridState,
    start_time::Real,
    end_time::Real,
    dt::Float64)

    set_init_state(h, init)

    time = [start_time:dt:end_time;]
    state = h.init
    S = [state]

    for t in time
        state = step(h, state, t, dt)
        push!(S, state)
    end
    pop!(S)
    # push!(time, end_time)
    return time, S
end


function plot_hybrid_state(time, X, Q, state_labels)
    p1 = plot(time, X, lw=3, labels=state_labels)
    p2 = plot(time, Q, lw=3, label="Mode")

    return [p1 p2]
end
