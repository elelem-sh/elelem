As a `developer`, I `want an ADR skill for design sessions`, so that `architectural decisions are documented consistently and repeatably`.

# SYNOPSIS

An `adr` skill that writes Architecture Decision Records from a standard template.

# DESCRIPTION

When architectural decisions emerge during design sessions, the agent
should be able to create ADRs using a consistent template. ADRs are
stored in `doc/adr/` and follow a numbered naming convention.

Core no longer has modes or a `design.erb` prompt, and `elelem-skills`
no longer bundles the `scrum` skill whose `design.md` replaced it
(dropped in elelem-skills 6a66dd9). Skills are now files the user keeps
under `.agents/skills/`, which `elelem-skills` loads.

So this becomes an `adr` skill, `.agents/skills/adr/SKILL.md`, that:

1. Explains when to create ADRs (significant architectural decisions)
2. Provides the ADR template
3. Writes ADRs to the `doc/adr/` directory

# SEE ALSO

* [ ] skills/README.md - how `elelem-skills` finds skills under `.agents/skills/`
* [ ] skills/lib/elelem/skills/catalog.rb - skill discovery
* [ ] doc/adr/ - ADR storage location (to be created)

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] `.agents/skills/adr/SKILL.md` exists and loads with `elelem-skills`
* [ ] The skill includes the ADR template
* [ ] The skill writes files to `doc/adr/`
* [ ] ADRs follow naming convention: `ADR-NNNN-short-name.md`
* [ ] Template includes: Date, Status, Context, Decision, Consequences
* [ ] Agent understands when to propose creating an ADR

# ADR Template

```markdown
# ADR-NNNN: Title

**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Deprecated | Superseded by ADR-XXXX

## Context

What is the issue that we're seeing that is motivating this decision or change?

## Decision

What is the change that we're proposing and/or doing?

## Consequences

**Positive:**
- Benefit 1
- Benefit 2

**Negative:**
- Tradeoff 1
- Tradeoff 2
```

# Guidance for the Skill

Include in the skill:

> **When to create an ADR:**
> - Choosing between multiple valid approaches
> - Adopting a new technology or pattern
> - Changing an existing architectural decision
> - Decisions that affect multiple components
>
> **When NOT to create an ADR:**
> - Implementation details within a single file
> - Bug fixes
> - Routine refactoring
