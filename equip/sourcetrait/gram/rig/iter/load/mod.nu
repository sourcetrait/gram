use equip/sourcetrait/gram/lib/iter

# An iter's boot files as text in GramBoot's order, its bootstrap last, one page.
export def main [data: record<iter: string, page: int>]: nothing -> record<page: int, remaining: int, content: string> {
    iter load $data.iter $data.page
}
