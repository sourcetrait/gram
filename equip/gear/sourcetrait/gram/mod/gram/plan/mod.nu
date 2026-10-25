use ../common
use ../repo

# A campaign's index entry from whichever pool lists it, with its pool and file.
export def campaign [
    iter: string
    campaign: string
]: [
    nothing -> record<
        campaign: string, pool: string, summary: string, stage: string,
        tasks: table<task: string, summary: string>, file: path
    >
] {
    let found = (find_campaign $iter $campaign)
    let file = ($found.iter_dir | path join 'plan' $found.pool $"($campaign).md")
    common require_files $found.repo_dir [$file]
    {
        campaign: $found.item.campaign
        pool: $found.pool
        summary: $found.item.summary
        stage: ($found.item.stage? | default 'criteria')
        tasks: ($found.item.tasks? | default [])
        file: $file
    }
}

# A task's index entry by its plan namepath, with its campaign, pool, and file.
export def task [
    iter: string
    task: string
]: [
    nothing -> record<
        task: string, campaign: string, pool: string, summary: string,
        stage: string, tasks: table<task: string, summary: string>,
        file: oneof<nothing, path>
    >
] {
    let names = (task_names $task)
    let found = (find_campaign $iter ($names | first))
    let entry = (walk_tasks $found.item $names)
    let file = (
        $found.iter_dir
        | path join 'plan' $found.pool ...($names | drop 1) $"($names | last).md"
    )
    let held = (($found.repo_dir | path join $file | path type) == 'file')
    {
        task: $entry.task
        campaign: $found.item.campaign
        pool: $found.pool
        summary: $entry.summary
        stage: ($entry.stage? | default 'criteria')
        tasks: ($entry.tasks? | default [])
        file: (if $held { $file } else { null })
    }
}

# A campaign scaffolded into a pool at criteria, returned as campaign returns it.
export def "new campaign" [
    iter: string
    pool: string
    campaign: string
    summary: string
]: [
    nothing -> record<
        campaign: string, pool: string, summary: string, stage: string,
        tasks: table<task: string, summary: string>, file: path
    >
] {
    common check_summary $summary 'plan'
    check_name $campaign 'campaign'
    if not ($pool =~ '^[a-z]+$') {
        error make --unspanned $"not a pool name: '($pool)'"
    }
    let repo_dir = (repo repo_dir)
    let iter_dir = (common repo_dir_iter $repo_dir $iter)
    let index_file = ($iter_dir | path join 'plan' $"($pool).yaml")
    if ($repo_dir | path join $index_file | path type) != 'file' {
        error make --unspanned $"no pool ($pool) in ($iter_dir | path join 'plan')"
    }
    let listed = (list_campaign $repo_dir $iter_dir $campaign)
    if ($listed | is-not-empty) {
        error make --unspanned (
            $"campaign ($campaign) already listed in ($listed | get pool | str join ', ')"
        )
    }
    let completed = (list_old_campaign $repo_dir $iter_dir $campaign)
    if ($completed | is-not-empty) {
        error make --unspanned (
            $"campaign ($campaign) already completed in ($completed | str join ', ')"
        )
    }
    let file = ($iter_dir | path join 'plan' $pool $"($campaign).md")
    if ($repo_dir | path join $file | path type) != null {
        error make --unspanned $"($file) already exists"
    }
    let items = (read_pool $repo_dir $index_file)
    let entry = {campaign: $campaign, summary: $summary, stage: 'criteria'}
    let updated = ($items | append [$entry])
    mkdir ($repo_dir | path join $iter_dir 'plan' $pool)
    $"# CAMPAIGN: ($campaign)(char nl)" | save ($repo_dir | path join $file)
    write_pool $repo_dir $index_file $updated
    campaign $iter $campaign
}

# A task scaffolded under its plan namepath at criteria, returned as task does.
export def "new task" [
    iter: string
    task: string
    summary: string
]: [
    nothing -> record<
        task: string, campaign: string, pool: string, summary: string,
        stage: string, tasks: table<task: string, summary: string>,
        file: oneof<nothing, path>
    >
] {
    common check_summary $summary 'plan'
    let names = (task_names $task)
    let leaf = ($names | last)
    if $leaf == ($names | drop 1 | last) {
        error make --unspanned $"task ($leaf) cannot share its parent's name: ($task)"
    }
    let found = (find_campaign $iter ($names | first))
    let parent = (walk_tasks $found.item ($names | drop 1))
    let siblings = ($parent.tasks? | default [])
    if ($siblings | any {|sibling| ($sibling | get -o task) == $leaf }) {
        let under = ($names | drop 1 | str join '/')
        error make --unspanned $"task ($leaf) already under ($under)"
    }
    let file = (
        $found.iter_dir
        | path join 'plan' $found.pool ...($names | drop 1) $"($leaf).md"
    )
    if ($found.repo_dir | path join $file | path type) != null {
        error make --unspanned $"($file) already exists"
    }
    let index_file = ($found.iter_dir | path join 'plan' $"($found.pool).yaml")
    let items = (read_pool $found.repo_dir $index_file)
    let entry = {task: $leaf, summary: $summary, stage: 'criteria'}
    let updated = (add_task $items 'campaign' ($names | drop 1) $entry)
    mkdir ($found.repo_dir | path join $file | path dirname)
    $"# TASK: ($leaf)(char nl)" | save ($found.repo_dir | path join $file)
    write_pool $found.repo_dir $index_file $updated
    task $iter $task
}

