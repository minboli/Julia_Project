using LinearAlgebra
using SparseArrays
include("Load_PV_system_1phase_delta.jl")
include("Load_HVAC_system_1phase_delta.jl")
include("Load_aggreg_Battery_1phase_delta.jl")
include("Load_aggreg_PV_sytem_1phase_delta.jl")
include("Load_Battery_1phase_delta.jl")
include("DER_coeff_computation.jl")
#everytime change model need to update lines data
# Lines = [
#     (1, 1, 2, 0.0922, 0.0477, 100, 60, 385),
#     (2, 2, 3, 0.4930, 0.2511, 90, 40, 355),
#     (3, 3, 4, 0.3660, 0.1864, 120, 80, 240),
#     (4, 4, 5, 0.3811, 0.1941, 60, 30, 240),
#     (5, 5, 6, 0.8190, 0.7070, 60, 20, 240),
#     (6, 6, 7, 0.1872, 0.6188, 200, 100, 110),
#     (7, 7, 8, 1.7114, 1.2351, 200, 100, 85),
#     (8, 8, 9, 1.0300, 0.7400, 60, 20, 70),
#     (9, 9, 10, 1.0400, 0.7400, 60, 20, 70),
#     (10, 10, 11, 0.1966, 0.0650, 45, 30, 55),
#     (11, 11, 12, 0.3744, 0.1238, 60, 35, 55),
#     (12, 12, 13, 1.4680, 1.1550, 60, 35, 55),
#     (13, 13, 14, 0.5416, 0.7129, 120, 80, 40),
#     (14, 14, 15, 0.5910, 0.5260, 60, 10, 25),
#     (15, 15, 16, 0.7463, 0.5450, 60, 20, 20),
#     (16, 16, 17, 1.2890, 1.7210, 60, 20, 20),
#     (17, 17, 18, 0.7320, 0.5740, 90, 40, 20),
#     (18, 2, 19, 0.1640, 0.1565, 90, 40, 40),
#     (19, 19, 20, 1.5042, 1.3554, 90, 40, 25),
#     (20, 20, 21, 0.4095, 0.4784, 90, 40, 20),
#     (21, 21, 22, 0.7089, 0.9373, 90, 40, 20),
#     (22, 3, 23, 0.4512, 0.3083, 90, 50, 85),
#     (23, 23, 24, 0.8980, 0.7091, 420, 200, 85),
#     (24, 24, 25, 0.8960, 0.7011, 420, 200, 40),
#     (25, 6, 26, 0.2030, 0.1034, 60, 25, 125),
#     (26, 26, 27, 0.2842, 0.1447, 60, 25, 110),
#     (27, 27, 28, 1.0590, 0.9337, 60, 20, 110),
#     (28, 28, 29, 0.8042, 0.7006, 120, 70, 110),
#     (29, 29, 30, 0.5075, 0.2585, 200, 600, 95),
#     (30, 30, 31, 0.9744, 0.9630, 150, 70, 55),
#     (31, 31, 32, 0.3105, 0.3619, 210, 100, 30),
#     (32, 32, 33, 0.3410, 0.5302, 60, 40, 20),
# ]
V0_LL_pu = 1
V0_LL_sub = 12000
mag_base = 1000
Zbase = 1
VbaseD = V0_LL_sub/mag_base
Vbase = VbaseD / sqrt(3)
SbaseD = (VbaseD^2) / Zbase
Sbase = (VbaseD^2) / Zbase
V0_LL_pu = V0_LL_pu * mag_base
Fact_1d = 1000/SbaseD
num_time = 24
pf_PV = 0.3 #need to be adjusted based at Baron Wu Model
pf_bat = 0.3 #need to be adjusted based at Baron Wu Model
dT = 60/60


#HVAC part / every time change model need to update data
tem_max = 26
tem_min = 18
tem_out = [18,20,20,21,22,23,24,27,29,30,33,35,37,35,33,30,26,23,21]
alpha = 0.6
beta = -0.02
HVAC_1d_Capacity, HVAC_1d_DSS_node, HVAC_1d_phase = Load_HVAC_systems_1phase_delta(HVAC_Capacity_1,
N_num,phase) #every time add 1 node should update for once

#calculate index of nodes to monitor
Nodes_monitor_V = 1:126
Nodes_monitor_V_index = Int[]
for pp in 1:length(Seq_numbers)
    if sum(floor.(Seq_numbers[pp]) .== Nodes_monitor_V) == 1
        push!(Nodes_monitor_V_index, pp)
    end
