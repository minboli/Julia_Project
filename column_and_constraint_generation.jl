using JuMP
using Gurobi
using MAT


#introduce u W D b
file_u = matopen(raw"C:\Users\minboli\Desktop\matlab data\Xincode\Xincode\u.mat")
z = read(file_u,"u")

file_W = matopen(raw"C:\Users\minboli\Desktop\matlab data\Xincode\Xincode\W.mat")
W = read(file_W,"W")

file_b = matopen(raw"C:\Users\minboli\Desktop\matlab data\Xincode\Xincode\b.mat")
b = read(file_b,"b")

file_D = matopen(raw"C:\Users\minboli\Desktop\matlab data\Xincode\Xincode\sparse_matrix_D.mat")
D = read(file_D,"D")

n = length(z)
m = length(b)

b_row = size(b)[1]
if length(size(b)) ==1
    b_col = 1
else
    b_col = size(b)[2]
end

p_max = ones(b_row,b_col)
p_min = ones(b_row,b_col)


#first step, define the master problem
function master_problem(lambda,mu,n, m, z,  b, W, D)
    model1 = Model(Gurobi.Optimizer)

    b_row = size(b)[1]
    if length(size(b)) ==1
        b_col = 1
    else
        b_col = size(b)[2]
    end
   

    @variable(model1, p_max[1:b_col,1:b_row])
    @variable(model1, p_min[1:b_col,1:b_row])

    @objective(model1, Max, p_max - p_min)
    
    part1 = z'*lambda
    
    for i in 1:m
        if value(mu[i]) >= 0
            part2 += (reshape(p_max,:,1)[i]-b[i])'*mu[i]
        else
            part2 += (reshape(p_min,:,1)[i]-b[i])'*mu[i]
        end
    end
    
    constraint_formula = part1+part2
    @constraint(model1,constraint_formula>=0)
    optimize!(model1)
    
    p_max_update = value.(p_max)
    p_min_update = value.(p_min)
    

    return constraint_formula,p_max_update, p_min_update
end

function sub_problem(p_max, p_min, n, m, z, b, W, D) 
    model2 = Model(Gurobi.Optimizer)
        
    @variable(model2, lambda[1:n] >= 0)
    @variable(model2, mu[1:m])
    @variable(model2, p[1:m])
        
    @objective(model2, Min, lambda' * z + mu' * (p - b))
        
    @constraint(model2, lambda' * W + mu' * D == 0)
    @constraint(model2, p .<= p_max)
    @constraint(model2, p .>= p_min)
    
    # for i in 1:m
    #     @constraint(model2, p[i] == p_max[i] => {mu[i] >= 0})
    #     @constraint(model2, p[i] == p_min[i] => {mu[i] <= 0})
    # end
    
    optimize!(model2)
    
    s = objective_value(model2)
    lambda_update = value.(lambda)
    mu_update = value.(mu)
    return s, lambda_update, mu_update
end

function constraint_generation(p_max,p_min,n, m, z, b, W, D)
    iteration_times = 0
    while iteration_times < 1e20
        iteration_times += 1
        if iteration_times ==1
            #first time p_max/p_min need to be estimated 
            s1_tempt,lambda_tempt,mu_tempt = sub_problem(p_max,p_min, n, m, z, b, W, D)
            constraint_formula_tempt,p_max_update,p_min_update = master_problem(lambda_tempt,mu_tempt,n, m, z, b, W, D)
            iteration += 1
        end
        s1_iteration,lambda_iteration,mu_iteration = sub_problem(p_max_update,p_min_update, n, m, z, b, W, D)
        
        if s1_iteration == 0
            break
        else
            costraint_formula_iteration,p_max_update,p_min_update = master_problem(lambda_iteration,mu_iteration,n, m, z, b, W, D)
            add_constraint(model1,constraint_formula_iteration)
            # add_constraint(master_problem,constraint_formula_iteration)
        end 
    end
    constraint_final,p_max_final,p_min_final = master_problem(lambda_iteration,mu_iteration,n, m, z, b, W, D)
    return p_max_final - p_min_final
end

print(constraint_generation(p_max,p_min,n, m, z, b, W, D))




#debug area
using JuMP
using Gurobi
using MAT
using LinearAlgebra


#introduce u W D b
file_u = matopen(raw"C:\Users\minboli\Desktop\matlab data\Xincode\Xincode\u.mat")
z = read(file_u,"u")

file_W = matopen(raw"C:\Users\minboli\Desktop\matlab data\Xincode\Xincode\W.mat")
W = read(file_W,"W")

file_b = matopen(raw"C:\Users\minboli\Desktop\matlab data\Xincode\Xincode\b.mat")
b = read(file_b,"b")

file_D = matopen(raw"C:\Users\minboli\Desktop\matlab data\Xincode\Xincode\sparse_matrix_D.mat")
D = read(file_D,"D")

b_row = size(b)[1]
if length(size(b)) ==1
    b_col = 1
else
    b_col = size(b)[2]
end

p_max = ones(b_row,b_col)
p_min = ones(b_row,b_col)

n = length(z)
m = length(b)

function sub_problem(p_max, p_min, n, m, z, b, W, D) 
    model = Model(Gurobi.Optimizer)

    @variable(model, lambda[1:n] >= 0)
    @variable(model, mu[1:m])
    # @variable(model, delta[1:m], Bin) 
    @variable(model, p[1:m])

    M = 1e5 

    @objective(model, Min, dot(lambda, z) + dot(mu, p - b))

    @constraint(model, lambda' * W + mu' * D .== 0)
    @constraint(model, lambda >= 0)

    @constraint(model, p .<= p_max)
    @constraint(model, p .>= p_min)
    # @constraint(model, p <= p_max - (1 - delta) * M)
    # @constraint(model, p >= p_min + delta * M)
    # @constraint(model, mu <= M * delta)
    # @constraint(model, mu >= -M * (1 - delta))

    optimize!(model)
    status = termination_status(model)
    if status != MOI.OPTIMAL
        error("The model did not solve correctly, status: $(status)")
    end

    return value.(lambda), value.(mu)
end

p_max_revised = reshape(p_max,:,1)
p_min_revised = reshape(p_min,:,1)

print(sub_problem(p_max_revised, p_min_revised, n, m, z, b, W, D))
