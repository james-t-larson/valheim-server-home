#!/usr/bin/env bash
# ==============================================================================
# 🛡️ Valheim Dedicated Server - Interactive Setup & Start Script
# ==============================================================================
set -e

# Change directory to the folder containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================================="
echo "   🛡️  Valheim Dedicated Server Setup & Startup  🛡️      "
echo "=========================================================="
echo "Please provide your server configuration details below."
echo "Press [Enter] to keep the default value shown in brackets."
echo ""

# Helper to read with default value
prompt_with_default() {
  local prompt_text="$1"
  local default_val="$2"
  local var_name="$3"
  local user_input

  read -r -p "$prompt_text [$default_val]: " user_input
  if [ -z "$user_input" ]; then
    eval "$var_name=\"$default_val\""
  else
    eval "$var_name=\"$user_input\""
  fi
}

# 1. Main Game Port
prompt_with_default "1. Game Port (UDP)" "2456:2456/udp" INPUT_PORT_1
# Normalize port format if only a number was provided
if [[ "$INPUT_PORT_1" =~ ^[0-9]+$ ]]; then
  VALHEIM_PORT_1="${INPUT_PORT_1}:${INPUT_PORT_1}/udp"
elif [[ "$INPUT_PORT_1" =~ ^[0-9]+:[0-9]+$ ]]; then
  VALHEIM_PORT_1="${INPUT_PORT_1}/udp"
else
  VALHEIM_PORT_1="$INPUT_PORT_1"
fi

# 2. Steam Query Port
prompt_with_default "2. Steam Query Port (UDP)" "2457:2457/udp" INPUT_PORT_2
# Normalize port format if only a number was provided
if [[ "$INPUT_PORT_2" =~ ^[0-9]+$ ]]; then
  VALHEIM_PORT_2="${INPUT_PORT_2}:${INPUT_PORT_2}/udp"
elif [[ "$INPUT_PORT_2" =~ ^[0-9]+:[0-9]+$ ]]; then
  VALHEIM_PORT_2="${INPUT_PORT_2}/udp"
else
  VALHEIM_PORT_2="$INPUT_PORT_2"
fi

# 3. Server Name
prompt_with_default "3. Server Name" "My Valheim Server" SERVER_NAME

# 4. World Name
prompt_with_default "4. World Name" "Dedicated" WORLD_NAME

# 5. Server Password (with validation)
while true; do
  prompt_with_default "5. Server Password (5+ chars, not in Server Name)" "secret1234" SERVER_PASS

  # Validation checks
  if [ ${#SERVER_PASS} -lt 5 ]; then
    echo "   ❌ Password must be at least 5 characters long. Please try again."
    continue
  fi

  # Case-insensitive check if password is contained in server name
  server_name_lower=$(echo "$SERVER_NAME" | tr '[:upper:]' '[:lower:]')
  server_pass_lower=$(echo "$SERVER_PASS" | tr '[:upper:]' '[:lower:]')
  if [[ "$server_name_lower" == *"$server_pass_lower"* ]]; then
    echo "   ❌ Password must NOT be contained within the server name ('$SERVER_NAME'). Please try again."
    continue
  fi

  break
done

# 6. Server Public
prompt_with_default "6. Server Public visibility (true/false)" "true" INPUT_PUBLIC
case $(echo "$INPUT_PUBLIC" | tr '[:upper:]' '[:lower:]') in
  y|yes|t|true|1) SERVER_PUBLIC="true" ;;
  n|no|f|false|0) SERVER_PUBLIC="false" ;;
  *) SERVER_PUBLIC="true" ;;
esac

# 7. Crossplay
prompt_with_default "7. Crossplay enabled for Xbox / PC Game Pass (true/false)" "false" INPUT_CROSSPLAY
case $(echo "$INPUT_CROSSPLAY" | tr '[:upper:]' '[:lower:]') in
  y|yes|t|true|1) CROSSPLAY="true" ;;
  n|no|f|false|0) CROSSPLAY="false" ;;
  *) CROSSPLAY="false" ;;
esac

# 8. Steam Platform
prompt_with_default "8. Steam Platform architecture (linux64/windows)" "linux64" STEAM_PLATFORM

