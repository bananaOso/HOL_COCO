#!/bin/bash
# validate-sql.sh
# PreToolUse hook that blocks dangerous SQL operations without safety clauses.
# Reads JSON input from stdin, checks the SQL content, and blocks or allows.

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null)

if [ "$TOOL_NAME" != "snowflake_sql_execute" ]; then
    echo '{"decision": "allow"}'
    exit 0
fi

SQL=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
sql = data.get('tool_input', {}).get('sql', '')
print(sql.upper())
" 2>/dev/null)

if echo "$SQL" | grep -qE '^\s*(DROP\s+TABLE|DROP\s+DATABASE|DROP\s+SCHEMA)' ; then
    echo '{"decision": "block", "reason": "BLOCKED: DROP statements are not allowed. Please confirm with your team lead before dropping objects."}'
    exit 2
fi

if echo "$SQL" | grep -qE '^\s*TRUNCATE\s+' ; then
    echo '{"decision": "block", "reason": "BLOCKED: TRUNCATE is not allowed via Cortex Code. Use the Snowsight UI for destructive operations."}'
    exit 2
fi

if echo "$SQL" | grep -qE '^\s*DELETE\s+' && ! echo "$SQL" | grep -qE 'WHERE' ; then
    echo '{"decision": "block", "reason": "BLOCKED: DELETE without a WHERE clause would remove all rows. Add a WHERE clause to proceed."}'
    exit 2
fi

echo '{"decision": "allow"}'
exit 0