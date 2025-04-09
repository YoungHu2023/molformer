# This script is for conda==24.9, pip==24.3, and cuda version 12.3 
# as shown by the command 'nvidia-smi'.

conda create --name MolTran_CUDA12 python=3.8.10 -y
conda init
source ~/.bashrc
conda activate MolTran_CUDA12

# no need to clone if this script is added to the repo
git clone https://github.com/IBM/molformer.git
cd molformer

# conda installations
conda install -y pytorch=1.7.1=py3.8_cuda11.0.221_cudnn8.0.5_0 cudatoolkit=11.0 -c pytorch
conda install -y numpy=1.22.3 pandas=1.2.4 scikit-learn=0.24.2 scipy=1.6.2
conda install -y rdkit==2022.03.2 -c conda-forge

# pip installations (dataset version requirement deleted)
pip install transformers==4.6.0 pytorch-lightning==1.1.5 datasets jupyterlab==3.4.0 \
    ipywidgets==7.7.0 bertviz==1.4.0

# Must build locally otherwise getting error
pip install --no-cache-dir pytorch-fast-transformers

# Use old version to avoid bug in mkl>=2024.1
conda install mkl==2024.0.0 -y

# Clone and install NVIDIA apex
git clone https://github.com/NVIDIA/apex
cd apex
git checkout tags/22.03 -b v22.03

# Need to manually ensure correct CUDA path
export CUDA_HOME='/usr/local/cuda'

# https://github.com/NVIDIA/apex/pull/323#discussion_r287021798
sed -i '33,41d' setup.py

pip install -v --disable-pip-version-check --no-cache-dir --no-build-isolation \
    --config-settings "--build-option=--cpp_ext" --config-settings "--build-option=--cuda_ext" ./

# magical bug fix from https://github.com/NVIDIA/apex/issues/1193
export LD_LIBRARY_PATH=~/miniforge3/envs/MolTran_CUDA12/lib:$LD_LIBRARY_PATH
python setup.py install --cuda_ext --cpp_ext