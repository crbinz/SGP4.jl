# Julia wrapper for the sgp4 Python library:
# https://pypi.python.org/pypi/sgp4/

VERSION >= v"0.4.0-dev+6521" && __precompile__()

module SGP4

using PyCall

import Base.getindex

const sgp4io = PyNULL()
const earth_gravity = PyNULL()

function __init__()
    copy!(sgp4io, pyimport_conda("sgp4.io", "sgp4", "conda-forge"))
    copy!(earth_gravity, pyimport("sgp4.earth_gravity"))
end

export GravityModel,
       twoline2rv,
       propagate

immutable GravityModel
    model::PyObject # can be any of {wgs72old, wgs72, wgs84}
end

type SGP4Sat
    s::PyObject
end
getindex(sat::SGP4Sat, sym::Symbol) = sat.s[sym]

GravityModel(ref::AbstractString) = GravityModel(earth_gravity[ref])

# sgp4.io convenience functions
function twoline2rv(line1::ASCIIString, line2::ASCIIString, grav::GravityModel)
    return SGP4Sat(sgp4io["twoline2rv"](line1,line2,grav.model))
end

"""
Propagate the satellite from its epoch to the date/time specified

Returns (position, velocity) at the specified time
"""
function propagate( sat::SGP4Sat,
                    year::Real,
                    month::Real,
                    day::Real,
                    hour::Real,
                    min::Real,
                    sec::Real )
    (pos, vel) = sat.s[:propagate](year,month,day,hour,min,sec)

    # check for errors
    if sat.s[:error] != 0
        println(sat.s[:error_message])
    end

    return ([pos...],[vel...])
end

function propagate( sat::SGP4Sat,
                    t::DateTime )
    propagate(sat,
              Dates.year(t),
              Dates.month(t),
              Dates.day(t),
              Dates.hour(t),
              Dates.minute(t),
              Dates.second(t))
end

function propagate(sat::SGP4Sat,
                   t::AbstractVector{DateTime})
    pos = zeros(3, length(t)) 
    vel = zeros(3, length(t)) 

    for (idx, ti) in enumerate(t)
        pos[:,i],vel[:,i] = propagate(sat, ti)
    end
    return (pos,vel)
end

"Generate a satellite ephemeris"
function propagate( sat::SGP4Sat,
                    tstart::DateTime,
                    tstop::DateTime,
                    tstep::Dates.TimePeriod )

    propagate(sat, tstart:step,tstop)
end

"tstep specified in seconds"
function propagate( sat::SGP4Sat,
                    tstart::DateTime,
                    tstop::DateTime,
                    tstep::Real )
    propagate(sat,tstart,tstop,Dates.Second(tstep))
end

"Propagate many satellites to a common time"
function propagate( sats::Vector{SGP4Sat},
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

function propagate( sats::Vector{SGP4Sat},
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
