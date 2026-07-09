#!/usr/bin/env bash
# ============================================================
#   DataDeck — Abstract Card Architecture  Tester
#                      v1.0
# ============================================================
# Mirrors the style/format of tester_codex.sh (PyMod06).
# Structural checks use grep (class/method presence, inheritance
# markers) since internal filenames inside ex0/ex1/ex2 are not
# mandated by the subject — only the package name and the three
# root scripts (battle.py, capacitor.py, tournament.py) are fixed.
# Output-string checks are intentionally lenient where the subject
# allows creative freedom ("you can use different Creatures").
# ============================================================

set -u

# ---------- colors ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

PASS=0
FAIL=0
PEND=0

ok() {
    echo -e "  ${GREEN}[OK]${NC} $1"
    PASS=$((PASS + 1))
}

ko() {
    echo -e "  ${RED}[KO]${NC} $1"
    if [ -n "${2:-}" ]; then
        echo -e "       ${YELLOW}↳ $2${NC}"
    fi
    FAIL=$((FAIL + 1))
}

pend() {
    echo -e "  ${CYAN}[··]${NC} $1"
    PEND=$((PEND + 1))
}

section() {
    echo ""
    echo -e "${BOLD}── $1 ─────────────────────────────────────────────${NC}"
}

banner() {
    echo -e "${BOLD}"
    echo "  ╔═══════════════════════════════════════════════════╗"
    echo "  ║   DataDeck — Abstract Card Architecture  Tester    ║"
    echo "  ║                      v1.0                          ║"
    echo "  ╚═══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo "  Python : $(python3 --version 2>&1)"
    echo "  Dir    : $(pwd)"
}

# ---------- helpers ----------
check_file() {
    if [ -f "$1" ]; then
        ok "file: $1"
    else
        ko "file: $1" "not found"
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        ok "dir:  $1"
    else
        ko "dir:  $1" "not found"
    fi
}

# grep_req <label> <pattern> <path (file or dir, dir = recursive)>
grep_req() {
    local label="$1"
    local pattern="$2"
    local path="$3"
    if [ -d "$path" ]; then
        if grep -rqE "$pattern" "$path" 2>/dev/null; then
            ok "$label"
        else
            ko "$label" "pattern not found: $pattern"
        fi
    elif [ -f "$path" ]; then
        if grep -qE "$pattern" "$path" 2>/dev/null; then
            ok "$label"
        else
            ko "$label" "pattern not found: $pattern"
        fi
    else
        ko "$label" "path not found: $path"
    fi
}

# grep_forbid <label> <pattern> <file>  (should NOT match)
grep_forbid() {
    local label="$1"
    local pattern="$2"
    local file="$3"
    if [ ! -f "$file" ]; then
        ko "$label" "file not found: $file"
        return
    fi
    if grep -qE "$pattern" "$file" 2>/dev/null; then
        ko "$label" "forbidden pattern found in $file: $pattern"
    else
        ok "$label"
    fi
}

# grep_forbid_dir <label> <pattern> <dir>  (should NOT match anywhere in dir)
grep_forbid_dir() {
    local label="$1"
    local pattern="$2"
    local dir="$3"
    if [ ! -d "$dir" ]; then
        ko "$label" "dir not found: $dir"
        return
    fi
    if grep -rqE "$pattern" "$dir" 2>/dev/null; then
        ko "$label" "forbidden pattern found in $dir: $pattern"
    else
        ok "$label"
    fi
}

