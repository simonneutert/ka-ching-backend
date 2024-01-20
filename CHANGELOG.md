# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [next] - yyyy-mm-dd

- [#73](https://github.com/simonneutert/ka-ching-backend/pull/73) Adds db setup for prod environments - [@simonneutert](https://github.com/simonneutert).
- [#72](https://github.com/simonneutert/ka-ching-backend/pull/72) Upgrades Ruby to v3.3.0 - [@simonneutert](https://github.com/simonneutert).

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
