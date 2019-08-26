#####
##### Velocity gradients
#####

# Diagonal
@inline ∂x_u(i, j, k, grid, u) = ∂x_caa(i, j, k, grid, u)
@inline ∂y_v(i, j, k, grid, v) = ∂y_aca(i, j, k, grid, v)
@inline ∂z_w(i, j, k, grid, w) = ∂z_aac(i, j, k, grid, w)

# Off-diagonal
@inline ∂x_v(i, j, k, grid, v) = ∂x_faa(i, j, k, grid, v)
@inline ∂x_w(i, j, k, grid, w) = ∂x_faa(i, j, k, grid, w)

@inline ∂y_u(i, j, k, grid, u) = ∂y_afa(i, j, k, grid, u)
@inline ∂y_w(i, j, k, grid, w) = ∂y_afa(i, j, k, grid, w)

@inline ∂z_u(i, j, k, grid, u) = ∂z_aaf(i, j, k, grid, u)
@inline ∂z_v(i, j, k, grid, v) = ∂z_aaf(i, j, k, grid, v)

#####
##### Strain components
#####

# ccc strain components
@inline Σ₁₁(i, j, k, grid, u) = ∂x_caa(i, j, k, grid, u)
@inline Σ₂₂(i, j, k, grid, v) = ∂y_aca(i, j, k, grid, v)
@inline Σ₃₃(i, j, k, grid, w) = ∂z_aac(i, j, k, grid, w)

@inline tr_Σ(i, j, k, grid, u, v, w) =
    Σ₁₁(i, j, k, grid, u) + Σ₂₂(i, j, k, grid, v) + Σ₃₃(i, j, k, grid, w)

# ffc
@inline Σ₁₂(i, j, k, grid::Grid{T}, u, v) where T =
    T(0.5) * (∂y_afa(i, j, k, grid, u) + ∂x_faa(i, j, k, grid, v))

# fcf
@inline Σ₁₃(i, j, k, grid::Grid{T}, u, w) where T =
    T(0.5) * (∂z_aaf(i, j, k, grid, u) + ∂x_faa(i, j, k, grid, w))

# cff
@inline Σ₂₃(i, j, k, grid::Grid{T}, v, w) where T =
    T(0.5) * (∂z_aaf(i, j, k, grid, v) + ∂y_afa(i, j, k, grid, w))

@inline Σ₁₂²(i, j, k, grid, u, v) = Σ₁₂(i, j, k, grid, u, v)^2
@inline Σ₁₃²(i, j, k, grid, u, w) = Σ₁₃(i, j, k, grid, u, w)^2
@inline Σ₂₃²(i, j, k, grid, v, w) = Σ₂₃(i, j, k, grid, v, w)^2

#####
##### Renamed functions for consistent function signatures
#####

@inline ∂x_u(i, j, k, grid, u, v, w) = ∂x_u(i, j, k, grid, u)
@inline ∂x_v(i, j, k, grid, u, v, w) = ∂x_v(i, j, k, grid, v)
@inline ∂x_w(i, j, k, grid, u, v, w) = ∂x_w(i, j, k, grid, w)

@inline ∂y_u(i, j, k, grid, u, v, w) = ∂y_u(i, j, k, grid, u)
@inline ∂y_v(i, j, k, grid, u, v, w) = ∂y_v(i, j, k, grid, v)
@inline ∂y_w(i, j, k, grid, u, v, w) = ∂y_w(i, j, k, grid, w)

@inline ∂z_u(i, j, k, grid, u, v, w) = ∂z_u(i, j, k, grid, u)
@inline ∂z_v(i, j, k, grid, u, v, w) = ∂z_v(i, j, k, grid, v)
@inline ∂z_w(i, j, k, grid, u, v, w) = ∂z_w(i, j, k, grid, w)

@inline Σ₁₁(i, j, k, grid, u, v, w) = Σ₁₁(i, j, k, grid, u)
@inline Σ₂₂(i, j, k, grid, u, v, w) = Σ₂₂(i, j, k, grid, v)
@inline Σ₃₃(i, j, k, grid, u, v, w) = Σ₃₃(i, j, k, grid, w)

@inline Σ₁₂(i, j, k, grid, u, v, w) = Σ₁₂(i, j, k, grid, u, v)
@inline Σ₁₃(i, j, k, grid, u, v, w) = Σ₁₃(i, j, k, grid, u, w)
@inline Σ₂₃(i, j, k, grid, u, v, w) = Σ₂₃(i, j, k, grid, v, w)

# Symmetry relations
const Σ₂₁ = Σ₁₂
const Σ₃₁ = Σ₁₃
const Σ₃₂ = Σ₂₃

# Trace and squared strains
@inline tr_Σ²(ijk...) = Σ₁₁(ijk...)^2 +  Σ₂₂(ijk...)^2 +  Σ₃₃(ijk...)^2

@inline Σ₁₂²(i, j, k, grid, u, v, w) = Σ₁₂²(i, j, k, grid, u, v)
@inline Σ₁₃²(i, j, k, grid, u, v, w) = Σ₁₃²(i, j, k, grid, u, w)
@inline Σ₂₃²(i, j, k, grid, u, v, w) = Σ₂₃²(i, j, k, grid, v, w)

#####
##### Same-location velocity products
#####

# ccc
@inline ∂x_u²(ijk...) = ∂x_u(ijk...)^2
@inline ∂y_v²(ijk...) = ∂y_v(ijk...)^2
@inline ∂z_w²(ijk...) = ∂z_w(ijk...)^2

# ffc
@inline ∂x_v²(ijk...) = ∂x_v(ijk...)^2
@inline ∂y_u²(ijk...) = ∂y_u(ijk...)^2

@inline ∂x_v_Σ₁₂(ijk...) = ∂x_v(ijk...) * Σ₁₂(ijk...)
@inline ∂y_u_Σ₁₂(ijk...) = ∂y_u(ijk...) * Σ₁₂(ijk...)

# fcf
@inline ∂z_u²(ijk...) = ∂z_u(ijk...)^2
@inline ∂x_w²(ijk...) = ∂x_w(ijk...)^2

@inline ∂x_w_Σ₁₃(ijk...) = ∂x_w(ijk...) * Σ₁₃(ijk...)
@inline ∂z_u_Σ₁₃(ijk...) = ∂z_u(ijk...) * Σ₁₃(ijk...)

# cff
@inline ∂z_v²(ijk...) = ∂z_v(ijk...)^2
@inline ∂y_w²(ijk...) = ∂y_w(ijk...)^2
@inline ∂z_v_Σ₂₃(ijk...) = ∂z_v(ijk...) * Σ₂₃(ijk...)
@inline ∂y_w_Σ₂₃(ijk...) = ∂y_w(ijk...) * Σ₂₃(ijk...)

#####
##### Tracer gradients
#####

@inline ∂x_c²(ijk...) = ∂x_faa(ijk...)^2
@inline ∂y_c²(ijk...) = ∂y_afa(ijk...)^2
@inline ∂z_c²(ijk...) = ∂z_aaf(ijk...)^2