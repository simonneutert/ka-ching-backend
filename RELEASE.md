# Release Process

In order to release a new version of the package, follow these steps:

## Preparing a release

It is preferred to release the package from the `main` branch. If you are not on the `main` branch, make sure to merge the latest changes from `main` into your branch.

It is also preferred to release often and in small increments. This makes it easier to track changes and to fix issues that might arise.

### Versioning

The package follows more or less the [Semantic Versioning](https://semver.org/) convention. The version number of a release is to be stored in the `version.json` file.

#### Patch / Hotfixes

- [ ] Create a release with tag from branch `main` named `vX.Y.Z`. Follow the SemVer convention.
- [ ] Release hotfixes either one by one or in a batch, depending on the urgency.
- [ ] Check the Changelog and make sure it is up to date with all PR merges, since the last release.

#### Minor

- [ ] Create a release with tag from branch `main` named `vX.Y.Z`. Follow the SemVer convention.
- [ ] Release the next minor afterwards.
- [ ] Check the Changelog and make sure it is up to date with all PR merges, since the last release.

#### Major

- [ ] Create a release with tag from branch `main` named `vX.Y.Z`. Follow the SemVer convention.
- [ ] Release the next major afterwards.
- [ ] Check the Changelog and make sure it is up to date with all PR merges, since the last release.

### Changelog and versioning

- [ ] Close the Changelog for this release in a designated commit.
- [ ] update `version.json` with the current version number (commit --amend --no-edit).
- [ ] Add the `next` section to the Changelog (commit --amend --no-edit).

### Upgrading hints?

- [ ] Optional: Do you need to add any help, warning or upgrading instructions to the Changelog / UPGRADING.md?

## Releasing

- [ ] create a new tag/release on GitHub with the version number and the Changelog for this release.

## After the release

- [ ] Update the `next` section in the Changelog with the new version number.
- [ ] Update the `version.json` file with the new version number.
- [ ] Open the Changelog for the next release.
- [ ] Push the changes to the repository.

---

The releasing of the package is done by the CI/CD pipeline. 🥳
