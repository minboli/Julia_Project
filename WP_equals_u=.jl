using JuMP
using Gurobi
using MAT
#upper_bound
model = Model(Gurobi.Optimizer)

N_PV_3d = 18
N_PV_1d = 3
N_PV_1w = 1
N_PVaggr_3d = 11
N_Bat_3d = 17
N_HVAC_3d = 5
num_time = 19
N_Bat_aggr_3d = 11

file_u = matopen(raw"C:\Users\minboli\Desktop\matlab data\Xincode\Xincode\u.mat")
u = read(file_u,"u")

file_W = matopen(raw"C:\Users\minboli\Desktop\matlab data\Xincode\Xincode\W.mat")
W = read(file_W,"W")

file_b = matopen(raw"C:\Users\minboli\Desktop\matlab data\Xincode\Xincode\b.mat")
b = read(file_b,"b")

file_D = matopen(raw"C:\Users\minboli\Desktop\matlab data\Xincode\Xincode\sparse_matrix_D.mat")
D = read(file_D,"D")

@variable(model, p_PV_3d_u[1:N_PV_3d, 1:num_time])
@variable(model, p_PV_1d_u[1:N_PV_1d, 1:num_time])
@variable(model, p_PV_1w_u[1:N_PV_1w, 1:num_time])
@variable(model, p_PVagg_3d_u[1:N_PVaggr_3d, 1:num_time])
@variable(model, p_bat_3d_u[1:N_Bat_3d, 1:num_time])
@variable(model, p_batagg_3d_u[1:N_Bat_aggr_3d, 1:num_time])
@variable(model, p_HVAC_3d_u[1:N_HVAC_3d, 1:num_time])
@variable(model, p0_u[1:3, 1:num_time])
#lower_bound
@variable(model, p_PV_3d_l[1:N_PV_3d, 1:num_time])
@variable(model, p_PV_1d_l[1:N_PV_1d, 1:num_time])
@variable(model, p_PV_1w_l[1:N_PV_1w, 1:num_time])
@variable(model, p_PVagg_3d_l[1:N_PVaggr_3d, 1:num_time])
@variable(model, p_bat_3d_l[1:N_Bat_3d, 1:num_time])
@variable(model, p_batagg_3d_l[1:N_Bat_aggr_3d, 1:num_time])
@variable(model, p_HVAC_3d_l[1:N_HVAC_3d, 1:num_time])
@variable(model, p0_l[1:3, 1:num_time])


function constraints_on_WP_lessthan_or_equalsto_U(m, upper_vars, lower_vars, W, D, u, b)
    #model W*P<=U,P0=D*P+b
    @constraint(m,W * upper_vars .<= u )
    @constraint(m,W * lower_vars .<= u )
    #guarantee every element in W*P lower than U
    @constraint(m, reshape(p0_u,:,1) .== D * upper_vars + b) 
    @constraint(m, reshape(p0_l,:,1) .== D * lower_vars + b)
    #guarantee P0 follow P0= DP+b
    @constraint(m, p_bat_3d_l .>= p_bat_3d_u)
    @constraint(m, p_batagg_3d_l .>= p_batagg_3d_u)
    @constraint(m, p_HVAC_3d_l .<= p_HVAC_3d_u)
    @constraint(m, sum(p0_l, dims=1) .<= sum(p0_u, dims=1))

end

upper_vars = vcat([p_PV_3d_u; p_PV_1d_u; p_PV_1w_u; p_PVagg_3d_u; p_bat_3d_u; p_batagg_3d_u; p_HVAC_3d_u])[:]
lower_vars = vcat([p_PV_3d_l; p_PV_1d_l; p_PV_1w_l; p_PVagg_3d_l; p_bat_3d_l; p_batagg_3d_l; p_HVAC_3d_l])[:]
constraints_on_WP_lessthan_or_equalsto_U(model, upper_vars, lower_vars, W, D, u, b)


len_u = length(upper_vars)
len_l = length(lower_vars)
f = zeros(len_u)' .* upper_vars + zeros(len_l)' .* lower_vars
@objective(model, Max, f)

optimize!(model)
print("Optimal value of upper_vars",value.(upper_vars))
print("Optimal value of lower_vars",value.(lower_vars))
print("Optimal value of p0_l",value.(p0_l))
print("Optimal value of p0_u",value.(p0_u))