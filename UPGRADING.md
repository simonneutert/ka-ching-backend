# Upgrading ka-ching-backend

## 0.1.0 to 0.2.0

### Changes

- [#1](https://github.com/simonneutert/ka-ching-backend) changes attribute/column from `realized` to `realized_at`. This is a breaking change, as the database schema needs to be updated. No migration is provided, as this is a very early release. Please update your database schema manually or drop the database and start from scratch.
