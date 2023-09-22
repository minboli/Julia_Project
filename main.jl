using MAT
using LinearAlgebra
include("titianiumlinearapprox_chen.jl")
include("Generate_loads.jl")
The_File_Path_Of_titaniumlinearapprox_chen = "C:\\Users\\minboli\\Desktop\\matlab data\\Xincode\\Xincode\\Titanium_nodes_Y.mat"
vars = matread(The_File_Path_Of_titaniumlinearapprox_chen)
V0_LL_sub = 12000
V0_LL_pu = 1
Vmin = 0.98
Vmax = 1.02
Nodes_monitor_V = 1:1:126
N_loads, Load_node_DSS, P_l, Q_l = Generate_loads()
L_index_3d = [1:2; 4:15; 17:31; 33:40; 42:49; 51:N_loads] 
L_index_1d = [16, 32, 50]
L_index_lw = [3, 41]
P_l=P_l*0.9
Q_l=Q_l*0.9
Load_node_DSS_3d = Load_node_DSS[L_index_3d]
P_l_3d = P_l[L_index_3d, :]
Q_l_3d = Q_l[L_index_3d, :]
Load_node_DSS_1d = Load_node_DSS[L_index_1d]
P_l_1d = P_l[L_index_1d, :]
Q_l_1d = Q_l[L_index_1d, :]
Load_node_DSS_1d = Load_node_DSS[L_index_1d]
P_l_1d = P_l[L_index_, :]
Q_l_1d = Q_l[L_index_1d, :]
