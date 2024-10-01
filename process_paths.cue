package evalcat

import (
	"strings"
	"path"
	"regexp"
)

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

// Process HandRems
handRems: [...] & [
	for filepath in _evalpaths
	let ver = strings.SplitN(filepath, "/", -1)[5]
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
				data_version: ver
			}
		}
	},
]

hydroTables: [...] & [
	for filepath in _evalpaths
	let ver = strings.SplitN(filepath, "/", -1)[5]
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
				data_version: ver
			}
		}
	},
]

reachRasters: [...] & [
	for filepath in _evalpaths
	let ver = strings.SplitN(filepath, "/", -1)[5]
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
				data_version: ver
			}
		}
	},
]

reachAttributes: [...] & [
	for filepath in _evalpaths
	let ver = strings.SplitN(filepath, "/", -1)[5]
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
				data_version: ver
			}
		}
	},
]

huc8Shapes: [...] & [
	for filepath in _evalpaths
	let ver = strings.SplitN(filepath, "/", -1)[5]
	let name = path.Base(filepath)
	if (#Huc8Shape & {filename: name}) != _|_ {
		let hucMatches = regexp.FindAll(#catchmentid_filter, filepath, -1)
		if len(hucMatches) == 1 {
			let hucstring = strings.Split(hucMatches[0], "/")[1]
			#Huc8Shape & {
				filename:     name
				huc:          hucstring
				data_version: ver
			}
		}
	},
]

hucBranchMaps: [...] & [
	for filepath in _evalpaths
	let ver = strings.SplitN(filepath, "/", -1)[5]
	let name = path.Base(filepath)
	if (#HucBranchMap & {filename: name}) != _|_ {
		#HucBranchMap & {
			filename:     name
			data_version: ver
		}
	},
]

vectorMasks: [...] & [
	for filepath in _evalpaths
	let name = path.Base(filepath)
	if (#VectorMasks & {filename: name}) != _|_ {
		#VectorMasks & {
			filename: name
		}
	},
]

wbdNational: [...] & [
	for filepath in _evalpaths
	let name = path.Base(filepath)
	if (#WbdNational & {filename: name}) != _|_ {
		#WbdNational & {
			filename: name
		}
	},
]
