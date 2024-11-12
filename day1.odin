package aoc

import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

@(private = "file")
spelled_digits := [?]struct {
	spelled: string,
	number:  rune,
} {
	{spelled = "one", number = '1'},
	{spelled = "two", number = '2'},
	{spelled = "three", number = '3'},
	{spelled = "four", number = '4'},
	{spelled = "five", number = '5'},
	{spelled = "six", number = '6'},
	{spelled = "seven", number = '7'},
	{spelled = "eight", number = '8'},
	{spelled = "nine", number = '9'},
}

@(private = "file")
occurrence :: struct {
	number: rune,
	index:  int,
}

//https://adventofcode.com/2023/day/1
day1 :: proc(input: string) -> (part1: int, part2: int) {
	split := strings.split(input, "\n")
	part1 = day1_part1(split)
	part2 = day1_part2(split)
	return
}

@(private = "file")
day1_part1 :: proc(lines: []string) -> (result: int) {
	digits: [dynamic]rune
	for line in lines {
		for ch in line {
			switch ch {
			case '0' ..= '9':
				append(&digits, ch)
			}
		}
		result += strconv.atoi(utf8.runes_to_string({digits[0], digits[len(digits) - 1]}))
		clear(&digits)
	}
	return
}

@(private = "file")
day1_part2 :: proc(lines: []string) -> (result: int) {
	occurrences: [dynamic]occurrence
	for line in lines {
		for spelled_digit in spelled_digits {
			// find all occurrences of spelled out digits
			for i := strings.index(line, spelled_digit.spelled); i >= 0; {
				occ := occurrence {
					index  = i,
					number = spelled_digit.number,
				}
				append(&occurrences, occ)
				next_index := i + len(spelled_digit.spelled)
				if next_index >= len(line) do break
				j := strings.index(line[next_index:], spelled_digit.spelled)
				if j >= 0 {
					i += j + len(spelled_digit.spelled)
				} else do break
			}
		}

		// find actual digits
		for ch, i in line {
			switch ch {
			case '0' ..= '9':
				append(&occurrences, occurrence{index = i, number = ch})
			}
		}

		// find first and last, add them together and sum up the result
		slice.sort_by(occurrences[:], proc(i, j: occurrence) -> bool {
			return i.index < j.index
		})
		str_rep := utf8.runes_to_string({occurrences[0].number, occurrences[len(occurrences) - 1].number})
		num := strconv.atoi(str_rep)
		result += num
		clear(&occurrences)
	}
	return
}
