### A Pluto.jl notebook ###
# v0.12.7

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ de6bdb00-5032-11ec-1ed0-19a7e77553d0
begin
	using StatsPlots, PlutoUI, Distributions, DataFrames, Pkg
	include("ShoupModel.jl")
	nothing
end

# ╔═╡ 61bb1740-6fce-11ec-2994-65231965ac77
md"""
# Complementary notebook for ShoupModel.jl

### This File
The purpose of this notebook is to accompany the ShoupModel.jl file, acting as supportive documentation for using the model. The model is based on the 2006 paper by Donal Shoup, [*Cruising for Parking*](https://www.researchgate.net/publication/222745846_Cruising_for_parking). This notebook is interactive, and I'd urge you to play around with the parameters. Also, any suggestions on further development are more than welcome!
"""

# ╔═╡ ca730b10-6fdf-11ec-1123-6b3d3d75359c
md"""
### The Paper
In the paper, Shoup(2006) presents a model which seeks to capture how the price-ratio between curb-side/off-street parking, fuel cost, and an individual's value of time impacts the incentive for cruising. The paper concludes that when curb-side parking is underpriced, it creates an incentive for individuals to cruise for parking, resulting in congestion and air pollution. Bringing the price of curb-side parking in-line with the off-street parking price can consequently yield a triple-dividend: reducing search times, reduce congestion, and raise revenue to reduce the deadweight loss from other forms taxation.
"""

# ╔═╡ e344a680-6fdf-11ec-3fe7-012d4ac6994a
html"""
<h3>The Model</h3>
<p>
The core model, as presented in the paper, has seven variables:

<ul>
<li>p - price of curb-side parking($/h)</li>
<li>m - price of off-street parking ($/h)</li>
<li>t - parking duration (h)</li>
<li>c - time spent searching for parking at the curb (h)</li>
<li>f - fuel cost of cruising ($/h)</li>
<li>n - number of people in the car (persons)</li>
<li>v - value of time spent cruising ($/h/person)</li>
</ul>
"""

# ╔═╡ 456483b0-6fe2-11ec-35c5-1fcc6cb28f52
html"""
From these variables, we can define three terms:
<table>
  <tr align="left">
    <th>Equation</th>
    <th>Definition</th>
  </tr>
  <tr>
    <td><div class="cmath"> $t(m-p)$ </div></td>
    <td>money saved by parking at the curb</td>
  </tr>
  <tr>
    <td><div class="cmath"> $fc$ </div></td>
    <td>money cost of cruising for curb parking</td>
  </tr>
  <tr>
    <td><div class="cmath"> $nvc$ </div></td>
    <td>monetized cost of time spent cruising for curb parking</td>
  </tr>
  <tr>
    <td><div class="cmath"> $fc + nvc = c(f+nv)$ </div></td>
    <td>money and (monetized) time cost of cruising for curb parking</td>
  </tr>
</table>
"""

# ╔═╡ 57b7a1a0-6fec-11ec-1b4c-b96567d844a4
md"""
First, the price money saved is the amount of time you wish to park multiplied by the hourly price difference between curb-side and off-street parking. This quantity represents the benefit, or the potential consumer surplus if the agent immediately found a space to park on the curb. On the other hand, the agent incurs two costs when searching for parking, the fuel cost, $fc$, and the monetized cost of time, $nvc$. The combined cost of these two would be the total cost incurred by an individual who is cruising.
"""

# ╔═╡ 4332dd00-6fea-11ec-3364-8155bae62815
md"""
The equilibrium cruising time is where the cost of cruising equates the potential benefits, that's to say:

$c^*(f+nv) = t(m-p)$

$c^* = \frac{t(m-p)}{f+nv}$

"""

# ╔═╡ 18934540-6ff8-11ec-1066-6d131c3e2346
md"""
From the above, one can see that cities can impose several strategies to tackle the issue of cruising for parking.

1. If $m=p$, then there will no longer be an incentive to park on the curb. This can either be achieved by increasing the curb-side parking fee, or increase the amount of off-street parking such that $m$ reduces to the same level as $p$.
2. Fuel taxes or emission permits could increase the cost of fuel and consequently increase the cost of cruising. In effect, this would reduce cruising however, unlikely to eliminate it, as it doesn't tackle the root cause of the issue..
3. Similarly to increases in increases in fuel cost, policy to promote carpooling, or secondary vehicle taxes may increase $n$ and reduce cruising times.
"""

