using MAT
function generate_loads()
    file = matopen("C:\\Users\\minboli\\Desktop\\matlab data\\Xincode\\Xincode\\loadavail20150908.mat") 
    Load = read(file, "Load") 
    loc = Int64.(Load["nameopal"]) 
    N_loads = length(loc)
    P_l = zeros(N_loads, length(Load["kW"][1]))
    Q_l = zeros(N_loads, length(Load["kW"][1]))
    Load_node_DSS = zeros(Int64, N_loads)
    for ii = 1:N_loads
        P_l[ii, :] = Load["kW"][ii]
        Q_l[ii, :] = Load["kVar"][ii]
        Load_node_DSS[ii] = loc[ii]
    end
    close(file)
    return N_loads, Load_node_DSS, P_l, Q_l
end
