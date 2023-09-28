using JuMP
using GLPK
model = Model(GLPK.Optimizer)

@variable(model, B[1:n, 1:n], Symmetric)
@variable(model, d[1:n])

@objective(model, Max, logdet(B))

for i = 1:m
    Ai = A[i, :]
    @constraint(model, [i=1:m], norm(B * A[i, :]', 2) + dot(A[i, :], d) <= b[i])
end

optimize!(model)