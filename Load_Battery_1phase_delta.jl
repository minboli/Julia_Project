function Load_Battery_1phase_delta(Capacity,Soc,N_num,eff_ch,eff_dis)
    Bat_1d_Capacity = Float64[];
    Bat_1d_DSS_node = Float64[];
    Bat_1d_soc = Float64[];
    Bat_1d_eff_ch = Float64[];
    Bat_1d_eff_dis = Float64[];
    push!(Bat_1d_Capacity, Capacity)
    push!(Bat_1d_DSS_node, N_num)
    push!(Bat_1d_soc, Soc)
    push!(Bat_1d_eff_ch,eff_ch)
    push!(Bat_1d_eff_dis,eff_dis)

    return Bat_1d_Capacity, Bat_1d_DSS_node, Bat_1d_soc,Bat_1d_eff_ch,Bat_1d_eff_dis
end
