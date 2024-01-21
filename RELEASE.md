# Release Process

- [ ] Check the Changelog and make sure it is up to date.
- [ ] Close the Changelog for the current release in a designated commit.
  - [ ] Optional: Do you need to add any help, warning or upgrading instructions to the Changelog?
- [ ] Create a release branch from `main` named `vX.Y.Z`. Follow the SemVer convention.
- [ ] Add the `next` section to the Changelog in a designated commit.

The releasing of the package is done by the CI/CD pipeline. 🥳
