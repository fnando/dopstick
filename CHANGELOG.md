# Changelog

<!--
Prefix your message with one of the following:

- [Added] for new features.
- [Changed] for changes in existing functionality.
- [Deprecated] for soon-to-be removed features.
- [Removed] for now removed features.
- [Fixed] for any bug fixes.
- [Security] in case of vulnerabilities.
-->

## v0.0.7 - 2021-12-04

- [Fixed] Set proper package ecosystem on dependabot's config file.
- [Changed] Update ruby default versions to 2.7 and 3.0.
- [Changed] Update node default versions to 16 and 17.

## v0.0.6 - 2020-12-09

- [Fixed] Babel loader's order is backwards, so TypeScript first, then
  JavaScript.

## v0.0.5 - 2020-11-14

- [Fixed] Jest configuration wasn't considering the full import path.

## v0.0.4 - 2020-11-14

- [Added] Generate
  [dependabot](https://help.github.com/github/administering-a-repository/configuration-options-for-dependency-updates)
  configuration.
- [Changed] Add Postgres env vars so tests can run smoothly.
- [Added] Add helper method to create migration classes with `--active-record`.
- [Added] Generate `.github/CODEOWNERS` template.
- [Changed] Generate Ruby packages with `--type gem`
- [Added] Generate NPM packages with `--type npm`.

## v0.0.3 - 2020-11-03

- [Changed] Remove unused `--repository` switch.
- [Changed] Make `--help` and `-h` work with `dopstick new`.

## v0.0.2 - 2020-11-02

- [Fixed] Link added to gemspec's meta info now open the correct code browser.
- [Fixed] Use correct key name for custom funding urls.

## v0.0.1 - 2020-11-02

- Initial release.