echo ""
echo "Configuration Summary:"
echo "----------------------------------------------------------"
echo "  Game Port:      $VALHEIM_PORT_1"
echo "  Query Port:     $VALHEIM_PORT_2"
echo "  Server Name:    $SERVER_NAME"
echo "  World Name:     $WORLD_NAME"
echo "  Password:       ********"
echo "  Public:         $SERVER_PUBLIC"
echo "  Crossplay:      $CROSSPLAY"
echo "  Platform:       $STEAM_PLATFORM"
echo "----------------------------------------------------------"
echo ""

# Write to ~/.bashrc
BASH_RC="$HOME/.bashrc"
touch "$BASH_RC"

CONFIG_BLOCK_START="# >>> Valheim Dedicated Server Environment Variables >>>"
CONFIG_BLOCK_END="# <<< Valheim Dedicated Server Environment Variables <<<"

NEW_CONFIG="${CONFIG_BLOCK_START}
export VALHEIM_PORT_1=\"${VALHEIM_PORT_1}\"
export VALHEIM_PORT_2=\"${VALHEIM_PORT_2}\"
export SERVER_NAME=\"${SERVER_NAME}\"
export WORLD_NAME=\"${WORLD_NAME}\"
export SERVER_PASS=\"${SERVER_PASS}\"
export SERVER_PUBLIC=\"${SERVER_PUBLIC}\"
export CROSSPLAY=\"${CROSSPLAY}\"
export STEAM_PLATFORM=\"${STEAM_PLATFORM}\"
${CONFIG_BLOCK_END}"

# If block exists in ~/.bashrc, replace it; otherwise append
if grep -qF "$CONFIG_BLOCK_START" "$BASH_RC"; then
  echo "Updating existing Valheim configuration block in $BASH_RC..."
  # Use python for portable and clean block replacement
  python3 -c "
import sys
path = sys.argv[1]
start_mark = sys.argv[2]
end_mark = sys.argv[3]
new_content = sys.argv[4]

with open(path, 'r') as f:
    text = f.read()

start_idx = text.find(start_mark)
end_idx = text.find(end_mark)

if start_idx != -1 and end_idx != -1:
    end_idx += len(end_mark)
    updated = text[:start_idx].rstrip() + '\n\n' + new_content + '\n' + text[end_idx:].lstrip()
    with open(path, 'w') as f:
        f.write(updated.strip() + '\n')
" "$BASH_RC" "$CONFIG_BLOCK_START" "$CONFIG_BLOCK_END" "$NEW_CONFIG"
else
  echo "Writing Valheim configuration to the end of $BASH_RC..."
  # Ensure file ends with newline before appending
  if [ -s "$BASH_RC" ] && [ -n "$(tail -c1 "$BASH_RC")" ]; then
    echo "" >> "$BASH_RC"
  fi
  echo "$NEW_CONFIG" >> "$BASH_RC"
fi

# Also write to local .env for seamless Docker Compose support across shells
ENV_FILE="$SCRIPT_DIR/.env"
cat <<EOF > "$ENV_FILE"
# Valheim Server Environment Variables (Auto-generated by start.sh)
VALHEIM_PORT_1="${VALHEIM_PORT_1}"
VALHEIM_PORT_2="${VALHEIM_PORT_2}"
SERVER_NAME="${SERVER_NAME}"
WORLD_NAME="${WORLD_NAME}"
SERVER_PASS="${SERVER_PASS}"
SERVER_PUBLIC="${SERVER_PUBLIC}"
CROSSPLAY="${CROSSPLAY}"
STEAM_PLATFORM="${STEAM_PLATFORM}"
EOF
echo "Saved local environment file ($ENV_FILE)."

# Export variables in current shell
export VALHEIM_PORT_1
export VALHEIM_PORT_2
export SERVER_NAME
export WORLD_NAME
export SERVER_PASS
export SERVER_PUBLIC
export CROSSPLAY
export STEAM_PLATFORM

echo "Environment variables set successfully!"
echo ""
echo "Starting Valheim Dedicated Server container..."
echo "----------------------------------------------------------"
docker compose up -d

echo ""
echo "=========================================================="
echo "🎉 Valheim Server started successfully!"
echo "=========================================================="
docker compose ps
echo ""
echo "Helpful tips:"
echo "  • View live logs:      docker compose logs -f"
echo "  • Stop the server:     docker compose down"
echo "  • Restart the server:  docker compose restart"
echo ""
