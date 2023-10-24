function Load_HVAC_systems_1phase_delta(Capacity,N_num,phase)
    HVAC_1d_DSS_node = Int[]
    HVAC_1d_Capacity = float64[]
    HVAC_1d_phase = Int[] # Phase index: 1 -> ab, 2 -> bc, 3 -> ca
    push!(HVAC_1d_Capacity, Capacity)
    push!(HVAC_1d_DSS_node, N_num)
    push!(HVAC_1d_phase, Phase)

    return HVAC_1d_Capacity, HVAC_1d_DSS_node, HVAC_1d_phase
end
