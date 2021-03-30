#!/bin/bash
#SBATCH --mail-user=jashnsh@vanderbilt.edu
#SBATCH --mail-type=ALL

#SBATCH --ntasks=1
#SBATCH --time=120:00:00
#SBATCH --mem=16G
#SBATCH --array=1-180
#SBATCH --output=Out_%A_%a.out

echo "SLURM_JOBID: " $SLURM_JOBID
echo "SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
echo "SLURM_ARRAY_JOB_ID: " $SLURM_ARRAY_JOB_ID

module load MATLAB
matlab -nodisplay -nosplash -r "do_FP_FIM_J(${SLURM_ARRAY_TASK_ID});quit;"