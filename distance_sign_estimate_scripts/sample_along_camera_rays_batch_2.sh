SCANNET_PATH=/cluster/scratch/xiaojwan/ScanNet_v2
TOOL_PATH=/cluster/scratch/xiaojwan/TSDF_utils
OUTPUT_PATH=/cluster/scratch/xiaojwan/ScanNet_v2_points_depthmap_camera_rays_0_1
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

    python3 $TOOL_PATH/sample_along_camera_rays/sample_along_camera_rays_from_depthmap.py \
        --scene_path $scene_path \
        --output_file $OUTPUT_PATH/$scene_name"_points_depthmap_camera_rays.dat" \
        --num_sample 10000 \
        --gaussian_variance 0.1

    # mkdir -p $DISTANCE_TOOL_PATH/scannet/$scene_name
    # $DISTANCE_TOOL_PATH/compute_distance_transform_scannet \
    #     -f $scene_path/$scene_name"_vh_clean_2.ply" \
    #     -p $scene_path/points_along_camera_rays.dat \
    #     -o $DISTANCE_TOOL_PATH/scannet/$scene_name \
    #     -v 10000


    # python3 $TOOL_PATH/scannet_signed_distance_compute/estimate_distance_sign_from_2D_cameras.py \
    #     --scene_path $scene_path \
    #     --scene_sampled_point_file $SCANNET_POINTS_PATH/$scene_name"_vh_clean_2.npy" \
    #     --output_file $OUTPUT_PATH/$scene_name".npz" \
    #     --truncated_distance 0.1
    #     --visualization True

    rm -r ${scene_path}/sensor  

    count=count+1

done