# ╔═╡ 53e32e20-6ff9-11ec-07e4-dfc341becda7
md"""
### Julia Implementation

Based on the simple model outlined above, one can outline a basic agent based model, where agents arrive to a curb-side parking location. If curbside parking is available, they will immediately park on the curb given that $p \leq m$. If no location is available, the agent will cruise for a maximum of time of $c^*$. If the agent has not been able to find a location to park within $c^*$ minutes, it will park off-street. When an available parking spot on the curb opens up, all of the agents which are currently cruising for parking are equally likely to occupy the available slot.
"""

# ╔═╡ adc3f310-6ffa-11ec-3fbc-01cb6365974c
md"""
###### Variable list
To enable a degree of heterogeneity between agents, almost all model inputs can be provided as distributions or absolute values. Furthermore, to due to a lack of information on certain variables, such as how frequently people are looking for parking, a few additional variables have been added to the model.
"""

# ╔═╡ 74e2d560-6ffb-11ec-29c4-ad84ddf64ef9
html"""
<table>
  <tr align="left">
    <th>Variable</th>
    <th>Definition</th>
	<th>Type</th>
  </tr>
  <tr>
    <td><em>p</em></td>
    <td>Price of curb-side parking ($/h)</td>
	<td>Union{Real, Distribution}</td>
  </tr>
  <tr>
    <td><em>m</em></td>
    <td>Price of off-street parking ($/h)</td>
	<td>Union{Real, Distribution}</td>
  </tr>
  <tr>
    <td><em>t</em></td>
    <td>Parking duration (h)</td>
	<td>Union{Real, Distribution}</td>
  </tr>
  <tr>
    <td><em>f</em></td>
    <td>Fuel cost when cruising ($/h)</td>
	<td>Union{Real, Distribution}</td>
  </tr>
  <tr>
    <td><em>n</em></td>
    <td>People in the car (persons)</td>
	<td>Union{Real, Distribution}</td>
  </tr>
  <tr>
    <td><em>v</em></td>
    <td>Value of time ($/h/person)</td>
	<td>Union{Real, Distribution}</td>
  </tr>
  <tr>
    <td><em>ar</em></td>
    <td>Arrival rate (arrivals/min)</td>
	<td>Union{Real, Distribution}</td>
  </tr>
  <tr>
    <td><em>cpk</em></td>
    <td>Number of available curb-side spaces</td>
	<td>Int64</td>
  </tr>
  <tr>
    <td><em>mint</em></td>
    <td>Minimum parking duration (h)</td>
	<td>Real</td>
  </tr>
  <tr>
    <td><em>minc</em></td>
    <td>Minimum time spent coasting (h)</td>
	<td>Real</td>
  </tr>
  <tr>
    <td><em>minv</em></td>
    <td>Minimum value of time ($/h/person)</td>
	<td>Real</td>
  </tr>
  <tr>
    <td><em>model_time</em></td>
    <td>Total simulation period (minutes)</td>
	<td>Int64</td>
  </tr>
  <tr>
    <td><em>init_occup</em></td>
    <td>Initial curb-side occupancy rate [0,1]</td>
	<td>Float64</td>
  </tr>
</table>
"""

# ╔═╡ f78ceda0-6ffd-11ec-1f0b-2d67cddbb9e7
md"""
The arrival rate and other limiting variables need to be specified to ensure convergence. Since the model solves minute-by-minute, an arrival rate of more than 1 arrival per minute is not supported. However, if an arrival rate of more than one vehicle per minute is desired, this can be achieved by increasing the **model_time** and adjusting the other input parameters accordingly to reflect the alteration to the time horizons.

All input parameters into the model are also optional parameters, with each value being assigned a default value and classified in to one of 3 parameter groupings.
"""

# ╔═╡ 62a8156e-7075-11ec-265e-09c6b23b2dea
md"""
**_NOTE:_** The default values represent arbitrary but plausible values.
"""

# ╔═╡ 1a484e30-707a-11ec-1e47-f99298189685
md"""
The model groupings serve no computational purpose, but were included as an aid to organise the parameter inputs in-case of an expansion of the model in future.
"""

