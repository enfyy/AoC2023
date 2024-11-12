package aoc

import "core:fmt"
import "core:math"
import "core:strings"

day10 :: proc(input: string) -> (part1: int, part2: int) {
	return 0, 0 // THIS IS WHERE I STOPPED, SO IM P SURE THIS SOLUTION IS INCORRECT.
	// part 1
	grid := strings.split(input, NEWLINE)
	start_tile, found := find_start(grid)
	assert(found, "Start pipe not found")
	current_tile, previous_direction, found_next := find_next(.North, start_tile, grid)
	assert(found_next, "No pipe connects to start")
	path_length := 0
	belongs_to_path := make([][]bool, len(grid))
	for _, i in belongs_to_path do belongs_to_path[i] = make([]bool, len(grid[0]))

	start_dir_1 := previous_direction
	for (current_tile[0] != start_tile[0] || current_tile[1] != start_tile[1]) && found_next {
		path_length += 1
		belongs_to_path[current_tile[1]][current_tile[0]] = true
		current_tile, previous_direction, found_next = find_next(previous_direction, current_tile, grid)
	}
	part1 = int(math.ceil(f32(path_length) / 2))

	start_dir_2 := opposite_dir(previous_direction)
	hidden_by_start := symbol_from_connection({start_dir_1, start_dir_2})
	for row, y in grid {
		enclosed := false
		for _, x in row {
			current := row[x]
			if y == start_tile[1] && x == start_tile[0] do current = hidden_by_start
			in_path := belongs_to_path[y][x]
			collision := in_path && (current == '|' || current == 'L' || current == 'J')
			if collision {
				enclosed = !enclosed
			} else if !in_path && enclosed {
				part2 += 1
			}
		}
	}

	return
}

Direction :: enum {
	North,
	East,
	South,
	West,
}

Tile :: [2]int

Direction_Set :: distinct bit_set[Direction]

direction_vectors := [Direction][2]int {
	.North = {0, -1},
	.East = {1, 0},
	.South = {0, 1},
	.West = {-1, 0},
}

find_start :: proc(grid: []string) -> (t: Tile, found: bool) {
	for row, y in grid {
		for ch, x in row {
			if ch == 'S' {
				return Tile{x, y}, true
			}
		}
	}
	return
}

find_next :: proc(came_from: Direction, tile: Tile, grid: []string) -> (destination: Tile, direction: Direction, found: bool) {
	symbol := grid[tile[1]][tile[0]]
	possible_next_directions := connection_from_symbol(symbol)
	if symbol != 'S' do possible_next_directions -= {opposite_dir(came_from)} // we came from nowhere at the start
	for dir in Direction {
		if dir not_in possible_next_directions do continue
		vec := direction_vectors[dir]
		next_pos := tile + vec
		next_pos_x, next_pos_y := next_pos[0], next_pos[1]
		in_bounds := next_pos_x >= 0 && next_pos_x < len(grid[0]) && next_pos_y >= 0 && next_pos_y < len(grid)
		if !in_bounds do continue
		destination_symbol := grid[next_pos_y][next_pos_x]

		if symbol == 'S' && destination_symbol != '.' || is_connected(symbol, destination_symbol, dir, grid) {
			return next_pos, dir, true
		}
	}
	return
}

opposite_dir :: proc(dir: Direction) -> Direction {
	if dir == .North do return .South
	if dir == .East do return .West
	if dir == .South do return .North
	return .East
}

is_connected :: proc(from, to: u8, dir: Direction, grid: []string) -> bool {
	start := connection_from_symbol(from)
	destination := connection_from_symbol(to)
	return dir in start && opposite_dir(dir) in destination
}

connection_from_symbol :: proc(symbol: u8) -> Direction_Set {
	switch symbol {
	case 'S':
		return {.North, .East, .South, .West}

	case '|':
		return {.North, .South}

	case '-':
		return {.East, .West}

	case 'L':
		return {.North, .East}

	case 'J':
		return {.North, .West}

	case '7':
		return {.South, .West}

	case 'F':
		return {.South, .East}
	}
	return {}
}

symbol_from_connection :: proc(set: Direction_Set) -> u8 {
	if .North in set && .South in set do return '|'
	if .East in set && .West in set do return '-'
	if .North in set && .East in set do return 'L'
	if .North in set && .West in set do return 'J'
	if .South in set && .West in set do return '7'
	if .South in set && .East in set do return 'F'
	panic("wtf are you doing")
}