# run_script <label> <script> <expect_exit_zero: yes/no> <substr1> <substr2> ...
run_script() {
    local label="$1"; shift
    local script="$1"; shift
    local expect_zero="$1"; shift
    local substrs=("$@")

    if [ ! -f "$script" ]; then
        ko "$label" "script not found: $script"
        return
    fi

    local output
    output="$(python3 "$script" 2>&1)"
    local exit_code=$?

    ok "$label header"

    local all_found=1
    local missing=""
    for s in "${substrs[@]}"; do
        if ! grep -qF -- "$s" <<< "$output"; then
            all_found=0
            missing="$missing | $s"
        fi
    done

    if [ "$all_found" -eq 1 ]; then
        ok "$label expected content present"
    else
        ko "$label expected content present" "missing substrings:$missing"
        echo "$output" | head -n 6 | sed 's/^/         /'
    fi

    if [ "$expect_zero" = "yes" ]; then
        if [ "$exit_code" -eq 0 ]; then
            ok "$label — exits 0"
        else
            ko "$label — exits 0" "non-zero exit code ($exit_code)"
        fi
    fi
}

# soft_grep_out <label> <output_var_content> <substr>  (pending, not fail)
soft_check() {
    local label="$1"
    local content="$2"
    local substr="$3"
    if grep -qF -- "$substr" <<< "$content"; then
        ok "$label"
    else
        pend "$label — customization allowed, not enforced ($substr)"
    fi
}

# ============================================================
banner

# ---------- 1. File Structure ----------
section "1 · File Structure"
check_dir "ex0"
check_file "ex0/__init__.py"
check_dir "ex1"
check_file "ex1/__init__.py"
check_dir "ex2"
check_file "ex2/__init__.py"
check_file "battle.py"
check_file "capacitor.py"
check_file "tournament.py"

# ---------- 2. Ex0 — Creature Factory structure ----------
section "2 · Ex0 Structure — Creature Factory (abstract factory pattern)"
grep_req "Creature: class definition"                 "class[[:space:]]+Creature[[:space:]]*\(" ex0
grep_req "Creature: uses ABC / abstractmethod"         "abstractmethod" ex0
grep_req "Creature: abstract attack()"                 "def[[:space:]]+attack" ex0
grep_req "Creature: concrete describe()"                "def[[:space:]]+describe" ex0
grep_req "Flameling: class inherits Creature"          "class[[:space:]]+Flameling\([^)]*Creature" ex0
grep_req "Pyrodon: class inherits Creature"             "class[[:space:]]+Pyrodon\([^)]*Creature" ex0
grep_req "Aquabub: class inherits Creature"             "class[[:space:]]+Aquabub\([^)]*Creature" ex0
grep_req "Torragon: class inherits Creature"            "class[[:space:]]+Torragon\([^)]*Creature" ex0
grep_req "CreatureFactory: class definition"            "class[[:space:]]+CreatureFactory[[:space:]]*\(" ex0
grep_req "CreatureFactory: abstract create_base()"      "def[[:space:]]+create_base" ex0
grep_req "CreatureFactory: abstract create_evolved()"   "def[[:space:]]+create_evolved" ex0
grep_req "FlameFactory: inherits CreatureFactory"       "class[[:space:]]+FlameFactory\([^)]*CreatureFactory" ex0
grep_req "AquaFactory: inherits CreatureFactory"        "class[[:space:]]+AquaFactory\([^)]*CreatureFactory" ex0
grep_forbid "ex0/__init__.py does NOT expose Flameling"  "Flameling" ex0/__init__.py
grep_forbid "ex0/__init__.py does NOT expose Pyrodon"    "Pyrodon" ex0/__init__.py
grep_forbid "ex0/__init__.py does NOT expose Aquabub"    "Aquabub" ex0/__init__.py
grep_forbid "ex0/__init__.py does NOT expose Torragon"   "Torragon" ex0/__init__.py

