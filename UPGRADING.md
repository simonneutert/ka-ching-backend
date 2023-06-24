# Upgrading ka-ching-backend

## 0.2.0 to 0.2.1

### Changes

- [#2]() `KACHING_DEMO_MODE` is replaced by `KACHING_RESET_PROTECTION`. `KACHING_RESET_PROTECTION` is `off`/`false` by default. This is a breaking change, as the environment variable name has changed. Please update your environment variables accordingly. And beware that resetting a tenant's database is now possible by default.

## 0.1.0 to 0.2.0

### Changes

- [#1](https://github.com/simonneutert/ka-ching-backend/pull/1) changes attribute/column from `realized` to `realized_at`. This is a breaking change, as the database schema needs to be updated. No migration is provided, as this is a very early release. Please update your database schema manually or drop the database and start from scratch.