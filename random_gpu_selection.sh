#if you have it here /etc/profile.d/gpu_selection.sh it will run everytime a user logs in

# Randomly choose gpu each time
gpu_no=$RANDOM
total_no_gpus=4
let "gpu_no %= $total_no_gpus"
export CUDA_VISIBLE_DEVICES=$gpu_no
