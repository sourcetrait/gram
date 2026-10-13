# GOVERNANCE
> REIN HUMAN
> DEF GramGov
> BEGIN GOV

## GRAMMAR

### TERMINOLOGY
> DEF GramTerminology

SourceTrait Grammar is a framework & toolkit for AI agent instruction,
organization, and operation.

GrammarBox is a customized Podman container image based on Fedora Toolbx that
standardizes some system configuration and $HOME layout. It builds upon the
uenv and pwrusr directory specifications.

Gram is the standard flagship AI instruction set; this governance.
It is also the term used to identify an agent adhering to it.

### REIN
> DEF GramRein

The concept of rein serves to explicitly designate authority and
resposibility between human and AI.

If something is under human rein, it is not to be mutated by AI and is to be
adhered to.

Where conflicts arise due to rein, stop and query the user.

### ENV
> DEF GramEnv

UENV standardizes explicit XDG environment configuration and establishes the
basic cross-platform $HOME/.sys structure.

PWRUSR extends UENV with more depth for interactive system users.

~/.sys is the designated path for software internals.
~/.sys/of is for internals that don't adhere well to XDG.

Relevant combined UENV and PWRUSR structure:
```
~/
 .config/ XDG_CONFIG_HOME
 .ssh/key/ai/{ai}/ SSH keys
 .sys/
  cache/ XDG_CACHE_HOME
  data/ XDG_DATA_HOME
  state/ XDG_STATE_HOME
  of/
  srv/
   git/{author}/{repo}/ Bare repositories for relay between host system and container
  local/[bin etc lib libexec src opt doc share] Installation
  adhoc/ Manual installation, same subdirs as local/
  mnt/ User mounts; FUSE, net, etc
 ai/{ai}/ AI Repository
 proj/{author}/{repo}/ Eg, first-party project repository, remoted to ~/.sys/srv/git/..
 repo/{provider}/{author}/{repo}/ Eg, Third-party repository (read-only)
 tmp/ai/{ai}/ Scratch / temporary
 down/ai/{ai}/ Downloads
 bak/ai/{ai}/ Backups
 data/ai/{ai}/ Heavy data / binaries repository (Git LFS and/or Rsync)
```

### STRING
> DEF GramStr

ASCII.
Emphasis (italics bold etc) is avoided. Em-dashes are not used.
Self-coined or highly contextualized terms are avoided.
Structure and content form real value.

Generally, snake_case is used for tokens, paths, variables, functions, etc.

Fields acting as a summary are 80 characters max without a period at the end.

### CONCEPT NAME
> DEF ConceptName ConceptNames ConceptNamed

WikiWords are used for naming cross-referencable concepts.
Descriptive. Normally 2-4 words.
Categorical terms are avoided (eg Slice Task etc).


### GRAM REF
> DEF GramRef GramRefs

In the format of: {a:b:c},{a:b:c:N},{a:b::c},{alias}

Components and aliases are either snake_case or ConceptNames.
Numerics (N) can refer to lines, revisions, etc.
`::` Indicates an inner content component

Well-known components (some may be combined, using '::'):
- mem:{ConceptName}:{SubConcept}:..
- iter:{topic}:{subtopic}
- info:{ConceptName}:{SubConcept}::H{header}
- journal:{rev}
- quote:{name}
- plan:{campaign}:{task}
- op:seq:{sequence} op:proto:{protocol}
- gov:{header}

### REF BLOCK
> DEF GramRefBlock RefBlock

Markdown files that make use of specific GramRefs more than once use a RefBlock
to efficiently re-use them.

An H2 titled 'REF' is appended to the end of the file.
Directly under the H2 is a line-separated KV list of `{ref_alias} {ref}`.

#### EXAMPLE: REF BLOCK
```md
# This is a title

Related ({some_alias}) and direct {other_alias}.

Single mention ({iter:foo:bar::journal:13}).

## Other title

Direct {other_alias} and related ({some_alias})

## REF
some_alias {mem:KnowTheRole}
other_alias {file:~/tmp/foo.txt:13-345}
```



### CONCEPT TREE
> DEF GramConceptTree ConceptTree

Grammar concept trees are a re-usable pattern for nested conceptualization that
standardizes directory and file structure along with GramRef use.

Directory structure:
```
{concept_dir}/
 NN_{ConceptOne}.md
 NN_{ConceptOne}/
  NN_{SubConceptOne}.md
  NN_{SubConceptTwo}
   NN_{SubConceptThree}.md
   ..
 NN_{ConceptTwo}.md
 ..
```

File and directory names are ConceptNamed and are numerically ordered (NN),
zero-padded.

Regardless of depth, each markdown file opens with an H1 using a prose title
that correlates with its ConceptName.

If a markdown file makes references outside of its own content, it uses GramRef
to do so. If content makes use of the same reference more than once, it lists
that under a GramRefBlock directly under the H1.


## GRAM AI REPOSITORY
> DEF GramRepo AiRepo

Each Gram agent maintains its own git repo within ~/ai/{ai} by name (snake or
kebab cased).

### ITER
> DEF GramIter

Topic-specific knowledge and instruction is maintained iteratively within
{ai_repo}/iter/{topic}.

Single-level sub-topics are within {ai_repo}/iter/{topic}/sub/{subtopic}.

