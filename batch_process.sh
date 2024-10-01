#!/bin/bash

# Set the batch size. 1000 paths at a time is good.
BATCH_SIZE=1000

MAX_JOBS=20  # Set the maximum number of parallel jobs

# Initialize job counter
JOB_COUNT=0

# Input paths file
PATHS_FILE="./paths/OE_eval_cat_paths.txt"

# Ensure the output directory exists
mkdir -p output

# Step 1: Split the paths into batches
split -l $BATCH_SIZE "$PATHS_FILE" batch_paths_

# Initialize batch counter
BATCH_NUM=0

# Step 2: Process each batch in parallel
for BATCH_FILE in batch_paths_*
do
    (
        echo "Processing batch $BATCH_NUM..."

        # Create temporary CUE file
        TEMP_CUE_FILE="temp_paths_$BATCH_NUM.cue"

        # Write _evalpaths to the temporary CUE file
        {
            echo "package evalcat"
            echo ""
            echo "_evalpaths: ["
            cat "$BATCH_FILE"
            echo "]"
        } > "$TEMP_CUE_FILE"

        # Run cue export with the batch paths
        cue export eval_schema.cue process_paths.cue "$TEMP_CUE_FILE" > "output/batch$BATCH_NUM.json"

        # Check for errors
        if [ $? -ne 0 ]; then
            echo "Error processing batch $BATCH_NUM."
            exit 1
        fi

        # Clean up the temporary CUE file
        rm "$TEMP_CUE_FILE"

        echo "Batch $BATCH_NUM processed."

    ) &

    JOB_COUNT=$((JOB_COUNT + 1))
    if [ "$JOB_COUNT" -ge "$MAX_JOBS" ]; then
        wait  # Wait for background jobs to finish
        JOB_COUNT=0
    fi

    # Increment the batch counter
    BATCH_NUM=$((BATCH_NUM + 1))
done

# Wait for all background jobs to finish
wait

# Step 3: Combine the batch outputs
echo "Combining batch outputs..."
jq -s 'reduce .[] as $item ({}; 
    . as $accum | 
    reduce ($item | keys_unsorted[]) as $key (
        $accum; 
        .[$key] = (.[$key] // []) + $item[$key]
    )
)' output/batch*.json > output/eval_cat.json

# Step 4: Clean up intermediate files
echo "Cleaning up intermediate files..."
rm output/batch*.json
rm batch_paths_*

echo "Processing complete. Output is in output/eval_cat.json"
