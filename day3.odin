package aoc

import "core:strconv"
import "core:strings"
import "core:unicode"

Number :: struct {
	num:         int,
	start_index: int,
	line_index:  int,
	len:         int,
}

day3 :: proc(input: string) -> (part1: int, part2: int) {
	lines := strings.split(input, "\n")
	bounds := [2]int{len(lines[0]) - 1, len(lines)}
	gear_coordinates_to_numbers := make(map[[2]int][dynamic]int)

	// gather potential part numbers
	nums: [dynamic]Number
	for line, y in lines {
		from := -1
		for char, x in line {
			if from == -1 {
				if unicode.is_digit(char) {
					from = x
				}
			} else {
				if !unicode.is_digit(char) {
					n := line[from:x]
					append(&nums, Number{len = len(n), num = strconv.atoi(n), start_index = from, line_index = y})
					from = -1
				}
			}
		}
	}

	for num in nums {
		is_part_numer: bool
		for neighbour in num_get_neighbour_indices(num, bounds) {
			neighbour_char := lines[neighbour[1]][neighbour[0]]

			if neighbour_char != '.' {
				if neighbour_char == '*' {
					list := gear_coordinates_to_numbers[[2]int{neighbour[0], neighbour[1]}]
					if list == nil {
						list = make([dynamic]int, 0, 12)
					}
					append(&list, num.num)
					gear_coordinates_to_numbers[[2]int{neighbour[0], neighbour[1]}] = list
				}

				is_part_numer = true
				break
			}
		}

		if is_part_numer do part1 += num.num
	}

	for _, numbers in gear_coordinates_to_numbers {
		if len(numbers) == 2 {
			part2 += numbers[0] * numbers[1]
		}
	}
	return
}

num_get_neighbour_indices :: proc(num: Number, bounds: [2]int) -> [][2]int {
	indices := make([dynamic][2]int, 0, 6 + (2 * num.len))
	in_bounds_left := num.start_index - 1 >= 0
	in_bounds_top := num.line_index > 0
	in_bounds_right := num.start_index + num.len < bounds[0]
	in_bounds_bot := num.line_index + 1 < bounds[1] - 1

	// .xxx.
	// .000.
	// .....
	if in_bounds_top do for i := 0; i < num.len; i += 1 do append(&indices, [2]int{num.start_index + i, num.line_index - 1})

	// .....
	// .000.
	// .xxx.
	if in_bounds_bot do for i := 0; i < num.len; i += 1 do append(&indices, [2]int{num.start_index + i, num.line_index + 1})

	if in_bounds_left {
		// x....
		// .000.
		// .....
		if in_bounds_top do append(&indices, [2]int{num.start_index - 1, num.line_index - 1})

		// .....
		// x000.
		// .....
		append(&indices, [2]int{num.start_index - 1, num.line_index})

		// .....
		// .000.
		// x....
		if in_bounds_bot do append(&indices, [2]int{num.start_index - 1, num.line_index + 1})
	}

	if in_bounds_right {
		// ....x
		// .000.
		// .....
		if in_bounds_top do append(&indices, [2]int{num.start_index + num.len, num.line_index - 1})

		// .....
		// .000x
		// .....
		append(&indices, [2]int{num.start_index + num.len, num.line_index})

		// .....
		// .000.
		// ....x
		if in_bounds_bot do append(&indices, [2]int{num.start_index + num.len, num.line_index + 1})
	}

	return indices[:]
}
