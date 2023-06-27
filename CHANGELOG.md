# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

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
