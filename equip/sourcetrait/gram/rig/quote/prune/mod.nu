use equip/sourcetrait/gram/lib/quote

# Every uncited top quote and its subtree moved into the iter's old/quote/.
export def main [data: record<iter: string>]: nothing -> record<kept: int, moved: int, quotes: list<string>> {
    quote prune $data.iter
}
