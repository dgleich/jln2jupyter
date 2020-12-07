#!julia
using JSON

function make_code_cell(code)
  cell = Dict{String,Any}()
  cell["cell_type"] = "code"
  cell["execution_count"] = nothing
  if typeof(code) <: AbstractString
    cell["source"] = [code]
  else
    cell["source"] = code
  end
  cell["metadata"] = Dict("collapsed" => false, "autoscroll" => false)
  cell["outputs"] = []
  return cell
end

function ipynb_structure()
  ipynb = Dict{String,Any}()
  kernelspec = Dict{String,String}("language" => "julia",
                                   "name" => "julia-$(VERSION.major).$(VERSION.minor)", "display_name" => "Julia v$(VERSION.major).$(VERSION.minor)")
  ipynb["metadata"] = Dict{String,Any}("kernelspec" => kernelspec)
  ipynb["nbformat"] = 4
  ipynb["nbformat_minor"] = 0
  ipynb["cells"] = Vector{Dict{String,Any}}()
  return ipynb
end

function test_output(output)
  ipynb = ipynb_structure()
  push!(ipynb["cells"], make_code_cell("1+1"))
  write(output, JSON.json(ipynb))
end

function jl2cells(filename)
  if VERSION < v"0.6"
    lines = collect(readlines(filename))
elseif VERSION < v"0.7"
    lines = collect(readlines(filename, chomp=false))
else  # keep keyword
    lines = collect(readlines(filename, keep=true))
  end
  cells = Vector{Vector{String}}()
  block = Vector{String}()
  just_started = false
  for line in lines
    if startswith(line, "##")
      if just_started
        # add to the current block
        push!(block, line)#join([line,"\n"])
      else
        # start a new block
        if length(block) > 0
          push!(cells, block)
        end
        just_started = true
        block = Vector{String}()
        push!(block, line)
      end
    else
      just_started = false
      # add to the current block
      push!(block, line)
    end
  end
  if length(block) > 0
    push!(cells, block)
  end
  return cells
end


function jl2ipynb(filename, output)
  ipynb = ipynb_structure()
  cells = jl2cells(filename)
  for cell in cells
    push!(ipynb["cells"], make_code_cell(cell))
  end
  nbytes = write(output, JSON.json(ipynb))
  return length(cells), nbytes
end

# When running this file as a script, try to do so with default values.  If arguments are passed
# in, use them as the arguments to build_sysimg above.
if !isinteractive()
    if length(ARGS) == 0 || length(ARGS) > 3 || ("--help" in ARGS || "-h" in ARGS)
        println()
        println("Usage: jln2jupyter.jl <julia> [<outputipynb>] [--verbose]")
        println("   <julia>        is the file name of the julia (*.jl or *.jln extension)")
        println("                  to be transformed into an Jupyter notebook")
        println("   <outputipynb>  is the optional filename of the Jupyter noteboook")
        println("                  it defaults to the julia file name with the .ipynb extension")
        println("   --help         Print out this help text and exit")
        println("   --verbose      Print out additional output")
        println()
        println(" Example:")
        println("   julia jln2jupyter.jl template.jl")
        println("   julia jln2jupyter.jl template.jl template_transformed.ipynb")
        println()
        println(" This will generate the ipython notebook template_transformed.ipynb")
        println("   that embeds the the file template.jl")
        return 0
    end

    verbose_flag = "--verbose" in ARGS
    filter!(x -> x != "--verbose", ARGS)

    jlfile = ARGS[1]
    if length(ARGS) < 2
      jlbase = splitext(jlfile)[1]
      ipynbfile = jlbase * ".ipynb"
    else
      ipynbfile = ARGS[2]
    end
    if verbose_flag
      println("Converting $jlfile to $ipynbfile")
    end

    ncells, nbytes = jl2ipynb(jlfile,ipynbfile)
    if verbose_flag
      println("Converted $ncells cells from $jlfile")
      println("Wrote $nbytes to $ipynbfile")
    end

    if nbytes == 0 # no output written
      exit(-1)
    else
      exit(0)
    end
end
