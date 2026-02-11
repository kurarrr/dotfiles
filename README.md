## Setup

### Fresh Mac (curl one-liner)

```bash
bash -c "$(curl -fsSL raw.github.com/kurarrr/dotfiles/master/setup.sh)" -s install
```

This will:

1. Download & extract dotfiles to `~/src/github.com/kurarrr/dotfiles`
2. Install Xcode CLI tools
3. Convert the directory to a git repo
4. Install Homebrew, zinit, Brewfile dependencies
5. Create symlinks

### Commands

```bash
./setup.sh install    # Full setup (steps above)
./setup.sh link       # Symlinks only
./setup.sh configure  # Apply macOS system preferences
```

## Reference

[Basis](https://github.com/okamos/dotfiles)

[Cask and mac configuration](https://queryok.ikuwow.com/entry/dotfiles-refined-with-brewfile/)