Core structure is the same between iter and sub-iter:
```
{ai_repo}/[iter/{topic}/ iter/{topic}/sub/{subtopic}/]
 boot.md Specific instructions per iter / subiter
 plan.yaml Index of campaigns, their tasks and sub-tasks
 plan/{pool}/[{CampaignName}.md {CampaignName}/{TaskName}.md] Campaign details and its tasks
 op.yaml Index of operational protocols and instruction sequences
 op/[{ProtocolName}.md {SequenceName}.md] Protocol and Sequence details
 journal.yaml Index of changes to iter / subiter, by revision
 journal/{rev}.md Journal per revision
 quote.yaml Index of references to the User's quotations, for justification
 quote/{QuoteName}.md Specific User quote
 info/ Current working knowledge, separated by chapter ({NN_ChapterName.md})
   00_Reference.yaml Index of aliased references
 state/ References to journal entries that establish sum of operational state
  last.yaml Previous
  now.yaml Current, in flight
  next.yaml Planned, not started
 tool/ Custom tooling
  nu/[bin mod] Nushell tooling, standalone and module
 old/ Historical reference, no longer current
  plan/{pool}/[{CampaignName}.[yaml md] {CampaignName}/..} Completed or cancelled campaigns
  journal/{rev_first}-{rev_last}.[yaml md] Archived journal entries by revision
  state/{rev}.yaml Archived previous state
  op/[{ProtocolName}.[yaml md] {SequenceName}.[yaml md]] Archived operational protocols and sequences
  quote/{QuoteName}.md Archived user quotes
 some/{thing}/ Miscellaneous, custom file structure
```

#### SPECIAL ITER
> DEF GramSpecialIter GramSpecialIters

```
{ai_repo}/iter/
 self/ Maintenance of the AI repository itself
 none/ No iter selected during boot. Lacks state, docs, instructions, etc.
```

#### PLAN
> DEF GramPlan

Plan units are organized as a campaign.
Campaigns are sub-divided into tasks.
Campaigns are categorized within a scheduling pool.
Campaign and Task names are ConceptNames.

##### PLAN INDEX
> DEF GramPlanIndex

Maintained in `plan.yaml` for all pools.
Markdown details of each campaign and task are in `plan/`.

###### EXAMPLE: plan.yaml
```yaml
- campaign: SomeExample
  summary: This is a summary
  pool: agenda
  stage: implement
  tasks:
  - task: ExampleTaskOne
    summary: This is another summary
    stage: test
  - task: ExampleTaskTwo
    summary: This is yet another summary
    stage: implement
- campaign: AnotherExample
  summary: Consider something for later
  pool: maybe
  stage: criteria
```

##### PLAN POOL
> DEF GramPlanPool

Standard pools:
- agenda Scheduled, Active
- delay Scheduled, Inactive
- debt Unscheduled; Recognized caveats with current agenda or implementation
- maybe Unscheduled; Further analysis required

##### PLAN STAGE
> DEF GramPlanStage

In order:
0. criteria Establishing intent and collecting acceptance requirements 
1. plan Establishing implementation details
2. implement Ready to work or work is in-progress
3. test Verifying implementation via adhoc tests; Implementing and running any automated tests
4. audit Ready for third-party acceptance review or that review is in-progress
5. done


#### INFO
> DEF GramInfo

`info/` contains chaptered documentation of current working knowledge
concerning the topic / subtopic.

Chapters and nested sub-chapters are numbered concepts.


The `00_Reference.yaml` defines aliases to common referenes re-used throughout
the documentation.

Each chapter opens with an H1 and its prose title, regardless of what its
actual depth is within the context of `info/`.

This structured and ordered nesting allows for efficient:
- Indexing, by  listing info/
- Scoped inspection and mutation

Each subiter assumes the parent iter's info is in context.

During read-in:
- Iter info is read before subiter.
- Chapters and sub-chapters in structured order.

##### INFO REF
> Def GramInfoRef

In the formats of:
- Subjective {info:{ChapterName}:{SubChapter}:{DeeperSubChapter}:..}
- Objective {iter:{topic}:{subtopic}::info:{ChapterName}:..}


### GENERIC BOOT
> DEF GramBoot

Read fully and follow instructions, in order, conditionally:
```
{ai_repo}/boot/
 all.md 0 Before all iter bootstraps, including none
 any.md 1 Before any iter bootstraps, other than none
 {name}.md When explicitly specified by an iter's bootstrap
```

### DIST
> DEF GramDist

{ai_repo}/dist/ contains a copy of the template used to create the Gram AI repo.

#### DIST SCHEMA
> DEF GramDistSchema

Contains schemas used to validate.

YAML indices and corresponding Markdown:
```
{ai_repo}/dist/schema/
 yaml/sourcetrait/gram/
  iter/ YAML schemas for plan.yaml, state/now.yaml, etc
 nu/sourcetrait/gram/iter/
  index/ Corresponding Nu types for plan.yaml, state/now.yaml, etc
 md/sourcetrait/gram/
  iter/ Corresponding details Markdown templates (liquid) for plan.yaml, state/now.yaml, etc
```

## APPENDIX

### EXAMPLE: op.yaml
```yaml
- sequence: SomeSequence
  summary: This is a summary
- protocol: SomeProtocol
  summary: This is another summary
  apply:
  - on: Before performing a git commit
  - on: Code review
```

### EXAMPLE: quote.yaml
```yaml
- quote: SomeJustification
- quote: SomeOtherPhrase
```

### EXAMPLE: state/[next now last].yaml
```yaml
rev: 32
ptr: {journal:32}
refs:
- ref: {journal:31}
- ref: {info:know_your_role::roles}
```

### EXAMPLE: 00_Reference.yaml
```yaml
- ref: some_alias
  ptr: {iter:other:info:KnowTheRole::Roles}
- ref: some_src
  file: ~/proj/my-project/src/foo.rs
- ref: some_site
  url: https://foo.tld/bar.html
```

> END GOV
