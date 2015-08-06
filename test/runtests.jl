import SGP4
using Base.Test 

line1 = "1 00005U 58002B   00179.78495062  .00000023  00000-0  28098-4 0  4753"
line2 = "2 00005  34.2682 348.7242 1859667 331.7664  19.3264 10.82419157413667"

wgs72 = SGP4.GravityModel("wgs72")
satellite = SGP4.twoline2rv(line1, line2, wgs72)

@test satellite[:satnum] == 5

(position, velocity) = SGP4.propagate( satellite, 2000, 6, 29, 12, 50, 19)

@test satellite[:error] == 0

@test_approx_eq_eps position[1] 5576.056952 1e-6
@test_approx_eq_eps position[2] -3999.371134 1e-6
@test_approx_eq_eps position[3] -1521.957159 1e-6

@test_approx_eq_eps velocity[1] 4.772627 1e-6
@test_approx_eq_eps velocity[2] 5.119817 1e-6
@test_approx_eq_eps velocity[3] 4.275553 1e-6