end

#calculate effiency for each der and aggregation der
A_PV_1d_p = zeros(length(Nodes_monitor_V_index), length(PV_1d_DSS_node))
A_PV_1d_q = zeros(length(Nodes_monitor_V_index), length(PV_1d_DSS_node))
M_PV_1d_p = zeros(3,length(PV_1d_DSS_node))
M_PV_1d_q = zeros(3,length(PV_1d_DSS_node))
for ii = 1:length(PV_1d_DSS_node)
    A, M, power_index = DER_coeff_computation(PV_1d_DSS_node[ii], "delta", [1], coeffMagWye, coeffMagDelta, coeffWyeP0, coeffDeltaP0, Seq_numbers)
    A_PV_1d_p[:, ii] = A[Nodes_monitor_V_index - 3, 1]
    A_PV_1d_q[:, ii] = A[Nodes_monitor_V_index - 3, 2]
    M_PV_1d_p[:, ii] = M[:, 1]
    M_PV_1d_q[:, ii] = M[:, 2]
end

A_PV_aggr_1d_p = zeros(length(Nodes_monitor_V_index), length(PV_aggr_1d_DSS_node))
A_PV_aggr_1d_q = zeros(length(Nodes_monitor_V_index), length(PV_aggr_1d_DSS_node))
M_PV_aggr_1d_p = zeros(3,length(PV_aggr_1d_DSS_node))
M_PV_aggr_1d_p = zeros(3,length(PV_aggr_1d_DSS_node))
for ii = 1:length(PV_aggr_1d_DSS_node)
    A, M, power_index = DER_coeff_computation(PV_aggr_1d_DSS_node[ii], "delta", [1], coeffMagWye, coeffMagDelta, coeffWyeP0, coeffDeltaP0, Seq_numbers)
    A_PV_aggr_1d_p[:, ii] = A[Nodes_monitor_V_index - 3, 1]
    A_PV_aggr_1d_q[:, ii] = A[Nodes_monitor_V_index - 3, 2]
    M_PV_aggr_1d_p[:, ii] = M[:, 1]
    M_PV_aggr_1d_q[:, ii] = M[:, 2]
end

A_Bat_1d_p = zeros(length(Nodes_monitor_V_index), length(Bat_1d_DSS_node))
A_Bat_1d_q = zeros(length(Nodes_monitor_V_index), length(Bat_1d_DSS_node))
M_Bat_1d_p = zeros(3,length(Bat_1d_DSS_node))
M_Bat_1d_p = zeros(3,length(Bat_1d_DSS_node))
for ii = 1:length(Bat_1d_DSS_node)
    A, M, power_index = DER_coeff_computation(Bat_1d_DSS_node[ii], "delta", [1], coeffMagWye, coeffMagDelta, coeffWyeP0, coeffDeltaP0, Seq_numbers)
    A_Bat_1d_p[:, ii] = A[Nodes_monitor_V_index - 3, 1]
    A_Bat_1d_q[:, ii] = A[Nodes_monitor_V_index - 3, 2]
    M_Bat_1d_p[:, ii] = M[:, 1]
    M_Bat_1d_q[:, ii] = M[:, 2]
end

A_Bat_aggr_1d_p = zeros(length(Nodes_monitor_V_index), length(Bat_aggr_1d_DSS_node))
A_Bat_aggr_1d_q = zeros(length(Nodes_monitor_V_index), length(Bat_aggr_1d_DSS_node))
M_Bat_aggr_1d_p = zeros(3,length(Bat_aggr_1d_DSS_node))
M_Bat_aggr_1d_p = zeros(3,length(Bat_aggr_1d_DSS_node))
for ii = 1:length(Bat_aggr_1d_DSS_node)
    A, M, power_index = DER_coeff_computation(Bat_aggr_1d_DSS_node[ii], "delta", [1], coeffMagWye, coeffMagDelta, coeffWyeP0, coeffDeltaP0, Seq_numbers)
    A_Bat_aggr_1d_p[:, ii] = A[Nodes_monitor_V_index - 3, 1]
    A_Bat_aggr_1d_q[:, ii] = A[Nodes_monitor_V_index - 3, 2]
    M_Bat_aggr_1d_p[:, ii] = M[:, 1]
    M_Bat_aggr_1d_q[:, ii] = M[:, 2]
