use equip/sourcetrait/gram/lib/log

# Every entry but the newest 20 moved into its old/log shard and its index.
export def main [args: record<iter: string>]: nothing -> record<kept: int, moved: int, shards: list<path>> {
    log prune $args.iter
}
