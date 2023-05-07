#!/bin/bash
#SBATCH --account=lcrads
#SBATCH --job-name=hw3
#SBATCH --output=hw3.out
#SBATCH --error=hw3.err
#SBATCH --time=0-01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1

# make a CSV file
cat Drerio_development1.csv Drerio_development2.csv Drerio_development3.csv | awk 'NR == 1 || !/^#/ {print}' > Drerio_development_complete.csv

# add ID column
awk -F, 'BEGIN {OFS=","} NR == 1 {print $0, "Sample_ID"; next} {print $0, $1"_"$2}' Drerio_development_complete.csv > Drerio_development_complete_temp.csv
mv Drerio_development_complete_temp.csv Drerio_development_complete.csv

# calculate means
output_file="Drerio_development_analysis.txt"

# header
echo -e "Group\tAverage Weight\tAverage Length\tAverage Pigmentation" > "$output_file"

patterns=("Female" "Male" "1" "2" "3" "4" "5" "Control" "Treatment")
group_names=("Sex_Female" "Sex_Male" "Age_1" "Age_2" "Age_3" "Age_4" "Age_5" "Condition_Control" "Condition_Treatment")

for i in "${!patterns[@]}"; do
    pattern="${patterns[$i]}"
    group_name="${group_names[$i]}"

    egrep "$pattern" Drerio_development_complete.csv | awk -F',' -v group="$group_name" \
    '{sum_weight+=$8; sum_length+=$9; sum_pigmentation+=$6; count++} \
    END {print group, (sum_weight/count), (sum_length/count), (sum_pigmentation/count)}' \
    >> "$output_file"
done