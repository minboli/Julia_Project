using JumMP
using Gurobi
using MAT

#introduce u W D b
file_u = matopen(raw"C:\Users\minboli\Desktop\matlab data\Xincode\Xincode\u.mat")
u = read(file_u,"u")

file_W = matopen(raw"C:\Users\minboli\Desktop\matlab data\Xincode\Xincode\W.mat")
W = read(file_W,"W")

file_b = matopen(raw"C:\Users\minboli\Desktop\matlab data\Xincode\Xincode\b.mat")
b = read(file_b,"b")

file_D = matopen(raw"C:\Users\minboli\Desktop\matlab data\Xincode\Xincode\sparse_matrix_D.mat")
D = read(file_D,"D")

n = length(u)
m = length(b)
#first step, define the master problem
function master_problem(u, b, n, m,constraint_generation_column)
    model1 = Model(Gurobi.Optimizer)
    @variable(model1, p_max)
    @variable(model1, p_min)
    @variable(model1, lambda[1:n])
    @variable(model1, mu[1:m])

    @objective(model1, Max, p_max - p_min)
    
    for i in 1:m
        if value(mu[i]) >= 0
            for j in length(constraint_generation_column)
                @constraint(model1, constraint_generation_column[j][1] >= 0)
            end
        else
            for  j in length(constraint_generation_column)
                @constraint(model1, constraint_generation_column[j][2] >= 0)
            end    
        end
    end
    

    optimize!(model1)
    
    p_max_update = value.(p_max)
    p_min_update = value.(p_min)
    lambda_update = value.(lambda)
    mu_update = value.(mu)

    return p_max_update, p_min_update, lambda_update, mu_update
end

function sub_problem(lambda, mu, u, b, W, D, p_max, p_min, n, m)
    model2 = Model(Gurobi.Optimizer)
    @variable(model2, lambda[1:n])
    @variable(model2, mu[1:m])
    @variable(model2, mu_p[1:m])

    objective_expr = lambda' * u + sum(mu_p[i] - mu[i] * b[i] for i in 1:m)
    
    @objective(model2, Min, objective_expr)
    @constraint(model2, lambda' * W + mu' * D == 0)

    for i in 1:m
        @constraint(model2, mu_p[i] =min(mu[i] * p_max[i],mu[i] * p_min[i]))
        
    end

    optimize!(model2)
    
    lambda_new = value.(lambda)
    mu_new = value.(mu)
    mu_p_new = value.(mu_p)

    return lambda_new, mu_new, mu_p_new
end

function constraint_generation()
    max_iteration = 1e10
    additional_constraints = [[Z' * lambda_origin + (p_max_val - b)' * mu_origin],[Z' * lambda_origin + (p_min_val - b)' * mu_origin]]
    for i in 1:max_iteration
        lambda_new, mu_new, mu_p_new = sub_problem(lambda_val, mu_val, u, b, W, D, p_min, p_max, n, m)
        subproblem_obj = dot(lambda_new, u) + sum(mu_p_new[i] - mu_new[i] * b[i] for i in 1:m)    
        
        if subproblem_obj > =0
            break
        end
        
        if subproblem_obj < 0
            new_lambda, new_mu,new_mu_P = sub_problem(lambda, mu, u, b, W, D, p_max, p_min, n, m)
            push!(additional_constraints,[Z' * new_lambda + (p_max_val - b)' * new_mu],[Z' * new_lambda + (p_min_val - b)' * new_mu])
            
_




