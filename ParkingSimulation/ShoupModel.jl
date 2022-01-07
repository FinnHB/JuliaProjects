using Distributions, DataFrames, ProgressMeter

#### COMMENTS
# Currently, there is an issue when both p and m are equal. No parking
# gets allocated to off-street parking.

####

#-- Misc. Functions --#
"""Returns n random draws from distribution x"""
function sample_vals(x::Distribution,n)
    return rand.(x,n)
end

"""Returns a vector of n repetitions of x"""
function sample_vals(x::Real,n)
    return repeat([x],n)
end

"""
    arr  -- Input array
    func -- Function to apply to elements which are not Nothing
Updates a mixed array of Union{Nothing,Real}.
"""
function update_array!(arr::Array, func::Function)
    arr[arr .!= nothing] = [func(x) for x in arr if x isa Real]
end

"""
    arr  -- Input array
    func -- Function to apply to elements which are not Nothing
Gets values after a function has been applied to all Real numbers of an array
of type Union{Nothing,Real}.
"""
function get_val(arr::Array, func::Function)
    return [func(x) for x in arr if !isnothing(x)]
end

"""
    parking_df     -- Dataframe containing input data
    i              -- Row index of the dataframe
    price_col      -- Character or Symbol containing th name of the price column
    duration_col   -- The column containing the parking duration in minutes (default = :tmin)
    price_interval -- Interval at which parking is charged (default = 60)

Takes in a parking dataframe and calculates the price paid.
"""
function calc_revenue(parking_df, i, price_col; duration_col=:tmin, price_interval=60)
    rid = ifelse(i isa Array, i, [i])
    x = copy(parking_df[rid,:])
    revenue = [ceil(x[i,duration_col]/price_interval)*x[i,price_col] for i in range(1,stop=nrow(x))]
    return sum(revenue)
end


#-- Cost Calculations --#
"""
    t -- Parking duration (hours)
    m -- Price of off-street parking (dollars per hour)
    p -- Price of parking on the curb (dollars per hour)

Computes the savings from parking on the curb versus parking off-street. Returns
monetary value in \$.
"""
curb_saving(t,m,p)= t*(m-p)


"""
    n      -- Number of people in the car (Int)
    v      -- Value of time for a person (dollars per hour)
    f      -- Fuel cost of cruising (dollars per hour)
    c      -- Time spent searching for parking at the curb (hours)
    n_pref -- Policy for whose time preferences are accounted for.
                Egalitarian (default): Everyone's time cost is accounted for
                Dictator: One person's time cost is accounted for
                Diarchy: Up to two people's time cost is accounted for

Returns the cost of cruising for some given cruising time c and cost parameters
n,v, and f.
"""
function cruising_cost(n,v,f,c;n_pref="egalitarian")
    if lowercase(n_pref) == "egalitarian"
        return c*(f+n*v)
    elseif lowercase(n_pref) == "dictator"
        return c*(f+v)
    elseif lowercase(n_pref) == "diarchy"
        return c*(f+min(n,2)*v)
    end
end

"""
savings   -- Potential saving from parking on the curb (dollars)
cost      -- Cruising cost per hour (dollars per hour)

Returns the maximum time someone is willing to cruise for given the potential
savings from parking on the curb and the cruising cost per hour
"""
function max_cruise_time(savings, cost)
    return round(60*(savings/cost))
end