# A plan namepath split into its campaign and tasks, each part a plain name.
def task_names [
    task: string
]: nothing -> list<string> {
    let names = ($task | split row '/')
    let bad = ($names | where {|name| not ($name =~ '^[A-Za-z0-9_-]+$') })
    if (($names | length) < 2) or ($bad | is-not-empty) {
        error make --unspanned $"not a task namepath, campaign then task: '($task)'"
    }
    $names
}

# A name refused unless it is letters, digits, `_`, and `-` alone.
def check_name [
    name: string
    kind: string
] {
    if not ($name =~ '^[A-Za-z0-9_-]+$') {
        error make --unspanned $"not a ($kind) name: '($name)'"
    }
}

# The entry a namepath reaches from its campaign, each step listed once.
def walk_tasks [
    item: record
    names: list<string>
]: nothing -> record {
    mut entry = $item
    mut walked = [($names | first)]
    for name in ($names | skip 1) {
        let children = ($entry.tasks? | default [])
        let matches = ($children | where {|child| ($child | get -o task) == $name })
        let under = ($walked | str join '/')
        if ($matches | is-empty) {
            error make --unspanned $"no task ($name) under ($under)"
        }
        if ($matches | length) > 1 {
            error make --unspanned $"task ($name) listed twice under ($under)"
        }
        $entry = ($matches | first)
        $walked = ($walked | append $name)
    }
    $entry
}

# The items with a task added under the entry the names reach, its key first.
def add_task [
    items: list<any>
    key: string
    names: list<string>
    entry: record
]: nothing -> list<any> {
    $items | each {|item|
        if ($item | get -o $key) != ($names | first) {
            $item
        } else if ($names | length) == 1 {
            $item | upsert tasks (($item | get -o tasks | default []) | append [$entry])
        } else {
            $item | update tasks (add_task ($item | get tasks) 'task' ($names | skip 1) $entry)
        }
    }
}

# A pool's items, refused unless its file is exactly what to yaml writes back.
def read_pool [
    repo_dir: directory
    index_file: path
]: nothing -> list<any> {
    let text = (open --raw ($repo_dir | path join $index_file) | decode)
    let items = ($text | from yaml | default [])
    if ($items | to yaml) != $text {
        error make --unspanned (
            $"($index_file) is not as to yaml writes it; rewriting would reformat it"
        )
    }
    $items
}

# A pool's items written as to yaml writes them, checked to read back equal.
def write_pool [
    repo_dir: directory
    index_file: path
    items: list<any>
] {
    let text = ($items | to yaml)
    if ($text | from yaml) != $items {
        error make --unspanned $"($index_file) would not read back as written"
    }
    $text | save --force ($repo_dir | path join $index_file)
}

# The pools listing a campaign, each with its entry; empty when none does.
def list_campaign [
    repo_dir: directory
    iter_dir: path
    campaign: string
]: nothing -> list<record> {
    glob ($repo_dir | path join $iter_dir 'plan' '*.yaml')
    | each {|path| $path | path basename }
    | sort
    | each {|pool_file|
        let pool = ($pool_file | str replace --regex '\.yaml$' '')
        let index_file = ($iter_dir | path join 'plan' $pool_file)
        common read_index $repo_dir $index_file
        | where {|item| ($item | get -o campaign) == $campaign }
        | each {|item| {pool: $pool, item: $item} }
    }
    | flatten
}

# The old/ pool directories holding a completed campaign; empty when none does.
def list_old_campaign [
    repo_dir: directory
    iter_dir: path
    campaign: string
]: nothing -> list<path> {
    ['plan' 'task']
    | each {|kind|
        let kind_dir = ($iter_dir | path join 'old' $kind)
        glob ($repo_dir | path join $kind_dir '*' $"($campaign).{md,yaml}")
        | each {|path| $kind_dir | path join ($path | path dirname | path basename) }
    }
    | flatten
    | uniq
    | sort
}

# A campaign's entry and pool from the iter's pools, refused unless listed once.
def find_campaign [
    iter: string
    campaign: string
]: nothing -> record {
    check_name $campaign 'campaign'
    let repo_dir = (repo repo_dir)
    let iter_dir = (common repo_dir_iter $repo_dir $iter)
    let listed = (list_campaign $repo_dir $iter_dir $campaign)
    if ($listed | is-empty) {
        error make --unspanned (
            $"no campaign ($campaign) in the pools of ($iter_dir | path join 'plan')"
        )
    }
    if ($listed | length) > 1 {
        error make --unspanned (
            $"campaign ($campaign) listed in ($listed | get pool | str join ', ')"
        )
    }
    let found = ($listed | first)
    {repo_dir: $repo_dir, iter_dir: $iter_dir, pool: $found.pool, item: $found.item}
}
