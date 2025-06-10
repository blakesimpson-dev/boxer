#!/usr/bin/env bash
# ----------------------------------------------------------------------------
#  boxer.sh
#  Safe static audit of mbox files for attachments, encodings, and red flags
#
#  Author: Blake Simpson
#  License: MIT
#  Version: 1.0.0
#  Usage: ./boxer.sh path/to/file.mbox [--summary|--verbose]
# ----------------------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
source "$(dirname "$0")/boxer.conf"

VERSION_FILE="$(dirname "$0")/VERSION"

# ----------------------------------------------------------------------------
# log_*(): Colored logging
# Globals: COLOR_*
# ----------------------------------------------------------------------------
log_info() { echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $*" >&1; }
log_warn() { echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $*" >&1; }
log_error() { echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2; }
log_success() { echo -e "${COLOR_GREEN}[OK]${COLOR_RESET} $*" >&1; }

# ----------------------------------------------------------------------------
# check_dependencies(): Validate required commands
# ----------------------------------------------------------------------------
check_dependencies() {
  for cmd in grep awk sed head tail; do
    if ! command -v "$cmd" >/dev/null; then
      log_error "Missing required command: $cmd"
      exit 1
    fi
  done
}

# ----------------------------------------------------------------------------
# init_flags(): Initialize default flag states
# ----------------------------------------------------------------------------
init_flags() {
  SUMMARY=$FALSE
  VERBOSE=$FALSE
}

# ----------------------------------------------------------------------------
# parse_args(): Handle CLI args and flags
# ----------------------------------------------------------------------------
parse_args() {
  if [[ $# -lt 1 ]]; then
    log_error "Usage: $0 <mbox_file> [--summary|--verbose|--version]"
    exit 1
  fi

  MBOX_FILE="$1"
  shift

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --summary) SUMMARY=$TRUE ;;
      --verbose) VERBOSE=$TRUE ;;
      --version | -v)
        cat "$VERSION_FILE"
        exit 0
        ;;
      *)
        log_error "Unknown argument: $1"
        exit 1
        ;;
    esac
    shift
  done

  if [[ ! -r "$MBOX_FILE" ]]; then
    log_error "Cannot read mbox file: $MBOX_FILE"
    exit 1
  fi
}

# ----------------------------------------------------------------------------
# audit_mbox(): Main audit logic
# Globals: MBOX_FILE, SUSPICIOUS_EXTENSIONS, BASE64_PATTERN
# ----------------------------------------------------------------------------
audit_mbox() {
  log_info "Auditing $MBOX_FILE"

  local msg_count=0
  local attach_count=0
  local suspect_count=0

  awk -v sus_ext="$SUSPICIOUS_EXTENSIONS" -v b64="$BASE64_PATTERN" '
    BEGIN {
      RS="\nFrom ";
      FS="\n";
      split(sus_ext, extarr, " ");
    }
    {
      msg_count++;

      for (i=1; i<=NF; i++) {
        line = $i;

        if (line ~ /^Subject:/) {
          subject = line;
        }

        if (line ~ /^Content-Disposition:.*filename=/) {
          attach_count++;
          for (j in extarr) {
            if (line ~ "\\." extarr[j] "\"?$") {
              suspect_count++;
              print "[SUSPICIOUS ATTACHMENT] " line;
            }
          }
        }

        if (line ~ /^Content-Transfer-Encoding: base64/) {
          if ($(i+1) ~ b64) {
            print "[BASE64 DETECTED] Message " msg_count ": potential binary blob";
          }
        }

        if (line ~ /^X-Attachment-Id:/ || line ~ /^X-Malware-Name:/) {
          print "[SUSPICIOUS HEADER] " line;
        }
      }

      if (ENVIRON["VERBOSE"] == 1) {
        print "----- EMAIL #" msg_count " -----";
        print subject;
        print "----------------------------";
      }
    }
    END {
      print "[SUMMARY] Messages: " msg_count;
      print "[SUMMARY] Attachments: " attach_count;
      print "[SUMMARY] Suspect: " suspect_count;
    }
  ' "$MBOX_FILE"
}

# ----------------------------------------------------------------------------
# main(): Entry point
# ----------------------------------------------------------------------------
main() {
  check_dependencies
  init_flags
  parse_args "$@"

  if [[ $SUMMARY -eq $TRUE ]]; then
    export VERBOSE=0
  elif [[ $VERBOSE -eq $TRUE ]]; then
    export VERBOSE=1
  else
    export VERBOSE=0
  fi

  audit_mbox
}

main "$@"
