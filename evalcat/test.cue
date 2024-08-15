package evalcat

// myHandRem: #HandRem & {
// 	filename:     "rem_zeroed_masked.tif"
// 	data_version: "fim_4_4_0_0"
// 	huc:          "12345678"
// }

// myHucBranches: #hucBranches & {
// 	data_version: "fim_4_5_0_0"
// 	huc:          "87654321"
// }

// myHydrotable: #Hydrotable & {
// 	data_version: "fim_4_4_0_0"
// 	huc:          "23456789"
// }

// myReachRaster: #ReachRaster & {
// 	filename:     "gw_catchments_reaches_filtered_addedAttributes.tif"
// 	data_version: "fim_5_0_0_0"
// 	huc:          "34567890"
// }

// myReachAttributes: #ReachAttributes & {
// 	data_version: "fim_4_5_0_0"
// 	huc:          "45678901"
// }

// myVectorMasks: #VectorMasks & {
// 	filename: "Levee_protected_areas.gpkg"
// }

// myWBD: #WBD

// myEvalMetrics: #EvalMetrics & {}

// myAgreementMap: #AgreementMap & {
// 	filename:         "ble_agreement_map.tif"
// 	benchmark_source: "ble"
// 	huc:              "56789012"
// 	magnitude:        "100yr"
// 	data_version:     "fim_4_4_0_0"
// 	version_env:      "official"
// }

// test hand extent with dates
myHandExtent: #HandExtent & {
	filename:         "usgs_inundation_extent.tif"
	benchmark_source: "usgs"
	huc:              "67890123"
	dates: {
		start: "2006-01-02"
		end:   "2006-01-03"
	}
	lid:          "ABCD"
	data_version: "fim_4_4_0_0"
	version_env:  "testing"
}

// test hand extent with magnitudes
myMagHandExtent: #HandExtent & {
	filename:         "usgs_inundation_extent.tif"
	benchmark_source: "usgs"
	huc:              "67890123"
	magnitude:        "major"
	lid:              "ABCD"
	data_version:     "fim_4_4_0_0"
	version_env:      "testing"
}
