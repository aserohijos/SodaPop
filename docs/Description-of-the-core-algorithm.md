![algo](https://user-images.githubusercontent.com/29554043/28376750-ecf38e40-6c78-11e7-92ec-3365d1dd9043.png)
**Illustration of SodaPop's core algorithm.**

The simulation algorithm is adapted from the Wright-Fisher model with selection. Generations are discrete time intervals in which all N parent cells within the population give birth to a certain number of daughter cells. The number of offspring k is drawn from a binomial distribution with N trials and mean w, which is the fitness of the parent cell over the sum of all cell fitnesses. The offspring go on to become the parents for the next generation.

Cell fitness is determined by the fitness function specified by the user. Among those are input-specific functions such as metabolic flux and cytotoxicity of misfolded proteins, which are dependent on protein stability (∆G). The distribution of fitness effects (DFE) can be input explicitly by the user in the form of a ∆∆G matrix or of deep mutational scanning (DMS) data. Fitness effects can also be drawn from a Gaussian distribution with a given mean and SD.

The population is implemented as a vector of cells. This is because vectors store elements contiguously in memory, making elements accessible through iterators and pointer arithmetic, and providing spatial locality of reference. The most common operation is appending a cell at the end of the vector, which is done in amortized constant time. This is linear if we append k cells at once. Random iterator access is also done in constant time, which proves useful for upsizing or downsizing the population. Vectors also allow for efficient memory handling as memory can be reserved ahead of time provided a good estimate of capacity is known. Because we have fixed size populations, this is a known variable, preventing costly reallocations when the vector is at full capacity.  

Cells also use vectors to implement genomes. Genes store stability in exponentiated form so it is readily available for most computations.  

The memory overhead for I/O is significantly higher than that for type conversion, so the performance gain of using binary files over text is negligible. However, we opted to read and write binary files because they are smaller in size. Once again, this is not significant for small-scale simulations but can weigh in for larger runs. 