# ╔═╡ 6e7af840-7075-11ec-1350-b73f65455de5
md"""
###### Model setup

The parameters are specified by the `init_params()` function, where all input parameters are entered as optional variables. The function returns a a tuple conatining each of the parameter groupings.

`(CharParams, PrefParams, ModelParams)`

Each parameter group is another nested tuple containing the relevant variables (see table above). The parameters are then passed to `init_dataframe()` which initialises a dataframe containing the characteristics of each agent, including the arrival time. In cases where a distribution is passed, the characteristics of the agent are independently sampled from the distribution specified. Sample dataframe output below.
"""

# ╔═╡ a83a8e10-707f-11ec-2574-41c9fd4fc95b
init_dataframe(init_params()...)[:,1:9] |>
df -> first(df,5)

# ╔═╡ 62b1e300-7081-11ec-34cc-3d216ea1254e
init_dataframe(init_params()...)[:,10:end] |>
df -> first(df,5)

# ╔═╡ a8bea040-7081-11ec-32a4-e900c194ca28
md"""
Based on the parameters set, the potential savings from parking on the curb, and the hourly cruising costs are calculated. These values are stored in *psav* and *ccost* respectively and are calculated based on *c* ($c^*$ in the paper). The maximum cruising time and desired cruising duration, in minutes, are given by *mct* and *tmin* respectively. Lastly, *arrt* is the iteration which the agent starts looking for parking which is determined based on the arrival rate parameter, *ar*.
"""

# ╔═╡ 2b9f58e0-7084-11ec-06c1-f769e4c39136
html"""
<table>
  <tr align="left">
    <th>Variable</th>
    <th>Definition</th>
  </tr>
  <tr>
    <td><em>curb_par_current</em></td>
    <td>Current number of agents parked on the curb</td>
  </tr>
  <tr>
    <td><em>offs_park_current</em></td>
    <td>Current number of agents parked off-street</td>
  </tr>
  <tr>
    <td><em>cruising_curent</em></td>
    <td>Current number of vehicles cruising</td>
  </tr>
  <tr>
    <td><em>curb_park_total</em></td>
    <td>Total number of vehicles parked on the curb</td>
  </tr>
  <tr>
    <td><em>offs_park_total</em></td>
    <td>Total number of vehicles parked off-street</td>
  </tr>
  <tr>
    <td><em>cruising_total_time</em></td>
    <td>Total time spent cruising (hours)</td>
  </tr>
  <tr>
    <td><em>curb_revenue</em></td>
    <td>Revenue for curb-parking provider ($)</td>
  </tr>
  <tr>
    <td><em>offs_revenue</em></td>
    <td>Revenue for off-street parking provider ($)</td>
  </tr>
</table>
"""

# ╔═╡ c3a26290-7070-11ec-0d31-fd1e738ab6cd
md"""
### Example

In this example, we'll look at how different pricing policies may impact congestion, and air pollution. For the sake of comparability, we'll be using the figures for the 2020 Honda Civic as a representative city car.

"""

# ╔═╡ dc687cc0-70a6-11ec-2859-5b2c6a20bc07
md"""
###### Running a single simulation

First step is to set the characteristics of the desired vehicle, a 2020 Honda Civic in this case.
"""

# ╔═╡ 6a238ec0-70a6-11ec-2004-855e94a8c0f0
begin
	#Setting vehicle emissions, coasting speed, and fuel efficiency (L/hour coasting)
	co2_kgkm = 0.11
	nox_kgkm = 1.49e-4
	coasting_speed_kmh = 8
	fuel_lh = 0.093*coasting_speed_kmh
	nothing
end

# ╔═╡ 39b88bee-70b5-11ec-1af3-29c7d60b3ee1
md"""
Subsequently, the rest of the model parameters can be set. In this case, all the model parameters are called explicitly, however, a parameter does not need to be explicitly set if the default value is desired.
"""

# ╔═╡ 86f22af0-70b2-11ec-27bd-710a12c8c4a7
#Setting model parameters
pparams, cparams, mparams = init_params(p          = 1.0,
									    m          = 13.25,
										t          = Normal(1.5,0.5),
										f          = fuel_lh,
										n          = Binomial(2,0.5),
										v          = Normal(40,5),
										ar         = Bernoulli(0.2),
										cpk        = 8,
										mint       = 0.1,
										minc       = 0.0,
										minv       = 10,
										model_time = 900,
										init_occup = 0.0);
										

