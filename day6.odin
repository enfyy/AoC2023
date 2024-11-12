package aoc

import "core:strconv"
import "core:strings"

day6 :: proc(input: string) -> (part1: int, part2: int) {
	// parse:
	lines := strings.split(input, "\n")
	timings_split := strings.split(lines[0], " ")
	distances_split := strings.split(lines[1], " ")
	timings: [dynamic]int
	record_distances: [dynamic]int
	for i := 1; i < max(len(timings_split), len(distances_split)); i += 1 {
		if i < len(timings_split) && timings_split[i] != "" do append(&timings, strconv.atoi(strings.trim_space(timings_split[i])))
		if i < len(distances_split) && distances_split[i] != "" do append(&record_distances, strconv.atoi(strings.trim_space(distances_split[i])))
	}
	time_ignored_spaces, _ := strings.replace_all(strings.split(lines[0], ":")[1], " ", "")
	record_ignored_spaces, _ := strings.replace_all(strings.split(lines[1], ":")[1], " ", "")
	part2_time := strconv.atoi(time_ignored_spaces)
	part2_record := strconv.atoi(record_ignored_spaces)

	assert(len(timings) == len(record_distances), "they should have the same length")
	times := timings[:]
	distances := record_distances[:]

	//part 1:
	for i := 0; i < len(times); i += 1 {
		total_time := times[i]
		record_to_beat := distances[i]
		ways_to_beat_the_record := calculate_ways_to_beat_the_record_brute_force(total_time, record_to_beat)
		if part1 == 0 {
			part1 = ways_to_beat_the_record
		} else {
			part1 *= ways_to_beat_the_record
		}
	}

	//part 2:
	part2 = calculate_ways_to_beat_the_record_brute_force(part2_time, part2_record)

	return
}

calculate_ways_to_beat_the_record_brute_force :: proc(total_time, record_to_beat: int) -> int {
	ways_to_beat_the_record := 0
	for button_hold_time := 0; button_hold_time < total_time; button_hold_time += 1 {
		mmps := button_hold_time
		travel_time := total_time - button_hold_time
		travel_distance := travel_time * mmps
		if travel_distance > record_to_beat {
			//fmt.println("we beat the record distance of", record_to_beat, "by holding the button down for", button_hold_time, "milliseconds and thus travelling a distance of", travel_distance)
			ways_to_beat_the_record += 1
		}
	}

	//fmt.println("there are", ways_to_beat_the_record, "ways to beat the record of", record_to_beat, "millimeters in", total_time, "milliseconds")
	return ways_to_beat_the_record
}
