function Load_PV_systems_1phase_delta(Capacity,N_num,phase)
    #Capacity refer to PV node Capacity, N_num refer to The PV node num, Phase refer to phase status
    PV_1d_Capacity = Float64[]  # Collect capacity [kW]
    PV_1d_DSS_node = Int[]      # Collect the node where the device is located
    PV_1d_phase = Int[]         # Phase index: 1 -> ab, 2 -> bc, 3 -> ca

    push!(PV_1d_Capacity, Capacity)
    push!(PV_1d_DSS_node, N_num)
    push!(PV_1d_phase, Phase)

    return PV_1d_Capacity, PV_1d_DSS_node, PV_1d_phase
end
