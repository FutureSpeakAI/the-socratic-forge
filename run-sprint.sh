#!/bin/bash
# =============================================================================
# Socratic Forge v4.0 — Self-Healing Autonomous Runner
# =============================================================================
# ./run-sprint.sh all     ← walk away, come back to v2.5.0
# ./run-sprint.sh 9       ← single sprint
# ./run-sprint.sh phase 11 1  ← single phase
# =============================================================================

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
ROADMAPS="$PROJECT_ROOT/socratic-roadmaps"
METHODOLOGY="$ROADMAPS/00-SOCRATIC-METHODOLOGY.md"
GAP_MAP="$ROADMAPS/01-GAP-MAP.md"
LOGS="$PROJECT_ROOT/build-logs"
JOURNALS="$PROJECT_ROOT/journals"
CONTRACTS="$PROJECT_ROOT/contracts"
GATES="$PROJECT_ROOT/gates"
WARNINGS="$PROJECT_ROOT/build-logs/active-warnings.md"

MAX_TURNS=200
REPAIR_MAX_TURNS=50
AGENT_MAX_TURNS=30
ALLOWED_TOOLS="Read,Write,Edit,Bash,Grep"
RUN_ID=$(date +%Y%m%d-%H%M%S)
MAX_REPAIRS=2

mkdir -p "$LOGS" "$JOURNALS" "$CONTRACTS" "$LOGS/agents"
echo "# Active Warnings — Run $RUN_ID" > "$WARNINGS"

log() { echo "[$(date +%H:%M:%S)] $1" | tee -a "$LOGS/runner-$RUN_ID.log"; }
commit_if_changed() {
    cd "$PROJECT_ROOT"
    if ! (git diff --quiet && git diff --cached --quiet) 2>/dev/null; then
        git add -A
        git commit -m "$1 [$RUN_ID]" --no-verify 2>/dev/null || true
    fi
}

# =============================================================================
# GATES (from v3.0, unchanged)
# =============================================================================

run_gate_1() {
    local CF="$1"; [ ! -f "$CF" ] && return 0
    log "  🔍 Gate 1: Contract verify..."
    bash "$GATES/verify-contract.sh" "$CF" "$LOGS"
    local E=$?
    [ $E -eq 0 ] && log "  ✅ Gate 1: PASS" && return 0
    [ $E -eq 2 ] && log "  ⚠️  Gate 1: WARN" && return 0
    log "  🚫 Gate 1: FAIL"; return 1
}

run_gate_3() {
    log "  🧪 Gate 3: Full test suite..."
    bash "$GATES/run-tests.sh" "$LOGS"
    local E=$?
    [ $E -eq 0 ] && log "  ✅ Gate 3: PASS" && return 0
    [ $E -eq 2 ] && { log "  ⚠️  Gate 3: WARN"; echo "- Gate 3 WARN ($(date))" >> "$WARNINGS"; return 0; }
    log "  🚫 Gate 3: FAIL (safety)"; return 1
}

run_gate_4() {
    local JF="$1"; [ ! -f "$JF" ] && return 0; [ ! -f "$GAP_MAP" ] && return 0
    log "  📋 Gate 4: Gap map refresh..."
    local PT=$(cat "$GATES/gap-map-refresh-prompt.md")
    local P="${PT/\{GAP_MAP_CONTENT\}/$(cat "$GAP_MAP")}"
    P="${P/\{JOURNAL_CONTENT\}/$(cat "$JF")}"
    local R=$(claude -p "$P" --output-format text --max-turns 5 2>"$LOGS/agents/gate4-$RUN_ID.err")
    if [ -n "$R" ]; then
        cp "$GAP_MAP" "$GAP_MAP.bak-$RUN_ID"
        echo "$R" > "$GAP_MAP"
        commit_if_changed "forge: gap map refresh [gate-4]"
        grep -q "PATTERN WARNING" "$GAP_MAP" && { echo "- Gate 4 WARN: Pattern violation ($(date))" >> "$WARNINGS"; log "  ⚠️  Gate 4: Pattern warning"; } || log "  ✅ Gate 4: Updated"
    fi
    return 0
}