# ---------- 3. Ex1 — Capabilities structure ----------
section "3 · Ex1 Structure — Capabilities (composition, not inheritance from Creature)"
grep_req "HealCapability: class definition"             "class[[:space:]]+HealCapability[[:space:]]*\(" ex1
grep_req "HealCapability: abstract heal()"               "def[[:space:]]+heal" ex1
grep_forbid_dir "HealCapability does NOT inherit Creature" "class[[:space:]]+HealCapability\([^)]*Creature" ex1
grep_req "TransformCapability: class definition"         "class[[:space:]]+TransformCapability[[:space:]]*\(" ex1
grep_req "TransformCapability: abstract transform()"      "def[[:space:]]+transform" ex1
grep_req "TransformCapability: abstract revert()"         "def[[:space:]]+revert" ex1
grep_forbid_dir "TransformCapability does NOT inherit Creature" "class[[:space:]]+TransformCapability\([^)]*Creature" ex1
grep_req "Sproutling: inherits Creature + HealCapability" "class[[:space:]]+Sproutling\(.*Creature.*HealCapability|class[[:space:]]+Sproutling\(.*HealCapability.*Creature" ex1
grep_req "Bloomelle: inherits Creature + HealCapability"  "class[[:space:]]+Bloomelle\(.*Creature.*HealCapability|class[[:space:]]+Bloomelle\(.*HealCapability.*Creature" ex1
grep_req "HealingCreatureFactory: inherits CreatureFactory" "class[[:space:]]+HealingCreatureFactory\([^)]*CreatureFactory" ex1
grep_req "Shiftling: inherits Creature + TransformCapability" "class[[:space:]]+Shiftling\(.*Creature.*TransformCapability|class[[:space:]]+Shiftling\(.*TransformCapability.*Creature" ex1
grep_req "Morphagon: inherits Creature + TransformCapability" "class[[:space:]]+Morphagon\(.*Creature.*TransformCapability|class[[:space:]]+Morphagon\(.*TransformCapability.*Creature" ex1
grep_req "TransformCreatureFactory: inherits CreatureFactory" "class[[:space:]]+TransformCreatureFactory\([^)]*CreatureFactory" ex1
grep_forbid "ex1/__init__.py does NOT expose Sproutling"  "Sproutling" ex1/__init__.py
grep_forbid "ex1/__init__.py does NOT expose Bloomelle"   "Bloomelle" ex1/__init__.py
grep_forbid "ex1/__init__.py does NOT expose Shiftling"   "Shiftling" ex1/__init__.py
grep_forbid "ex1/__init__.py does NOT expose Morphagon"   "Morphagon" ex1/__init__.py

# ---------- 4. Ex2 — Abstract Strategy structure ----------
section "4 · Ex2 Structure — Abstract Strategy pattern"
grep_req "BattleStrategy: class definition"              "class[[:space:]]+BattleStrategy[[:space:]]*\(" ex2
grep_req "BattleStrategy: abstract act()"                 "def[[:space:]]+act" ex2
grep_req "BattleStrategy: abstract is_valid()"             "def[[:space:]]+is_valid" ex2
grep_req "NormalStrategy: inherits BattleStrategy"         "class[[:space:]]+NormalStrategy\([^)]*BattleStrategy" ex2
grep_req "AggressiveStrategy: inherits BattleStrategy"     "class[[:space:]]+AggressiveStrategy\([^)]*BattleStrategy" ex2
grep_req "DefensiveStrategy: inherits BattleStrategy"      "class[[:space:]]+DefensiveStrategy\([^)]*BattleStrategy" ex2
grep_req "Dedicated exception class defined"               "class[[:space:]]+[A-Za-z_]*(Error|Exception)[[:space:]]*\(" ex2

# ---------- 5. Ex0 execution — battle.py ----------
section "5 · Exercise 0: Creature Factory — battle.py"
battle_output="$(python3 battle.py 2>&1)"
battle_exit=$?
if [ -f "battle.py" ]; then
    ok "battle.py runs"
    run_script "battle.py" "battle.py" "yes" \
        "Testing factory" "Testing battle" "vs." "fight!"
    soft_check "battle.py — mentions Flameling" "$battle_output" "Flameling"
    soft_check "battle.py — mentions Aquabub" "$battle_output" "Aquabub"
    soft_check "battle.py — mentions Pyrodon (evolved)" "$battle_output" "Pyrodon"
    soft_check "battle.py — mentions Torragon (evolved)" "$battle_output" "Torragon"