#-- Initialisation Functions --#
ParamType = Union{Real, Distribution}
"""
    p          -- Price of parking on the curb (dollars per hour)
    m          -- Price of off-street parking (dollars per hour)
    t          -- Parking duration (hours)
    c          -- Time spent searching for parking at the curb (hours)
    f          -- Fuel cost when cruising (dollars per hour)
    n          -- Number of people in a car (people)
    v          -- Value of time (dollars per hour per person)
    ar         -- Rate of new arrivals (arrivals per minute)
    cpk        -- Number of available curbside parking spaces (Int64)
    mint       -- Minimum parking duration (hours)
    minc       -- Minimum time spent coasting (hours)
    minv       -- Minimum value of time (dollars per hour per person)
    model_time -- Total simulation period (minutes)
    init_occup -- Initial on-street occupancy rate (0.0 to 1.0)

Initialises parameter structs which contain assumptions and distributions for the model
estimation. Returns a named tuple with the 'Preference Parameters', 'Characteristic Parameters',
and 'Model Parameters'. Note: ParamType = Union{Real, Distribution}.

    Preference Parameters     : t,c,n,v
    Characteristic Parameters : p,m,f,ar,cpk,mint,minc,minv
    Model Parameters          : model_time, init_occup
"""
function init_params(;p::ParamType         = 1.0,
                      m::ParamType         = 8.0,
                      t::ParamType         = Normal(1,0.5),
                      c::ParamType         = Normal(0.5,0.08),
                      f::ParamType         = 1.0,
                      n::ParamType         = Binomial(3,0.8),
                      v::ParamType         = Normal(40,5),
                      ar::ParamType        = Bernoulli(0.2),
                      cpk::Int64           = 8,
                      mint::Real           = 0.1 ,
                      minc::Real           = 0.0,
                      minv::Real           = 0.,
                      model_time::Int64    = 720,
                      init_occup::Float64  = 0.0)

    #Checks
    (p isa Distribution || (p isa Number && p >= 0)) || error("Price of parking on the curb (p) must be nonnegative")
    (m isa Distribution || (m isa Number && m >= 0)) || error("Price of parking off-street (m) must be nonnegative")
    (t isa Distribution || (t isa Number && t >= 0)) || error("Parking duration (t) must be nonnegative")
    (c isa Distribution || (c isa Number && c >= 0)) || error("Time spent searching for curb-side parking (c) must be nonnegative")
    (n isa Distribution || (n isa Number && n >= 1)) || error("Number of people in a vehicle (n) must be greater than or equal to 1")
    (ar isa Distribution || (ar isa Number && ar >= 0)) || error("The rate of new arrivials (ar) must be nonnegative")
    (cpk isa Distribution || (cpk isa Number && cpk >= 0)) || error("The rate of new arrivials (ar) must be nonnegative")
    (mint isa Distribution || (mint isa Number && mint > 0)) || error("Minimum parking duration (mint) must be greater than 0")
    (minc isa Distribution || (minc isa Number && minc >= 0)) || error("Minimum time spent coasting (minc) must be nonnegative")
    (model_time > 0) || error("model_time must be greater than 0")
    (init_occup >= 0 && init_occup <= 1) || error("init_occup must be between 0 and 1")

    #Create parameter structs
    pparams = (t=t,c=c,n=n,v=v)
    cparams = (p=p,m=m,f=f,ar=ar,cpk=cpk,mint=mint,minc=minc,minv=minv)
    mparams = (model_time=model_time, init_occup=init_occup)

    #Return parameter structs as named tuples
    return (PrefParams=pparams, CharParams=cparams, ModelParams=mparams)
end



"""
Returns a dataframe of input parameters. The function also calculates additional parameters
which are added to the dataframe. These variables include include:

    psav  -- Potential savings from parking on the curb (dollars)
    ccost -- Cost of cruising for one hour (dollars per hour)
    mct   -- Maximum time a person is willing to cruise for before they park off-street (minutes)
    arrt  -- Arrival time indexed by minutes (start=0)
    tmin  -- Parking duration in minutes (minutes)
"""
function init_dataframe(pparams::NamedTuple, cparams::NamedTuple, mparams::NamedTuple)
    #Get an array of when people arrive to park
    arrivals = sample_vals(cparams.ar, mparams.model_time)
    num_arrivals = sum(arrivals)

    #Identify parameters to be stored in dataframe
    df_params = vcat(pparams..., cparams...)
    df_names = map(string, vcat(keys(pparams)..., keys(cparams)...))

    #Create dataframe of outputs & apply maximum & minimum conditions
    df = DataFrame(sample_vals.(df_params, num_arrivals)) |>
         df -> float.(df) |>
         df -> rename(df, df_names)

    #Truncate values at the minimum values
    df.t = [maximum(x) for x in eachrow(df[:,[:t,:mint]])]
    df.c = [maximum(x) for x in eachrow(df[:,[:t,:minc]])]
    df.v = [maximum(x) for x in eachrow(df[:,[:t,:minv]])]

    #Calculate costs, cruising time, and arrival
    df.psav = curb_saving.(df.t, df.m, df.p)
    df.ccost = cruising_cost.(df.n, df.v, df.f, df.c)
    df.mct = max_cruise_time.(df.psav, df.ccost)
    df.arrt = findall(x->x==1, arrivals)
    df.tmin = df[:,:t]*60

    #Returns filled dataframe
    return df