# ╔═╡ b56b8730-70b4-11ec-05df-efcd34269c56
md"""
Once the model parameters have been stored in our parameter variables, we can generate the dataframe and run the simulation.
"""

# ╔═╡ a21bdfd0-70b5-11ec-0cad-999dc19d82bd
begin
	#Setting model parameters
	model_df = init_dataframe(pparams, cparams, mparams)

	#Running simulation
	model_results = run_simulation(model_df, pparams, cparams, mparams)
	nothing
end

# ╔═╡ 32eceef0-70b6-11ec-0b34-c95060e14569
md"""
We can not plot the results with respect to time.
"""

# ╔═╡ 5e88dfb2-70b6-11ec-296a-f385f059872e
begin
	#Denoting time in hours instead of minutes
	decimal_minute = 1/60
	endtime_hours = mparams[:model_time]/60				
	time_hours = collect(decimal_minute:decimal_minute:endtime_hours)
	
	#Extracting values from model results
	current_curbside = [x.curb_park_current for x in model_results]
	current_offs = [x.offs_park_current for x in model_results]
	current_cruisers = [x.cruising_current for x in model_results]
	
	#Plotting the results
	plot(lw=2,
		 legend=:topleft,
		 title="Model Output: Current State",
		 xlabel="Hours",
		 ylabel="Vehicles")
	plot!(time_hours, current_curbside, lw=2, label="Parked on Curb", linecolor=:blue)
	plot!(time_hours, current_offs,     lw=2, label="Parked Off-Street",
		  linecolor=:orange)
	plot!(time_hours, current_cruisers, lw=2, label="Cruising", linecolor=:green)
end

# ╔═╡ 56a4d100-70bb-11ec-0601-d7452e0f929f
md"""The above graphs shows the state which agents are in along the time-horizon which the model solves for. The green line shows the number of vehicles which are currently cruising to look for parking. Similarly, the blue and orange lines represent the number of vehicles which are currently parked either on the curb or off-street respectively.""" 

# ╔═╡ f3bcba70-70bb-11ec-2891-6d6debf7dcfe
md"""
###### Running many simulations

Arguably, running a single simulation is not particularlyn useful, as we are pulling from several distributions, it could be that we are just getting a tail-case event. Running a monte-carlo, we can get a better sense of what range of results one may expect from the model output.

We are going to use the same parameter settings as above, however, we will now also specify the number of times we want to run the simulation. 
"""

# ╔═╡ 2f7f17c0-514e-11ec-04cf-978158950869
md"""
**model iterations**:
$(@bind model_iterations Slider(10:5:100, default=50, show_value=true))
"""

# ╔═╡ bd48cc2e-70bc-11ec-3bf9-e1aefe67fe4e
model_results_mc = mc_simulation(pparams, cparams, mparams, n=model_iterations);

# ╔═╡ 30641d00-70bd-11ec-3d18-951f9e15b112
md"""
Plotting the results, we get the following:
"""

# ╔═╡ edb79a62-70bf-11ec-0a29-d9e13a0c4c44
md"""
*curb-side transparency*:
$(@bind curbside_alpha Slider(0:0.05:1, default=0.15, show_value=true))

*off-street transparency*:
$(@bind offstreet_alpha Slider(0:0.05:1, default=0.15, show_value=true))

*cruising transparency*:
$(@bind cruising_alpha Slider(0:0.05:1, default=0.15, show_value=true))
"""

