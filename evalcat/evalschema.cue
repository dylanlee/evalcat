package evalcat

import "path"

import "time"

// Top-level pathing
InsOuts: {
	eval: string & "/path/to/eval"
	hand: string & "/path/to/hand"
}

// List of FIM output versions
#FimVersions: string & "fim_4_4_0_0" | *"fim_4_5_2_11"

// Benchmark sources
#BenchmarkSources: string & "ble" | *"usgs" | "nws" | "hwm" | "gfm"

// Magnitudes
#Magnitudes: {
	ble:  string & "100yr" | "500yr"
	ahps: string & "action" | "minor" | "moderate" | "major"
}

#DateRange: {
	start: string
	end:   string
}

// REM tifs
#HandRem: {
	filename: "rem_zeroed_masked.tif" | "rem_clipped_zeroed_masked.tif"
	input_to: ["eval"]
	output_of: ["hand"]
	data_version: #FimVersions
	data_roles: ["rem"]
	huc:    string & =~"^[0-9]+$"
	branch: string & =~"^[0-9]+$"
	dir_path: path.Join([InsOuts.hand, data_version, huc, "branches", branch], path.Unix)
}

// Hydrotable
#Hydrotable: {
	filename: "*.hydroTable.*"
	input_to: ["eval"]
	output_of: ["hand"]
	data_version: #FimVersions
	data_roles: ["channel_geometry", "rating_curve"]
	huc:    string & =~"^[0-9]+$"
	branch: string & =~"^[0-9]+$"
	dir_path: path.Join([InsOuts.hand, data_version, huc, "branches", branch], path.Unix)
}

// Pixel mapped reaches tifs
#ReachRaster: {
	filename: ".*gw_catchments_reaches.*\\.tif$"
	input_to: ["eval"]
	output_of: ["hand"]
	data_version: #FimVersions
	data_roles: ["pixel_mapped_reach"]
	huc:    string & =~"^[0-9]+$"
	branch: string & =~"^[0-9]+$"
	dir_path: path.Join([InsOuts.hand, data_version, huc, "branches", branch], path.Unix)
}

// Reach gpkg
#ReachAttributes: {
	filename: ".*gw_catchments_reaches.*\\.gpkg$"
	input_to: ["eval"]
	output_of: ["hand"]
	data_version: #FimVersions
	data_roles: ["cross_walked_reach"]
	huc:    string & =~"^[0-9]+$"
	branch: string & =~"^[0-9]+$"
	dir_path: path.Join([InsOuts.hand, data_version, huc, "branches", branch], path.Unix)
}

// individual huc8 gpkgs
#huc8shape: {
	filename: "wbd.gpkg"
	input_to: ["eval"]
	output_of: ["hand"]
	data_version: #FimVersions
	data_roles: ["model_boundary"]
	huc: string & =~"^[0-9]+$"
	dir_path: path.Join([InsOuts.hand, data_version, huc], path.Unix)
}

// HUC branch table
#hucBranchMap: {
	filename: "fim_inputs.csv"
	input_to: ["eval"]
	output_of: ["hand"]
	data_version: #FimVersions
	data_roles: ["branch_lookup"]
	huc: string & =~"^[0-9]+$"
	dir_path: path.Join([InsOuts.hand, data_version], path.Unix)
}

// Vector masks
#VectorMasks: {
	filename: "Levee_protected_areas.gpkg" | "nwm_lakes.gpkg"
	input_to: ["eval"]
	data_roles: ["mask"]
	dir_path: path.Join([
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

// national WBD data (all hucs)
#WBD_National: {
	filename: "WBD_National.gpkg"
	input_to: ["eval"]
	data_roles: ["model_boundary"]
	dir_path: path.Join([InsOuts.eval, "inputs", "wbd"], path.Unix)
}

// Metric CSV file
#EvalMetrics: {
	filename: ".*metrics.csv$"
	output_of: ["eval"]
	data_roles: ["model_evaluation"]
	dir_path: path.Join([InsOuts.eval], path.Unix)
}

// Agreement map
#AgreementMap: {
	filename:         string & =~".*agreement.*"
	benchmark_source: #BenchmarkSources
	huc:              string & =~"^[0-9]+$"
	magnitude?:       #Magnitudes.ble | #Magnitudes.ahps
	dates?: {
		start: time.Format(time.RFC3339Date)
		end:   time.Format(time.RFC3339Date)
	}
	lid?: string & =~"^[A-Za-z0-9]{4}$" | null
	data_roles: ["agreement_map"]
	data_version: #FimVersions
	version_env:  "official" | "testing"
	output_of: ["eval"]
	dir_path: path.Join([
		InsOuts.eval,
		"test_cases",
		benchmark_source + "_test_cases",
		huc + "_" + benchmark_source,
		version_env + "_versions",
		data_version,
		if magnitude != _|_ {
			magnitude
		},
		if dates != _|_ {
			dates.start + "_to_" + dates.end
		},
	], path.Unix)
}

// Inundated extent produced during benchmark
#HandExtent: {
	filename:         string & =~".*inundation_extent.*"
	benchmark_source: #BenchmarkSources
	huc:              string & =~"^[0-9]+$"
	magnitude?:       #Magnitudes.ble | #Magnitudes.ahps
	dates?: {
		start: time.Format(time.RFC3339Date)
		end:   time.Format(time.RFC3339Date)
	}
	lid?: string & =~"^[A-Za-z0-9]{4}$" | null
	data_roles: ["hand_extent"]
	data_version: #FimVersions
	version_env:  "official" | "testing"
	output_of: ["eval"]
	dir_path: path.Join([
		InsOuts.eval,
		"test_cases",
		benchmark_source + "_test_cases",
		huc + "_" + benchmark_source,
		version_env + "_versions",
		data_version,
		if magnitude != _|_ {
			magnitude
		},
		if dates != _|_ {
			dates.start + "_to_" + dates.end
		},
	], path.Unix)
}
