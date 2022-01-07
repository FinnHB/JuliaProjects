#================#
#==  PACKAGES  ==#
#================#
using Plots, Distributions

#=======================#
#==  SPECIAL STRUCTS  ==#
#=======================#

Base.@kwdef struct Stills
    block = [0 0 0 0
             0 1 1 0
             0 1 1 0
             0 0 0 0]
    bee_hive = [0 0 0 0 0 0
                0 0 1 1 0 0
                0 1 0 0 1 0
                0 0 1 1 0 0
                0 0 0 0 0 0]
    loaf = [0 0 0 0 0 0
            0 0 1 1 0 0
            0 1 0 0 1 0
            0 0 1 0 1 0
            0 0 0 1 0 0
            0 0 0 0 0 0]
    boat = [0 0 0 0 0
            0 1 1 0 0
            0 1 0 1 0
            0 0 1 0 0
            0 0 0 0 0]
    tub = [0 0 0 0 0
           0 0 1 0 0
           0 1 0 1 0
           0 0 1 0 0
           0 0 0 0 0]
end

Base.@kwdef struct Oscillators
    blinker = [0 0 0 0 0
               0 1 1 1 0
               0 0 0 0 0]
    toad = [0 0 0 0 0 0
            0 0 1 1 1 0
            0 1 1 1 0 0
            0 0 0 0 0 0]
    beacon = [0 0 0 0 0 0
              0 1 1 0 0 0
              0 1 1 0 0 0
              0 0 0 1 1 0
              0 0 0 1 1 0
              0 0 0 0 0 0]
    pulsar = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
              0 0 0 1 1 1 0 0 0 1 1 1 0 0 0
              0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
              0 1 0 0 0 0 1 0 1 0 0 0 0 1 0
              0 1 0 0 0 0 1 0 1 0 0 0 0 1 0
              0 1 0 0 0 0 1 0 1 0 0 0 0 1 0
              0 0 0 1 1 1 0 0 0 1 1 1 0 0 0
              0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
              0 0 0 1 1 1 0 0 0 1 1 1 0 0 0
              0 1 0 0 0 0 1 0 1 0 0 0 0 1 0
              0 1 0 0 0 0 1 0 1 0 0 0 0 1 0
              0 1 0 0 0 0 1 0 1 0 0 0 0 1 0
              0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
              0 0 0 1 1 1 0 0 0 1 1 1 0 0 0]
    tub = [0 0 0 0 0
           0 1 1 1 0
           0 1 0 1 0
           0 1 1 1 0
           0 1 1 1 0
           0 1 1 1 0
           0 1 1 1 0
           0 1 0 1 0
           0 1 1 1 0
           0 0 0 0 0]
end

Base.@kwdef struct Spaceships
    glider = [0 0 0 0 0
              0 0 1 0 0
              0 0 0 1 0
              0 1 1 1 0
              0 0 0 0 0]
    light_weight = [0 0 0 0 0 0 0
                    0 0 1 0 0 1 0
                    0 1 0 0 0 0 0
                    0 1 0 0 0 1 0
                    0 1 1 1 1 0 0]
    middle_weight = [0 0 0 0 0 0 0 0
                     0 0 0 0 1 0 0 0
                     0 0 1 0 0 0 1 0
                     0 1 0 0 0 0 0 0
                     0 1 0 0 0 0 1 0
                     0 1 1 1 1 1 0 0]
    heavy_weight = [0 0 0 0 0 0 0 0 0
                     0 0 0 0 1 1 0 0 0
                     0 0 1 0 0 0 0 1 0
                     0 1 0 0 0 0 0 0 0
                     0 1 0 0 0 0 0 1 0
                     0 1 1 1 1 1 1 0 0]
end


#=================#
#==  FUNCTIONS  ==#
#=================#
#Function for identifying number of neighbours
get_neighbours = function(matrix::Matrix, i::Int)
    #Matrix size
    M = copy(matrix)
    size_M = size(M)

    #Getting nth column and mth row
    m = i%(size_M[1])
    m = ifelse(m == 0, size_M[1], m)
    n = ceil(Int, i/size_M[1])

    #Corner conditions because of non-infinite grid
    m_min = max(1, m-1)
    m_max = min(size_M[1], m+1)
    n_min = max(1, n-1)
    n_max = min(size_M[2], n+1)

    #Value of center square
    centroid = M[m,n]

    #Value of neighbours and centroid
    neighs = M[m_min:m_max, n_min:n_max]

    #Only value of neighbours
    output = sum(neighs)-centroid
    return output
end

#Function for playing the game of life for 1 iteration
play_life = function(matrix::Matrix)
    M = copy(matrix)
    for i in 1:length(M)
        #Boolean if the cell is alive
        alive = Bool(matrix[i])

        #Number of neighbours
        neighs = get_neighbours(matrix, i)

        #Playing the game of life
        if (neighs in [2,3]) & alive
            M[i] = 1                                                      #Rule 1 Live to next generation
        elseif neighs == 3
            M[i] = 1                                                      #Rule 4: Reproduces
        else
            M[i] = 0                                                      #Rule 1/3: Dies from loneliness/overpopulation
        end
    end
    return M
end

#Plot Life
plot_life = function(matrix::Matrix; zoom = 0, title = "")
    M = copy(matrix)

    #Setting new extent
    y_zoom = size(M)[1]*(zoom/100)/2
    y_range = (1 + y_zoom, size(M)[1]-y_zoom)
    x_zoom = size(M)[2]*(zoom/100)/2
    x_range = (1 + x_zoom, size(M)[2]-x_zoom)

    #Plotting
    life_plot = heatmap(M, grid = true, xaxis = false, yaxis = false, colour = :greys, legend = false,
                        title = title, xlims = x_range, ylims = y_range)
    return life_plot
end

#Life's GIF
life_gif = function(matrix::Matrix; n::Int = 100, zoom = 0)
    M = copy(matrix)
    anim = @animate for i in 1:n
        #Plotting the current life
        plot_life(M, zoom = zoom, title = "Game of Life: Year $i")

        #Updating the matrix of life
        M = play_life(M)
    end
    return anim
end

#Pads 0's (false) on to each side of a matrix
pad_matrix = function(matrix::Matrix, n::Int)
    #Copy of input matrix
    M = copy(matrix)

    #Pad horizontally
    h_pad = zeros(Int, size(M)[1], n)
    M = hcat(h_pad, M, h_pad)

    #Pad vertically
    v_pad = zeros(Int, size(M)[2], n)
    M = vcat(v_pad', M, v_pad')

    return M
end

#======================#
#==  INITIALISATION  ==#
#======================#
#Creating an initial matrix with random placement
A = rand(Bool, 80, 80)

#Creating matrix with different density for each quadrant
B₁ = rand(Bernoulli(0.50), 50, 50)
B₂ = rand(Bernoulli(0.90), 50, 50)
B₃ = rand(Bernoulli(0.10), 50, 50)
B₄ = rand(Bernoulli(0.00), 50, 50)
B = hcat(vcat(B₁, B₃), vcat(B₂, B₄))

#Special matrices
C = pad_matrix(Spaceships().glider, 8)
C = repeat(Spaceships().glider, 4, 4)


#============#
#==  GAME  ==#
#============#
#Simulating the game of life
out_gif = life_gif(B, zoom = 20, n = 100)

#Creating a gif
gif(out_gif, "anim_fps15.gif", fps = 6)
