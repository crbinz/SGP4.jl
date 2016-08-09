# Julia wrapper for the sgp4 Python library:
# https://pypi.python.org/pypi/sgp4/

VERSION >= v"0.4.0-dev+6521" && __precompile__()

module SGP4

import Compat.ASCIIString

using PyCall

function __init__()
    try 
        global const sgp4io = PyCall.pywrap(pyimport("sgp4.io"))
        global const earth_gravity = PyCall.pywrap(pyimport("sgp4.earth_gravity"))
    catch e
        error("Error loading sgp4 python package - check to make sure it's installed")
    end
end

export GravityModel,
       twoline2rv,
       propagate

immutable GravityModel
    model::PyObject # can be any of {wgs72old, wgs72, wgs84}
end
GravityModel(ref::AbstractString) = earth_gravity.pymember(ref)

# sgp4.io convenience functions
twoline2rv(args...) = sgp4io.twoline2rv(args...)

"""
Propagate the satellite from its epoch to the date/time specified

Returns (position, velocity) at the specified time
"""
function propagate( sat::PyObject,
                    year::Real,
                    month::Real,
                    day::Real,
                    hour::Real,
                    min::Real,
                    sec::Real )
    (pos, vel) = sat[:propagate](year,month,day,hour,min,sec)

    # check for errors
    if sat[:error] != 0
        println(sat[:error_message])
    end

    return ([pos...],[vel...])
end

function propagate( sat::PyObject,
                    t::DateTime )
    propagate(sat,
              Dates.year(t),
              Dates.month(t),
              Dates.day(t),
              Dates.hour(t),
              Dates.minute(t),
              Dates.second(t))
end

"Propagate many satellites to a common time"
function propagate( sats::Vector{PyObject},
                    year::Real,
                    month::Real,
                    day::Real,
                    hour::Real,
                    min::Real,
                    sec::Real )
    pos = zeros(3,length(sats))
    vel = zeros(3,length(sats))
    for i = 1:length(sats)
        (pos[:,i],vel[:,i]) = propagate(sats[i],year,month,day,hour,min,sec)
    end
    return (pos,vel)
end

function propagate( sats::Vector{PyObject},
                    t::DateTime )
    propagate(sats,
              Dates.year(t),
              Dates.month(t),
              Dates.day(t),
              Dates.hour(t),
              Dates.minute(t),
              Dates.second(t))
end

end #module
