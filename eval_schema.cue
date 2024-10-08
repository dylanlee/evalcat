package evalcat

import "path"

import "time"

// Top-level pathing
InsOuts: {
	eval_out: string & "fimc-data/hand_fim/"
	hand_in:  string & "noaa-nws-owp-fim/hand_fim/inputs/"
	hand_out: string & "noaa-nws-owp-fim/hand_fim/"
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

// BEGIN HAND DEFINITONS
#HandRem: {
	filename: =~"rem_(zeroed|clipped_zeroed)_masked"
	input_to: ["eval"]
	output_of: ["hand"]
	data_version: #FimVersions
	data_roles: ["rem"]
	huc:    string & =~"^[0-9]+$"
	branch: string & =~"^[0-9]+$"
	dir_path: "s3://" + path.Join([InsOuts.hand_out, data_version, huc, "branches", branch], path.Unix)
}

// Hydrotable
#HydroTable: {
	filename: =~"hydroTable"
	input_to: ["eval"]
	output_of: ["hand"]
	data_version: #FimVersions
	data_roles: ["channel_geometry", "rating_curve"]
	huc:    string & =~"^[0-9]+$"
	branch: string & =~"^[0-9]+$"
	dir_path: "s3://" + path.Join([InsOuts.hand_out, data_version, huc, "branches", branch], path.Unix)
}

// reach raster
#ReachRaster: {
	filename: =~".*gw_catchments_reaches.*\\.tif$"
	input_to: ["eval"]
	output_of: ["hand"]
	data_version: #FimVersions
	data_roles: ["pixel_mapped_reach"]
	huc:    string & =~"^[0-9]+$"
	branch: string & =~"^[0-9]+$"
	dir_path: "s3://" + path.Join([InsOuts.hand_out, data_version, huc, "branches", branch], path.Unix)
}

#ReachAttributes: {
	filename: =~".*gw_catchments_reaches.*\\.gpkg$"
	input_to: ["eval"]
	output_of: ["hand"]
	data_version: #FimVersions
	data_roles: ["cross_walked_reach"]
	huc:    string & =~"^[0-9]+$"
	branch: string & =~"^[0-9]+$"
	dir_path: "s3://" + path.Join([InsOuts.hand_out, data_version, huc, "branches", branch], path.Unix)
}

#Huc8Shape: {
	filename: "wbd.gpkg"
	input_to: ["eval"]
	output_of: ["hand"]
	data_version: #FimVersions
	data_roles: ["model_boundary"]
	huc: string & =~"^[0-9]+$"
	dir_path: "s3://" + path.Join([InsOuts.hand_out, data_version, huc], path.Unix)
}

// HUC branch table
#HucBranchMap: {
	filename: "fim_inputs.csv"
	input_to: ["eval"]
	output_of: ["hand"]
	data_version: #FimVersions
	data_roles: ["branch_lookup"]
	dir_path: "s3://" + path.Join([InsOuts.hand_out, data_version], path.Unix)
}

// Vector masks
#VectorMasks: {
	filename: string & =~".*(?:Levee_protected_areas|nwm_lakes\\.gpkg).*" //_filenamePattern
	input_to: ["eval", "hand"]
	output_of: []
	data_roles: ["mask"]
	dir_path: "s3://" + path.Join([
		InsOuts.hand_in,
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
#WbdNational: {
	filename: "WBD_National.gpkg"
	input_to: ["eval", "hand"]
	output_of: []
	data_roles: ["model_boundary"]
	dir_path: "s3://" + path.Join([InsOuts.hand_in, "inputs", "wbd"], path.Unix)
}

// Metric CSV file
#EvalMetrics: {
	filename: =~".*metrics.csv$"
	output_of: ["eval"]
	data_roles: ["model_evaluation"]
	dir_path: "s3://" + path.Join([InsOuts.eval_out, "metrics"], path.Unix)
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
	dir_path: "s3://" + path.Join([
		InsOuts.eval_out,
		"testy_cases",
		benchmark_source + "_test_cases",
		huc,
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
	dir_path: "s3://" + path.Join([
		InsOuts.eval_out,
		"testy_cases",
		benchmark_source + "_test_cases",
		huc,
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