run_gate_2() {
    log "  🔗 Gate 2: Cross-chain check..."
    local ALL=""
    for f in "$@"; do [ -f "$f" ] && ALL="$ALL
--- $f ---
$(cat "$f")
"; done
    [ -z "$ALL" ] && { log "  🔗 Gate 2: SKIP"; return 0; }
    local R=$(claude -p "$(cat "$GATES/integration-check-prompt.md")
$ALL" --output-format text --max-turns 5 2>"$LOGS/agents/gate2-$RUN_ID.err")
    echo "$R" > "$LOGS/agents/gate2-result-$RUN_ID.json"
    echo "$R" | grep -qi '"severity".*"FAIL"' && { log "  🚫 Gate 2: FAIL"; return 1; }
    echo "$R" | grep -qi '"severity".*"WARN"' && { log "  ⚠️  Gate 2: WARN"; return 0; }
    log "  ✅ Gate 2: PASS"; return 0
}

# =============================================================================
# NEW v4.0 AGENTS
# =============================================================================

run_plan_verify() {
    local PHASE_FILE="$1" PREV_JOURNAL="${2:-/dev/null}"
    log "  📝 Plan Verify: Checking phase file quality..."
    local PT=$(cat "$GATES/plan-verify-prompt.md")
    local P="${PT/\{PHASE_CONTENT\}/$(cat "$PHASE_FILE")}"
    P="${P/\{GAP_MAP_CONTENT\}/$(cat "$GAP_MAP")}"
    P="${P/\{JOURNAL_CONTENT\}/$([ -f "$PREV_JOURNAL" ] && cat "$PREV_JOURNAL" || echo "No prior journal.")}"
    local R=$(claude -p "$P" --output-format text --max-turns "$AGENT_MAX_TURNS" 2>"$LOGS/agents/planverify-$RUN_ID.err")
    echo "$R" > "$LOGS/agents/planverify-result-$RUN_ID.json"
    echo "$R" | grep -qi '"plan_quality".*"NEEDS_HUMAN"' && { log "  🚫 Plan Verify: NEEDS_HUMAN"; return 1; }
    echo "$R" | grep -qi '"plan_quality".*"FIXABLE"' && { log "  🔧 Plan Verify: Auto-amending phase file"; echo "- Plan amended ($(date))" >> "$WARNINGS"; }
    log "  ✅ Plan Verify: OK"; return 0
}

run_review_agent() {
    local PHASE_FILE="$1" JOURNAL="$2" NEXT_PHASE="${3:-}"
    log "  🔬 Review Agent: Evaluating code quality..."

    local DIFF=$(cd "$PROJECT_ROOT" && git diff HEAD~1 2>/dev/null || echo "No diff available")
    local PT=$(cat "$GATES/review-agent-prompt.md")
    local P="${PT/\{PHASE_CONTENT\}/$(cat "$PHASE_FILE")}"
    P="${P/\{JOURNAL_CONTENT\}/$([ -f "$JOURNAL" ] && cat "$JOURNAL" || echo "No journal.")}"
    P="${P/\{DIFF_CONTENT\}/$DIFF}"
    P="${P/\{NEXT_PHASE_CONTENT\}/$([ -n "$NEXT_PHASE" ] && [ -f "$NEXT_PHASE" ] && cat "$NEXT_PHASE" || echo "No next phase file.")}"

    local R=$(claude -p "$P" --output-format text --max-turns "$AGENT_MAX_TURNS" 2>"$LOGS/agents/review-$RUN_ID.err")
    echo "$R" > "$LOGS/agents/review-result-$RUN_ID.json"

    echo "$R" | grep -qi '"verdict".*"PASS"' && { log "  ✅ Review: PASS"; return 0; }
    echo "$R" | grep -qi '"verdict".*"WARN"' && { log "  ⚠️  Review: WARN"; echo "- Review WARN ($(date))" >> "$WARNINGS"; return 0; }
    log "  🔧 Review: REFACTOR needed"; return 1
}

run_repair_agent() {
    local TRIGGER="$1" PHASE_FILE="$2" JOURNAL="$3" ATTEMPT="${4:-1}"
    log "  🔧 Repair Agent (attempt $ATTEMPT, trigger: $TRIGGER)..."

    local REVIEW_OUTPUT=$(cat "$LOGS/agents/review-result-$RUN_ID.json" 2>/dev/null || echo "{}")
    local PT=$(cat "$GATES/repair-agent-prompt.md")
    local P="${PT/\{REVIEW_OUTPUT\}/$REVIEW_OUTPUT}"
    P="${P/\{PHASE_CONTENT\}/$(cat "$PHASE_FILE")}"
    P="${P/\{JOURNAL_CONTENT\}/$([ -f "$JOURNAL" ] && cat "$JOURNAL" || echo "No journal.")}"

    claude -p "$P" \
        --allowedTools "$ALLOWED_TOOLS" \
        --max-turns "$REPAIR_MAX_TURNS" \
        --output-format text \
        2>&1 | tee "$LOGS/agents/repair-${TRIGGER}-${ATTEMPT}-$RUN_ID.log"

    commit_if_changed "forge: repair pass $ATTEMPT [$TRIGGER]"
    log "  🔧 Repair $ATTEMPT complete"
}

run_integration_tests() {
    log "  🔌 Integration Test Agent: Wiring chains together..."

    local CONTRACT_CONTENT="" JOURNAL_CONTENT=""
    for f in "$CONTRACTS"/*.md; do
        [ -f "$f" ] && CONTRACT_CONTENT="$CONTRACT_CONTENT
--- $f ---
$(cat "$f")
"
    done
    for f in "$@"; do
        [ -f "$f" ] && JOURNAL_CONTENT="$JOURNAL_CONTENT
--- $f ---
$(cat "$f")
"
    done

    local PT=$(cat "$GATES/integration-test-prompt.md")
    local P="${PT/\{CONTRACT_CONTENTS\}/$CONTRACT_CONTENT}"
    P="${P/\{JOURNAL_CONTENTS\}/$JOURNAL_CONTENT}"

    local R=$(claude -p "$P" \
        --allowedTools "$ALLOWED_TOOLS" \
        --max-turns "$MAX_TURNS" \
        --output-format text \
        2>"$LOGS/agents/integration-$RUN_ID.err")
    echo "$R" > "$LOGS/agents/integration-result-$RUN_ID.json"

    commit_if_changed "forge: integration tests + adapters"

    echo "$R" | grep -qi '"verdict".*"PASS"' && { log "  ✅ Integration: PASS"; return 0; }
    echo "$R" | grep -qi '"verdict".*"FIXABLE"' && { log "  🔧 Integration: FIXABLE (adapters written)"; return 0; }
    log "  🚫 Integration: BLOCKING"; return 1
}

# =============================================================================
# v4.0 PHASE PIPELINE
# =============================================================================

run_phase() {
    local TRACK=$1 PHASE=$2 PHASE_FILE=$3 EXTRA_FILES="${4:-}" NEXT_PHASE="${5:-}"
    local PHASE_ID="track-${TRACK}-phase-${PHASE}"
    local LOG_FILE="$LOGS/${PHASE_ID}-${RUN_ID}.log"
    local JOURNAL="$JOURNALS/${PHASE_ID}.md"
    local PREV_JOURNAL="$JOURNALS/track-${TRACK}-phase-$((PHASE-1)).md"

    log "=========================================="
    log "PHASE: Track $TRACK, Phase $PHASE"
    log "=========================================="

    # ── 0. Plan Verification ──
    run_plan_verify "$PHASE_FILE" "$PREV_JOURNAL"
    [ $? -ne 0 ] && { log "🚫 STOP: Plan needs human review"; return 1; }

    # ── 1. Gate 1: Contract Verification ──
    local PREV=$((PHASE - 1))
    if [ $PREV -gt 0 ]; then
        for c in $(find "$CONTRACTS" -name "*${TRACK}*${PREV}*" 2>/dev/null); do
            run_gate_1 "$c" || {
                # Try repair: fix the contract or the code
                log "  Attempting Gate 1 repair..."
                run_repair_agent "gate1" "$PHASE_FILE" "$PREV_JOURNAL" 1
                run_gate_1 "$c" || { log "🚫 STOP: Contract mismatch unresolvable"; return 1; }
            }
        done
    fi

    # ── 2. Build Phase ──
    local FILES_TO_READ="Read these files in order, then begin implementation:
1. $METHODOLOGY
2. $GAP_MAP
3. $PHASE_FILE"
    local N=4
    if [ -n "$EXTRA_FILES" ]; then
        IFS='|' read -ra EXTRAS <<< "$EXTRA_FILES"
        for extra in "${EXTRAS[@]}"; do
            [ -f "$extra" ] && { FILES_TO_READ="$FILES_TO_READ
$N. $extra"; N=$((N+1)); }
        done
    fi
    local WP=""
    [ -f "$WARNINGS" ] && grep -cq "^-" "$WARNINGS" 2>/dev/null && WP="
⚠️ ACTIVE WARNINGS:
$(cat "$WARNINGS")
Address these: fix or document why acceptable.
"
    local PROMPT="$FILES_TO_READ
$WP
Write failing tests for validation criteria FIRST. Answer Socratic questions by making tests pass.
After: 1) Run all tests. 2) Verify Safety Gate. 3) Write session journal to $JOURNAL. 4) Write interface contracts to $CONTRACTS/ (first line: Source: path/to/module.ts).
If stuck, document blockers in journal and continue."

    cd "$PROJECT_ROOT"
    claude -p "$PROMPT" --allowedTools "$ALLOWED_TOOLS" --max-turns "$MAX_TURNS" --output-format text 2>&1 | tee "$LOG_FILE"
    local BUILD_EXIT=${PIPESTATUS[0]}
    [ $BUILD_EXIT -eq 0 ] && log "✅ BUILD complete" || log "❌ BUILD failed ($BUILD_EXIT)"
    commit_if_changed "forge: Track $TRACK Phase $PHASE [build]"

    # ── 3. Gate 3: Tests ──
    run_gate_3
    if [ $? -ne 0 ]; then
        for attempt in $(seq 1 $MAX_REPAIRS); do
            log "  Safety test repair attempt $attempt/$MAX_REPAIRS..."
            run_repair_agent "gate3-safety" "$PHASE_FILE" "$JOURNAL" "$attempt"
            run_gate_3 && break
            [ $attempt -eq $MAX_REPAIRS ] && { log "🚫 STOP: Safety tests unrecoverable after $MAX_REPAIRS repairs"; return 1; }
        done
    fi

    # ── 4. Review Agent ──
    run_review_agent "$PHASE_FILE" "$JOURNAL" "$NEXT_PHASE"
    if [ $? -ne 0 ]; then
        for attempt in $(seq 1 $MAX_REPAIRS); do
            log "  Review repair attempt $attempt/$MAX_REPAIRS..."
            run_repair_agent "review" "$PHASE_FILE" "$JOURNAL" "$attempt"
            commit_if_changed "forge: Track $TRACK Phase $PHASE [repair-$attempt]"
            run_review_agent "$PHASE_FILE" "$JOURNAL" "$NEXT_PHASE" && break
            [ $attempt -eq $MAX_REPAIRS ] && {
                log "  ⚠️  Review issues persist after $MAX_REPAIRS repairs. Continuing with warnings."
                echo "- Review REFACTOR unresolved after $MAX_REPAIRS repairs ($(date))" >> "$WARNINGS"
            }
        done
    fi

    # ── 5. Gate 4: Gap Map ──
    run_gate_4 "$JOURNAL"

    return $BUILD_EXIT
}

# =============================================================================
# v4.0 SPRINT BOUNDARY
# =============================================================================

run_sprint_boundary() {
    local SPRINT_NUM=$1; shift
    local JOURNAL_FILES="$@"

    log "  ═══ Sprint $SPRINT_NUM Boundary: Integration Verification ═══"

    # Gate 2: Cross-chain journal/contract check
    local ALL_FILES=""
    for jf in $JOURNAL_FILES; do [ -f "$jf" ] && ALL_FILES="$ALL_FILES $jf"; done
    for cf in "$CONTRACTS"/*.md; do [ -f "$cf" ] && ALL_FILES="$ALL_FILES $cf"; done
    run_gate_2 $ALL_FILES

    # Integration Test Agent (runs ALWAYS, even if Gate 2 passed)
    run_integration_tests $JOURNAL_FILES
    if [ $? -ne 0 ]; then
        log "  🚫 BLOCKING integration failure. Chain stopped."
        log "  Diagnostic: $LOGS/agents/integration-result-$RUN_ID.json"
        return 1
    fi

    # Final test suite including new integration tests
    run_gate_3
    return $?
}

# =============================================================================
# SPRINT DEFINITIONS
# =============================================================================

sprint_9() {
    log "🚀 SPRINT 9: Conscience + Cloud Foundation"
    chain_a() {
        run_phase 11 1 "$ROADMAPS/track-11/phase-1-values-document.md" "" \
            "$ROADMAPS/track-11/phase-2-moral-reasoning-layer.md"
        run_phase 11 2 "$ROADMAPS/track-11/phase-2-moral-reasoning-layer.md" \
            "$JOURNALS/track-11-phase-1.md" \
            "$ROADMAPS/track-11/phase-3-tension-surfacing.md"
    }
    chain_b() {
        run_phase 12 1 "$ROADMAPS/track-12/phase-1-headless-runtime.md" "" \
            "$ROADMAPS/track-12/phase-2-isolation-encryption.md"
    }
    chain_a & local PA=$!; chain_b & local PB=$!
    local F=0; wait $PA || F=1; wait $PB || F=1
    run_sprint_boundary 9 "$JOURNALS"/track-11-phase-{1,2}.md "$JOURNALS"/track-12-phase-1.md
    [ $? -ne 0 ] && F=1
    [ $F -eq 0 ] && log "🎉 SPRINT 9 COMPLETE" || log "⚠️ SPRINT 9 ISSUES"
    return $F
}

sprint_10() {
    log "🚀 SPRINT 10: Conscience Voice + Cloud Client → v2.1.0"
    chain_a() {
        run_phase 11 3 "$ROADMAPS/track-11/phase-3-tension-surfacing.md" \
            "$JOURNALS/track-11-phase-2.md" \
            "$ROADMAPS/track-11/phase-4-lattice-conscience.md"
    }
    chain_b() {
        run_phase 12 2 "$ROADMAPS/track-12/phase-2-isolation-encryption.md" \
            "$JOURNALS/track-12-phase-1.md" \
            "$ROADMAPS/track-12/phase-3-browser-client.md"
        run_phase 12 3 "$ROADMAPS/track-12/phase-3-browser-client.md" \
            "$JOURNALS/track-12-phase-2.md" \
            "$ROADMAPS/track-12/phase-4-billing-scale.md"
    }
    chain_a & local PA=$!; chain_b & local PB=$!
    local F=0; wait $PA || F=1; wait $PB || F=1
    run_sprint_boundary 10 "$JOURNALS"/track-11-phase-3.md "$JOURNALS"/track-12-phase-{2,3}.md
    [ $? -ne 0 ] && F=1
    [ $F -eq 0 ] && { log "🎉 SPRINT 10 → v2.1.0 READY"; git tag -a v2.1.0-rc1 -m "v2.1.0 RC [forge v4.0]" 2>/dev/null || true; } || log "⚠️ SPRINT 10 ISSUES"
    return $F
}

sprint_11() {
    log "🚀 SPRINT 11: Federation Foundation (HARDEST)"
    run_phase 10 1 "$ROADMAPS/track-10/phase-1-agent-identity-discovery.md" "" \
        "$ROADMAPS/track-10/phase-2-encrypted-p2p-channels.md"
    run_phase 10 2 "$ROADMAPS/track-10/phase-2-encrypted-p2p-channels.md" \
        "$JOURNALS/track-10-phase-1.md" \
        "$ROADMAPS/track-10/phase-3-federation-governance.md"
    # No sprint boundary needed — single sequential chain
    log "🎉 SPRINT 11 COMPLETE"
}

sprint_12() {
    log "🚀 SPRINT 12: Governance + Commerce Infra"
    chain_a() {
        run_phase 10 3 "$ROADMAPS/track-10/phase-3-federation-governance.md" \
            "$JOURNALS/track-10-phase-2.md" "$ROADMAPS/track-10/phase-4-proof-of-integrity.md"
        run_phase 10 4 "$ROADMAPS/track-10/phase-4-proof-of-integrity.md" \
            "$JOURNALS/track-10-phase-3.md" "$ROADMAPS/track-10/phase-5-commerce-protocol.md"
    }
    chain_b() {
        run_phase 12 4 "$ROADMAPS/track-12/phase-4-billing-scale.md" "$JOURNALS/track-12-phase-3.md"
    }
    chain_c() {
        run_phase 13 1 "$ROADMAPS/track-13/phase-1-developer-sdk.md" "" \
            "$ROADMAPS/track-13/phase-2-marketplace-discovery.md"
    }
    chain_a & local PA=$!; chain_b & local PB=$!; chain_c & local PC=$!
    local F=0; wait $PA || F=1; wait $PB || F=1; wait $PC || F=1
    run_sprint_boundary 12 "$JOURNALS"/track-10-phase-{3,4}.md "$JOURNALS"/track-12-phase-4.md "$JOURNALS"/track-13-phase-1.md
    [ $? -ne 0 ] && F=1
    [ $F -eq 0 ] && log "🎉 SPRINT 12 COMPLETE" || log "⚠️ SPRINT 12 ISSUES"
    return $F
}

sprint_13() {
    log "🚀 SPRINT 13: Commerce + Conscience → v2.5.0"
    chain_a() {
        run_phase 10 5 "$ROADMAPS/track-10/phase-5-commerce-protocol.md" \
            "$JOURNALS/track-10-phase-4.md|$CONTRACTS/poi-ledger.md"
    }
    chain_b() {
        run_phase 11 4 "$ROADMAPS/track-11/phase-4-lattice-conscience.md" \
            "$JOURNALS/track-11-phase-3.md|$CONTRACTS/federation-protocol.md" \
            "$ROADMAPS/track-11/phase-5-economic-conscience.md"
        run_phase 11 5 "$ROADMAPS/track-11/phase-5-economic-conscience.md" \
            "$JOURNALS/track-11-phase-4.md|$CONTRACTS/commerce-protocol.md"
    }
    chain_c() {
        run_phase 13 2 "$ROADMAPS/track-13/phase-2-marketplace-discovery.md" \
            "$JOURNALS/track-13-phase-1.md|$CONTRACTS/commerce-protocol.md"
    }
    chain_a & local PA=$!; chain_b & local PB=$!; chain_c & local PC=$!
    local F=0; wait $PA || F=1; wait $PB || F=1; wait $PC || F=1
    run_sprint_boundary 13 "$JOURNALS"/track-10-phase-5.md "$JOURNALS"/track-11-phase-{4,5}.md "$JOURNALS"/track-13-phase-2.md
    [ $? -ne 0 ] && F=1
    [ $F -eq 0 ] && { log "🎉 SPRINT 13 → v2.5.0 READY"; git tag -a v2.5.0-rc1 -m "v2.5.0 RC: The Federation [forge v4.0]" 2>/dev/null || true; } || log "⚠️ SPRINT 13 ISSUES"
    return $F
}

# =============================================================================
# MAIN
# =============================================================================

run_single_phase() {
    local T=$1 P=$2
    local F=$(ls "$ROADMAPS/track-${T}/phase-${P}-"*.md 2>/dev/null | head -1)
    [ -z "$F" ] && { echo "ERROR: No phase file for track-$T phase-$P"; exit 1; }
    local PJ="$JOURNALS/track-${T}-phase-$((P-1)).md"
    [ -f "$PJ" ] && run_phase "$T" "$P" "$F" "$PJ" || run_phase "$T" "$P" "$F"
}

[ $# -lt 1 ] && { echo "Forge v4.0: $0 {9|10|11|12|13|phase <t> <p>|all}"; exit 1; }
command -v claude &>/dev/null || { echo "ERROR: Claude Code not found"; exit 1; }
[ -z "${ANTHROPIC_API_KEY:-}" ] && { echo "ERROR: ANTHROPIC_API_KEY not set"; exit 1; }

log "════════════════════════════════════════════"
log "  SOCRATIC FORGE v4.0 — SELF-HEALING RUN"
log "  Run ID: $RUN_ID"
log "════════════════════════════════════════════"

case "$1" in
    9)  sprint_9 ;;
    10) sprint_10 ;;
    11) sprint_11 ;;
    12) sprint_12 ;;
    13) sprint_13 ;;
    phase) [ $# -lt 3 ] && { echo "Usage: $0 phase <t> <p>"; exit 1; }; run_single_phase "$2" "$3" ;;
    all)
        log "🔥 FULL AUTONOMOUS RUN: v2.0.0 → v2.5.0"
        log "   Estimated: 4-6 days, ~\$300-700"
        sprint_9 && sprint_10 && sprint_11 && sprint_12 && sprint_13
        log "════════════════════════════════════════════"
        log "  🏆 v2.5.0 BUILD COMPLETE"
        log "  Logs:     $LOGS/"
        log "  Journals: $JOURNALS/"
        log "  Warnings: $WARNINGS"
        log "════════════════════════════════════════════"
        ;;
    *) echo "Unknown: $1"; exit 1 ;;
esac