end

"""Mutable struct for storing results from parking simulation"""
mutable struct ParkState
    curb_park_current::Int64
    offs_park_current::Int64
    cruising_current::Int64
    curb_park_total::Int64
    offs_park_total::Int64
    cruising_total_time::Float64
    curb_revenue::Float64
    offs_revenue::Float64
end

"""Gets value from a single ParkState"""
function Base.values(x::ParkState)
    return Array([x.curb_park_current,
                  x.offs_park_current,
                  x.cruising_current,
                  x.curb_park_total,
                  x.offs_park_total,
                  x.cruising_total_time,
                  x.curb_revenue,
                  x.offs_revenue])
end

"""Returns a matrix of results of the ParkState, in an n × 8 matrix
 As input, takes an array of ParkStates (simulation output)"""
function as_matrix(x::Array)
    nested_arrays = values.(x)
    long_matrix = hcat(nested_arrays...)'
    return long_matrix
end



"""Base copy version of ParkState"""
Base.copy(x::ParkState) = ParkState(x.curb_park_current,
                                    x.offs_park_current,
                                    x.cruising_current,
                                    x.curb_park_total,
                                    x.offs_park_total,
                                    x.cruising_total_time,
                                    x.curb_revenue,
                                    x.offs_revenue)


"""Initialises statistics on cruiser_parked vehicles. Returns a struct of ParkState"""
function init_parking(pparams, cparams, mparams)
    #Occupy a proportion of curbside parking
    occupied_spaces = round(mparams.init_occup * cparams.cpk)
    return ParkState(occupied_spaces,0,0,0,0,0,0,0)
end