end

A_HVAC_1d_p = zeros(length(Nodes_monitor_V_index), length(Bat_HVAC_DSS_node))
A_HVAC_1d_q = zeros(length(Nodes_monitor_V_index), length(Bat_HVAC_DSS_node))
M_HVAC_1d_p = zeros(3,length(HVAC_1d_DSS_node))
M_HVAC_1d_p = zeros(3,length(HVAC_1d_DSS_node))
for ii = 1:length(HVAC_1d_DSS_node)
    A, M, power_index = DER_coeff_computation(HVAC_1d_DSS_node[ii], "delta", [1], coeffMagWye, coeffMagDelta, coeffWyeP0, coeffDeltaP0, Seq_numbers)
    A_HVAC_1d_p[:, ii] = A[Nodes_monitor_V_index - 3, 1]
    A_HVAC_1d_q[:, ii] = A[Nodes_monitor_V_index - 3, 2]
    M_HVAC_1d_p[:, ii] = M[:, 1]
    M_HVAC_1d_q[:, ii] = M[:, 2]
end

#calculate n = N_PV_1d  + N_PVaggr_1d + N_Bat_1d + N_Bat_aggr_1d + N_HVAC_1d
n_PV_1d = length(n_PV_1d_Capacity)
n_PVaggr_1d = length(n_PVaggr_1d_Capcity)
n_Bat_1d = length(n_bat_1d_Capacity)
n_Bat_aggr_1d = length(n_Bat_aggr_1d)
N_HVAC_1d = length(n_HVAC_1d_Capcity)
n = N_PV_1d  + N_PVaggr_1d + N_Bat_1d + N_Bat_aggr_1d + N_HVAC_1d
nT = n * num_time
M1 = sparse(hcat(
    A_PV_3d_p + pf_PV * A_PV_3d_q,
    A_PV_1d_p + pf_PV * A_PV_1d_q,
    A_PV_1w_p + pf_PV * A_PV_1w_q,
    A_PV_aggr_3d_p + pf_PV * A_PV_aggr_3d_q,
    A_Bat_3d_p + pf_bat * A_Bat_3d_q,
    A_Bat_aggr_3d_p + pf_bat * A_Bat_aggr_3d_q,
    -A_HVAC_3d_p
))  #generate M1 matrix
M2 = -dT * hcat(sparse(N_Bat_1d,N_PV_1d + N_PVaggr_1d),
    I(N_Bat_1d),
    sparse(N_Bat_1d, N_Bat_aggr_1d + N_HVAC_1d)
)
M3 = -dT * hcat(sparse(N_Bat_aggr_1d, N_PV_1d + N_PVaggr_1d),
    I(N_Bat_aggr_1d),
    sparse(N_Bat_aggr_1d, N_Bat_aggr_1d + N_HVAC_1d)
)
mult = zeros(num_time)
for i = 1:num_time
    mult[i, 1:i] .= beta * (1-alpha) .^ (i-1:-1:0)
end
mult = sparse(mult)
M4 = hcat(sparse(N_HVAC_1d,N_PV_1d+N_PVaggr_1d+N_Bat_1d+N_Bat_aggr_1d),I(N_HVAC_1d))
#divide W into different part
power_upper_bound = I(nT)
power_lower_bound = -I(nT)
voltage_upper_bound = kron(SparseMatrixCSC(I, num_time, num_time), M1)
voltage_upper_bound = -kron(SparseMatrixCSC(I, num_time, num_time), M1)
bat_1d_time_coupling_constraint_upper_bound = kron(tril(ones(num_time, num_time)), M2)
bat_1d_time_coupling_constraint_lower_bound = -kron(tril(ones(num_time, num_time)), M2)
bat_aggr_1d_time_coupling_constraint_upper_bound = kron(tril(ones(num_time, num_time)), M3)
bat_aggr_1d_time_coupling_constraint_lower_bound = -kron(tril(ones(num_time, num_time)), M3)
HVAC_1d_upper_bound = kron(mult, M4)
HVAC_1d_lower_bound = kron(mult, M4)
accum_tem_out = zeros(N_HVAC_1d, num_time)
accum_tem_out[:, 1] .= tem_out[1]
for i = 2:num_time
    accum_tem_out[:, i] .= (1-alpha) .* accum_tem_out[:, i-1] .+ alpha .* tem_out[i]
end
