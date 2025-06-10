# ROADMAP.md

# Boxer Project Roadmap — Production Readiness

This roadmap outlines enhancements required to bring `boxer` to a production-ready state as a static `.mbox` audit tool. Items are grouped by concern and designed for milestone-based progression.

-------------------------------------------------------------------------------

Security / Safety
-------------------------------------------------------------------------------

- [ ] Attachment content type matching
      - Detect mismatch between declared Content-Type and actual file extension
- [ ] Base64 size threshold
      - Warn on large base64 blocks (> configurable size, e.g., 500KB)
- [ ] Header injection detection
      - Identify duplicate or malformed headers (e.g., multiple Subject: lines)
- [ ] No unguarded temp files
      - Ensure future extraction happens in isolated, short-lived tmpdir
- [ ] Safe output handling
      - Sanitize filenames and suppress anything that could inject into shell logs

-------------------------------------------------------------------------------

Logic & Detection
-------------------------------------------------------------------------------

- [ ] MIME boundary detection robustness
      - Handle nested or malformed boundary sections
- [ ] Encoded subject/body detection
      - Flag base64 or quoted-printable encoded headers
- [ ] Suspicious pattern DB
      - External regex file (e.g., suspicious_patterns.txt) sourced from config
- [ ] Multi-line header reassembly
      - Properly combine headers that span multiple lines with folding
- [ ] Known-bad filename pattern detection
      - Detect executables disguised with double extensions (e.g. photo.jpg.exe)

-------------------------------------------------------------------------------
Usability

- [ ] Dry run mode (--dry-run)
      - Show what would be flagged without writing anything
- [ ] Quiet mode (--quiet)
      - Suppress non-critical output
- [ ] Output to file (--out file.log)
      - Log results to a file with same formatting
- [ ] Progress indicator for large files
      - Optional line/percent progress for feedback on large inboxes
- [ ] Show affected message summary
      - Include From:, Subject:, Date: in flags for easier tracing

-------------------------------------------------------------------------------

Maintenance & Project Hygiene
-------------------------------------------------------------------------------

- [ ] ShellCheck clean
      - Zero warnings or well-documented disables
- [ ] Consistent log formatting
      - Log levels aligned, clean output formatting
- [ ] Config-driven detection
      - Allow boxer.conf to define:
          - Dangerous extensions
          - Suspicious headers
          - Size limits
- [ ] Graceful interruption
      - Use trap to catch SIGINT and cleanup if needed
- [ ] Centralized logging
      - log_info, log_warn, etc., sourced from config colors

-------------------------------------------------------------------------------
Future-proofing

- [ ] Optional test harness
      - `tests/` folder with README and stub cases
- [ ] Sample data
      - `samples/harmless.mbox` and `samples/payload.mbox` for local testing
- [ ] Document trust boundary
      - Clarify boxer is static only; no verification of message authenticity
- [ ] Changelog automation prep
      - Scripted changelog updates for version bumps

-------------------------------------------------------------------------------
Last updated: 2025-05-26 by ChatGPT
