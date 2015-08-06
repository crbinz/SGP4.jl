# SGP4.jl
For now, a simple wrapper of [python-sgp4](https://github.com/brandon-rhodes/python-sgp4) using [PyCall.jl](https://github.com/stevengj/PyCall.jl). There are several small changes from `python-sgp4`:

1. Gravity coefficients are loaded into a `GravityModel` type. For instance, to load the WGS-72 coefficients, just do `GravityModel("wgs72")`. The other two options are "wgs72old" and "wgs84".

2. Propagation is a standalone function, as opposed to a `satellite` member function. So, propagation is accomplished by `propagate( sat, year, month, day, hour, min, sec)`.

## Installation
You will need the [SGP4](https://pypi.python.org/pypi/sgp4/) Python package installed on your system: `pip install sgp4`. I tested this using SGP4 v1.4.

## Usage
Following the example given [here](https://pypi.python.org/pypi/sgp4/), the TEME position and velocity for Vanguard 1 at 12:50:19 on 29 June 2000 may be calculated by:

```
using SGP4
line1 = "1 00005U 58002B   00179.78495062  .00000023  00000-0  28098-4 0  4753"
line2 = "2 00005  34.2682 348.7242 1859667 331.7664  19.3264 10.82419157413667"
wgs72 = GravityModel("wgs72")
satellite = twoline2rv(line1, line2, wgs72)
(position, velocity) = propagate( satellite, 2000, 6, 29, 12, 50, 19)
```

`satellite` attributes, such as the TLE epoch, may be accessed as `satellite[:epoch]`.

For other documentation, see [this page](https://pypi.python.org/pypi/sgp4/).
