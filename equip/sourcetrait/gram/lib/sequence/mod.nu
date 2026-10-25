use ../indexed

# A sequence by name, or a table of them by a list of names.
export def main [
    iter: string
    sequence: oneof<list<string>, string>
]: [
    nothing -> oneof<
        record<name: string, summary: string, file: path>,
        table<name: string, summary: string, file: path>
    >
] {
    let single = (($sequence | describe) == 'string')
    let names = if $single { [$sequence] } else { $sequence }
    let found = (indexed entries $iter 'sequence' $names | each {|entry|
        {name: $entry.name, summary: $entry.summary, file: $entry.file}
    })
    if $single { $found | first } else { $found }
}
