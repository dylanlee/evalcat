#!/bin/bash

# Total number of paths
TOTAL_PATHS=$(grep '^/' OE_eval_cat_paths.cue | wc -l)

BATCH_SIZE=10000
TOTAL_BATCHES=$(( (TOTAL_PATHS + BATCH_SIZE - 1) / BATCH_SIZE ))

for (( i=0; i<TOTAL_BATCHES; i++ ))
do
    cue cmd -t batchNumber=$i processHandRems 
    # Add other commands if needed
done

# Combine the batch outputs
jq -s 'reduce .[] as $item ({}; . * $item)' output/handRems_batch*.json > output/handRems_combined.json

# Clean up intermediate files
rm output/handRems_batch*.json

