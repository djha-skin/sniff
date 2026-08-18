# Contributing

Thanks for wanting to help with sniff. The project follows the
`djha-skin-janet` conventions: jpm for builds, Judge for tests,
an 80-character line rule, and a Keep a Changelog changelog.

## Workflow

1. **Log an issue first** and discuss the change with the team.
   For small, obvious fixes (a typo, a docstring), a PR without an
   issue is fine — see the small-patch exception below.
2. **Branch from `main`** and make your change there.
3. **Run the checks** (below) until they pass.
4. **Update the documentation** — docstrings for new bindings, and
   the docs pages for user-visible changes, with `docs/api.md`
   regenerated.
5. **Add a changelog entry** to `CHANGELOG.md` under
   `[Unreleased]`, in the right section (Added / Changed / Fixed).
6. **Open a PR.**

## Checks

```bash
jpm -l deps                        # nrdl, judge, documentarian
jpm -l test                        # unit tests
janet ~/.agents/skills/djha-skin-janet/scripts/fmt.janet --check
janet ~/.agents/skills/djha-skin-janet/scripts/check-parens.janet src test
jpm -l run doc                     # regenerate docs/api.md
```

The style guide's rules apply to test code and docs as well as
source: kebab-case names, `?` predicates, `!` for mutating
functions, 80 characters per line, no trailing whitespace.

## PR checklist

- Based on the `main` branch.
- Tests pass (`jpm -l test`).
- Documentation updated: docstrings, the docs pages, and
  `docs/api.md` regenerated.
- Changelog entry added.
- The formatting and paren checks are clean.

## Small-patch exception

Typos, doc fixes, and other small patches do not need an issue or
a changelog entry — just a clean PR with a clear description.

## Code of conduct

Be kind and constructive. That is the whole policy.
