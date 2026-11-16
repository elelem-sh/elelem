As a `user who finds elelem on RubyGems`, I `want the gem page to link to the docs, the changelog and the backlog`, so that `I can learn the tool and see what is planned`.

# SYNOPSIS

Add `documentation_uri`, `changelog_uri` and `bug_tracker_uri` to the gemspec.

# DESCRIPTION

The gemspec already sets `spec.homepage = "https://elelem.sh"` with a
matching `homepage_uri`, and `source_code_uri` points at
`https://github.com/elelem-sh/elelem`. RubyGems shows the other
standard metadata links on the gem page, and core sets none of them.

Add:

```ruby
spec.metadata["documentation_uri"] = "https://elelem.sh/docs/"
spec.metadata["changelog_uri"] = "https://github.com/elelem-sh/elelem/blob/main/CHANGELOG.md"
spec.metadata["bug_tracker_uri"] = "https://github.com/elelem-sh/elelem/tree/main/.agents/backlog"
```

`bug_tracker_uri` points at the backlog directory in the source repo,
not at GitHub issues: stories now live in `.agents/backlog/`. Check that
`https://elelem.sh/docs/` exists before release; use the site's
documentation index if the path differs.

Keep `allowed_push_host` and `rubygems_mfa_required`. The new links
show on RubyGems after the next release.

Plugin gems need the same change in their own repos; that is out of
scope here.

# SEE ALSO

* [ ] Formerly elelem-sh/elelem.sh#41
* [ ] elelem.gemspec:13 - `spec.homepage`
* [ ] elelem.gemspec:18 - `homepage_uri`, `source_code_uri`, `rubygems_mfa_required`
* [ ] CHANGELOG.md - target of `changelog_uri`
* [ ] .agents/backlog/ - target of `bug_tracker_uri`
* [ ] https://guides.rubygems.org/specification-reference/#metadata

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [x] `spec.homepage` and `homepage_uri` are `https://elelem.sh`
* [ ] `documentation_uri` points at the docs on elelem.sh and the page loads
* [ ] `changelog_uri` points at `CHANGELOG.md` on the main branch
* [ ] `bug_tracker_uri` points at `.agents/backlog` in the source repo, not at GitHub issues
* [ ] `allowed_push_host` and `rubygems_mfa_required` are unchanged
* [ ] `gem build elelem.gemspec` succeeds with no metadata warnings
* [ ] After the next release, the RubyGems page shows all five links
