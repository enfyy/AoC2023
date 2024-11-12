package aoc

import "core:fmt"
import "core:strconv"
import "core:strings"

day9 :: proc(input: string) -> (part1: int, part2: int) {
	lines := strings.split(input, NEWLINE)
    difference_sequences: [dynamic][]int
	for line in lines {
		starting_seq := parse_sequence(line)
		diff_seq := calculate_difference_sequence(starting_seq)
		append(&difference_sequences, starting_seq, diff_seq)

		for !is_all_zeros(diff_seq) {
			diff_seq = calculate_difference_sequence(diff_seq)
			append(&difference_sequences, diff_seq)
		}

        part1 += extrapolate_left(difference_sequences[:])
        part2 += extrapolate_right(difference_sequences[:])
        clear(&difference_sequences)
	}

	return
}

parse_sequence :: proc(line: string) -> []int {
	seq: [dynamic]int
	num_strings := strings.split(line, " ")
	for num_str in num_strings {
		append(&seq, strconv.atoi(num_str))
	}
	return seq[:]
}

calculate_difference_sequence :: proc(nums: []int) -> []int {
	seq: [dynamic]int
	for i := 0; i < len(nums) - 1; i += 1 {
		l := nums[i]
		r := nums[i + 1]
		append(&seq, r - l)
	}
	return seq[:]
}

is_all_zeros :: proc(nums: []int) -> bool {
	result := true
	for n in nums {
		if n != 0 {
			result = false
			break
		}
	}
	return result
}

extrapolate_left :: proc(sequences: [][]int) -> int {
    val := 0
    #reverse for seq in sequences[:len(sequences)-1] {
        val = seq[len(seq)-1] + val
    }
	return val
}

extrapolate_right :: proc(sequences: [][]int) -> int {
    val := 0
    #reverse for seq in sequences[:len(sequences)-1] {
        val = seq[0] - val
    }
	return val
}
