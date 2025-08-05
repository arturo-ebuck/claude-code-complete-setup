# Shell Scripting Best Practices

## Shell Script Fundamentals

### 1. Shebang and Interpreter
```bash
#!/usr/bin/env bash
# Portable shebang - finds bash in PATH

#!/bin/bash
# Direct path - faster but less portable

#!/bin/sh
# POSIX shell - maximum portability
```

### 2. Essential Script Header
```bash
#!/usr/bin/env bash
#
# Script: deploy.sh
# Description: Deploy application to production
# Author: jb_remus
# Date: 2025-07-29
# Version: 1.0.0
#

set -euo pipefail  # Exit on error, undefined vars, pipe failures
IFS=$'\n\t'       # Set Internal Field Separator

# Enable debug mode if DEBUG env var is set
[[ "${DEBUG:-0}" == "1" ]] && set -x
```

### 3. Error Handling
```bash
# Basic error handling
set -e  # Exit on any error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

# Custom error handler
error_handler() {
    local line_no=$1
    local bash_lineno=$2
    local last_command=$3
    local code=$4

    echo "Error on line ${line_no}: command '${last_command}' exited with status ${code}"
    # Additional cleanup if needed
    exit "${code}"
}

trap 'error_handler ${LINENO} ${BASH_LINENO} "${BASH_COMMAND}" $?' ERR
```

## Variables and Parameters

### 1. Variable Declaration
```bash
# Declare variables with meaningful names
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_FILE="${SCRIPT_DIR}/config.conf"
readonly LOG_FILE="/var/log/myapp.log"

# Use local in functions
process_data() {
    local input_file="$1"
    local output_file="$2"
    local -r max_retries=3  # readonly local
    
    # Process...
}

# Default values
DATABASE_HOST="${DATABASE_HOST:-localhost}"
DATABASE_PORT="${DATABASE_PORT:-5432}"
VERBOSE="${VERBOSE:-false}"
```

### 2. Parameter Handling
```bash
# Positional parameters with validation
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <input> <output> [options]"
    exit 1
fi

input_file="$1"
output_file="$2"
shift 2  # Remove first two arguments

# Option parsing
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            # Positional argument
            ARGS+=("$1")
            shift
            ;;
    esac
done
```

## Functions

### 1. Function Structure
```bash
# Function with documentation
# Prints colored output to terminal
# Arguments:
#   $1 - Color code (red, green, yellow, blue)
#   $2 - Message to print
# Returns:
#   0 on success, 1 on invalid color
print_color() {
    local color="$1"
    local message="$2"
    
    case "${color}" in
        red)    echo -e "\033[0;31m${message}\033[0m" ;;
        green)  echo -e "\033[0;32m${message}\033[0m" ;;
        yellow) echo -e "\033[0;33m${message}\033[0m" ;;
        blue)   echo -e "\033[0;34m${message}\033[0m" ;;
        *)      echo "${message}"; return 1 ;;
    esac
    return 0
}

# Function with error checking
safe_copy() {
    local source="$1"
    local destination="$2"
    
    if [[ ! -f "${source}" ]]; then
        print_color red "Error: Source file '${source}' not found"
        return 1
    fi
    
    if ! cp "${source}" "${destination}"; then
        print_color red "Error: Failed to copy file"
        return 1
    fi
    
    print_color green "Successfully copied ${source} to ${destination}"
    return 0
}
```

### 2. Function Best Practices
```bash
# Return values vs exit codes
get_user_count() {
    local count
    count=$(wc -l < /etc/passwd)
    echo "${count}"  # Output result
    return 0         # Return success
}

# Capture function output
user_count=$(get_user_count)
if [[ $? -eq 0 ]]; then
    echo "User count: ${user_count}"
fi

# Global vs local variables
GLOBAL_CONFIG="/etc/myapp.conf"

load_config() {
    local config_file="${1:-${GLOBAL_CONFIG}}"
    local -n config=$2  # nameref for associative array
    
    while IFS='=' read -r key value; do
        config["${key}"]="${value}"
    done < "${config_file}"
}
```

## Input/Output Operations

### 1. File Operations
```bash
# Safe file reading
while IFS= read -r line; do
    echo "Processing: ${line}"
done < "${input_file}"

# Read with timeout
if read -t 5 -p "Enter your choice: " choice; then
    echo "You chose: ${choice}"
else
    echo "Timeout - using default"
fi

# Process substitution
diff <(sort file1.txt) <(sort file2.txt)

# Here documents
cat > "${config_file}" << 'EOF'
# Configuration file
host=localhost
port=8080
debug=false
EOF
```

