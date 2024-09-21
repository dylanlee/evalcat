package evalcat

import (
	"strings"
	"path"
	"regexp"
	"list"
)

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

#ProcessFiles: {
	filepaths: [...string]
	schema: _
	output: [for filepath in filepaths
		let ver = strings.SplitN(filepath, "/", -1)[5]
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
						data_version: ver
					}
				}
				if len(hucMatches) == 1 {
					let hucstring = strings.Split(hucMatches[0], "/")[1]
					schema & {
						filename:     name
						huc:          hucstring
						data_version: ver
					}
				}
			}
			if list.Contains(schema.output_of, "hand") {
				schema & {
					filename:     name
					data_version: ver
				}
			}
			if list.Contains(schema.input_to, "eval") {
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

_hydroTables: #ProcessFiles & {
	filepaths: _evalpaths
	schema:    #HydroTable
}

_reachRasters: #ProcessFiles & {
	filepaths: _evalpaths
	schema:    #ReachRaster
}

_reachAttributes: #ProcessFiles & {
	filepaths: _evalpaths
	schema:    #ReachAttributes
}

_huc8Shapes: #ProcessFiles & {
	filepaths: _evalpaths
	schema:    #Huc8Shape
}

_hucBranchMaps: #ProcessFiles & {
	filepaths: _evalpaths
	schema:    #HucBranchMap
}

_vectorMasks: #ProcessFiles & {
	filepaths: _evalpaths
	schema:    #VectorMasks
}

// Output the processed files
handRems:        _handRems.output
hydroTables:     _hydroTables.output
reachRasters:    _reachRasters.output
reachAttributes: _reachAttributes.output
huc8Shapes:      _huc8Shapes.output
hucBranchMaps:   _hucBranchMaps.output
vectorMasks:     _vectorMasks.output
