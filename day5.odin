package aoc

import "core:slice"
import "core:strconv"
import "core:strings"

Mapping_Entry :: struct {
	source_range_start:      u64,
	range_length:            u64,
	destination_range_start: u64,
}

day5 :: proc(input: string) -> (part1: int, part2: int) {

	section_split := strings.split(input, NEWLINE + NEWLINE)
	assert(len(section_split) == 8, "the split was not size 8")

	seed_section := strings.split(section_split[0], ": ")
	seed_number_split := strings.split(seed_section[1], " ")

	maps := [][]Mapping_Entry {
		parse_map(section_split[1]),
		parse_map(section_split[2]),
		parse_map(section_split[3]),
		parse_map(section_split[4]),
		parse_map(section_split[5]),
		parse_map(section_split[6]),
		parse_map(section_split[7]),
	}

	part1_lowest_location := max(u64)
	part2_lowest_location := max(u64)
	for i := 0; i < len(seed_number_split) - 1; i += 2 {
		seed := seed_number_split[i]
		range_len := seed_number_split[i + 1]
		num, ok1 := strconv.parse_u64_of_base(seed, 10)
		len, ok2 := strconv.parse_u64_of_base(range_len, 10)
		assert(ok1 && ok2, "failed to parse seed  to u64")
		part1_lowest_location = min(part1_lowest_location, get_location_from_seed(num, maps))
		part1_lowest_location = min(part1_lowest_location, get_location_from_seed(len, maps))
		part2_lowest_location = min(part2_lowest_location, get_lowest_location_from_seed_range([2]u64{num, len}, maps))
	}

	part1 = int(part1_lowest_location)
	part2 = int(part2_lowest_location)
	return
}

parse_map :: proc(lines: string) -> []Mapping_Entry {
	result: [dynamic]Mapping_Entry
	without_title := strings.split(lines, ":" + NEWLINE)
	lines := strings.split(without_title[1], NEWLINE)
	for line in lines {
		line_split := strings.split(line, " ")
		destination_range_start, ok1 := strconv.parse_u64_of_base(line_split[0], 10)
		source_range_start, ok2 := strconv.parse_u64_of_base(line_split[1], 10)
		range_length, ok3 := strconv.parse_u64_of_base(line_split[2], 10)
		assert(ok1 && ok2 && ok3, "failed to parse a map")
		append(&result, Mapping_Entry{destination_range_start = destination_range_start, source_range_start = source_range_start, range_length = range_length})
	}

	slice.sort_by(result[:], proc(i, j: Mapping_Entry) -> bool {
		return i.source_range_start < j.source_range_start
	})

	// fill in the gaps in the ranges
	start: u64 = 0
	for entry, i in result[:] {
		if start < entry.source_range_start {
			// something needs to be before this entry
			// from start to entry start
			inject_at(&result, i, Mapping_Entry{source_range_start = start, destination_range_start = start, range_length = entry.source_range_start - start})
			start = entry.source_range_start + entry.range_length
		}
	}

	// last gap at the end
	last := result[len(result) - 1]
	start = last.source_range_start + last.range_length
	append(&result, Mapping_Entry{source_range_start = start, destination_range_start = start, range_length = max(u64) - start})

	return result[:]
}

get_location_from_seed :: proc(seed: u64, maps: [][]Mapping_Entry) -> u64 {
	current := seed
	for m in maps {
		for entry in m {
			in_range := current >= entry.source_range_start && current < entry.source_range_start + entry.range_length
			if in_range {
				current = entry.destination_range_start + (current - entry.source_range_start)
				break
			}
		}
	}
	return current
}

get_lowest_location_from_seed_range :: proc(range: Range, maps: [][]Mapping_Entry) -> u64 {
	current_level_ranges: [dynamic]Range
	append(&current_level_ranges, range)
	next_level_ranges: [dynamic]Range
	for level in maps {
		for r in current_level_ranges {
			append(&next_level_ranges, ..convert_range(r, level[:]))
		}
		clear(&current_level_ranges)
		append(&current_level_ranges, ..next_level_ranges[:])
		clear(&next_level_ranges)
	}

	result := max(u64)
	for r in current_level_ranges do result = min(result, r[0])
	return result
}

Range :: [2]u64 // index 0 is the start, index 1 is the length
convert_range :: proc(range: Range, dict: []Mapping_Entry) -> []Range {
	current_range_start := range[0]
	current_range_len := range[1]

	ready_for_next_level: [dynamic]Range
	for mapped_range in dict {
		mapped_range_end := mapped_range.source_range_start + mapped_range.range_length
		start_is_inside := current_range_start < mapped_range_end && current_range_start >= mapped_range.source_range_start
		if !start_is_inside {
			// since the ranges are sorted we can just look at the next one :: unless it would fit in the gap between this range and the next
			continue
		}
		seed_end := current_range_start + current_range_len
		end_is_inside := seed_end < mapped_range_end

		if end_is_inside {
			// its fully contained, meaning the entire range can be converted to a range for the next level
			next_level_range_start := mapped_range.destination_range_start + (current_range_start - mapped_range.source_range_start)
			next_level_range_len := seed_end - current_range_start
			append(&ready_for_next_level, [2]u64{next_level_range_start, next_level_range_len})
			current_range_len = 0
			break
		} else {
			// this needs to go through the next levels of the maps:
			next_level_range_start := mapped_range.destination_range_start + (current_range_start - mapped_range.source_range_start)
			next_level_range_len := mapped_range_end - current_range_start
			append(&ready_for_next_level, [2]u64{next_level_range_start, next_level_range_len})

			// this still needs to go through this dict and its ranges and potentially be split again
			current_range_len -= next_level_range_len
			current_range_start = mapped_range_end
		}
	}
	assert(current_range_len <= 0, "we shouldve split up our range entirely by this point")
	return ready_for_next_level[:]

}