# ╔═╡ 4ea419f0-70bd-11ec-21e5-5dc42d2a4db7
begin
	#-- Setting up variables --#
	#Extracting variables from all simulation runs
	current_curbside_mc = model_results_mc[:,1,:]
	current_offs_mc = model_results_mc[:,2,:]
	current_cruisers_mc = model_results_mc[:,3,:]
	
	#Calculating averages variable at each time step
	current_curbside_mc_avg = mean(current_curbside_mc, dims=2)
	current_offs_mc_avg = mean(current_offs_mc, dims=2)
	current_cruisers_mc_avg = mean(current_cruisers_mc, dims=2)
	
	#-- Plotting --#
	#Initialising plot
	plot(lw=2,
		 legend=:topleft,
		 title="Model Output: Current State",
		 xlabel="Hours",
		 ylabel="Vehicles")
	
	#Plotting all runs
	plot!(time_hours, current_curbside_mc, label="",
		  linecolor=:blue, alpha = curbside_alpha)
	plot!(time_hours, current_offs_mc,     label="",
		  linecolor=:orange, alpha = offstreet_alpha)
	plot!(time_hours, current_cruisers_mc, label="",
		  linecolor=:green, alpha = cruising_alpha)
	
	#Plotting model the means
	plot!(time_hours, current_curbside_mc_avg, lw=2, label="Parked on Curb",
		  linecolor=:blue)
	plot!(time_hours, current_offs_mc_avg,     lw=2, label="Parked Off-Street",
		  linecolor=:orange)
	plot!(time_hours, current_cruisers_mc_avg, lw=2, label="Cruising",
		  linecolor=:green)
end

# ╔═╡ faadd20e-70c0-11ec-3e0d-e96e4593636c
md"""
###### Emissions

Using the vehicle emission data specified earlier ($co2_kgkm kg CO$$_2$$/km and $nox_kgkm kg NO$$_x$$/km) and assuming an average cruising speed of $coasting_speed_kmh km/h, we can easily derive the emissions generated from coasting.
"""

# ╔═╡ 510717c0-70df-11ec-37f6-1b66d47a5beb
md"""
The variance in the emission distribution is determined by variances in cruising time. On the left the CO$_2$ emissions in kg, and on the right are the NO$_x$ emissions in g.
"""

# ╔═╡ 8eaeac40-70e0-11ec-03c1-d11c30659461
md"""
### Conclusion

###### Summary
Although at first, the concept of cruising for parking may seem somewhat benal, however, if perverse incentives are set up, it can have large implications for local pollution and congestion. Increasing the price of curb-side parking to align with the price of off-street parking removes the incentive for cruising all together. Increasing the cost of curb-side parking will also raise revenue for the parking provider (typically government) which consequently contribute to the triple-dividend effect.
"""

# ╔═╡ ddcadbf0-71a3-11ec-031d-4978a5670b4c
html"""
<h6>Limitations</h6>
<p>Lastly, I would like to also discuss two main limitations of the current modelling approach. This is by no means ment to be exhaustive, but hopefully brings to light some more questions.</p>


<p>First and foremost, hourly prices seldom work additively. Someone may pay \$10 for parking for 1 hour, and \$12 for parking for 3 hours. Generally, the price curves would be increasing but diminishingly. For the sake of the simulation, this would mean that in the current set-up, people who want to park for a long time are over-estimating the potential savings.</p>

<p>Secondly, agents are myopic and will cruise until the cost of parking on the curb plus the cost of cruising equals the cost of parking off-street. However, in reality, agents likely make decisions based on their expected cruising time, rather than the amount of time realised. If they have already circled the block and all the parking spots are full, they may decide to park off-street without searching any further. At this point, I would also like to point out that the model doesn't account for cyclical road patters, such as rush hour, which agents may also factor into their expected cruising time.</p>
"""

# ╔═╡ 906e8680-70a5-11ec-25f3-0d821f4f7a7e
md""" ### Appendix"""

# ╔═╡ 1469afe0-6fe4-11ec-1eb5-f19eb0f7eccc
md"""
###### Limitations and improvements

1. Hourly prices seldom work additively over longer parking stays.
2. Agents are currently miopic and do not have a prior expectation of how long it will take to find parking.
3. Street is assumed to be limitless and can host an infinite amount of cruisers
4. Assumes static variables/distributions throughout the modelling period. i.e. doesn't account for rush-hour etc.

"""

# ╔═╡ afe4fab0-7070-11ec-1028-bd689ab685d7
md""" ###### Function for calculating emissions"""

