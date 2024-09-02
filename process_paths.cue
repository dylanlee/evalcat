package evalcat

import (
	"strings"
	"path"
	"regexp"
	"list"
)

//output lists of versions sources and a magnitude object for eval scripts
fimVersions: ["fim_4_4_0_0", "fim_4_5_2_11"]
benchmarkSources: ["ble", "usgs", "nws", "hwm", "gfm"]
magnitudes: {
	ble: ["100yr", "500yr"]
	ahps: ["action", "minor", "moderate", "major"]
}

// BEGIN REGEXP PATTERN DEFINITIONS
// This pattern matches any sequence of digits between forward slashes
#catchmentid_filter: "/([0-9]+)/"

// BEGIN PATH PROCESSING FUNCTIONS
// generic input for different path processing function-alikes
#Input: {
	pattern: string
	path:    string
}

// generic output for your function outputs
#Output: string

#GetVer: {
	_in:          #Input
	data_version: #Output

	// Intermediate fields
	_splitPath:      strings.Split(_in.path, _in.pattern)
	_remainingPath:  _splitPath[1]
	_versionPattern: "^/([^/]+)"
	_match:          regexp.FindSubmatch(_versionPattern, _remainingPath)

	data_version: _match[1]
	...
}

#ProcessFiles: {
	filepaths: [...string]
	schema: _
	output: [for filepath in filepaths
		let ver = #GetVer & {_in: {pattern: "hand_fim", path: filepath}}
		let name = path.Base(filepath)
		if (schema & {filename: name}) != _|_ {
			if list.Contains(schema.output_of, "hand") && regexp.FindAll(#catchmentid_filter, filepath, -1) != _|_ {
				let hucMatches = regexp.FindAll(#catchmentid_filter, filepath, -1)
				if len(hucMatches) == 2 {
					let hucstring = strings.Split(hucMatches[0], "/")[1]
					let branchstring = strings.Split(hucMatches[1], "/")[1]
					schema & {
						filename:     name
						huc:          hucstring
						branch:       branchstring
						data_version: ver.data_version
					}
				}
				if len(hucMatches) == 1 {
					let hucstring = strings.Split(hucMatches[0], "/")[1]
					schema & {
						filename:     name
						huc:          hucstring
						data_version: ver.data_version
					}
				}
				schema & {
					filename:     name
					data_version: ver.data_version
				}
			}
			if list.Contains(schema.input_to, "eval") {
				schema & {
					filename: name
				}
			}

			//added this condition for individual huc8 wbd data
			if list.Contains(schema.data_roles, "model_boundary") {
				schema & {
					filename: name
				}
			}
		},
	]
}

_handRems: #ProcessFiles & {
	filepaths: _evalpaths
	schema:    #HandRem
}

// _hydroTables: #ProcessFiles & {
// 	filepaths: _evalpaths
// 	schema:    #HydroTable
// }

// _reachRasters: #ProcessFiles & {
// 	filepaths: _evalpaths
// 	schema:    #ReachRaster
// }

// _reachAttributes: #ProcessFiles & {
// 	filepaths: _evalpaths
// 	schema:    #ReachAttributes
// }

// _huc8Shapes: #ProcessFiles & {
// 	filepaths: _evalpaths
// 	schema:    #Huc8Shape
// }

// _hucBranchMaps: #ProcessFiles & {
// 	filepaths: _evalpaths
// 	schema:    #HucBranchMap
// }

// _vectorMasks: #ProcessFiles & {
// 	filepaths: _evalpaths
// 	schema:    #VectorMasks
// }

// // Output the processed files
handRems: _handRems.output
// hydroTables:     _hydroTables.output
// reachRasters:    _reachRasters.output
// reachAttributes: _reachAttributes.output
// huc8Shapes:      _huc8Shapes.output
// hucBranchMaps:   _hucBranchMaps.output
// vectorMasks:     _vectorMasks.output
