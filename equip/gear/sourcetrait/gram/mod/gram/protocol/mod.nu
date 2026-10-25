use ../indexed

# A protocol by name, or a table of them by a list of names.
export def main [
    iter: string
    protocol: oneof<list<string>, string>
]: [
    nothing -> oneof<
        record<
            name: string, summary: string, apply: table<on: string>, file: path
        >,
        table<
            name: string, summary: string, apply: table<on: string>, file: path
        >
    >
] {
    let single = (($protocol | describe) == 'string')
    let names = if $single { [$protocol] } else { $protocol }
    let found = (indexed entries $iter 'protocol' $names)
    if $single { $found | first } else { $found }
}