# ╔═╡ 122174e0-70a5-11ec-2b13-ed49d1272b93
function calculate_emissions(results; emission_co2=0.11, emission_nox=1.49e-4, coast_speed_kmh=8)
	#Calculate the total amount of time spend coasting
	hours_coasting = results[end,6,:]/60

	#Calculate emissions
	emissions_co2 = (hours_coasting*coast_speed_kmh)*emission_co2 #Kg of CO2
	emissions_nox = (hours_coasting*coast_speed_kmh)*emission_nox #Kg of NOx

	#Return named tuple with results
	return (co2=emissions_co2, nox=emissions_nox)
end;

# ╔═╡ 2f22fa60-70d1-11ec-149f-0f16c3bb99e0
begin
	#Creating the dataframe (function found in appendix)
	emissions = calculate_emissions(model_results_mc;
									emission_co2=co2_kgkm,
									emission_nox=nox_kgkm) |>
				DataFrame
	
	#Multiplying nox by 1,000 to be easier to compare to CO2 figures
	emissions[:nox]*=1000   #g/km
	emissions[:label] = ""
	nothing
end

# ╔═╡ 2fa9e830-70d2-11ec-15b1-73a3d2c33b71
begin
	#Getting ylimits
	yaxs_min_vals = [minimum(emissions[k]) for k in [:co2,:nox]] |> minimum
	yaxs_max_vals = [maximum(emissions[k]) for k in [:co2,:nox]] |> maximum
	yaxs_vals = [yaxs_min_vals,yaxs_max_vals]
	
	#Initialise plot
	plot(lw=2,
		 legend=:topleft,
		 title="Emissions",
		 ylabel="kg   |   g")
	
	
	#Plotting results
	@df emissions violin!(string.(:label), :co2, side=:left, lw=0,
						  label="CO2 (kg)", show_mean = false, ylim=yaxs_vals,
						  color=Colors.RGBA(0.1, 0, 0.4, 0.9),
						  legend=:topleft)
	
	@df emissions violin!(twinx(), string.(:label), :nox, side=:right, lw=0,
					      label="NOx (g)", show_mean = false, ylim=yaxs_vals,
						  color=Colors.RGBA(0.4, 0, 0.1, 0.9),
						  legend=:topright)
end

# ╔═╡ aee289b2-717f-11ec-0ef9-0d6c141887a3
md""" ###### Distance calculations"""

# ╔═╡ f7a996e0-717d-11ec-0356-c95d25d938c6
begin
	dist_la2nyc =  4469
	average_cruising_time = mean(model_results_mc[:,6,end]) |> 
							round |>
							Int
	km_travelled = mean(model_results_mc[:,6,end])*coasting_speed_kmh |>
				   round |>
				   Int
	mc_distance_cruised = round(km_travelled/dist_la2nyc, digits=2)
	nothing
end

# ╔═╡ d26b70b0-717d-11ec-3c9e-91ea8f02b2ce
md"""
###### Distance cruising

On average, $average_cruising_time hours were spent cruising based on the simulation runs. This equates to the same distance as from Los Angeles to New York $mc_distance_cruised times. Although some liberties are taken by assuming an infinite space for crusing and that agents not updating their expectation.

"""

# ╔═╡ 0b2d1460-5150-11ec-342f-cfd379b234c5
begin
	function create_plot(M, dims; colors=[:red,:blue,:green,:purple,:yellow])
		#Deriving values
		averages=[mean(M[:,i,:], dims=2) for i in dims]
		max_val=maximum([maximum(M[:,i,:]) for i in dims])

		#Plotting
		result_plot=plot(ylims=[0,max_val])
		for (i,dim) in enumerate(dims)
			result_plot=plot!(M[:,dim,:], linecolor=colors[i], alpha=0.1, legend=false)
			result_plot=plot!(averages[i], linecolor=colors[i], alpha=1, legend=false, lw=3)
		end

		#Returning
		return result_plot
	end
	nothing
end

