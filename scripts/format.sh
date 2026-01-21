#!/bin/bash

# Format script - Formats Kotlin, Swift, Dart, XML, Gradle, and Podfiles

set +e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Capitalize first letter (portable)
capitalize() {
    local str="$1"
    local first=$(echo "$str" | cut -c1 | tr '[:lower:]' '[:upper:]')
    local rest=$(echo "$str" | cut -c2-)
    echo "${first}${rest}"
}

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

FORMAT_KOTLIN=false
FORMAT_SWIFT=false
FORMAT_DART=false
FORMAT_XML=false
FORMAT_GRADLE=false
FORMAT_PODFILE=false

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Format code files"
    echo ""
    echo "Options:"
    echo "  --kotlin, -k      Format Kotlin files (.kt)"
    echo "  --swift, -s       Format Swift files (.swift)"
    echo "  --gradle, -g      Format Gradle files (.gradle, .gradle.kts)"
    echo "  --dart, -d        Format Dart files (.dart)"
    echo "  --xml, -x         Format XML files (.xml)"
    echo "  --podfile, -p     Format Podfiles"
    echo "  --all, -a         Format all file types (default)"
    echo "  --help, -h        Show this help"
    exit 0
}

if [ $# -eq 0 ]; then
    FORMAT_KOTLIN=true FORMAT_SWIFT=true FORMAT_DART=true
    FORMAT_XML=true FORMAT_GRADLE=true FORMAT_PODFILE=true
else
    while [[ $# -gt 0 ]]; do
        case $1 in
            --kotlin|-k) FORMAT_KOTLIN=true ;;
            --swift|-s) FORMAT_SWIFT=true ;;
            --dart|-d) FORMAT_DART=true ;;
            --xml|-x) FORMAT_XML=true ;;
            --gradle|-g) FORMAT_GRADLE=true ;;
            --podfile|-p) FORMAT_PODFILE=true ;;
            --all|-a)
                FORMAT_KOTLIN=true FORMAT_SWIFT=true FORMAT_DART=true
                FORMAT_XML=true FORMAT_GRADLE=true FORMAT_PODFILE=true
                ;;
            --help|-h) show_help ;;
            *) echo -e "${RED}Unknown option: $1${NC}"; exit 1 ;;
        esac
        shift
    done
fi

FORMAT_LIST=()
[ "$FORMAT_KOTLIN" = true ] && FORMAT_LIST+=("Kotlin")
[ "$FORMAT_SWIFT" = true ] && FORMAT_LIST+=("Swift")
[ "$FORMAT_DART" = true ] && FORMAT_LIST+=("Dart")
[ "$FORMAT_XML" = true ] && FORMAT_LIST+=("XML")
[ "$FORMAT_GRADLE" = true ] && FORMAT_LIST+=("Gradle")
[ "$FORMAT_PODFILE" = true ] && FORMAT_LIST+=("Podfiles")

