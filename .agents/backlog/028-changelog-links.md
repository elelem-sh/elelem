As a `user reading the changelog`, I `want every link in CHANGELOG.md to go to the right place`, so that `I can follow a change to its commit, compare view or story`.

# SYNOPSIS

Fix the old link list and the misdirected issue links in CHANGELOG.md, and stop release-please from making new ones.

# DESCRIPTION

Version, changelog and RubyGems are in step now: 0.13.0, 0.13.1 and
0.14.0 are released and have release-please entries. What remains is
the links.

1. **Wrong-repo issue links.** Four 0.13.0 entries cite
   `elelem-sh/elelem.sh#N` in the commit subject. release-please turned
   the `#N` into a link to `https://github.com/elelem-sh/elelem/issues/N`,
   which is the wrong repo: `elelem-sh/elelem.sh[#19](.../elelem/issues/19)`.
   Point them at `https://github.com/elelem-sh/elelem.sh/issues/N`, or
   drop the link and keep the plain text.
2. **Old link list.** The reference links at the end of the file point
   to `https://src.mokhan.ca/xlgmokha/elelem/compare/...`. Point them at
   `https://github.com/elelem-sh/elelem/compare/...` (every tag from
   v0.1.0 to v0.14.0 exists there), and add the missing `[0.11.0]` and
   `[0.12.0]` references.
3. **Stray 0.1.3.** The `[0.2.0]` link compares from `v0.1.3`, and tag
   `v0.1.3` exists, but there is no 0.1.3 entry and no `[0.1.3]` link.
   Add a short 0.1.3 entry from `git log v0.1.2..v0.1.3`, or say in the
   0.2.0 entry that it includes 0.1.3.
4. **Stale flag.** The 0.9.0 entry lists "`-p`/`-m` flags". The model
   flag is `--model` now; note that in the entry, without rewriting
   history.
5. **New releases.** Stories now live in `.agents/backlog/`, not GitHub
   issues. Commit subjects should cite a story by number and name (for
   example `(backlog 024)`), never `#N`, so release-please has nothing
   to link to the wrong repo. Write this convention down where commit
   style is documented, and check one release PR follows it.

# SEE ALSO

* [ ] Formerly elelem-sh/elelem.sh#18
* [ ] Formerly elelem-sh/elelem.sh#55
* [ ] CHANGELOG.md:44 - #19 linked to elelem-sh/elelem/issues/19
* [ ] CHANGELOG.md:45 - #6 linked to elelem-sh/elelem/issues/6
* [ ] CHANGELOG.md:48 - #20 linked to elelem-sh/elelem/issues/20
* [ ] CHANGELOG.md:53 - #3 linked to elelem-sh/elelem/issues/3
* [ ] CHANGELOG.md:183 - 0.9.0 mentions `-p`/`-m` flags
* [ ] CHANGELOG.md:408 - link list on src.mokhan.ca/xlgmokha
* [ ] CHANGELOG.md:421 - `[0.2.0]` compares from v0.1.3
* [ ] release-please-config.json - release-please settings
* [ ] .github/workflows/release.yml - release-please job

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [x] `lib/elelem/version.rb`, the newest CHANGELOG entry and RubyGems agree (0.14.0)
* [ ] `grep -n 'elelem-sh/elelem/issues' CHANGELOG.md` finds nothing
* [ ] `grep -n 'src.mokhan.ca' CHANGELOG.md` finds nothing
* [ ] Every `## [X.Y.Z]` heading without an inline link has a matching reference link
* [ ] Every reference link points at an existing tag on github.com/elelem-sh/elelem
* [ ] 0.1.3 has an entry, or the 0.2.0 entry says it covers 0.1.3
* [ ] The 0.9.0 entry notes that `-m` is now `--model`
* [ ] The commit convention for citing backlog stories is written down
* [ ] The next release PR has no links to `elelem-sh/elelem/issues`
