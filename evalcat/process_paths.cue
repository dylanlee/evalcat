package evalcat

import (
	"strings"
	"path"
	"regexp"
)

_filepaths: [...string]

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

// BEGIN PATH LIST PROCESSING
// Define the result as a list of structs
_result: [
	for _filepath in _filepaths {
		let ver = #GetVer & {_in: {pattern: "hand_fim", path: _filepath}}
		let name = path.Base(_filepath)
		let hucstring = strings.Split(regexp.FindAll(#catchmentid_filter, _filepath, -1)[0], "/")[1]
		let branchstring = strings.Split(regexp.FindAll(#catchmentid_filter, _filepath, -1)[1], "/")[1]
		if (#HandRem & {filename: name}) != _|_ {
			rem:
				#HandRem & {
					filename:     name
					huc:          hucstring
					branch:       branchstring
					data_version: ver.data_version
				}
		}
		if (#HydroTable & {filename: name}) != _|_ {
			hydroTable:
				#HydroTable & {
					filename:     name
					huc:          hucstring
					branch:       branchstring
					data_version: ver.data_version
				}
		}
		if (#ReachRaster & {filename: name}) != _|_ {
			reachRaster: #ReachRaster & {
				filename:     name
				huc:          hucstring
				branch:       branchstring
				data_version: ver.data_version
			}
		}

		if (#ReachAttributes & {filename: name}) != _|_ {
			reachAttribute: #ReachAttributes & {
				filename:     name
				huc:          hucstring
				branch:       branchstring
				data_version: ver.data_version
			}
		}
		if name == #Huc8Shape.filename {
			huc8Shape: #Huc8Shape & {
				filename:     name
				huc:          hucstring
				data_version: ver.data_version
			}
		}
		if name == #HucBranchMap.filename {
			hucBranchMap: #HucBranchMap & {
				filename:     name
				data_version: ver.data_version
			}
		}

		if (#VectorMasks & {filename: name}) != _|_ {
			vectorMask: #VectorMasks & {
				filename: name
			}
		}

		if (#WbdNational & {filename: name}) != _|_ {
			wbdNational: #WbdNational & {
				filename: name
			}
		}
		if (#EvalMetrics & {filename: name}) != _|_ {
			evalMetric: #EvalMetrics & {
				filename: name
			}
		}
		if (#AgreementMap & {filename: name}) != _|_ {
			//need to extract version from eval pathing with a different split string 
			let eval_ver = #GetVer & {_in: {pattern: "versions", path: _filepath}}
			agreementMap: #AgreementMap & {
				filename: name
				huc:      hucstring
				dates: {start: "2006-01-02"
					end: "2006-01-03"
				}
				version_env:  "official"
				data_version: eval_ver.data_version
			}
		}
	},
]

// Flatten the list of lists into multiple lists. One containing all the hand_rem structs called "hand_rem" another containing all the hydrotable structs
hydroTables: [
	for x in _result
	if x.hydroTable != _|_ {x.hydroTable},
]

rems: [
	for x in _result
	if x.rem != _|_ {x.rem},
]

reachRasters: [
	for x in _result
	if x.reachRaster != _|_ {x.reachRaster},
]

reachAttributes: [
	for x in _result
	if x.reachAttribute != _|_ {x.reachAttribute},
]

huc8Shapes: [
	for x in _result
	if x.huc8Shape != _|_ {x.huc8Shape},
]

hucBranchMaps: [
	for x in _result
	if x.hucBranchMap != _|_ {x.hucBranchMap},
]

vectorMasks: [
	for x in _result
	if x.vectorMask != _|_ {x.vectorMask},
]

wbdNational: [
	for x in _result
	if x.wbdNational != _|_ {x.wbdNational},
]

evalMetrics: [
	for x in _result
	if x.evalMetric != _|_ {x.evalMetric},
]

agreementMaps: [
	for x in _result
	if x.agreementMap != _|_ {x.agreementMap},
]
