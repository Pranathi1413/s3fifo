# Commands to setup and run on Explorer cluster

## Setup and install dependencies
```bash
module load anaconda3/2024.06 
module list
conda create -n prancache python=3.10
conda activate prancache
conda init
conda install -c conda-forge glib gperftools cmake make zstd 
```

## Build cachesim and example run of a trace in conda env
```bash
pushd libCacheSim/scripts && bash install_libcachesim.sh && popd;
curl -O https://ftp.pdl.cmu.edu/pub/datasets/twemcacheWorkload/cacheDatasets/twitter/sample100/cluster26.oracleGeneral.sample100.zst
./libCacheSim/_build/bin/cachesim data/cluster26.oracleGeneral.sample100.zst oracleGeneral s3fifo 0.1 --ignore-obj-size 1
```

## Run parallelly on all traces in trace.manifest
```bash
srun --partition=short --job-name=s3fifo --nodes=2 --ntasks=10 --cpus-per-task=2 --mem-per-cpu=6G --time=03:00:00 --output=logs/%x-%j-%t.out --error=logs/%x-%j-%t.out bash -lc './testrun.sh'
```