# ╔═╡ 6cc5a3f2-7071-11ec-25e7-19525d559590
begin
	_defaultt_ = init_params()[:PrefParams][:t]
	_defaultn_ = init_params()[:PrefParams][:n]
	_defaultv_ = init_params()[:PrefParams][:v]
	_defaultp_ = init_params()[:CharParams][:p]
	_defaultm_ = init_params()[:CharParams][:m]
	_defaultf_ = init_params()[:CharParams][:f]
	_defaultar_ = init_params()[:CharParams][:ar]
	_defaultcpk_ = init_params()[:CharParams][:cpk]
	_defaultmint_ = init_params()[:CharParams][:mint]
	_defaultminc_ = init_params()[:CharParams][:minc]
	_defaultminv_ = init_params()[:CharParams][:minv]
	_defaultmodeltime_ = init_params()[:ModelParams][:model_time]
	_defaultinitoccup_ = init_params()[:ModelParams][:init_occup]
	
	_smpl_simulation_params_ = init_params(model_time=10)
	_smpl_simulation_df_ = init_dataframe(_smpl_simulation_params_...)
	_smpl_simulation_result_ = run_simulation(_smpl_simulation_df_,
									          _smpl_simulation_params_...)
	simulationdims = _smpl_simulation_result_[1] |>
					 x -> values(x) |>
					 x -> length(x)
	nothing
end

# ╔═╡ 7d84f8f0-706f-11ec-1f77-2f0e8d275688
HTML("""
<table>
  <tr align="left">
    <th>Variable</th>
    <th>Default Value</th>
	<th>Parameter Grouping</th>
  </tr>
  <tr>
    <td><em>p</em></td>
    <td>$_defaultp_</td>
	<td>Characteristic</td>
  </tr>
  <tr>
    <td><em>m</em></td>
    <td>$_defaultm_</td>
	<td>Characteristic</td>
  </tr>
  <tr>
    <td><em>t</em></td>
    <td>$_defaultt_</td>
	<td>Preference</td>
  </tr>
  <tr>
    <td><em>f</em></td>
    <td>$_defaultf_</td>
	<td>Characteristic</td>
  </tr>
  <tr>
    <td><em>n</em></td>
    <td>$_defaultn_</td>
	<td>Preference</td>
  </tr>
  <tr>
    <td><em>v</em></td>
    <td>$_defaultv_</td>
	<td>Preference</td>
  </tr>
  <tr>
    <td><em>ar</em></td>
    <td>$_defaultar_</td>
	<td>Characteristic</td>
  </tr>
  <tr>
    <td><em>cpk</em></td>
    <td>Number of available curb-side spaces</td>
	<td>Characteristic</td>
  </tr>
  <tr>
    <td><em>mint</em></td>
    <td>$_defaultmint_</td>
	<td>Characteristic</td>
  </tr>
  <tr>
    <td><em>minc</em></td>
    <td>$_defaultminc_</td>
	<td>Characteristic</td>
  </tr>
  <tr>
    <td><em>minv</em></td>
    <td>$_defaultminv_</td>
	<td>Characteristic</td>
  </tr>
  <tr>
    <td><em>model_time</em></td>
    <td>$_defaultmodeltime_</td>
	<td>Model</td>
  </tr>
  <tr>
    <td><em>init_occup</em></td>
    <td>$_defaultinitoccup_</td>
	<td>Model</td>
  </tr>
</table>""")

# ╔═╡ 66174330-7083-11ec-3bfa-c5a9f1bbf264
md"""
The dataframe and input parameters are then passed to `run_simulation()`, which runs the model over the specified time horizon. The model returns an array with *model_time* rows, populated with a struct of type `ParkState`, where each parkstate contains $simulationdims variables. The struct includes:
"""

# ╔═╡ ee31fc50-7084-11ec-1cdc-8938be027965
md"""
By using the `as_matrix()` function, the simulation output can be converted into a matrix of dimension [*model_time*, $simulationdims]. When in matrix format, the each column will correspond to one of the variables above, where the order of the columns will correspond with the order of the elements in the struct.
"""

# ╔═╡ b068db70-7096-11ec-0ae0-0d57f4a56a73
md"""
###### Monte-carlo

When model inputs are passed as distributions, it is more insightful to run a monte-carlo to get a sence of the distribution of the outcome variables of interest. To support this, `mc_simulation()` runs the simulation $n_{mc}$ times. For the monte-carlo simulation, the default output is a 3D array of size [*model_time*, $simulationdims, $$n_{mc}$$]. Since the dataframe is generated for each model run, the function does not require a dataframe input, only the parameters and the number iterations.
"""

