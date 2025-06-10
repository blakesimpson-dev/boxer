# boxer

**boxer** is a safe, static audit tool for `.mbox` email archives. It scans for suspicious attachments, encodings, and headers, making it easy to review large mailbox files offline.

## Features

- Detects dangerous attachment types (e.g., `.exe`, `.js`, `.zip`)
- Flags base64-encoded payloads
- Warns on sketchy headers like `X-Attachment-Id`, `X-Malware-Name`
- Summary or verbose output modes
- No parsing libraries or network use — safe static read

## Usage

```bash
./boxer.sh path/to/mailbox.mbox [--summary|--verbose|--version]
```

### Arguments
| Flag         | Description                             |
|--------------|-----------------------------------------|
| `--summary`  | Show count totals only                  |
| `--verbose`  | Show message-level output               |
| `--version`  | Print version number and exit           |

## Example

```bash
./boxer.sh archive.mbox --summary

[INFO] Auditing archive.mbox
[SUMMARY] Messages: 1200
[SUMMARY] Attachments: 87
[SUMMARY] Suspect: 12
```

## Output Types
- `[SUSPICIOUS ATTACHMENT]` — e.g. `.exe`, `.js`, etc.
- `[BASE64 DETECTED]` — large encoded body sections
- `[SUSPICIOUS HEADER]` — malware-adjacent metadata

## Project Structure
```
boxer/
├── boxer.sh         # Main script
├── boxer.conf       # Config (extensions, colors, patterns)
├── VERSION          # Canonical version tracking
├── LICENSE          # MIT License
├── .gitignore       # Ignore logs, test data
├── .editorconfig    # 2-space indent consistency
└── CHANGELOG.md     # Version history
```

## Requirements
- POSIX shell
- `awk`, `sed`, `grep`, `head`, `tail`

## License
MIT — see [LICENSE](./LICENSE) file.

---

*Written by Blake Simpson.*
