package aoc

import "core:math"
import "core:strings"

day8 :: proc(input: string) -> (part1: int, part2: int) {
	section_split := strings.split(input, NEWLINE + NEWLINE)
	instructions := section_split[0]
	lookup_section := strings.split(section_split[1], NEWLINE)

	// parse lookup section
	lookup: [dynamic][2]int
	temp_lookup: [dynamic][2]string
	start: int
	goal: int
	ends_with_a := make([dynamic]int, 0, len(lookup_section))
	ends_with_z := make([dynamic]bool, len(lookup_section))

	name_to_index := make(map[string]int)
	for entry, i in lookup_section {
		entry_split := strings.split(entry, " = (")
		name := entry_split[0]
		name_to_index[name] = i

		if name == "AAA" do start = i
		else if name == "ZZZ" do goal = i

		if name[2] == 'A' do append(&ends_with_a, i)
		else if name[2] == 'Z' do ends_with_z[i] = true

		left_right_split := strings.split(entry_split[1], ", ")
		left := left_right_split[0]
		right := strings.trim(left_right_split[1], ")")
		append(&temp_lookup, [2]string{left, right})
	}

	for node, i in temp_lookup {
		left := name_to_index[node[0]]
		right := name_to_index[node[1]]
		append(&lookup, [2]int{left, right})
	}

	// part1:
	current := start
	for ; current != goal; part1 += 1 {
		direction := 0 if instructions[part1 % len(instructions)] == 'L' else 1
		current = lookup[current][direction]
	}

	// part2:
	current_indices := make([dynamic]int, 0, len(lookup_section))
	append(&current_indices, ..ends_with_a[:])
	index_to_required_steps_to_z_node := make(map[int]int)

	for turn_counter := 0; len(index_to_required_steps_to_z_node) < len(current_indices); turn_counter += 1 {
		direction := 0 if instructions[turn_counter % len(instructions)] == 'L' else 1
		for i := 0; i < len(current_indices); i += 1 {
			next := lookup[current_indices[i]][direction]
			_, already_found := index_to_required_steps_to_z_node[i]
			if ends_with_z[next] && !already_found {
				index_to_required_steps_to_z_node[i] = turn_counter + 1
			}
			current_indices[i] = next
		}
	}

	result := index_to_required_steps_to_z_node[0]
	for i := 1; i < len(index_to_required_steps_to_z_node); i += 1 {
		result = math.lcm(result, index_to_required_steps_to_z_node[i])
	}
	part2 = result

	return
}
