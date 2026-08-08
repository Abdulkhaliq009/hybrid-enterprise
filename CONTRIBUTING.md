# Contributing

This is a personal portfolio project, but suggestions are welcome.

## Workflow

1. Fork and create a feature branch: `feat/<name>` or `fix/<name>`
2. Run checks locally before pushing:
   - `terraform fmt -recursive && terraform validate`
   - `npm test` (in app/)
   - `helm lint helm/hybrid-api`
3. Open a pull request — CI must pass (fmt, validate, tfsec, Checkov, tests, Trivy)
4. One approval required before merge (see CODEOWNERS)

## Commit convention

Conventional Commits: `feat:`, `fix:`, `docs:`, `chore:`, `test:`, `refactor:`
