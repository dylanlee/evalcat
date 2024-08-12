package evalcat

import "path"

// Top-level pathing
InsOuts: {
	eval: string & "/path/to/eval"
	hand: string & "/path/to/hand"
}

// List of FIM output versions
#FimVersions: string & "fim_4_4_0_0" | *"fim_4_5_0_0" | "fim_5_0_0_0"

// Benchmark sources
#BenchmarkSources: string & "ble" | *"usgs" | "nws" | "hwm" | "gfm"

// Magnitudes
Magnitudes: {
	ble: ["100yr", "500yr"]
	ahps: ["action", "minor", "moderate", "major"]
}

// REM tifs
#HandRem: {
	filename: "rem_zeroed_masked.tif" | "rem_clipped_zeroed_masked.tif"
	input_to: ["eval"]
	output_of: ["hand"]
	data_version: #FimVersions
	data_roles: ["rem"]
	huc: string & =~"^[0-9]{8}$"
	write_path: path.Join([InsOuts.hand, data_version, huc], path.Unix)
}

// HUC branches
#hucBranches: {
	filename: "fim_inputs.csv"
	input_to: ["eval"]
	output_of: ["hand"]
	data_version: #FimVersions
	data_roles: ["branch_lookup"]
	huc: string & =~"^[0-9]{8}$"
	write_path: path.Join([InsOuts.hand, data_version], path.Unix)
}

// Hydrotable
#Hydrotable: {
	filename: "hydroTable.csv"
	input_to: ["eval"]
	output_of: ["hand"]
	data_version: #FimVersions
	data_roles: ["channel_geometry", "rating_curve"]
	huc: string & =~"^[0-9]{8}$"
	write_path: path.Join([InsOuts.hand, data_version, huc], path.Unix)
}

// Pixel mapped reaches tifs
#ReachRaster: {
	filename: "gw_catchments_reaches_filtered_addedAttributes.tif" | "gw_catchments_reaches_clipped_addedAttributes.tif"
	input_to: ["eval"]
	output_of: ["hand"]
	data_version: #FimVersions
	data_roles: ["pixel_mapped_reaches"]
	huc: string & =~"^[0-9]{8}$"
	write_path: path.Join([InsOuts.hand, data_version, huc], path.Unix)
}

// Reach gpkg
#ReachAttributes: {
	filename: "gw_catchments_reaches_filtered_addedAttributes_crosswalked.gpkg"
	input_to: ["eval"]
	output_of: ["hand"]
	data_version: #FimVersions
	data_roles: ["cross_walked_reaches"]
	huc: string & =~"^[0-9]{8}$"
	write_path: path.Join([InsOuts.hand, data_version, huc], path.Unix)
}

// Vector masks
#VectorMasks: {
	filename: "Levee_protected_areas.gpkg" | "nwm_lakes.gpkg"
	input_to: ["eval"]
	data_roles: ["mask"]
	write_path: path.Join([
		InsOuts.eval,
		"inputs",
		if filename == "Levee_protected_areas.gpkg" {
			"nld_vectors"
		},
		if filename == "nwm_lakes.gpkg" {
			"nwm_hydrofabric"
		},
	], path.Unix)
}

// WBD data
#WBD: {
	filename: "WBD_National.gpkg"
	input_to: ["eval"]
	data_roles: ["model_boundary"]
	write_path: path.Join([InsOuts.eval, "inputs", "wbd"], path.Unix)
}

// Metric CSV file
#EvalMetrics: {
	filename: "eval_metrics.csv"
	output_of: ["eval"]
	data_roles: ["model_evaluation"]
	write_path: path.Join([InsOuts.eval], path.Unix)
}

// Agreement map
#AgreementMap: {
	filename:         string & =~".*agreement"
	benchmark_source: #BenchmarkSources
	huc:              string & =~"^[0-9]{8}$"
	magnitude?:       string
	lid?:             string & =~"^[A-Za-z0-9]{4}$" | null
	data_roles: ["agreement_map"]
	data_version: #FimVersions
	version_env:  "official" | "testing"
	output_of: ["eval"]
	write_path: path.Join([InsOuts.eval, "test_cases", benchmark_source + "_test_cases", huc + "_" + benchmark_source, version_env + "_versions", data_version, magnitude], path.Unix)
}

// Inundated extent produced during benchmark
#HandExtent: {
	filename:         string & =~".*inundation_extent.*"
	benchmark_source: #BenchmarkSources
	huc:              string & =~"^[0-9]{8}$"
	magnitude?:       string
	lid?:             string & =~"^[A-Za-z0-9]{4}$" | null
	data_roles: ["hand_extent"]
	data_version: #FimVersions
	version_env:  "official" | "testing"
	output_of: ["eval"]
	write_path: path.Join([InsOuts.eval, "test_cases", benchmark_source + "_test_cases", huc + "_" + benchmark_source, version_env + "_versions", data_version, magnitude], path.Unix)
}
