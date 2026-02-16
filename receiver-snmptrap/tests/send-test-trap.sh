#!/bin/bash
# Script to send test SNMP traps to the receiver
# Requires net-snmp package (snmptrap command)

HOST="${1:-localhost}"
PORT="${2:-162}"
COMMUNITY="${3:-public}"

echo "Sending test SNMP traps to ${HOST}:${PORT} with community '${COMMUNITY}'"
echo "========================================================================"

# Test 1: Simple v2c trap with enterprise OID and custom string
echo "[Test 1] Sending SNMPv2c enterprise trap..."
snmptrap -v 2c -c "${COMMUNITY}" "${HOST}:${PORT}" '' \
    1.3.6.1.4.1.8072.2.3.0.1 \
    1.3.6.1.4.1.8072.2.3.2.1 i 123 \
    1.3.6.1.2.1.1.5.0 s "Hello from test trap!" 2>/dev/null

# Test 2: Link down notification
echo "[Test 2] Sending linkDown trap..."
snmptrap -v 2c -c "${COMMUNITY}" "${HOST}:${PORT}" '' \
    1.3.6.1.6.3.1.1.5.3 \
    1.3.6.1.2.1.2.2.1.1.1 i 1 \
    1.3.6.1.2.1.2.2.1.2.1 s "GigabitEthernet0/1" \
    1.3.6.1.2.1.2.2.1.8.1 i 2 2>/dev/null

# Test 3: Link up notification
echo "[Test 3] Sending linkUp trap..."
snmptrap -v 2c -c "${COMMUNITY}" "${HOST}:${PORT}" '' \
    1.3.6.1.6.3.1.1.5.4 \
    1.3.6.1.2.1.2.2.1.1.1 i 1 \
    1.3.6.1.2.1.2.2.1.2.1 s "GigabitEthernet0/1" \
    1.3.6.1.2.1.2.2.1.8.1 i 1 2>/dev/null

# Test 4: Cold start
echo "[Test 4] Sending coldStart trap..."
snmptrap -v 2c -c "${COMMUNITY}" "${HOST}:${PORT}" '' \
    1.3.6.1.6.3.1.1.5.1 2>/dev/null

echo ""
echo "Done! Check the receiver logs with: docker logs -f <container_id>"