"""
The function runs the number of iterations of the parking simulation which is
specified by mparams.model_time. The outputs of the model are returned as a
vector of ParkState mutable structs with the same length as the number of
iterations. The elements of the struct are:

    curb_park_current     --  Current number of cars parked at the curb
    offs_park_current     --  Current number of cars parked off-street
    cruising_current      --  Current number of cars cruising for parking
    curb_park_total       --  Total number of cars which have parked on the curb since the start of modelling
    offs_park_total       --  Total number of cars which have parked off-street since the start of modelling
    cruising_total_time   --  Total amount of time spent cruising by vehicles (hours)
    curb_revenue          --  Total revenue of owner of curb parking
    offs_revenue          --  Total revenue of owner of off-street parking
"""
function run_simulation(df, pparams, cparams, mparams)
    #Creating an ID for each car to keep tract of dataframe columns
    mrange = 1:mparams.model_time
    cid = 1

    #Initialise temporary containers
    state = init_parking(pparams, cparams, mparams)
    states = [deepcopy(state) for i in mrange]
    parking_curb = Union{Nothing,Float64,Int64}[nothing for i in mrange]
    parking_offs = Union{Nothing,Float64,Int64}[nothing for i in mrange]
    cruising = Union{Nothing,Float64,Int64}[nothing for i in mrange]

    #Iterate through every minute
    for i in mrange
        #- Starting -#
        #Identify if a car will arrive this iteration
        arrival = df[cid,:arrt]==i

        #- Move existing drivers -#
        #Update stored values
        update_array!(parking_curb, x -> x-1)
        update_array!(parking_offs, x -> x-1)
        update_array!(cruising, x -> x-1)

        #Leave parking
        state.curb_park_current -= state.curb_park_current > 0 && Int(sum(get_val(parking_curb, x -> x<=0)))
        state.offs_park_current -= state.offs_park_current > 0 && Int(sum(get_val(parking_offs, x -> x<=0)))

        #-- Allow cruisers to park if available --#
        #Check parking availability
        available_parking = state.curb_park_current < df[cid,:cpk]
        cruisers = get_val(cruising, x -> x>=0)
        cruiser_parked = false
        if available_parking & any(cruisers)
            #Uniform distribution for cruiser or new arrival parking in the available space.
            park_probability = sum(cruisers)/(sum(cruisers)+arrival)
            cruiser_parked = rand(Bernoulli(park_probability))
            if cruiser_parked
                time_id = rand(findall(x->x isa Real, cruising))
                cruiser_id = findall(x->x == time_id, df.arrt)[1]

                #Add to parked stock
                parking_curb[i] = df[cruiser_id,:tmin]
                state.curb_revenue += calc_revenue(df, cruiser_id, :p)
                state.curb_park_current += cruiser_parked
                state.curb_park_total += cruiser_parked
            end
        end

        #- Allocate newly arrived drivers -#
        if arrival
            #Park if available (clause added to not have multiple slots occupied in one time period)
            park_curb = (df[cid,:p] <= df[cid,:m]) & (cruiser_parked == false) && available_parking
            parking_curb[i] = ifelse(park_curb, df[cid,:tmin], parking_curb[i])

            state.curb_revenue += ifelse(park_curb, calc_revenue(df, cid, :p), 0)
            state.curb_park_current += Int(park_curb)
            state.curb_park_total += Int(park_curb)

            #Park off-street if cheaper
            park_offs = df[cid,:m] < df[cid,:p]
            parking_offs[i] = ifelse(park_offs, df[cid,:tmin], nothing)
            state.offs_revenue += ifelse(park_offs, calc_revenue(df, cid, :m), 0)
            state.offs_park_current += Int(park_offs)
            state.offs_park_total += Int(park_offs)

            #Cruise if no parking is available
            cruise = !park_curb && !park_offs && df[cid,:mct] >= 0
            cruising[i] = ifelse(cruise, df[cid,:mct], nothing)
            state.cruising_current += Int(cruise)

            #Add one to the car ID
            cid = min(cid+1, size(df)[1])
        end

        #- Allocate cruisers -#
        #Move people who are tired of cruising to off-street parking.
        tired_cruisers = get_val(cruising, x -> x<=0)
        if any(tired_cruisers)
            #Identify correct row of the dataframe
            time_id = findall(x->x isa Real, cruising)
            time_id = time_id[findall(x->x <= 5, cruising[time_id])]
            cruiser_id = findall(x->x in time_id, df.arrt)

            #Cars park off-street (if 2 cars, add the time together)
            parking_offs[i] = sum(df[cruiser_id,:tmin])
            state.offs_revenue += ifelse(!isnothing(parking_offs[i]), calc_revenue(df, cruiser_id, :m), 0)
            state.offs_park_current += sum(tired_cruisers)
            state.offs_park_total += sum(tired_cruisers)
            state.cruising_current -= sum(tired_cruisers)
        end

        #- Update values -#
        #Parking situation
        update_array!(parking_curb, x -> ifelse(x>0,x,nothing))
        update_array!(parking_offs, x -> ifelse(x>0,x,nothing))
        update_array!(cruising, x -> ifelse(x>0,x,nothing))

        #Update total cruising time & store state
        state.cruising_total_time += state.cruising_current/60
        states[i] = copy(state)
    end
    return states
end


"""Monte-Carlo version of the parking simulation, returning a 3D array of output values.

    D1 : Number of time-steps for the model run as set in the model parameters
    D2 : Dimensions of ParkingState struct (8)
    D3 : Number of iterations

    The D2 elements are:
        curb_park_current     --  Current number of cars parked at the curb
        offs_park_current     --  Current number of cars parked off-street
        cruising_current      --  Current number of cars cruising for parking
        curb_park_total       --  Total number of cars which have parked on the curb since the start of modelling
        offs_park_total       --  Total number of cars which have parked off-street since the start of modelling
        cruising_total_time   --  Total amount of time spent cruising by vehicles (hours)
        curb_revenue          --  Total revenue of owner of curb parking
        offs_revenue          --  Total revenue of owner of off-street parking
"""
function mc_simulation(pparams, cparams, mparams; n=100)
    #Initialise container to store results
    container = zeros(mparams.model_time, 8, n)

    #Run simulation
    @showprogress for i in range(1, stop=n)
        df = init_dataframe(pparams, cparams, mparams)
        sim = run_simulation(df, pparams, cparams, mparams)
        container[:,:,i] = as_matrix(sim)
    end

    #Returning matrix of results
    return container
end
