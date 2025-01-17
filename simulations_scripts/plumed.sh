#!/bin/bash

module purge
#module load openmpi/4.1.3-gnu plumed/2.8.0-2022 GROMACS/2022.3-plumed


export grouphome=/dartfs-hpc/rc/lab/R/RobustelliP/

plu="/usr/bin/singularity run --bind ${grouphome} --bind ${HOME}/scratch:/scratch --bind $HOME ${grouphome}/SINGULARITY_BUILDS/gromacs/gromacs_2022.3plumed_turing.sif plumed"

#sh echo.sh

t=$1
nreps=$2

rm -rf hills_temp
mkdir hills_temp

tn=$(( t * nreps * 1000 ))

for i in rg ohbond ahelixright betasheet ahelixleft polypro fstdr scddr trddr frthdr fiftdr sixtdr ; do

head ../../0/HILLS_${i} -n3 > ./hills_temp/hills_${i}
grep -vE '@|#' ../../0/HILLS_${i} | head -n $tn >> ./hills_temp/hills_${i}

done

sh echo_temp.sh
wait

#pkill -15 krenew
#krenew -b -a -vL -K60


nohup $plu driver --plumed ./plumed_hills_rg.dat --mf_xtc c_${t}.xtc --kt 2.494339 > plumed_rg.log &
nohup $plu driver --plumed ./plumed_hills_ohbond.dat --mf_xtc c_${t}.xtc --kt 2.494339 > plumed_ohbond.log &
nohup $plu driver --plumed ./plumed_hills_ahelixright.dat --mf_xtc c_${t}.xtc --kt 2.494339 > plumed_ahelixright.log &
nohup $plu driver --plumed ./plumed_hills_betasheet.dat --mf_xtc c_${t}.xtc --kt 2.494339 > plumed_betasheet.log &
nohup $plu driver --plumed ./plumed_hills_ahelixleft.dat --mf_xtc c_${t}.xtc --kt 2.494339 > plumed_ahelixleft.log &
nohup $plu driver --plumed ./plumed_hills_polypro.dat --mf_xtc c_${t}.xtc --kt 2.494339 > plumed_polypro.log &
#nohup $plu driver --plumed ./plumed_hills_fstdr.dat --mf_xtc c_${t}.xtc  --kt 2.494339 > plumed_fstdr.log &
nohup $plu driver --plumed ./plumed_hills_scddr.dat --mf_xtc c_${t}.xtc --kt 2.494339 > plumed_scddr.log &
nohup $plu driver --plumed ./plumed_hills_trddr.dat --mf_xtc c_${t}.xtc --kt 2.494339 > plumed_trddr.log &
#nohup $plu driver --plumed ./plumed_hills_frthdr.dat --mf_xtc c_${t}.xtc --kt 2.494339 > plumed_frthdr.log &
nohup $plu driver --plumed ./plumed_hills_fiftdr.dat --mf_xtc c_${t}.xtc --kt 2.494339 > plumed_fiftdr.log &
#nohup $plu driver --plumed ./plumed_hills_sixtdr.dat --mf_xtc c_${t}.xtc --kt 2.494339 > plumed_sixtdr.log &

wait

#nohup plumed driver --plumed ./plumed_grid.dat --mf_xtc combined.xtc --kt 2.494339 > plumed.log
nohup $plu driver --plumed ./plumed_grids.dat --mf_xtc c_${t}.xtc --kt 2.494339 > plumed.log &

wait

mv COLVAR_PBMETAD.REWEIGHT_GRIDS colvar_${t}.dat

rm bck.*
