# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

Schema for new entries:

```markdown
- [#<PRNUMBER>](https://github.com/simonneutert/ka-ching-backend/pull/<PRNUMBER>) description - [@<username>](https://github.com/<username>)
```

## [next] - yyyy-mm-dd

- [#107](https://github.com/simonneutert/ka-ching-backend/pull/107) updates ruby (asdf) to 3.3.5, bumps bundler to latest and pg for ci from 15 to 16 - [@simonneutert](https://github.com/simonneutert)
- [#106](https://github.com/simonneutert/ka-ching-backend/pull/106) Bump rexml from 3.3.0 to 3.3.6 - @dependabot
- [#105](https://github.com/simonneutert/ka-ching-backend/pull/105) Bump rack from 3.1.3 to 3.1.5 - @dependabot
- [#104](https://github.com/simonneutert/ka-ching-backend/pull/104) Bump the patch-and-minor-dependencies group across 1 directory with 10 updates - @dependabot
- [#85](https://github.com/simonneutert/ka-ching-backend/pull/85) Bump yard from 0.9.34 to 0.9.36 - @dependabot
- [#97](https://github.com/simonneutert/ka-ching-backend/pull/97) Bump nokogiri from 1.16.2 to 1.16.5 - @dependabot
- [#77](https://github.com/simonneutert/ka-ching-backend/pull/77) BigDecimal will be moved out of Ruby StandardLibrary from Ruby 3.4 onwards - [@simonneutert](https://github.com/simonneutert)
- [#76](https://github.com/simonneutert/ka-ching-backend/pull/76) Adds healthcheck for db services. Updating dependencies whilst on it and adds parallel flag to rubocop config - [@simonneutert](https://github.com/simonneutert)

## [0.5.1] - 2023-12-21

- [#74](https://github.com/simonneutert/ka-ching-backend/pull/74) Loads DB config constants on startup to fix a bug when running the project with docker compose - [@simonneutert](https://github.com/simonneutert).
- [#73](https://github.com/simonneutert/ka-ching-backend/pull/73) Adds db setup for prod environments - [@simonneutert](https://github.com/simonneutert).

## [0.5.0] - 2023-12-20

- [#72](https://github.com/simonneutert/ka-ching-backend/pull/72) Upgrades Ruby to v3.3.0 - [@simonneutert](https://github.com/simonneutert).
- [#65](https://github.com/simonneutert/ka-ching-backend/pull/65) Upgrades Ruby to v3.2.x - [@simonneutert](https://github.com/simonneutert).

As well as patching some dependencies.

## [0.4.3] - 2023-12-21

- [#46](https://github.com/simonneutert/ka-ching-backend/pull/46) Bump roda, rubocop, alba and bundler itself - [@simonneutert](https://github.com/simonneutert).
- [#47](https://github.com/simonneutert/ka-ching-backend/pull/47) Upgrade alba gem to v3+ - [@simonneutert](https://github.com/simonneutert).

- [#<PRNUMBER>](https://github.com/simonneutert/ka-ching-backend/pull/<PRNUMBER>) description - [@<username>](https://github.com/<username>).

## [0.4.2] - 2023-10-09

- [#45](https://github.com/simonneutert/ka-ching-backend/pull/45) Bump gems via `bundle update` - [@simonneutert](https://github.com/simonneutert).
- [#44](https://github.com/simonneutert/ka-ching-backend/pull/44) Bump rubocop from 1.56.3 to 1.56.4.
- [#43](https://github.com/simonneutert/ka-ching-backend/pull/43) Bump sequel from 5.72.0 to 5.73.0.
- [#42](https://github.com/simonneutert/ka-ching-backend/pull/42) Bump rubocop-minitest from 0.32.1 to 0.32.2.
- [#41](https://github.com/simonneutert/ka-ching-backend/pull/41) Bump puma from 6.3.1 to 6.4.0.
- [#40](https://github.com/simonneutert/ka-ching-backend/pull/40) Bump rubocop-minitest from 0.31.1 to 0.32.1.
- [#39](https://github.com/simonneutert/ka-ching-backend/pull/39) Bump rubocop-performance from 1.19.0 to 1.19.1.

## [0.4.1] - 2023-09-16

Upgrades Dependencies.

## [0.4.0] - 2023-07-11

- [#15](https://github.com/simonneutert/ka-ching-backend/pull/15) implements pg_json extension to quicker deserialize json columns - [@simonneutert](https://github.com/simonneutert).

## [0.3.0] - 2023-06-27

### Fixed

- [#10](https://github.com/simonneutert/ka-ching-backend/pull/10) locking in between bookings can cause saldo to become negative (edge case / theoretical) - [@simonneutert](https://github.com/simonneutert).

### Changed

- [#6](https://github.com/simonneutert/ka-ching-backend/pull/6) errors return a status and a message for caught errors of API request - [@simonneutert](https://github.com/simonneutert).

## [0.2.1] - 2023-06-24

- [#5](https://github.com/simonneutert/ka-ching-backend/pull/5) resetting a tenant's database is now under `/admin` namespace and resetting is now enabled by default - [@simonneutert](https://github.com/simonneutert).
- [#5](https://github.com/simonneutert/ka-ching-backend/pull/5) adds the ability for `per_page` pagination of `tenants` - [@simonneutert](https://github.com/simonneutert).

## [0.2.0] - 2023-06-20

- [#1](https://github.com/simonneutert/ka-ching-backend/pull/1) changes attribute/column from `realized` to `realized_at` - [@simonneutert](https://github.com/simonneutert).

## [0.1.0] - 2023-06-14

- Initial release.
