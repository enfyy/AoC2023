package aoc

import "core:fmt"
import "core:time"

main :: proc() {
	fmt.println("===============================================================")
	fmt.println("|                     PART1 |             PART2 |  TIME       |")
	fmt.println("===============================================================")
	sw: time.Stopwatch
	for day, i in days {
		time.stopwatch_start(&sw)
		p1, p2 := day.fn(day.input)
		time.stopwatch_stop(&sw)
		fmt.printf(":: Day %d: %16s | %16s | %fms \n", i + 1, fmt.aprint(p1), fmt.aprint(p2), time.duration_milliseconds(time.stopwatch_duration(sw)))
		fmt.println("---------------------------------------------------------------")
		time.stopwatch_reset(&sw)
		free_all()
	}
}

Day :: struct {
	fn:    day_function,
	input: string,
}

day_function :: #type proc(_: string) -> (int, int)
days := [?]Day {
	{day1, #load("inputs/day1.txt")},
	{day2, #load("inputs/day2.txt")},
	{day3, #load("inputs/day3.txt")},
	{day4, #load("inputs/day4.txt")},
	{day5, #load("inputs/day5.txt")},
	{day6, #load("inputs/day6.txt")},
	{day7, #load("inputs/day7.txt")},
	{day8, #load("inputs/day8.txt")},
	{day9, #load("inputs/day9.txt")},
	{day10, #load("inputs/day10.txt")},
}

// This is just for quick copy pasting:
dayX :: proc(input: string) -> (part1: int, part2: int) {
	part1 = -1
	part2 = -1
	return
}

when ODIN_OS == .Windows {
	NEWLINE :: "\r\n" // why are you like this, windows...
} else {
	NEWLINE :: "\n"
}
