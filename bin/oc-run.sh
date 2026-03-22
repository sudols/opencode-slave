#!/usr/bin/env bash
BUFFER_DIR="$HOME/.cache/oc-buffer"
SESSION_FILE="$HOME/.cache/oc-buffer/.session_id"
STATUS_FILE="$HOME/.cache/oc-buffer/.status"
mkdir -p "$BUFFER_DIR"

FILES=()
while IFS= read -r -d '' f; do
  FILES+=("$f")
done < <(find "$BUFFER_DIR" -maxdepth 1 -type f ! -name '.*' ! -name '.session_id' -print0)

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "idle" >"$STATUS_FILE.tmp" && mv "$STATUS_FILE.tmp" "$STATUS_FILE"
  exit 0
fi

echo "buffering" >"$STATUS_FILE.tmp" && mv "$STATUS_FILE.tmp" "$STATUS_FILE"

FILE_ARGS=()
for f in "${FILES[@]}"; do
  [[ "$f" == "$SESSION_FILE" ]] && continue
  FILE_ARGS+=("-f" "$f")
done

# Build session args
SESSION_ARGS=()
if [[ -f "$SESSION_FILE" ]]; then
  SID=$(cat "$SESSION_FILE")
  SESSION_ARGS=("-s" "$SID")
fi

PROMPT="
  You are a competitive programming assistant. Your sole purpose is to solve DSA problems with pixel-perfect correctness.
  
  ## Input
  You will receive one or more of the following:
  - Images containing a DSA problem statement
  - Text containing a DSA problem statement
  - Test cases (optional)
  
  All three are optional. You will work with whatever is provided.
  
  ## Partial Input Handling
  - If ONLY an image is provided: extract and interpret the full problem from it and solve
  - If ONLY text is provided: treat it as the complete problem statement and solve
  - If ONLY test cases are provided:
    - Reverse-engineer the problem by analyzing input/output patterns across all test cases
    - Infer data types, constraints, edge cases, and the transformation logic
    - Formulate the most probable problem statement internally (do not output it)
    - Solve based on that inferred understanding
    - Your code must still pass all provided test cases exactly
  - If a mix is provided (e.g. image + test cases, text + no test cases): cross-reference all available context to produce the most accurate solution
  
  Never ask for clarification. Never state what is missing. Always attempt a solution regardless of how incomplete the input is.
  
  ## Strict Output Rules
  - Output ONLY raw, executable Python code
  - Do NOT include any explanation, comments, docstrings, or markdown
  - Do NOT wrap the code in a code block (no triple backticks)
  - Do NOT include any print statements beyond what is required for the correct output
  - The first and last line of your response must be code
  
  ## Correctness Requirements
  - The code must pass ALL provided test cases
  - Output must match the expected output EXACTLY — including whitespace, newlines, and formatting
  - Read input using standard input methods (input() or sys.stdin) unless the problem specifies otherwise
  - Handle all edge cases visible in the problem constraints
  
  ## Error Correction Protocol
  - If I report failing test cases, I will provide the test case input, your output, and the expected output. You will silently fix the logic and return the corrected full code only
  - If I report a syntax or runtime error, you will silently fix it and return the corrected full code only
  - Never explain what you changed. Never apologize. Just return the fixed code
  
  ## Language
  - Default language: Python
  - If I specify a different language, switch to it immediately and follow the same rules
"

echo "running" >"$STATUS_FILE.tmp" && mv "$STATUS_FILE.tmp" "$STATUS_FILE"
OUTPUT=$(opencode run "$PROMPT" "${FILE_ARGS[@]}" "${SESSION_ARGS[@]}" 2>/dev/null)

if [[ -z "$OUTPUT" ]]; then
  echo "error" >"$STATUS_FILE.tmp" && mv "$STATUS_FILE.tmp" "$STATUS_FILE"
  exit 1
fi

# Save session ID from the run (grab it via opencode session list -n 1)
if [[ ! -f "$SESSION_FILE" ]]; then
  NEW_SID=$(opencode session list -n 1 --format json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['id'])" 2>/dev/null)
  [[ -n "$NEW_SID" ]] && echo "$NEW_SID" >"$SESSION_FILE"
fi

# Strip markdown code fences if present
FIRST_LINE=$(echo "$OUTPUT" | head -n1)
LAST_LINE=$(echo "$OUTPUT" | tail -n1)

if [[ "$FIRST_LINE" =~ ^\`\`\`[a-zA-Z0-9]*$ ]] && [[ "$LAST_LINE" == '```' ]]; then
  # Strip first and last lines (markdown fences)
  CLEANED=$(echo "$OUTPUT" | sed '1d;$d')
  echo "$CLEANED" | wl-copy
else
  # Keep output as-is
  echo "$OUTPUT" | wl-copy
fi

echo "done" >"$STATUS_FILE.tmp" && mv "$STATUS_FILE.tmp" "$STATUS_FILE"
