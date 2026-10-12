# GOVERNANCE
>REIN HUMAN
>BEGIN GOV

## GRAMMAR

### TERMINOLOGY

SourceTrait Grammar is a framework & toolkit for AI agent instruction,
organization, and operation.

GrammarBox is a customized Podman container image based on Fedora Toolbx that
standardizes some system configuration and $HOME layout. It builds upon the
uenv and pwrusr directory specifications.

Gram is the standard flagship AI instruction set. It is used to classify an
agent adhering to it as well.

### UENV AND PWRUSR

UEnv relies upon explicit XDG environment configuration.
It uses ~/.sys for software internals and ~/.sys/of for internals that don't
strictly adhere to XDG.

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

## GRAM AI REPOSITORY

Each Gram agent maintains its own git repo within ~/ai/{ai} by name (snake or
kebab cased).

### ITER

Topic-specific knowledge and instruction is maintained iteratively within
{ai_repo}/iter/{topic}.

Single-level sub-topics are within {ai_repo}/iter/{topic}/sub/{subtopic}.

Core structure is the same between iter and sub-iter:
```
{ai_repo}/[iter/{topic}/ iter/{topic}/sub/{subtopic}/]
 boot.md Specific instructions per iter / subiter
 plan.yaml Index of campaigns, their tasks and sub-tasks
 plan/{pool}/[{CampaignName}.md {CampaignName}/{TaskName}.md {CampaignName}/{TaskName}/{SubTaskName}.md {CampaignName}/{TaskName}/{SubTaskName}/..] Campaign details, its tasks, sub-tasks follow suite
 op.yaml Index of operational protocols and instruction sequences
 op/[{ProtocolName}.md {SequenceName}.md] Protocol and Sequence details
 journal.yaml Index of changes to iter / subiter, by revision
 journal/{rev}.md Journal per revision
 quote.yaml Index of references to the User's quotations, for justification
 quote/{QuoteName}.md Specific User quote
 info/ Current working knowledge, separated by chapter ({NN_ChapterName.md})
   00_Index.yaml Index of aliased references, chapters, chapter sections
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

#### SPECIAL ITERS
```
{ai_repo}/iter/
 self/ Maintenance of the AI repository itself
 none/ No iter selected during boot. Lacks state, docs, instructions, etc.
```

### GENERIC BOOT
Read fully and follow instructions, in order, conditionally:
```
{ai_repo}/boot/
 all.md 0 Before all iter bootstraps, including none
 any.md 1 Before any iter bootstraps, other than none
 {name}.md When explicitly specified by an iter's bootstrap
```

### DIST
{ai_repo}/dist/ contains a copy of the template used to create the Gram AI repo.

#### DIST SCHEMA
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

>END GOV