### 2. Output Formatting
```bash
# Logging functions
readonly LOG_FILE="/var/log/script.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "${LOG_FILE}" >&2
}

# Progress indicators
show_progress() {
    local current=$1
    local total=$2
    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    
    printf "\rProgress: ["
    printf "%${filled}s" | tr ' ' '='
    printf "%$((50 - filled))s"
    printf "] %d%%" "${percent}"
}
```

## Control Structures

### 1. Conditionals
```bash
# File tests
if [[ -f "${file}" ]]; then
    echo "File exists"
elif [[ -d "${file}" ]]; then
    echo "Directory exists"
else
    echo "Not found"
fi

# String comparisons
if [[ -z "${var}" ]]; then
    echo "Variable is empty"
fi

if [[ "${string1}" == "${string2}" ]]; then
    echo "Strings are equal"
fi

# Numeric comparisons
if [[ ${num1} -gt ${num2} ]]; then
    echo "${num1} is greater than ${num2}"
fi

# Regular expressions
if [[ "${email}" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "Valid email"
fi
```

### 2. Loops
```bash
# For loop with array
files=("file1.txt" "file2.txt" "file3.txt")
for file in "${files[@]}"; do
    process_file "${file}"
done

# For loop with glob
for file in *.log; do
    [[ -e "${file}" ]] || continue  # Skip if no matches
    gzip "${file}"
done

# While loop with counter
counter=0
while [[ ${counter} -lt 10 ]]; do
    echo "Count: ${counter}"
    ((counter++))
done

# Until loop
until ping -c 1 google.com &> /dev/null; do
    echo "Waiting for network..."
    sleep 5
done
```

## Array Handling

### 1. Indexed Arrays
```bash
# Declaration
declare -a fruits=("apple" "banana" "orange")

# Adding elements
fruits+=("grape")
fruits[4]="mango"

# Accessing elements
echo "${fruits[0]}"      # First element
echo "${fruits[@]}"      # All elements
echo "${#fruits[@]}"     # Array length
echo "${fruits[-1]}"     # Last element (Bash 4.3+)

# Iteration
for fruit in "${fruits[@]}"; do
    echo "Fruit: ${fruit}"
done

# Slicing
echo "${fruits[@]:1:2}"  # Elements 1 and 2
```

### 2. Associative Arrays
```bash
# Declaration (Bash 4.0+)
declare -A config=(
    [host]="localhost"
    [port]="8080"
    [debug]="false"
)

# Adding/updating
config[timeout]=30
config[host]="example.com"

# Accessing
echo "${config[host]}"
echo "${!config[@]}"     # All keys
echo "${config[@]}"      # All values

# Checking existence
if [[ -v config[debug] ]]; then
    echo "Debug is set to: ${config[debug]}"
fi
```

## Process Management

### 1. Background Jobs
```bash
# Run in background
long_running_command &
pid=$!

# Wait for specific process
wait ${pid}
exit_code=$?

# Run multiple jobs in parallel
for file in *.txt; do
    process_file "${file}" &
done
wait  # Wait for all background jobs

# Job control
jobs -l  # List jobs
kill %1  # Kill job 1
```

### 2. Process Substitution
```bash
# Compare command outputs
diff <(ls dir1) <(ls dir2)

# Feed command output to while loop
while read -r user; do
    echo "Processing user: ${user}"
done < <(cut -d: -f1 /etc/passwd)

# Multiple inputs
paste <(seq 1 5) <(seq 6 10)
```

## Security Best Practices

### 1. Input Validation
```bash
# Validate user input
validate_input() {
    local input="$1"
    
    # Check for empty input
    if [[ -z "${input}" ]]; then
        echo "Error: Input cannot be empty"
        return 1
    fi
    
    # Check for special characters
    if [[ "${input}" =~ [^a-zA-Z0-9_-] ]]; then
        echo "Error: Input contains invalid characters"
        return 1
    fi
    
    # Check length
    if [[ ${#input} -gt 255 ]]; then
        echo "Error: Input too long"
        return 1
    fi
    
    return 0
}

# Sanitize filename
sanitize_filename() {
    local filename="$1"
    # Remove path components and special chars
    filename="${filename##*/}"
    filename="${filename//[^a-zA-Z0-9._-]/_}"
    echo "${filename}"
}
```

### 2. Secure Practices
```bash
# Use quotes to prevent word splitting
rm -rf "${user_input}"  # Always quote variables

# Avoid eval - use alternatives
# Bad: eval "command ${user_input}"
# Good:
case "${user_input}" in
    start) start_service ;;
    stop)  stop_service ;;
    *)     echo "Invalid command" ;;
esac

# Secure temporary files
temp_file=$(mktemp) || exit 1
trap 'rm -f "${temp_file}"' EXIT

# Restrict permissions
umask 077  # Files created with 600 permissions
```

