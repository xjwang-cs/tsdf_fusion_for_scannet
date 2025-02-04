SCANNET_PATH=/cluster/scratch/xiaojwan/ScanNet_v2
SCANNET_POINTS_PATH=/cluster/scratch/xiaojwan/ScanNet_v2_distance_uniform
TOOL_PATH=/cluster/scratch/xiaojwan/TSDF_utils
OUTPUT_PATH=/cluster/scratch/xiaojwan/ScanNet_v2_sdf_uniform
declare -i count=0
for scene_path in $(ls -d $SCANNET_PATH/scans/scene*)
do
	scene_name=$(basename $scene_path)

	if [ $count -lt 300 ]; then
		count=count+1
        continue
    fi

    if [ $count -eq 600 ]; then
        echo $scene_name
        break
    fi


    if [ -d ${scene_path}/sensor ]; then
    	rm -r ${scene_path}/sensor    
    fi


    $TOOL_PATH/SensReader/c++/sens \
     	$scene_path/${scene_name}.sens $scene_path/sensor



    python3 $TOOL_PATH/scannet_signed_distance_compute/estimate_distance_sign_from_2D_cameras.py \
        --scene_path $scene_path \
        --scene_sampled_point_file $SCANNET_POINTS_PATH/$scene_name".npy" \
        --output_file $OUTPUT_PATH/$scene_name".npz" \
        --truncated_distance 0.15 \
        --visualization True \
        --visual_output_file $OUTPUT_PATH/$scene_name"_sdf_vis.ply"

    rm -r ${scene_path}/sensor  

    count=count+1

done
