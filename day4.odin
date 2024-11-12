package aoc

import "core:strings"
import "core:strconv"

Card_Numbers :: bit_set[0..=99]

day4 :: proc(input: string) -> (part1: int, part2: int) {
	lines := strings.split(input, "\n")
    card_instances_count:= make([dynamic]int, len(lines)+1)
    for i:=1; i < len(card_instances_count); i+=1 do card_instances_count[i] = 1

    for line in lines {
        card_points := 0
        winning_set: Card_Numbers
        my_set: Card_Numbers

        numbers_split:= strings.split(line, ":")
        current_card_id := strconv.atoi(strings.trim_space(strings.split(numbers_split[0], "Card")[1]))
        middle_split := strings.split(numbers_split[1], "|")
        winning_split := strings.split(middle_split[0], " ") 
        my_split := strings.split(middle_split[1], " ")

        for num in winning_split {
            if num == "" do continue
            winning_set += {strconv.atoi(strings.trim_space(num))}
        }

        winning_card_count := 0
        for num in my_split {
            if num == "" do continue
            if strconv.atoi(strings.trim_space(num)) in winning_set {
                card_points = 1 if card_points == 0 else card_points*2
                winning_card_count+=1
            }
        }

        part1 += card_points
        for i:=0; i < card_instances_count[current_card_id]; i+=1 {
            for j:=1; j <= winning_card_count; j+=1 {
                copied_card_id := current_card_id + j
                card_instances_count[copied_card_id] += 1
            }
        }
    }
    for count in card_instances_count do part2 += count
    return
}