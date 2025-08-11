# build_deb (deb builder)

A configurable and scriptable `.deb` package builder using shell scripting and a `.config` file.  
Easily define metadata, control fields, payload files/directories, Raspberry Pi conditions, changelogs, and more.

---

## 📦 Features

- Configurable `.deb` building via a simple config file
- Automatic creation of `control`, `changelog`, and `copyright`
- Supports `preinst`, `postinst`, `prerm`, `postrm` scripts (inline or file)
- Raspberry Pi hardware & OS version detection
- Changelog parsing from Keep a Changelog markdown
- Minimal external dependencies
- Auto calculation of package size
- Supports both files and folders as payload

---

## 🧪 Usage

```bash
./build_deb.sh [OPTION]
```

### Options:

- `[config_path]` – path to config file (`*.config`), defaults to `build_deb.config`
- `-v`, `--version` – print version info and exit
- `-h`, `--help` – print help and exit

> ⚠️ Only one option at a time is allowed!

---

## ⚙️ Configuration

All build options are set in a `.config` file. Format is bash-style key=value.

### 🔹 Required Fields

```bash
CFG_NAME="myapp"                          # Package name: lowercase, digits, + - . (min 2 chars)
CFG_VERSION="1.2.3-1"                    # Format: [epoch:]upstream[-debian]
CFG_PRIORITY="optional"                 # required | important | standard | optional
CFG_ARCH="all"                          # all | any | amd64 | arm64 | i386 | armhf
CFG_MAINTAINER="John Doe <john@x.com>"  # Format: Name <email>
CFG_DESCRIPTION="MyApp
  A longer description about what it does."
```

### 🔹 Optional Fields

```bash
CFG_HOMEPAGE="https://example.com"
CFG_DEPENDS="curl (>= 7.0), bash"
CFG_CONFLICTS="some-other-package"
CFG_SIZE=""                              # Optional, auto-calculated if empty
CFG_ADD_SIZE="15"                        # Additional size (KB) to add
CFG_COPYRIGHT_STRING="..."              # Debian copyright text
CFG_COPYRIGHT_FILE_PATH="./LICENSE"
CFG_CHANGELOG_STRING="..."              # Debian changelog format
CFG_CHANGELOG_FILE_PATH="./CHANGELOG.md"
CFG_BUILD_DIR="/tmp"
CFG_RELEASE_DIR="./release"
CFG_DEB_BASE_FILE_NAME="myapp_1.2.3-1_all"
```

---

## 📁 Files & Directories

Define files and folders to include in the package:

### Files

```bash
CFG_FILES_CONF="
./bin/myapp.sh=/usr/bin/myapp
./lib/mylib.so=/usr/lib/myapp/mylib.so"
```

### Directories

```bash
CFG_DIRS_CONF="
./assets=/usr/share/myapp/assets"
```

> At least one of `CFG_FILES_CONF` or `CFG_DIRS_CONF` is required.

---

## ⚙️ Lifecycle Scripts

You can define installation/removal/upgrade scripts either as **file paths** or **inline strings**:

```bash
CFG_PREINST="#!/bin/bash
echo 'Running preinst script'"

CFG_POSTINST="/absolute/path/to/postinst.sh"
CFG_PRERM=""
CFG_POSTRM=""
```

Scripts are executed automatically by `dpkg` during install/uninstall/upgrade.

---

## 🍓 Raspberry Pi Targeting (Optional)

Restrict installation to specific hardware or OS conditions:

```bash
CFG_RES_RAS_PI="rpi3|rpi4|rpi5"     # Raspberry Pi model
CFG_RES_RAS_OS="bullseye|bookworm" # Raspbian release
CFG_RES_CPU_ARCH="armhf|arm64"     # CPU architecture
CFG_RES_OS_ARCH="32|64"            # OS architecture
```

These values are evaluated in the auto-generated `preinst` script.

---

## 📝 Example Config: `build_deb.config`

```bash
CFG_NAME="myapp"
CFG_VERSION="1.0.0-1"
CFG_PRIORITY="optional"
CFG_ARCH="all"
CFG_MAINTAINER="Jane Doe <jane@example.com>"
CFG_DESCRIPTION="MyApp
  A tool to do X and Y."

CFG_HOMEPAGE="https://example.com"
CFG_DEPENDS="bash, curl"
CFG_CONFLICTS=""
CFG_BUILD_DIR="/tmp"
CFG_RELEASE_DIR="./release"
CFG_DEB_BASE_FILE_NAME="myapp_1.0.0-1_all"

CFG_FILES_CONF="
./bin/myapp.sh=/usr/bin/myapp
./data/config.json=/etc/myapp/config.json"

CFG_DIRS_CONF="
./assets=/usr/share/myapp/assets"

CFG_COPYRIGHT_FILE_PATH="./LICENSE"
CFG_CHANGELOG_FILE_PATH="./CHANGELOG.md"

CFG_PREINST="#!/bin/bash
echo 'Running pre-install hook'"
```

---

## 🧰 Dependencies

These system tools are required:

- `bash`
- `dpkg-deb`
- `grep`, `cut`, `sed`, `tee`, `cat`, `file`, `find`, `readlink`

They are available by default on most Debian-based systems.

---

## 📦 Build Your Package

```bash
./build_deb.sh ./build_deb.config
```

> The resulting `.deb` file will be placed in your `CFG_RELEASE_DIR`, e.g.:

```bash
./release/myapp_1.0.0-1_all.deb
```

---

## 🧪 Test Your Package

Install:

```bash
sudo dpkg -i ./release/myapp_1.0.0-1_all.deb
```

Uninstall:

```bash
sudo dpkg -r myapp
```

---

## 📜 License

MIT License  
See `LICENSE` file or provide via `CFG_COPYRIGHT_STRING` or `CFG_COPYRIGHT_FILE_PATH`.
