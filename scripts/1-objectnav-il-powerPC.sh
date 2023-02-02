#!/bin/bash
#SBATCH --job-name=pirlnav
#SBATCH --time=01:00:00
#SBATCH --partition=compute_full_node
#SBATCH --gpus-per-node 4
#SBATCH --nodes 2
#SBATCH --ntasks-per-node 4
#SBATCH --output=slurm_logs/ddpil-train-%j.out
#SBATCH --error=slurm_logs/ddpil-train-%j.err

# source /srv/flash1/rramrakhya6/miniconda3/etc/profile.d/conda.sh
# conda deactivate
#conda activate pirlnav

module load MistEnv/2020a cuda/10.2.89 gcc/8.4.0 anaconda3/2019.10 cudnn/7.6.5.32 pybind11/2.6.2\
source activate pirlnav-v3
cd $SCRATCH/pirlnav

export GLOG_minloglevel=2
export MAGNUM_LOG=quiet
export HABITAT_SIM_LOG=quiet

MASTER_ADDR=$(srun --ntasks=1 hostname 2>&1 | tail -n1)
export MASTER_ADDR

#cd /srv/flash1/rramrakhya6/spring_2022/pirlnav

dataset=$1


# DATA_PATH="data/datasets/objectnav/objectnav_hm3d/${dataset}"
# TENSORBOARD_DIR="tb/objectnav_il/${dataset}/ovrl_resnet50/seed_1/"
# CHECKPOINT_DIR="data/new_checkpoints/objectnav_il/${dataset}/ovrl_resnet50/seed_1/"

# DATA_PATH="data/datasets/objectnav/objectnav_hm3d/objectnav_hm3d_10k/"
config="configs/experiments/il_objectnav.yaml"
DATA_PATH="data/datasets/objectnav/objectnav_hm3d/objectnav_hm3d_hd"
TENSORBOARD_DIR="tb/objectnav_il/overfitting/ovrl_resnet50/seed_3_wd_zero/"
CHECKPOINT_DIR="data/new_checkpoints/objectnav_il/overfitting/ovrl_resnet50/seed_3_wd_zero/"
INFLECTION_COEF=3.234951275740812

mkdir -p $TENSORBOARD_DIR
mkdir -p $CHECKPOINT_DIR
set -x

echo "In ObjectNav IL DDP"
srun python -u -m run \
--exp-config $config \
--run-type train \
TENSORBOARD_DIR $TENSORBOARD_DIR \
CHECKPOINT_FOLDER $CHECKPOINT_DIR \
NUM_UPDATES 20000 \
NUM_ENVIRONMENTS 2 \
RL.DDPPO.force_distributed True \
TASK_CONFIG.DATASET.DATA_PATH "$DATA_PATH/{split}/{split}.json.gz" \
TASK_CONFIG.TASK.INFLECTION_WEIGHT_SENSOR.INFLECTION_COEF $INFLECTION_COEF \

# python3 -u -m run --exp-config $config --run-type train TENSORBOARD_DIR $TENSORBOARD_DIR CHECKPOINT_FOLDER $CHECKPOINT_DIR NUM_UPDATES 20000 NUM_ENVIRONMENTS 2 RL.DDPPO.force_distributed True TASK_CONFIG.DATASET.DATA_PATH "$DATA_PATH/{split}/{split}.json.gz" TASK_CONFIG.TASK.INFLECTION_WEIGHT_SENSOR.INFLECTION_COEF $INFLECTION_COEF 
