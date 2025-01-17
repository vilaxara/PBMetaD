# Parallel bias meta dynamics aggregate analysis

## :auto_rickshaw: System information

- <u>**Protein**</u> : C terminal of $\alpha$-synuclien
- <u>**Small molecules**</u> : Fasudil & Ligand 47
- <u>**Number of collective variables**</u> : Rg, hydrogen-bonds, ahelixright, betasheet, ahelixleft, polypro for apo and distance between COM of protein which is cut up into six segments and COM(center of mass) of small molecules are added in presence of ligands.
- <u>**Number of replicas**</u> : 16
- <u>**Simulation time**</u> : 1$\mu$s which aggregates to 16*1 = 16$\mu$s 
  
## :auto_rickshaw: How is it done?

The simulations trajectories which are run for 1$\mu$s are sliced at 100ns interval using `gmx trjconv` command. The sliced trajectories are then concatenated using `gmx trjcat` giving us a combined trajectory for further analysis. Before we start, `HILLS` files which are generated should be sliced which will be used in the analysis. The commands used to do this is:

```bash

t=\$1 # Intervel value. Eg : 100, 200, ....
nreps=$2 # Number of replicas

tn=$(( t * nreps * 1000 ))

mkdir hills_temp

for i in rg ohbond ahelixright betasheet ahelixleft polypro fstdr scddr trddr frthdr fiftdr sixtdr ; do

head path/to/hills_files/HILLS_\${i} -n3 > ./hills_temp/hills_\${i}
grep -vE '@|#' path/to/hills_files/HILLS_\${i} | head -n $tn >> ./hills_temp/hills_\${i}

done
```


Once the files are generated, the grid files are generated using the following plumed command :

```bash
plumed driver --plumed ./plumed_hills_rg.dat --mf_xtc sliced_combined_trajectory.xtc --kt 2.494339 | tee plumed_rg.log
```

This is for Rg. Similarly we will repeat this for all the collective variables. This will generate `GRID` files which will be used in the next step to generate the respective `COLVAR` file which contains weights for each frame. The command used to generate the `COLVAR` file is :

```bash
plumed driver --plumed ./plumed_grids.dat --mf_xtc sliced_combined_trajectory.xtc --kt 2.494339 | tee plumed.log
```

For reference see the [plumed.sh](./simulations_scripts/plumed.sh) file. U+1F601

## :auto_rickshaw: What to do now?

Now we have the required weights we will plot re-weighted 1-D free energies as shown in the analysis notebooks named `agg_rg_*.ipynb`. A function as mention bellow is used to compute the free energies :

```python

def free_energy_1D_blockerror( a:np.array, x0:float, xmax:float, bins:int, blocks:int, T:float = 300.00, weights:np.array=None):
    histo, xedges = np.histogram(
        a, bins=bins, range=[x0, xmax], density=True, weights=weights)
    max = np.max(histo)
    # free_energy=-(0.001987*T)*np.log(histo)
    free_energy = -(0.001987*T)*np.log(histo+.000001)
    free_energy = free_energy-np.min(free_energy)
    xcenters = xedges[:-1] + np.diff(xedges)/2
    Ind = chunkIt(len(a), blocks)
    block_size = (Ind[0][1]-Ind[0][0])
    hist_blocks = []
    for i in range(0, len(Ind)):
        block_data = a[Ind[i][0]:Ind[i][1]]
        hist, binedges = np.histogram(block_data, bins=bins, range=[
                                    x0, xmax], density=True, weights=weights[Ind[i][0]:Ind[i][1]])
        hist_blocks.append(hist)
    hist_blocks = np.array(hist_blocks)
    average = np.average(hist_blocks, axis=0)
    variance = np.var(hist_blocks, axis=0)
    N = len(hist_blocks)
    error = np.sqrt(variance / N)
    ferr = -(0.001987*T)*(error / average)

    return free_energy, xcenters, ferr

```

THe obtained values are plotted. For reference see [Block_analysis.py](./simulations_scripts/Block_analysis.py). Functions used to compute ligand contacts and bound fraction for respective trajectories are present in [structure_analysis.py](./simulations_scripts/structure_analysis.py). All the data and colvar files can be downloaded from [here](https://dartmouth-my.sharepoint.com/:f:/r/personal/f006f50_dartmouth_edu/Documents/PBMetaD?csf=1&web=1&e=aqmO7K). 

