package evalcat

import (
	"tool/file"
	"tool/exec"
)

#process: {
	output:  string
	outFile: string
	run: exec.Run & {
		cmd: ["cue", "export",
			"eval_schema.cue",
			"esip_paths.cue",
			"process_paths.cue",
			"-e", output]
		stdout: string
	}
	format: exec.Run & {
		cmd: ["sh", "-c", "echo '{\"\(output)\": ' && cat && echo '}'"]
		stdin:  run.stdout
		stdout: string
	}
	write: file.Create & {
		filename: outFile
		contents: format.stdout
	}
}

// Define commands for each schema
command: {
	processHandRems: #process & {
		output:  "handRems"
		outFile: "handRems.json"
	}

	processHydroTables: #process & {
		output:  "hydroTables"
		outFile: "hydroTables.json"
	}

	processReachRasters: #process & {
		output:  "reachRasters"
		outFile: "reachRasters.json"
	}

	processReachAttributes: #process & {
		output:  "reachAttributes"
		outFile: "reachAttributes.json"
	}

	processHuc8Shapes: #process & {
		output:  "huc8Shapes"
		outFile: "huc8Shapes.json"
	}

	processHucBranchMaps: #process & {
		output:  "hucBranchMaps"
		outFile: "hucBranchMaps.json"
	}

	processVectorMasks: #process & {
		output:  "vectorMasks"
		outFile: "vectorMasks.json"
	}

	// Add a command to run all processes
	processAll: {
		runAll: exec.Run & {
			cmd: [
				"sh", "-c",
				"cue cmd processHandRems && " +
				"cue cmd processHydroTables && " +
				"cue cmd processReachRasters && " +
				"cue cmd processReachAttributes && " +
				"cue cmd processHuc8Shapes && " +
				"cue cmd processHucBranchMaps && " +
				"cue cmd processVectorMasks",
			]
		}
	}

	// Add a command to combine specific JSON files
	combineResults: {
		run: exec.Run & {
			cmd: [
				"sh",
				"-c",
				"jq -s 'reduce .[] as $item ({}; . * $item)' handRems.json hydroTables.json reachRasters.json reachAttributes.json huc8Shapes.json hucBranchMaps.json vectorMasks.json",
			]
			stdout: string
		}

		write: file.Create & {
			filename: "combined_results.json"
			contents: run.stdout
		}
	}
}
