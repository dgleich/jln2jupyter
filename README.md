`jln2jupyter.jl` to convert a Julia Notebook into a Jupyter Notebook
====================================================================

Summary
--------

Take a julia file where computational cells are marked with double comments,
such as
~~~~
## Step 1. Generate data on eigenvalues of random matrices
samples = map(_ -> eigvals!(randn(50,50)), 1:50)

## Step 2. Plot the results
histogram(map(x->maximum(abs(x)), samples))
~~~~
and turn it into a valid Jupyter notebook (`ipynb` file) that can be
published as an HTML file.
~~~~
julia jln2jupyter.jl mycode.jl                     # convert to mycode.ipynb
jupyter nbconvert --execute -to html mycode.ipynb  # convert to mycode.html
~~~~

Note that Juno (Atom) has support for executing cell-mode `.jl` files. We
chose to call them `Julia notebook` files (`.jln`), although there is nothing
special about `.jln` files (see below). Any Julia file is a Julia notebook
file. But the idea with the new extension is to enable separation of
experiments (`.jln`) from re-usuable code (`.jl`). Also, the separate
extension helps us write Makefiles that only process `.jln` files.

Usage
-----
~~~~
Usage: jln2jupyter.jl <julia> [<outputipynb>] [--verbose]
   <julia>        is the file name of the julia (*.jl or *.jln extension)
                  to be transformed into an Jupyter notebook
   <outputipynb>  is the optional filename of the Jupyter noteboook
                  it defaults to the julia file name with the .ipynb extension
   --help         Print out this help text and exit
   --verbose      Print out additional output

  Example:
    Generate sample.ipynb from sample.jln
      julia jln2jupyter.jl sample.jln        
    Generate sample_notebook.ipynb from sample.jln
      julia jln2jupyter.jl sample.jln sample_notebook.ipynb
~~~~

Motivation
----------
Interactive cell-mode computation is an incredibly useful, and efficient
way to explore data and algorithms. Jupyter notebooks and Matlab cell-mode
are the two premier environments for this type of computational experimentation.
Matlab's cell-mode uses an easy-to-write text file that is interpreted by the
IDE in terms of computational cells -- small blocks of code that accomplish
a goal. These can be executed and then published to an HTML file.

Jupyter's notebooks are another implementation of this idea inside a browser.
The downside to Juypter notebooks is that the code lives in a `.ipynb` file
that is JSON formatted and hard to write by hand.

For Julia, we wanted something with just text-files, where it is still
possible to publish the results of Julia experiments as Jupyter
notebooks (and HTML pages). This is to emulate the `publish` command
in Matlab, which takes a cell-formatted Matlab file and generates
a results filled HTML file. Using `jln2jupyter.jl` and jupyter, we
can duplicate this functionality in an easy-to-use fashion.

The Julia Notebook format
-------------------------

Any `.jl` file that Julia would run is a valid Julia Notebook file. So
why do we call them "Julia notebook" files? We expect `.jln` files to
include computational cells, akin to computational notebook environments
such as Matlab's cell-mode and Jupyter notebooks. Here's the same example of
a Julia notebook file that we had above

~~~~
## Step 1. Generate data on eigenvalues of random matrices
samples = map(_ -> eigvals!(randn(50,50)), 1:50)

## Step 2. Plot the results
histogram(map(x->maximum(abs(x)), samples))
~~~~

Note how Step 1 and Step 2 both start with a double comment `##`
The idea is that in a text editor with support for "cell-mode" computation,
we can run Step 1 a single time. Then we can interactively refine the plotting
step. This is exactly how environment such as Jupyter notebooks work. The
goal of Julia notebook files is to enable the same type of functionality in
a pure-text file. (Jupyter notebook files are pure text, but are JSON files,
which makes writing them by hand unnatural.)