## Performance Optimization

### 1. Efficient Commands
```bash
# Use built-ins when possible
# Slow: cat file | grep pattern
# Fast: grep pattern file

# Avoid useless cats
# Bad:  cat file | command
# Good: command < file

# Use appropriate tools
# Bad:  grep pattern file | wc -l
# Good: grep -c pattern file

# Batch operations
# Bad:
for file in *.txt; do
    mv "${file}" "${file}.bak"
done
# Good:
rename 's/\.txt$/.txt.bak/' *.txt
```

### 2. Optimization Techniques
```bash
# Cache expensive operations
get_system_info() {
    if [[ -z "${CACHED_SYSTEM_INFO}" ]]; then
        CACHED_SYSTEM_INFO=$(uname -a)
    fi
    echo "${CACHED_SYSTEM_INFO}"
}

# Use process substitution instead of temp files
# Bad:
grep pattern file > temp
process_data < temp
rm temp

# Good:
process_data < <(grep pattern file)

# Parallel processing
export -f process_file
find . -name "*.log" -print0 | \
    xargs -0 -P 4 -I {} bash -c 'process_file "$@"' _ {}
```

## Debugging and Testing

### 1. Debugging Techniques
```bash
# Debug mode
set -x  # Print commands as executed
set +x  # Disable debug mode

# Conditional debugging
[[ "${DEBUG}" == "1" ]] && set -x

# Debug specific sections
debug() {
    [[ "${DEBUG}" == "1" ]] && echo "DEBUG: $*" >&2
}

debug "Variable value: ${var}"

# Trace function calls
set -o functrace
trap 'echo "Calling: ${FUNCNAME[1]}"' DEBUG
```

### 2. Testing Scripts
```bash
# Unit test function
test_addition() {
    local result
    result=$(add 2 3)
    
    if [[ "${result}" -eq 5 ]]; then
        echo "PASS: test_addition"
        return 0
    else
        echo "FAIL: test_addition - expected 5, got ${result}"
        return 1
    fi
}

# Run tests
run_tests() {
    local failed=0
    
    test_addition || ((failed++))
    test_subtraction || ((failed++))
    test_validation || ((failed++))
    
    if [[ ${failed} -eq 0 ]]; then
        echo "All tests passed!"
        return 0
    else
        echo "${failed} tests failed"
        return 1
    fi
}
```

## Script Templates

### 1. Basic Script Template
```bash
#!/usr/bin/env bash
set -euo pipefail

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
VERBOSE=false

# Usage function
usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS] <input>

Description of what the script does.

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output
    -f, --force     Force operation

EXAMPLES:
    ${SCRIPT_NAME} input.txt
    ${SCRIPT_NAME} -v input.txt

EOF
}

# Main function
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -*)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                INPUT_FILE="$1"
                shift
                ;;
        esac
    done
    
    # Validate input
    if [[ -z "${INPUT_FILE:-}" ]]; then
        echo "Error: Input file required"
        usage
        exit 1
    fi
    
    # Main logic here
    echo "Processing ${INPUT_FILE}..."
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## Common Pitfalls and Solutions

### 1. Word Splitting
```bash
# Problem: Unquoted variables
files="file with spaces.txt"
rm $files  # Tries to remove 'file', 'with', 'spaces.txt'

# Solution: Quote variables
rm "$files"

# Arrays need special handling
arr=("file 1.txt" "file 2.txt")
# Bad:  command ${arr[@]}
# Good: command "${arr[@]}"
```

### 2. Exit Codes
```bash
# Always check important commands
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed"
    exit 1
fi

# Preserve exit codes
backup_files() {
    tar -czf backup.tar.gz /important/files
    local exit_code=$?
    
    if [[ ${exit_code} -ne 0 ]]; then
        log_error "Backup failed with code ${exit_code}"
    fi
    
    return ${exit_code}
}
```

## Best Practices Summary

1. **Always use `set -euo pipefail`**
2. **Quote all variables: `"${var}"`**
3. **Use `shellcheck` for validation**
4. **Prefer `[[ ]]` over `[ ]` in bash**
5. **Use meaningful variable names**
6. **Add error handling and logging**
7. **Make scripts idempotent**
8. **Document complex logic**
9. **Test edge cases**
10. **Keep it simple and readable**

## Last Updated
2025-07-29

## Status
ACTIVE - SHELL SCRIPTING GUIDE