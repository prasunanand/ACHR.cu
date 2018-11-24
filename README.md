# Description
ACHR.cu is a General Purpose Graphical Processing Unit (GP-GPU) implementation of the popular sampling algorithm of metabolic models ACHR.
Sampling is the tool of choice in metabolic modeling in unbiased analysis as it allows to explore the solution space constrained by the linear bounds without neccessarily
assuming an objective function. As metabolic models grow in size tio represent communities of bacteria and complex human tissues, sampling became less used because of the large analysis time.
With ACHR.cu we can achieve at least a speed up of 10x in the sampling process.

Technically sampling is a two step process:

1. The generation of warmup points.

2. The actual sampling starting from the previously generated warmup points.

# Installation
The software can be installed via cloning this repository to your local machine and compiling `VFWarmup` (for step 1) and `ACHR.cu` (for step 2) at their root folders.
More details can be founds in the [documentation](https://achrcu.readthedocs.io/en/latest/).

## Dependencies 

+ IBM CPLEX v12.6 (free for academics)

+ GSL linear algebra library

+ CUDA v8.0

+ MPI and OpenMP

## Harwarde requirements

+ Nvidia GPU with sm_35 architecture and above. Check the [documentation](https://achrcu.readthedocs.io/en/latest/) for more details on the requirements.

# Quick guide

Sampling is a two-step process:

1. The generation of warmup points.

```
mpirun -np nCores --bind-to none -x OMP_NUM_THREADS=nThreads createWarmupPts model.mps
```

This command allows to generate warmup points given by the user in runtime of the model in `model.mps` file using dyncamically load balanced `nCores` and `nThreads` through a hybrid MPI/OpenMP.

2. The actual sampling starting from the previously genrated warmup points.

`./ACHR model.mps warmuppoints.csv nFiles nPoints nSteps`

This command allows to generate the actual sampling points starting from the previously generated sampling points stored in `warmuppoints.csv` to generate a total of `nFiles*nPoints` with each point
requiring `nSteps` to converge. 

# Acknowledgments

The experiments were carried out using the [HPC facilities of the University of Luxembourg](http://hpc.uni.lu)

# License

The project is licensed under the MIT license, see the file [LICENSE](<https://github.com/marouenbg/ACHR.cu/blob/master/LICENSE.txt>) for details.

# Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md).
By participating in this project you agree to abide by its terms.

