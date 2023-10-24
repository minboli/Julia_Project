function DER_coeff_computation(Node, connection, phase, coeffMagWye, coeffMagDelta, coeffWyeP0, coeffDeltaP0, Seq_numbers)

    Nmulti_wye = size(coeffMagWye, 1)
    Nmulti_delta = div(size(coeffMagDelta, 2), 2)
    A = zeros(Nmulti_wye, 2)
    M = zeros(3, 2)
    # Check connection status with wye
    if connection == "wye"
        for jj in 1:length(phase)
            node_phase = Node + phase[jj] / 10
            index = findfirst(isequal(node_phase), Seq_numbers) - 1
            col = [index, index + Nmulti_wye]
            A .+= coeffMagWye[:, col]
            M .+= coeffWyeP0[:, col]
        end
    end
    # Check connection status with delta
    if connection == "delta"
        for jj in 1:length(phase)
            node_phase = Node + phase[jj] / 10
            index = findfirst(isequal(node_phase), Seq_numbers) - 1
            col = [index, index + Nmulti_delta]
            A .+= coeffMagDelta[:, col]
            M .+= coeffDeltaP0[:, col]
        end
    end
    # position index
    power_index = Int[]
    for jj in 1:length(phase)
        node_phase = Node + phase[jj] / 10
        index = findfirst(isequal(node_phase), Seq_numbers) - 1
        push!(power_index, index)
    end
    rr, cc = size(M)
    for ii in 1:rr
        for jj in 1:cc
            if abs(M[ii, jj]) > 1
                M[ii, jj] = sign(M[ii, jj]) * 0.99
            end
        end
    end

    return A, M, power_index
end
