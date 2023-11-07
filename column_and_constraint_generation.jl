using JuMP
using Gurobi
using MAT
using LinearAlgebra



# Define size of z D W b



z = [1 2 3 4]'
W = [5 6 7 8]'
b = [1 2 3]'
D = [4 5 6]'

z_row = size(z)[1]
if length(size(z_row)) == 1
    z_col = 1
else
    z_col = size(z)[2]
end 

D_row = size(D)[1]
if length(size(D_row)) == 1
    D_col = 1
else
    D_col = size(D)[2]
end 

W_row = size(W)[1]
if length(size(W)) == 1
    W_col = 1
else
    W_col = size(D)[2]
end 

b_row = size(b)[1]
if length(size(b_row)) == 1
    b_col = 1
else
    b_col = size(b)[2]
end 


#we need first to define p_max_initial and p_min_initial
p_max_initial = [ 7 8 9 ]'
p_min_initial = [ 4 5 6 ]'

#define CCP Algorithm 
function CCP(z,z_row,z_col,D,D_row,D_col,W,W_row,W_col,b,b_row,b_col,p_max_initial,p_min_initial)
    #master probelm
    model1 = Model(Gurobi.Optimizer)
    
    @variable(model1, p_max[1:b_row,1:b_col])
    @variable(model1, p_min[1:b_row,1:b_col]) 

    @objective(model1,Max,reshape(p_max,:,1)-reshape(p_min,:,1))

    part1 = dot(z,lambda)
    for i in 1:b_row
        if mu[i] >=0
            part2 += (reshape(p_max,:,1)[i]-b[i])'*mu[i]
        else
            part2 += (reshape(p_min,:,1)[i]-b[i])'*mu[i]
        end
    end
    constraint_formula = part1+part2
    @constraint(model1,constraint_formula>=0)
    # optimize!(model1)

    function sub_problem(p_max,p_min,z,z_row,z_col,D,D_row,D_col,W,W_row,W_col,b,b_row,b_col)
        model2 = Model(Gurobi.Optimizer)
        
        @variable(model2, lambda_sub[1:W_row,1:W_col] >= 0)
        @variable(model2, mu_sub[1:b_row,1:b_col])
        @variable(model2, p[1:b_row,1:b_col])
        
        @objective(model2, Min, dot(lambda_sub, z) + dot(mu_sub, p - b))
        
        @constraint(model2, dot(lambda_sub, W) + dot(mu_sub, D) .== 0)
        @constraint(model2, p .<= p_max)
        @constraint(model2, p .>= p_min)
    
        optimize!(model2)
    
        s = objective_value(model2)
        lambda_update = value.(lambda_sub)
        mu_update = value.(mu_sub)
        return s, lambda_update, mu_update
    end

    function optimize_master(model_master)
        return optimize!(model_master)
    end

    s_initial,lambda_initial,mu_initial = sub_problem(p_max_initial,p_min_initial,z,z_row,z_col,D,D_row,D_col,W,W_row,W_col,b,b_row,b_col)
    #s_initial cant decide p_max - p_min
    if s_initial ==0
        s_initial = -1
    end
    #start iteration
    while s_initial != 0
        optimize_master(model1)
        optimized_p_max = value.(p_max)
        optimized_p_min = value.(p_min)
        s_initial,lambda_initial,mu_initial = sub_problem(optimized_p_max,optimized_p_min,z,z_row,z_col,D,D_row,D_col,W,W_row,W_col,b,b_row,b_col)
        if s_initial == 0 
            break
        else
            part1_updated = dot(z,lambda_initial)
            for i in 1:b_row
                if value(mu_initial[i]) >= 0
                    part2_updated += (reshape(optimized_p_max,:,1)[i]-b[i])'*mu_initial[i]
                else
                    part2_updated += (reshape(optimized_p_min,:,1)[i]-b[i])'*mu_initial[i]
                end
            end
            constraint_formula_iteration = part1_updated + part2_updated
            add_constraints(model1,constraint_formula_iteration)
        end
    end

    return optimize_master(model1)
end

print(CCP(z,z_row,z_col,D,D_row,D_col,W,W_row,W_col,b,b_row,b_col,p_max_initial,p_min_initial))



#debug mod
using JuMP
using Gurobi
using MAT
using LinearAlgebra
# Define size of z D W b
z = [1 2 3 4]'
W = [5 6 7 8]'
b = [1 2 3]'
D = [4 5 6]'
z_row = 4
z_col = 1
D_row = 3
D_col = 1
W_row =4
b_row = 3
b_col = 1


#we need first to define p_max_initial and p_min_initial
p_max_initial = [ 7 8 9 ]'
p_min_initial = [ 4 5 6 ]'

function sub_problem(p_max,p_min,z,z_row,z_col,D,D_row,D_col,W,W_row,W_col,b,b_row,b_col)
    model2 = Model(Gurobi.Optimizer)
    
    @variable(model2, lambda[1:W_row,1:W_col] >= 0)
    @variable(model2, mu[1:b_row,1:b_col])
    @variable(model2, p[1:b_row,1:b_col])
    
    @objective(model2, Min, dot(lambda, z) + dot(mu, p - b))
    
    @constraint(model2, dot(lambda,W) + dot(mu,D) .== 0)
    @constraint(model2, p .<= p_max)
    @constraint(model2, p .>= p_min)

    optimize!(model2)

    s = objective_value(model2)
    lambda_update = value.(lambda)
    mu_update = value.(mu)
    return s, lambda_update, mu_update
end
print(sub_problem(p_max_initial,p_min_initial,z,z_row,z_col,D,D_row,D_col,W,W_row,W_col,b,b_row,b_col))