use equip/sourcetrait/gram/lib/quote

# New quotes in order: each one's index item and its stub titled for it.
export def main [data: record<quotes: table<iter: string, quote: string, summary: string>>]: nothing -> record<quotes: table<quote: string, summary: string, file: path>> {
    mut made = []
    for entry in $data.quotes {
        $made = ($made | append (quote new $entry.iter $entry.quote $entry.summary))
    }
    { quotes: $made }
}
