#!/bin/bash
date

pipe_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $pipe_path
mkdir -p conda_env
mkdir -p git_repo


# active conda inside script
temp=$(which conda)
conda_path=$(echo ${temp%/*bin/conda})
if [ -f ${conda_path}/etc/profile.d/conda.sh ]; then
        . ${conda_path}/etc/profile.d/conda.sh
else
        echo "ERROR: conda path can't be corrected identified!!!"
        exit 1
fi
unset conda_path


# create env
# Still use py3.7 as may encounter pkg conflicts in 3.8+
conda create -y -p ${PWD}/conda_env/MAPS_py37 python=3.7
conda activate ${PWD}/conda_env/MAPS_py37
conda install -y -c anaconda seaborn
conda install -y -c bioconda kmc
conda install -y -c bioconda sourmash
conda install -y -c bioconda sra-tools

conda deactivate




date
echo "pipe done"