# ╔═╡ Cell order:
# ╟─61bb1740-6fce-11ec-2994-65231965ac77
# ╟─ca730b10-6fdf-11ec-1123-6b3d3d75359c
# ╟─e344a680-6fdf-11ec-3fe7-012d4ac6994a
# ╟─456483b0-6fe2-11ec-35c5-1fcc6cb28f52
# ╟─57b7a1a0-6fec-11ec-1b4c-b96567d844a4
# ╟─4332dd00-6fea-11ec-3364-8155bae62815
# ╟─18934540-6ff8-11ec-1066-6d131c3e2346
# ╟─53e32e20-6ff9-11ec-07e4-dfc341becda7
# ╟─adc3f310-6ffa-11ec-3fbc-01cb6365974c
# ╟─74e2d560-6ffb-11ec-29c4-ad84ddf64ef9
# ╟─f78ceda0-6ffd-11ec-1f0b-2d67cddbb9e7
# ╟─7d84f8f0-706f-11ec-1f77-2f0e8d275688
# ╟─62a8156e-7075-11ec-265e-09c6b23b2dea
# ╟─1a484e30-707a-11ec-1e47-f99298189685
# ╟─6e7af840-7075-11ec-1350-b73f65455de5
# ╟─a83a8e10-707f-11ec-2574-41c9fd4fc95b
# ╟─62b1e300-7081-11ec-34cc-3d216ea1254e
# ╟─a8bea040-7081-11ec-32a4-e900c194ca28
# ╟─66174330-7083-11ec-3bfa-c5a9f1bbf264
# ╟─2b9f58e0-7084-11ec-06c1-f769e4c39136
# ╟─ee31fc50-7084-11ec-1cdc-8938be027965
# ╟─b068db70-7096-11ec-0ae0-0d57f4a56a73
# ╟─c3a26290-7070-11ec-0d31-fd1e738ab6cd
# ╟─dc687cc0-70a6-11ec-2859-5b2c6a20bc07
# ╠═6a238ec0-70a6-11ec-2004-855e94a8c0f0
# ╟─39b88bee-70b5-11ec-1af3-29c7d60b3ee1
# ╠═86f22af0-70b2-11ec-27bd-710a12c8c4a7
# ╟─b56b8730-70b4-11ec-05df-efcd34269c56
# ╠═a21bdfd0-70b5-11ec-0cad-999dc19d82bd
# ╟─32eceef0-70b6-11ec-0b34-c95060e14569
# ╟─5e88dfb2-70b6-11ec-296a-f385f059872e
# ╟─56a4d100-70bb-11ec-0601-d7452e0f929f
# ╟─f3bcba70-70bb-11ec-2891-6d6debf7dcfe
# ╟─2f7f17c0-514e-11ec-04cf-978158950869
# ╠═bd48cc2e-70bc-11ec-3bf9-e1aefe67fe4e
# ╟─30641d00-70bd-11ec-3d18-951f9e15b112
# ╟─4ea419f0-70bd-11ec-21e5-5dc42d2a4db7
# ╟─edb79a62-70bf-11ec-0a29-d9e13a0c4c44
# ╟─faadd20e-70c0-11ec-3e0d-e96e4593636c
# ╠═2f22fa60-70d1-11ec-149f-0f16c3bb99e0
# ╟─2fa9e830-70d2-11ec-15b1-73a3d2c33b71
# ╟─510717c0-70df-11ec-37f6-1b66d47a5beb
# ╟─d26b70b0-717d-11ec-3c9e-91ea8f02b2ce
# ╟─8eaeac40-70e0-11ec-03c1-d11c30659461
# ╟─ddcadbf0-71a3-11ec-031d-4978a5670b4c
# ╟─906e8680-70a5-11ec-25f3-0d821f4f7a7e
# ╟─1469afe0-6fe4-11ec-1eb5-f19eb0f7eccc
# ╟─afe4fab0-7070-11ec-1028-bd689ab685d7
# ╠═122174e0-70a5-11ec-2b13-ed49d1272b93
# ╟─aee289b2-717f-11ec-0ef9-0d6c141887a3
# ╠═f7a996e0-717d-11ec-0356-c95d25d938c6
# ╟─0b2d1460-5150-11ec-342f-cfd379b234c5
# ╟─6cc5a3f2-7071-11ec-25e7-19525d559590
# ╟─de6bdb00-5032-11ec-1ed0-19a7e77553d0
