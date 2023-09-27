using JuMP
using GLPK
#upper_bound
model = Model(GLPK.Optimizer)
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

@objective(model, Max, sum(log.(sum(p0_u, dims=1) .- sum(p0_l, dims=1))))

function constraints_on_WP_lessthan_or_equalsto_U(m, upper_vars, lower_vars, W, D, u, b)
#m refers to model, W*P<=U,P0=D*P+b
    upper_modification = vcat(upper_vars...)
    #joint elements in upper_vars together
    lower_modification = vcat(lower_vars...)
    #joint elements in lower_vars together
    @constraint(m,W * upper_reshape .<= u )
    @constraint(m,W * lower_reshape .<= u )
    #guarantee every element in W*P lower than U
    @constraint(m, vec(p0_u) .== D * upper_reshape + b) 
    @constraint(m, vec(p0_l) .== D * lower_reshape + b)
    #guarantee P0 follow P0= DP+b
    @constraint(m, p_bat_3d_l .>= p_bat_3d_u)
    @constraint(m, p_batagg_3d_l .>= p_batagg_3d_u)
    @constraint(m, p_HVAC_3d_l .<= p_HVAC_3d_u)
    @constraint(m, sum(p0_l, dims=1) .<= sum(p0_u, dims=1))
end
upper_vars = [p_PV_3d_u, p_PV_1d_u, p_PV_1w_u, p_PVagg_3d_u, p_bat_3d_u, p_batagg_3d_u, p_HVAC_3d_u]
lower_vars = [p_PV_3d_l, p_PV_1d_l, p_PV_1w_l, p_PVagg_3d_l, p_bat_3d_l, p_batagg_3d_l, p_HVAC_3d_l]

constraints_on_WP_lessthan_or_equalsto_U(m, upper_vars, lower_vars, W, D, u, b)
optimize!(model)