function block_diag(matrices::AbstractMatrix...)
    total_rows = sum(size(mat, 1) for mat in matrices)
    total_cols = sum(size(mat, 2) for mat in matrices)
    result = zeros(total_rows, total_cols)
    row_start, col_start = 1, 1
    for mat in matrices
        n, m = size(mat)
        result[row_start:(row_start+n-1), col_start:(col_start+m-1)] = mat
        row_start += n
        col_start += m
    end
    return result
end