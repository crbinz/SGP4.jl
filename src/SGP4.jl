# Julia wrapper for the sgp4 Python library:
# https://pypi.python.org/pypi/sgp4/

# Requres a slightly modified version of the library

module SGP4

using PyCall

export GravityModel,
       twoline2rv,
       propagate

# initialization
@pyimport sgp4.io as sgp4io
@pyimport sgp4.earth_gravity as earth_gravity

immutable GravityModel
    model::PyObject # can be any of {wgs72old, wgs72, wgs84}
end
GravityModel(ref::String) = earth_gravity.pymember(ref)

# sgp4.io convenience functions
twoline2rv(args...) = sgp4io.twoline2rv(args...)

function propagate( sat::PyObject,
                    year::Real,
                    month::Real,
                    day::Real,
                    hour::Real,
                    min::Real,
                    sec::Real )
    # propagate the satellite from its epoch to the date/time
    # specified
    # returns (position, velocity) at the specified time
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
              year(t),
              month(t),
              day(t),
              hour(t),
              minute(t),
              second(t))
end

function propagate( sats::Vector{PyObject},
                    year::Real,
                    month::Real,
                    day::Real,
                    hour::Real,
                    min::Real,
                    sec::Real )
    # propagate many satellites to a common time
    pos = zeros(3,length(sats))
    vel = zeros(3,length(sats))
    for i = 1:length(sats)
        (pos[:,i],vel[:,i]) = propagate(sats[i],year,month,day,hour,min,sec)
    end
    return (pos,vel)
end


end #module
