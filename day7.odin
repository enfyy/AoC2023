package aoc

import "core:slice"
import "core:strconv"
import "core:strings"

Card :: enum {
	Two,
	Three,
	Four,
	Five,
	Six,
	Seven,
	Eight,
	Nine,
	T,
	J,
	Q,
	K,
	A,
}

Hand :: struct {
	cards: [5]Card,
	bid:   int,
}

// This is just for quick copy pasting:
day7 :: proc(input: string) -> (part1: int, part2: int) {
	lines := strings.split(input, "\n")
	hands: [dynamic]Hand
	for line in lines {
		line_split := strings.split(line, " ")
		cards := line_split[0]
		bid := line_split[1]
		append(&hands, Hand{cards = parse_cards(strings.trim_space(cards)), bid = strconv.atoi(bid)})
	}

	slice.sort_by(hands[:], compare_hands_without_joker)
	for hand, i in hands {
		rank := i + 1
		part1 += rank * hand.bid
	}

	slice.sort_by(hands[:], compare_hands_with_joker)
	for hand, i in hands {
		rank := i + 1
		//fmt.println(hand.cards, "is rank", rank)
		part2 += rank * hand.bid
	}

	return
}

parse_cards :: proc(card_string: string) -> [5]Card {
	assert(len(card_string) == 5, "expected 5 cards")
	result: [5]Card
	for c, i in card_string {
		switch c {
		case '2':
			result[i] = .Two
		case '3':
			result[i] = .Three
		case '4':
			result[i] = .Four
		case '5':
			result[i] = .Five
		case '6':
			result[i] = .Six
		case '7':
			result[i] = .Seven
		case '8':
			result[i] = .Eight
		case '9':
			result[i] = .Nine
		case 'T':
			result[i] = .T
		case 'J':
			result[i] = .J
		case 'Q':
			result[i] = .Q
		case 'K':
			result[i] = .K
		case 'A':
			result[i] = .A
		}
	}
	return result
}

compare_hands_with_joker :: proc(i, j: Hand) -> bool {
	return compare_hands(i, j, true)
}

compare_hands_without_joker :: proc(i, j: Hand) -> bool {
	return compare_hands(i, j, false)
}

// procedure to test whether two values are ordered "i < j"
compare_hands :: proc(i, j: Hand, treat_as_joker := false) -> bool {
	card_counts_i: [Card]int
	card_counts_j: [Card]int

	for x := 0; x < 5; x += 1 {
		card_counts_i[i.cards[x]] += 1
		card_counts_j[j.cards[x]] += 1
	}

	// five of a kind
	cmp_i := is_x_of_a_kind(5, card_counts_i, treat_as_joker)
	cmp_j := is_x_of_a_kind(5, card_counts_j, treat_as_joker)
	if !cmp_i && cmp_j do return true
	if cmp_i && !cmp_j do return false
	if cmp_i && cmp_j do return compare_first_higher_card(i, j, treat_as_joker)

	// four of a kind
	cmp_i = is_x_of_a_kind(4, card_counts_i, treat_as_joker)
	cmp_j = is_x_of_a_kind(4, card_counts_j, treat_as_joker)
	if !cmp_i && cmp_j do return true
	if cmp_i && !cmp_j do return false
	if cmp_i && cmp_j do return compare_first_higher_card(i, j, treat_as_joker)

	// full house
	cmp_i = is_full_house(card_counts_i, treat_as_joker)
	cmp_j = is_full_house(card_counts_j, treat_as_joker)
	if !cmp_i && cmp_j do return true
	if cmp_i && !cmp_j do return false
	if cmp_i && cmp_j do return compare_first_higher_card(i, j, treat_as_joker)

	// three of a kind
	cmp_i = is_x_of_a_kind(3, card_counts_i, treat_as_joker)
	cmp_j = is_x_of_a_kind(3, card_counts_j, treat_as_joker)
	if !cmp_i && cmp_j do return true
	if cmp_i && !cmp_j do return false
	if cmp_i && cmp_j do return compare_first_higher_card(i, j, treat_as_joker)

	i_pair_count := count_pairs(card_counts_i, treat_as_joker)
	j_pair_count := count_pairs(card_counts_j, treat_as_joker)

	// two pair
	cmp_i = i_pair_count == 2
	cmp_j = j_pair_count == 2
	if !cmp_i && cmp_j do return true
	if cmp_i && !cmp_j do return false
	if cmp_i && cmp_j do return compare_first_higher_card(i, j, treat_as_joker)

	// one pair
	cmp_i = i_pair_count == 1
	cmp_j = j_pair_count == 1
	if !cmp_i && cmp_j do return true
	if cmp_i && !cmp_j do return false
	if cmp_i && cmp_j do return compare_first_higher_card(i, j, treat_as_joker)

	return compare_first_higher_card(i, j, treat_as_joker)
}

// procedure to test whether two values are ordered "i < j"
compare_first_higher_card :: proc(i, j: Hand, with_joker := false) -> bool {
	for x := 0; x < 5; x += 1 {
		val_i := int(i.cards[x])
		val_j := int(j.cards[x])
		if with_joker {
			if i.cards[x] == .J do val_i = -1
			if j.cards[x] == .J do val_j = -1
		}

		if val_i != val_j {
			return val_i < val_j
		}
	}
	return false // they must be identical?
}

is_x_of_a_kind :: proc(x: int, counts: [Card]int, with_joker := false) -> bool {
	for count, card in counts {
		if with_joker {
			joker_count := counts[.J]
			if card == .J {
				if joker_count == x do return true
			} else {
				if count + joker_count == x do return true
			}
		} else {
			if count == x do return true
		}
	}
	return false
}

is_full_house :: proc(counts: [Card]int, with_joker := false) -> bool {
	joker_count := counts[.J]

	three_counts: int
	two_counts: int
	one_counts: int
	for count, card in counts {
		if with_joker && joker_count > 0 {
			if card == .J do continue // we count jokers seperately
			if count == 1 do one_counts += 1
			if count == 2 do two_counts += 1
			if count == 3 do three_counts += 1
		} else {
			if count == 2 do two_counts += 1
			if count == 3 do three_counts += 1
		}
	}

	if with_joker && joker_count > 0 {
		switch {
		case three_counts == 1 && one_counts == 1 && joker_count == 1:
			return true
		case two_counts == 2 && joker_count == 1:
			return true
		case two_counts == 1 && one_counts == 1 && joker_count == 2:
			return true
		case one_counts == 2 && joker_count == 3:
			return true
		}
		return false
	} else {
		return three_counts == 1 && two_counts == 1
	}
}

count_pairs :: proc(counts: [Card]int, with_joker := false) -> int {
	joker_count := counts[.J]
	jokers_available := joker_count
	pair_count := 0
	for count, card in counts {
		if with_joker && joker_count > 0 {
			if count == 2 {
				pair_count += 1
				if card == .J do jokers_available -= 2
			} else if count == 1 && jokers_available > 0 {
				pair_count += 1
				jokers_available -= 1
			}
		} else {
			if count == 2 do pair_count += 1
		}
	}
	return pair_count
}
