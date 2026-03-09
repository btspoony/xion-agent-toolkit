# Release Process

This document describes the release workflow for the Xion Agent Toolkit using [cargo-dist](https://axodotdev.github.io/cargo-dist/).

## Overview

We use `cargo-dist` to automate cross-platform binary builds and GitHub releases. The process is triggered by pushing a version tag to the repository.

## Supported Platforms

Each release includes pre-built binaries for:

| Platform | Target | Archive Format |
|----------|--------|----------------|
| Linux x64 (GNU) | `x86_64-unknown-linux-gnu` | `.tar.xz` |
| Linux x64 (musl) | `x86_64-unknown-linux-musl` | `.tar.xz` |
| Linux ARM64 | `aarch64-unknown-linux-gnu` | `.tar.xz` |
| macOS Intel | `x86_64-apple-darwin` | `.tar.xz` |
| macOS Apple Silicon | `aarch64-apple-darwin` | `.tar.xz` |
| Windows x64 | `x86_64-pc-windows-msvc` | `.zip` |

## How to Prepare a Release

### 1. Update Version in `Cargo.toml`

```bash
# Edit Cargo.toml and update the version
[package]
version = "0.X.X"  # Update this
```

### 2. Update `CHANGELOG.md`

Move items from the `[Unreleased]` section to a new version section following [Keep a Changelog](https://keepachangelog.com/) format:

```markdown
## [0.X.X] - YYYY-MM-DD

### Added
- New feature description

### Changed
- Change description

### Fixed
- Bug fix description
```

### 3. Commit Changes

```bash
git add Cargo.toml CHANGELOG.md
git commit -m "chore(release): prepare for v0.X.X"
git push origin main
```

## How to Trigger a Release

Create and push a version tag:

```bash
# Create an annotated tag
git tag -a v0.X.X -m "Release v0.X.X"

# Push the tag to trigger the release workflow
git push origin v0.X.X
```

**Tag Format**: Tags must follow semantic versioning with a `v` prefix:
- `v0.2.0` - Valid
- `v0.2.1-alpha.1` - Valid (prerelease)
- `0.2.0` - Invalid (missing `v` prefix)

## What Happens Automatically

Once a tag is pushed:

1. **CI Trigger**: The `.github/workflows/release.yml` workflow runs automatically
2. **Test Phase**: Tests run on all platforms
3. **Build Phase**: Binaries are built for all supported targets
4. **Artifact Generation**: Archives, installers, and checksums are created
5. **GitHub Release**: A release is created with:
   - Pre-built binaries for all platforms
   - Shell installer (`xion-agent-toolkit-installer.sh`)
   - PowerShell installer (`xion-agent-toolkit-installer.ps1`)
   - SHA256 checksums for all artifacts
   - Release notes from `CHANGELOG.md`

## Release Workflow Status

Monitor the release progress in GitHub Actions:

1. Go to **Actions** → **Release** workflow
2. The workflow has these jobs:
   - `plan` - Determines what needs to be built
   - `build-local-artifacts` - Builds platform-specific binaries
   - `build-global-artifacts` - Creates installers and checksums
   - `host` - Uploads artifacts and creates the GitHub release

## Installing from a Release

### Using the Shell Installer (macOS/Linux)

```bash
curl --proto '=https' --tlsv1.2 -LsSf \
  https://github.com/burnt-labs/xion-agent-toolkit/releases/download/v0.X.X/xion-agent-toolkit-installer.sh | sh
```

### Using the PowerShell Installer (Windows)

```powershell
powershell -c "irm https://github.com/burnt-labs/xion-agent-toolkit/releases/download/v0.X.X/xion-agent-toolkit-installer.ps1 | iex"
```

### Manual Installation

Download the appropriate archive from the [releases page](https://github.com/burnt-labs/xion-agent-toolkit/releases) and extract it to a directory in your `PATH`.

## Post-Release Steps

After a successful release:

1. **Verify the Release**: Check that all artifacts are present on the GitHub release page
2. **Test Installers**: Run the shell/PowerShell installers on different platforms
3. **Update Documentation**: If the release includes significant changes, update relevant docs
4. **Announce**: Share the release in appropriate channels (if applicable)

## Troubleshooting

### Build Failures

If a build fails:

1. Check the GitHub Actions logs for the specific error
2. Common issues:
   - Missing system dependencies for cross-compilation
   - Network timeouts during dependency download
   - Platform-specific code compilation errors

### Re-running a Release

If a release fails mid-way, you can re-trigger it by:

1. Deleting the partially created GitHub release (if it exists)
2. Deleting and re-pushing the tag:
   ```bash
   git tag -d v0.X.X
   git push --delete origin v0.X.X
   git tag -a v0.X.X -m "Release v0.X.X"
   git push origin v0.X.X
   ```

## Configuration

Release configuration is stored in:

- `Cargo.toml` - `[profile.dist]` section for build settings
- `dist-workspace.toml` - cargo-dist specific configuration
- `.github/workflows/release.yml` - CI workflow definition

### Modifying Targets

To add or remove target platforms, edit `dist-workspace.toml`:

```toml
[dist]
targets = [
  "x86_64-unknown-linux-gnu",
  # Add or remove targets here
]
```

Then regenerate the CI:

```bash
dist generate
```

## Local Testing

Test the release process locally before pushing a tag:

```bash
# Generate a release plan
dist plan

# Build for the current platform
dist build

# Build for a specific target
dist build --target x86_64-apple-darwin

# Build for all targets (requires cross-compilation setup)
dist build --target=all
```

## Security

- All releases are built in GitHub Actions with reproducible builds
- SHA256 checksums are generated for all artifacts
- Releases are signed by GitHub's GPG key

## See Also

- [cargo-dist documentation](https://axodotdev.github.io/cargo-dist/)
- [GitHub Releases](https://github.com/burnt-labs/xion-agent-toolkit/releases)
- [CHANGELOG.md](../CHANGELOG.md)
