This repo contains the code for ACHR.cu the cuda GPU implementation of the sampling algorithm ACHR.

The repo also contains VFwarmup which an implementation of the generation of sampling warmup points using dynamic load balancing.

The sampling of the solution space of metabolic models is a two-step process:

1- Generation of warmup points

The first step of sampling the solution space of metabolic networks involves the generation of warmup points that are solutions of the metabolic model's linear program. The sampling MCMC chain starts from those solutions to explore the solution space. The generation of p warmup points corresponds to flux variability analysis (FVA) solutions for the first p < 2n points, with n the number of reactions in the network, and to randomly generated solutions genrated through a randomc objective vector c for the p > 2n points.

The genration of warmup points is a time-consuming process and requires the use of more than one core in parallel. The distribution of the points to generate among the c cores of the computer is often performed through static balancing; which means that each core gets p/c points to generate. Nevertheless, the formulation of the problem induces a large imbalance in the distribution of work, meaning that the workers will not converge in the same time which slows dowmn the overall process. I showed previously that FVA is imbalanced especially with metabolism-expression models. In this case, the generation of warmup points through random c vectors of objective coefficients is yet another factor to favor the imbalance between the points to generate.

To remediate to this issue, dynamic loading balancing implemented through the OpenMP parallel library in C allows to assign less points to workers that required more time to solve previous chunks. In the end, the workers converge at the same time.
Below I report the run times of the generation of warmup points in MATLAB (CreateWarmupMATLAB) and through a hybrid MPI/OpenMP impelementation (CreateWarmupVF), both for the generation of 30,000 warmup points. 
Since the original implementation in MATLAB does not support parallelism, I reported the run times for the sequential version below. We can divide by the number of cores to get the times (at best) for a parallel version.The experiments are the average of 3 trials in every settings.

| Model         | CreateWarmupMATLAB | CreateWarmupVF  |CreateWarmupVF  |CreateWarmupVF |CreateWarmupVF |CreateWarmupVF |CreateWarmupVF |
| ------------- |:------------------:| ---------------:|----|---|---|---|---|
| Cores         | 1                  | 1               |2   |4  |8  |16 |32 |
| Ecoli core    |149                 |2.8              |1.8 |0.8|0.7|0.5|0.5|
| P Putida      | 385                | 12.5            |13  |8  |4  |2  |2  |
| EcoliK12      | 801                |    49           |43  |23 |10.4|9.5|9.1|
| Recon2        | 11346              |     288         |186 |30 |32  |24 |21|
| E Matrix      | NA*                |   602           |508 |130|52  |43 |43|
| Ec Matrix     | NA*                | 5275            |4986|924|224 |118|117|

*did not converge after 20,000 seconds.

The speed up is impressive (up to 50x in some cases) and shows the power of dynamic load balancing in imbalanced metabolic models.

2- The actual sampling of the solution space starting from the warmup points.

Sampling of the solution space of metabolic models involves the generation of MCMC chains starting from the warmup points.
The sampling in MATLAB was performed using the ACHR serial function using one sampling chain and the data was saved every 1000 points. The GPU parallel version creates one chain for each point. 
Each thread in the GPU executes one chain.   
In this case, the speed up with the GPU is quite important in the table below. It is noteworthy that even for a single core, the CPU is multithreaded especially with MATLAB base functions such as min and max.


| Model         | Points             | Steps           |Intel Xeon (3.5 Ghz)  |Tesla K40 |
| ------------- |:------------------:| ---------------:|----------------------|----------|
| Ecoli core    | 1000               | 1000            |42                    |          |
| Ecoli core    | 5000               | 1000            |208                   |  |
| Ecoli core    | 10000              | 1000            |420                   |  |
| P Putida      | 1000               | 1000            |103                   | 17.5  (SVD) |
| P Putida      | 5000               | 1000            |516                   | 70.84 (SVD) |
| P Putida      | 10000              | 1000            |1081                  | 138   (SVD) |
| Recon2        | 1000               | 1000            |2309                  | 269   (QR)  |
| Recon2        | 5000               | 1000            |                      |  |
| Recon2        | 10000              | 1000            |                      |  |

*SVD and QR refer to the impelementation of the null space computation.
 
The implementation of null space was a major determinant in the final run time and the fastest implementation was reported in the final run times.

While computing the SVD of the S matrix is more precise than QR, it is not prone for parallel computation in the GPU which can be even slower than the CPU in some cases.

Computing the null space through QR decompostion is faster but less precise and consumes more memory as it takes all the dimensions of the matrix as opposed to SVD that removes colmuns below a given precision of the SV.

 
3- Comparison to existing software
OptGP sampler

