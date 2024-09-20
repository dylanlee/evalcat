package evalcat

import (
	"strings"
	"path"
	"regexp"
	"math"
)

//output lists of versions sources and a magnitude object for eval scripts
fimVersions: ["fim_4_4_0_0", "fim_4_5_2_11", "PI3_fim60_10m_wbt"]
benchmarkSources: ["ble", "usgs", "nws", "hwm", "gfm"]
magnitudes: {
	ble: ["100yr", "500yr"]
	ahps: ["action", "minor", "moderate", "major"]
}

// Define batch parameters
batchSize:   int & >0 | *10000 // Default batch size of 10,000
batchNumber: int & >=0 | *0    @tag(batchNumber,type="int")

// Calculate start and end indices
startIndex: batchNumber * batchSize
endIndex:   math.Min(startIndex+batchSize, len(_evalpaths))

// Slice the paths to process only the current batch
pathsToProcess: _evalpaths[startIndex:endIndex]

// regexp pattern definitions to be used in filepaths
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

// Process HandRems
handRems: [...] & [
	for filepath in _pathsToProcess
	let ver = #GetVer & {_in: {pattern: "outputs", path: filepath}}
	let name = path.Base(filepath)
	if (#HandRem & {filename: name}) != _|_ {
		let hucMatches = regexp.FindAll(#catchmentid_filter, filepath, -1)
		if len(hucMatches) >= 2 {
			let hucstring = strings.Split(hucMatches[0], "/")[1]
			let branchstring = strings.Split(hucMatches[1], "/")[1]
			#HandRem & {
				filename:     name
				huc:          hucstring
				branch:       branchstring
				data_version: ver.data_version
			}
		}
	},
]

hydroTables: [...] & [
	for filepath in _pathsToProcess
	let ver = #GetVer & {_in: {pattern: "outputs", path: filepath}}
	let name = path.Base(filepath)
	if (#HydroTable & {filename: name}) != _|_ {
		let hucMatches = regexp.FindAll(#catchmentid_filter, filepath, -1)
		if len(hucMatches) >= 2 {
			let hucstring = strings.Split(hucMatches[0], "/")[1]
			let branchstring = strings.Split(hucMatches[1], "/")[1]
			#HydroTable & {
				filename:     name
				huc:          hucstring
				branch:       branchstring
				data_version: ver.data_version
			}
		}
	},
]

reachRasters: [...] & [
	for filepath in _pathsToProcess
	let ver = #GetVer & {_in: {pattern: "outputs", path: filepath}}
	let name = path.Base(filepath)
	if (#ReachRaster & {filename: name}) != _|_ {
		let hucMatches = regexp.FindAll(#catchmentid_filter, filepath, -1)
		if len(hucMatches) >= 2 {
			let hucstring = strings.Split(hucMatches[0], "/")[1]
			let branchstring = strings.Split(hucMatches[1], "/")[1]
			#ReachRaster & {
				filename:     name
				huc:          hucstring
				branch:       branchstring
				data_version: ver.data_version
			}
		}
	},
]

reachAttributes: [...] & [
	for filepath in _pathsToProcess
	let ver = #GetVer & {_in: {pattern: "outputs", path: filepath}}
	let name = path.Base(filepath)
	if (#ReachAttributes & {filename: name}) != _|_ {
		let hucMatches = regexp.FindAll(#catchmentid_filter, filepath, -1)
		if len(hucMatches) >= 2 {
			let hucstring = strings.Split(hucMatches[0], "/")[1]
			let branchstring = strings.Split(hucMatches[1], "/")[1]
			#ReachAttributes & {
				filename:     name
				huc:          hucstring
				branch:       branchstring
				data_version: ver.data_version
			}
		}
	},
]
