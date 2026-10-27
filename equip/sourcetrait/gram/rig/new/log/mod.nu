use equip/sourcetrait/gram/lib/log

# New log entries in order: each one's index item and its stub titled by rev.
export def main [data: record<logs: table<iter: string, summary: string>>]: nothing -> record<logs: table<rev: int, summary: string, file: path>> {
    mut made = []
    for entry in $data.logs {
        $made = ($made | append (log new $entry.iter $entry.summary))
    }
    { logs: $made }
}
