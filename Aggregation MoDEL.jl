using JuMP
using GLPK
model = Model(GLPK.Optimizer)
@variable(model, F[1:num_time, 1:num_time], PSD)
@variable(model, f[1:num_time])
@variable(model, c[1:ntp])
@variable(model, L[1:ntp, 1:num_time])

@objective(model, Max, logdet(F))

M
for i in 1:ntp  
    @constraint(model, norm((dot(W1,F) + dot(W2,L))[:, i] for i in 1:size(M,2)) + dot(W1, f) + dot(W2, c) - u <= 0)
end

optimize!(model)