else
    ko "battle.py runs" "file not found"
fi

# ---------- 6. Ex1 execution — capacitor.py ----------
section "6 · Exercise 1: Capabilities — capacitor.py"
if [ -f "capacitor.py" ]; then
    cap_output="$(python3 capacitor.py 2>&1)"
    run_script "capacitor.py" "capacitor.py" "yes" \
        "Testing Creature with healing capability" \
        "Testing Creature with transform capability" \
        "base:" "evolved:"
    soft_check "capacitor.py — mentions Sproutling" "$cap_output" "Sproutling"
    soft_check "capacitor.py — mentions Bloomelle" "$cap_output" "Bloomelle"
    soft_check "capacitor.py — mentions Shiftling" "$cap_output" "Shiftling"
    soft_check "capacitor.py — mentions Morphagon" "$cap_output" "Morphagon"
    soft_check "capacitor.py — heal action described" "$cap_output" "heal"
    soft_check "capacitor.py — transform action described" "$cap_output" "transform"
    soft_check "capacitor.py — revert action described" "$cap_output" "revert"
else
    ko "capacitor.py runs" "file not found"
fi

# ---------- 7. Ex2 execution — tournament.py ----------
section "7 · Exercise 2: Abstract Strategy — tournament.py"
if [ -f "tournament.py" ]; then
    tourn_output="$(python3 tournament.py 2>&1)"
    run_script "tournament.py" "tournament.py" "yes" \
        "Tournament" "opponents involved" "Battle" "fight!"
    soft_check "tournament.py — invalid combo handled gracefully (error message)" "$tourn_output" "rror"
    soft_check "tournament.py — NormalStrategy scenario present" "$tourn_output" "Normal"
else
    ko "tournament.py runs" "file not found"
fi

# ---------- 8. Flake8 Style ----------
section "8 · Flake8 Style"
if command -v flake8 >/dev/null 2>&1; then
    all_py_files=$(find . -name "*.py" -not -path "./.git/*" 2>/dev/null)
    for f in $all_py_files; do
        result=$(flake8 "$f" 2>&1)
        if [ -z "$result" ]; then
            ok "flake8 clean: $f"
        else
            ko "flake8: $f"
            echo "$result" | sed 's/^/         /'
        fi
    done
else
    pend "flake8 not installed — skipping style checks"
fi

# ---------- 9. Mypy Type Annotations ----------
section "9 · Mypy Type Annotations"
if command -v mypy >/dev/null 2>&1; then
    mypy_output=$(mypy . 2>&1)
    mypy_errors=$(echo "$mypy_output" | grep -c "error:")
    if [ "$mypy_errors" -eq 0 ]; then
        ok "mypy — no type errors"
    else
        ko "mypy — $mypy_errors unexpected error(s)"
        echo "$mypy_output" | grep "error:" | sed 's/^/         /'
    fi
else
    pend "mypy not installed — skipping type checks"
fi

# ============================================================
TOTAL=$((PASS + FAIL))
echo ""
echo -e "${BOLD}══════════════════════════════════════${NC}"
echo -e "${BOLD}  RESULTS${NC}"
echo -e "${BOLD}══════════════════════════════════════${NC}"
echo -e "  Passed  : ${GREEN}${PASS}${NC}"
echo -e "  Failed  : ${RED}${FAIL}${NC}"
echo -e "  Pending : ${CYAN}${PEND}${NC}  (soft checks — customization allowed by subject)"
echo -e "  Total   : ${TOTAL}"
echo -e "${BOLD}══════════════════════════════════════${NC}"
echo ""

if [ "$FAIL" -eq 0 ]; then
    echo -e "  ${GREEN}🃏  All hard checks passed! Your deck is battle-ready.${NC}"
    exit 0
else
    echo -e "  ${RED}💥  ${FAIL} test(s) failed. Check the architect's notes above.${NC}"
    exit 1
fi
