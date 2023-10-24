function Load_PV_systems_1phase_delta(Capacity,N_num,N_inv)
    #Capacity refer to PV node Capacity, N_num refer to The PV node num, Phase refer to phase status
    PVaggr_1d_Capacity = Float64[]  # Collect capacity [kW]
    PVaggr_1d_DSS_node = Int[]      # Collect the node where the device is located
    PVaggr_1d_number = Int[]         # Phase index: 1 -> ab, 2 -> bc, 3 -> ca

    push!(PVaggr_1d_Capacity, Capacity)
    push!(PVaggr_1d_DSS_node, N_num)
    push!(PVaggr_1d_number, N_inv)

    return PVaggr_1d_Capacity, PVaggr_1d_DSS_node, PVaggr_1d_number
end
