package aoc

import "core:strconv"
import "core:strings"

@(private = "file")
max_rgb :: [3]int{12, 13, 14}

//https://adventofcode.com/2023/day/2
day2 :: proc(input: string) -> (part1: int, part2: int) {
	split := strings.split(input, "\n")
	for line in split {
		game_split := strings.split(line, ":")
		id := to_int(strings.split(game_split[0], " ")[1])
		rounds_split := strings.split(game_split[1], ";")
		game_rgb_max := [3]int{}
		for round in rounds_split {

			color_split := strings.split(round, ",")
			for grab in color_split {
				switch {
				case strings.contains(grab, "red"):
					count := to_int(strings.split(grab, "red")[0])
					game_rgb_max[0] = max(count, game_rgb_max[0])

				case strings.contains(grab, "green"):
					count := to_int(strings.split(grab, "green")[0])
					game_rgb_max[1] = max(count, game_rgb_max[1])

				case strings.contains(grab, "blue"):
					count := to_int(strings.split(grab, "blue")[0])
					game_rgb_max[2] = max(count, game_rgb_max[2])
				}
			}
		}
		possible := game_rgb_max[0] <= max_rgb[0] && game_rgb_max[1] <= max_rgb[1] && game_rgb_max[2] <= max_rgb[2]
		if possible do part1 += id
		part2 += game_rgb_max[0] * game_rgb_max[1] * game_rgb_max[2]
	}

	return
}

@(private = "file")
to_int :: proc(s: string) -> int {
	return strconv.atoi(strings.trim_space(s))
}