[ ${#FORMAT_LIST[@]} -eq 0 ] && { echo -e "${YELLOW}No file types selected${NC}"; exit 1; }

FORMAT_STR=$(printf '%s, ' "${FORMAT_LIST[@]}" | sed 's/, $//')
echo -e "${BLUE}🔧 Formatting ${FORMAT_STR}...${NC}\n"

SKIPPED=0

command_exists() { command -v "$1" >/dev/null 2>&1; }

# Generic file-by-file formatter
# Args: pattern exclude_paths format_cmd
format_per_file() {
    local pattern="$1" exclude="$2" cmd="$3"
    local files=()
    while IFS= read -r -d '' f; do files+=("$f"); done < <(find . -name "$pattern" -not -path "./.git/*" -not -path "*/build/*" -not -path "*/DerivedData/*" $(echo "$exclude" | sed 's/[^ ]*/ -not -path "&"/g') -print0)
    [ ${#files[@]} -eq 0 ] && return
    for f in "${files[@]}"; do
        local before=$(md5sum "$f" 2>/dev/null | cut -d' ' -f1 || echo "")
        [ -z "$before" ] && continue
        eval "$cmd \"\$f\"" >/dev/null 2>&1
        local after=$(md5sum "$f" 2>/dev/null | cut -d' ' -f1 || echo "")
        [ -n "$after" ] && [ "$before" != "$after" ] && {
            echo -e "    ${GREEN}✓${NC}  Formatted: ${f#./}"
        }
    done
}

# Generic batch formatter (for tools that format all files at once)
# Args: lang_name format_cmd parse_output_cmd tool_name
format_batch() {
    local lang="$1" cmd="$2" parse="$3" tool="$4"
    local lang_display=$(capitalize "$lang")
    echo -e "${BLUE}📝 Formatting ${lang_display} files...${NC}"
    echo "  Using $tool..."
    local output=$(eval "$cmd" 2>&1)
    eval "$parse"
    echo ""
}

# Language-specific formatters
[ "$FORMAT_KOTLIN" = true ] && {
    echo -e "${BLUE}📝 Formatting Kotlin files...${NC}"
    if command_exists ktlint; then
        echo "  Using ktlint..."
        files=()
        while IFS= read -r -d '' f; do files+=("$f"); done < <(find . -name "*.kt" -not -path "./.git/*" -not -path "*/build/*" -print0)
        [ ${#files[@]} -eq 0 ] && { echo ""; } || {
            output=$(ktlint -F "${files[@]}" 2>&1)
            echo "$output" | grep -E "^.*\.kt:" | grep -v "cannot be auto-corrected" | cut -d: -f1 | sort -u | while read -r f; do [ -n "$f" ] && echo -e "    ${GREEN}✓${NC}  Formatted: ${f#./}"; done
            echo "$output" | grep "cannot be auto-corrected" | while read -r line; do
                f=$(echo "$line" | cut -d: -f1)
                w=$(echo "$line" | sed 's/^[^:]*: *//')
                [ -n "$f" ] && echo -e "    ${YELLOW}⚠${NC}  ${f#./}: $w"
            done
        }
    elif command_exists ktfmt; then
        echo "  Using ktfmt..."
        format_per_file "*.kt" "" "ktfmt \"\$f\""
    else
        echo -e "${YELLOW}  ⚠️  Skipping: ktlint or ktfmt not found${NC}"
        SKIPPED=$((SKIPPED + 1))
    fi
    echo ""
}

[ "$FORMAT_SWIFT" = true ] && format_batch "swift" \
    "swiftformat . --swiftversion 5.0 --exclude .git,build,DerivedData,Pods 2>&1" \
    'echo "$output" | grep -E "^[^/]*\.swift" | grep "formatted" | while read -r l; do echo -e "    ${GREEN}✓${NC}  Formatted: $(echo "$l" | sed "s/ .*//" | sed "s|^\./||")"; done; echo "$output" | grep -iE "warning|error" | while read -r w; do echo -e "    ${YELLOW}⚠${NC}  $w"; done' \
    "swiftformat"

[ "$FORMAT_DART" = true ] && {
    if command_exists dart; then
        format_batch "dart" \
            "dart format . 2>&1" \
            'echo "$output" | grep -iE "warning|error" | while read -r w; do echo -e "    ${YELLOW}⚠${NC}  $w"; done' \
            "dart"
    elif command_exists flutter; then
        format_batch "dart" \
            "flutter format . 2>&1" \
            'echo "$output" | grep -iE "warning|error" | while read -r w; do echo -e "    ${YELLOW}⚠${NC}  $w"; done' \
            "flutter"
    else
        echo -e "${BLUE}📝 Formatting Dart files...${NC}"
        echo -e "${YELLOW}  ⚠️  Skipping: dart or flutter not found${NC}"
        SKIPPED=$((SKIPPED + 1))
        echo ""
    fi
}

[ "$FORMAT_XML" = true ] && {
    echo -e "${BLUE}📝 Formatting XML files...${NC}"
    if command_exists xmllint; then
        echo "  Using xmllint..."
        format_per_file "*.xml" "./Pods/*" "xmllint --format \"\$f\" > \"\$f.tmp\" && mv \"\$f.tmp\" \"\$f\" || rm -f \"\$f.tmp\""
        # Clean up any leftover .tmp files
        find . -name "*.xml.tmp" -not -path "./.git/*" -not -path "./build/*" -delete 2>/dev/null || true
    elif command_exists prettier; then
        echo "  Using prettier..."
        format_per_file "*.xml" "./Pods/*" "prettier --write \"\$f\""
    else
        echo -e "${YELLOW}  ⚠️  Skipping: xmllint or prettier not found${NC}"
        SKIPPED=$((SKIPPED + 1))
    fi
    echo ""
}

[ "$FORMAT_GRADLE" = true ] && {
    echo -e "${BLUE}📝 Formatting Gradle files...${NC}"
    has_tool=false
    if command_exists ktlint; then
        echo "  Using ktlint for .gradle.kts files..."
        format_per_file "*.gradle.kts" "./Pods/*" "ktlint -F \"\$f\""
        has_tool=true
    fi
    if command_exists npm-groovy-lint; then
        echo "  Using npm-groovy-lint for .gradle files..."
        format_per_file "*.gradle" "./Pods/*" "npm-groovy-lint --format \"\$f\" --no-insight"
        has_tool=true
    fi
    [ "$has_tool" = false ] && {
        echo -e "${YELLOW}  ⚠️  Skipping: ktlint or npm-groovy-lint not found${NC}"
        SKIPPED=$((SKIPPED + 1))
    }
    echo ""
}

[ "$FORMAT_PODFILE" = true ] && {
    echo -e "${BLUE}📝 Formatting Podfiles...${NC}"
    if command_exists rubocop; then
        echo "  Using rubocop..."
        files=()
        while IFS= read -r -d '' f; do files+=("$f"); done < <(find . -name "Podfile" -not -path "./.git/*" -not -path "*/build/*" -not -path "./Pods/*" -print0)
        [ ${#files[@]} -eq 0 ] && { echo ""; } || {
            for f in "${files[@]}"; do
                before=$(md5sum "$f" 2>/dev/null | cut -d' ' -f1 || echo "")
                output=$(rubocop -A "$f" 2>&1)
                after=$(md5sum "$f" 2>/dev/null | cut -d' ' -f1 || echo "")
                [ -n "$before" ] && [ -n "$after" ] && [ "$before" != "$after" ] && {
                    echo -e "    ${GREEN}✓${NC}  Formatted: ${f#./}"
                }
                echo "$output" | grep -E "^[A-Z]/" | while read -r o; do
                    echo -e "    ${YELLOW}⚠${NC}  ${f#./}: $o"
                done
            done
        }
    elif command_exists prettier; then
        echo "  Using prettier..."
        format_per_file "Podfile" "./Pods/*" "prettier --write \"\$f\""
    else
        echo -e "${YELLOW}  ⚠️  Skipping: rubocop or prettier not found${NC}"
        SKIPPED=$((SKIPPED + 1))
    fi
    echo ""
}

[ $SKIPPED -eq 0 ] && echo -e "${GREEN}✅ Formatting complete!${NC}" || \
    echo -e "${YELLOW}⚠️  Formatting complete with $SKIPPED skipped formatter(s)${NC}"
