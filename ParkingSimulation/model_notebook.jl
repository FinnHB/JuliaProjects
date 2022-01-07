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
	using Plots, PlutoUI, Statistics
	include("ShoupModel.jl")
end

# ╔═╡ 61bb1740-6fce-11ec-2994-65231965ac77
md"""
# Complementary notebook for ShoupModel.jl

### This File
The purpose of this notebook is to accompany the ShoupModel.jl file, acting as supportive documentation for using the model. The model is based on the 2006 paper by Donal Shoup [*Cruising for Parking*](https://www.researchgate.net/publication/222745846_Cruising_for_parking)
"""

# ╔═╡ ca730b10-6fdf-11ec-1123-6b3d3d75359c
md"""
### The Paper
In the paper, Shoup(2006) presents a model which seeks to capture how the price-ratio between curb-side/off-street parking, fuel cost, and an individual's value of time impacts the incentive for cruising. The paper concludes that when curb-side parking is underpriced, it creates an incentive for individuals to cruise for parking, resulting in congestion, air pollution. Bringing the price of curb-side parking in-line with the off-street parking price can consequently yield a triple-dividend: reducing search times, reduce congestion, and raise revenue to reduce the deadweight loss of other forms of taxation.
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
From these variables, a set of four relationships are established:
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

Based on the simple model outlined above, one can outline a basic agent based model, where agents arrive to a curb-side parking location. If curbside parking is available, they will immediately park on the curb given that $p \leq m$. If no location is available, the agent will cruise for a maximum of time of $c^*$. If the agent has not been able to find a location to park within $c^*$ minutes, it will park off-street. When an available parking spot on the curb opens up, all of the agents which are currently cruising for parking, are equally likely to occupy the available slot.
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


# ╔═╡ 2f7f17c0-514e-11ec-04cf-978158950869
md"""
**Model Iterations**:
$(@bind n Slider(10:500, default=50, show_value=true))

**Curbside Price:**
$(@bind p Slider(0:0.1:10, default=0, show_value=true))

**Off-Street Price:**
$(@bind m TextField(default="1.0"))
"""

# ╔═╡ 1469afe0-6fe4-11ec-1eb5-f19eb0f7eccc
md"""
Limitations and improvements

1. Hourly prices seldom work additively over longer parking stays.
2. Agents are currently miopic, they do not make a prior prediction regarding the expected cruising time before arrival.
3. Street is assumed to be limitless
4. Assumes static variables/distributions throughout the modelling period.

"""

# ╔═╡ 0b2d1460-5150-11ec-342f-cfd379b234c5
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

# ╔═╡ 405f3b20-5210-11ec-3b08-17762da9ca35
create_plot(mc_simulation(init_params(p=p, m=m)...,n=n), [6,7])

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
# ╠═f78ceda0-6ffd-11ec-1f0b-2d67cddbb9e7
# ╠═2f7f17c0-514e-11ec-04cf-978158950869
# ╠═1469afe0-6fe4-11ec-1eb5-f19eb0f7eccc
# ╟─405f3b20-5210-11ec-3b08-17762da9ca35
# ╟─0b2d1460-5150-11ec-342f-cfd379b234c5
# ╠═de6bdb00-5032-11ec-1ed0-19a7e77553d0
