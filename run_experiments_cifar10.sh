#!/bin/bash

strategies=("fedavg" "fedopt-adam" "fedopt-adagrad" "fedavg-weighted")
partitions=("iid" "dirichlet" "dirichlet-skewed" "pathological")

declare -A strategy_options
strategy_options["fedavg"]="strategy-name=\"fedavg\""
strategy_options["fedopt-adam"]="strategy-name=\"fedopt\" strat_optimizer=\"adam\""
strategy_options["fedopt-adagrad"]="strategy-name=\"fedopt\" strat_optimizer=\"adagrad\""
strategy_options["fedavg-weighted"]="strategy-name=\"fedavg-weighted\""

declare -A partition_options
partition_options["iid"]="partitioning-strategy=\"iid\""
partition_options["dirichlet"]="partitioning-strategy=\"dirichlet\" dirichlet-alpha=0.5"
partition_options["dirichlet-skewed"]="partitioning-strategy=\"dirichlet\" dirichlet-alpha=0.1"
partition_options["pathological"]="partitioning-strategy=\"pathological\" classes-per-partition=3 complete-mode=true"

common_options="dataset=\"uoft-cs/cifar10\" num-server-rounds=40 fraction-fit=1.0 different-compute=true batch-size=1024 client-learning-rate=0.001 architecture=\"vgg11\""

experiment_id=0
skip_experiments=12

for partition in "${partitions[@]}"; do
    partition_option=${partition_options[$partition]}
    
    for strategy in "${strategies[@]}"; do
	experiment_id=$((experiment_id + 1))
	if [ $experiment_id -le $skip_experiments ]; then
            continue
        fi

	strategy_option=${strategy_options[$strategy]}
        run_name="${strategy}-${partition}"
        echo "Starting run $experiment_id: $run_name"

        flwr run . --run-config "run-name=\"$run_name\" $strategy_option $partition_option $common_options"

        echo "Completed run: $run_name"
        echo "----------------------------------------"
    done
done
