#!/bin/bash
# ============================================================
#  LINUX QUEST v5 - world builder (boxed + white-text edition)
#  Palette: dark green + dark cyan-blue borders, white body text
#  Every message renders inside a border. Hints are boxed with
#  highlighted commands.
#  Usage:   bash <(curl -sL YOURLINK/setup.sh)
#  Reset:   re-run the same command (name + keys survive)
#  Fresh:   bash setup.sh --fresh
# ============================================================

Q="$HOME/linux-quest"
KEYS="$HOME/.quest_keys"
NAMEF="$HOME/.quest_name"
BIN="$HOME/.local/bin"
LIB="$HOME/.quest_lib.sh"
GUM_VER="0.14.5"

# always run from a stable directory (setup may delete the CWD)
cd "$HOME" || exit 1

# ---------- reset ----------
if [ -d "$Q" ]; then
    chmod -R 700 "$Q" 2>/dev/null
    rm -rf "$Q"
fi
if [ "$1" = "--fresh" ]; then rm -f "$KEYS" "$NAMEF"; fi
touch "$KEYS"
mkdir -p "$Q" "$BIN"

# ---------- get gum (best effort, never blocks) ----------
if [ ! -x "$BIN/gum" ] && ! command -v gum >/dev/null 2>&1; then
    if [ "$(uname -m)" = "x86_64" ]; then
        curl -sL "https://github.com/charmbracelet/gum/releases/download/v${GUM_VER}/gum_${GUM_VER}_Linux_x86_64.tar.gz" \
            | tar xz -C /tmp 2>/dev/null \
            && cp "/tmp/gum_${GUM_VER}_Linux_x86_64/gum" "$BIN/gum" 2>/dev/null \
            && chmod +x "$BIN/gum"
    fi
fi
GUM="$BIN/gum"
[ -x "$GUM" ] || GUM="$(command -v gum 2>/dev/null)"

# ---------- shared quest library (sourced by all scripts) ----------
cat > "$LIB" << 'EOF'
# linux-quest shared lib
GUM="$HOME/.local/bin/gum"; [ -x "$GUM" ] || GUM="$(command -v gum 2>/dev/null)"
WHT=$'\033[1;38;5;255m'   # bright white body text
GRN=$'\033[1;38;5;40m'    # green (success, fragments)
BLU=$'\033[1;38;5;44m'    # cyan-blue (info, targets)
RED=$'\033[1;38;5;196m'   # red (denied, danger)
RST=$'\033[0m'
CMD=$'\033[48;5;235m\033[1;38;5;42m'   # command chip: dark bg, green text
# qbox <border-color-256> <line> [line...]   - message in a rounded border
qbox() {
    local c="$1"; shift
    if [ -n "$GUM" ]; then
        "$GUM" style --border rounded --padding "0 2" --margin "0 1" \
            --border-foreground "$c" "$@"
    else
        echo ""
        local l; for l in "$@"; do echo "   $l"; done
        echo ""
    fi
}
EOF

QLOAD='LIB="$HOME/.quest_lib.sh"; if [ -f "$LIB" ]; then . "$LIB"; else WHT=""; GRN=""; BLU=""; RED=""; RST=""; CMD=""; qbox(){ shift; echo ""; local l; for l in "$@"; do echo "   $l"; done; echo ""; }; fi'

# ---------- ask the explorer's name (once) ----------
if [ ! -s "$NAMEF" ]; then
    QNAME=""
    if [ -t 0 ]; then
        if [ -n "$GUM" ]; then
            QNAME=$("$GUM" input --placeholder "state your name, explorer..." \
                    --prompt "🐧 > " --prompt.foreground "34" --cursor.foreground "44")
        else
            echo ""
            echo "Before the system wakes... state your name, explorer:"
            read -r QNAME
        fi
    fi
    [ -z "$QNAME" ] && QNAME="Explorer"
    echo "$QNAME" > "$NAMEF"
fi
QNAME="$(cat "$NAMEF")"

# ---------- optional fun tools (never block if they fail) ----------
if ! command -v cowsay >/dev/null 2>&1; then
    if sudo -n true 2>/dev/null; then
        sudo apt-get install -y cowsay lolcat figlet >/dev/null 2>&1 || true
    fi
fi

# ============================================================
#  ACT 1 - THE AWAKENING            (pwd, ls, cd, cat, ls -a)
# ============================================================
mkdir -p "$Q"/act1/{north_door,south_door,east_door,west_door}

cat > "$Q/START_HERE.txt" << 'EOF'
          [[G]]L I N U X   Q U E S T[[/G]]

You wake up inside an abandoned system.

The previous admin vanished years ago... but he left
notes everywhere. His first note is taped to the screen:

   "[[B]]Rule 1:[[/B]] When lost, ask the system WHERE you are.
            It will print your working directory.

    [[B]]Rule 2:[[/B]] Then LOOK around. List what surrounds you.

    [[B]]Rule 3:[[/B]] Read everything. [[X]]Trust nothing.[[/X]]"

Somewhere near you is a room called [[G]]act1[[/G]].
It has four doors. One of them is lying to you.

(Stuck at any point? type:  [[C]] hint [[E]] )
EOF

cat > "$Q/act1/note.txt" << 'EOF'
Four doors. North, South, East, West.
The admin scratched into the wall:

   "To enter a door, [[B]]Change Directory[[/B]] into it.
    To read a note, let the [[G]]cat[[/G]] read it to you."
EOF

cat > "$Q/act1/north_door/note.txt" << 'EOF'
Empty room. Dust everywhere.
On the wall: "The [[B]]EAST[[/B]] door lies."
EOF

cat > "$Q/act1/south_door/note.txt" << 'EOF'
A broken chair. A cold coffee mug. Nothing useful.
Someone wrote: "Went east. Never came back."
EOF

cat > "$Q/act1/west_door/note.txt" << 'EOF'
A poster of a penguin. Below it:
"His name is [[G]]Tux[[/G]]. Remember that name."
EOF

cat > "$Q/act1/east_door/note.txt" << 'EOF'
"Nothing to see here. This room is completely empty.
 [[X]]Definitely no hidden storage.[[/X]] Move along."

           - The Management
EOF

mkdir -p "$Q/act1/east_door/.storage"
cat > "$Q/act1/east_door/.storage/diary.txt" << 'EOF'
Day 47.
I started hiding my files by naming them with a dot.
Nobody ever finds dotfiles...
unless they ask ls to show [[B]]-a-ll[[/B]] of them.

You found this. You're smarter than the last one.

   [[G]]>>> KEY FRAGMENT: TUX-1 <<<[[/G]]

Go back to the quest folder. Find [[B]]gate2[[/B]].
It will not open without proof you found me.
EOF

# ---- easter egg #1 ----
mkdir -p "$Q/act1/.graffiti"
cat > "$Q/act1/.graffiti/wall.txt" << 'EOF'
  [[G]]🥚 EASTER EGG FOUND 🥚[[/G]]
  [[B]]ACHIEVEMENT UNLOCKED: The Curious One[[/B]]
  (you checked a room nobody told you about)

      .--.
     |o_o |     "i use linux btw"
     |:_/ |          - the admin, probably
    //   \ \
   (|     | )
  /'\_   _/`\
  \___)=(___/
EOF

# ============================================================
#  GATE 2  (checks TUX-1, unlocks act2)
# ============================================================
mkdir -p "$Q/act2_locked"

cat > "$Q/gate2.sh" << EOF
#!/bin/bash
$QLOAD
Q="\$HOME/linux-quest"
KEYS="\$HOME/.quest_keys"

if [ -n "\$GUM" ] && [ -t 0 ]; then
    answer=\$("\$GUM" input --placeholder "speak the first key fragment..." \\
             --prompt "🔒 gate2 > " --prompt.foreground "31" --cursor.foreground "44")
else
    echo "The gate hums: 'Speak the first key fragment.'"
    read -r answer
fi

if [ "\$answer" = "TUX-1" ]; then
    if [ -n "\$GUM" ] && [ -t 0 ]; then
        "\$GUM" spin --spinner dot --spinner.foreground "38" \\
            --title "the gate verifies your fragment..." -- sleep 1.5
    fi
    grep -q "TUX-1" "\$KEYS" || echo "TUX-1" >> "\$KEYS"
    chmod 755 "\$Q/act2_locked" 2>/dev/null
    mv "\$Q/act2_locked" "\$Q/act2" 2>/dev/null
    qbox 40 \\
        "\${WHT}The gate slides open. A new room appears: \${GRN}act2\${RST}" \\
        "" \\
        "\${WHT}The admin's voice, from an old recording:\${RST}" \\
        "\${BLU}'Reading was the easy part. Now you BUILD.'\${RST}"
else
    qbox 196 \\
        "\${WHT}The gate stays shut. Explore act1 more carefully.\${RST}" \\
        "\${WHT}(Something in the east door was \${RED}hidden\${WHT}...)\${RST}"
fi
EOF
chmod +x "$Q/gate2.sh"

# ============================================================
#  ACT 2 - THE EXPEDITION     (mkdir, touch, cp, mv, grep)
# ============================================================
A2="$Q/act2_locked"

# ---- mission 1: the builder ----
mkdir -p "$A2/mission1_builder"
cat > "$A2/mission1_builder/note.txt" << 'EOF'
Rebuild the admin's workshop, right here:

   [[G]]workshop/
     tools/
     blueprints/
     secrets/[[/G]]

Then create an empty file  badge.txt  inside secrets/.
(The admin created empty files with a gentle [[U]]"touch"[[/U]].)

Go back here and inspect after that:

   [[C]] ./inspect.sh [[E]]
EOF

cat > "$A2/mission1_builder/inspect.sh" << EOF
#!/bin/bash
$QLOAD
B="\$(dirname "\$0")/workshop"
KEYS="\$HOME/.quest_keys"
if [ -d "\$B/tools" ] && [ -d "\$B/blueprints" ] && [ -f "\$B/secrets/badge.txt" ]; then
    grep -q "TUX-2" "\$KEYS" || echo "TUX-2" >> "\$KEYS"
    qbox 40 \\
        "\${WHT}The workshop stands again. The dust settles.\${RST}" \\
        "" \\
        "\${GRN}>>> KEY FRAGMENT: TUX-2 <<<\${RST}" \\
        "" \\
        "\${WHT}Next: \${BLU}mission2_rescue\${RST}"
else
    qbox 196 \\
        "\${WHT}Something is still \${RED}missing\${WHT} or misplaced.\${RST}" \\
        "\${WHT}Re-read note.txt. Check your structure with ls.\${RST}"
fi
EOF
chmod +x "$A2/mission1_builder/inspect.sh"

# ---- mission 2: the rescue ----
mkdir -p "$A2/mission2_rescue/rubble" "$A2/mission2_rescue/vault"
echo "a shiny gem. priceless. do not lose."       > "$A2/mission2_rescue/rubble/gem.txt"
echo "old newspaper. worthless."                  > "$A2/mission2_rescue/rubble/trash1.txt"
echo "banana peel. why is this in a computer."    > "$A2/mission2_rescue/rubble/trash2.txt"

cat > "$A2/mission2_rescue/note.txt" << 'EOF'
The admin's gem is buried under rubble/.

  1. [[B]]MOVE[[/B]] it into vault/           [[C]] mv <from> <to> [[E]]
  2. [[B]]COPY[[/B]] it, inside vault/, to a
     second file: gem_backup.txt   [[C]] cp <from> <to> [[E]]

Leave the trash alone. It has feelings too. Then:

   [[C]] ./check.sh [[E]]
EOF

cat > "$A2/mission2_rescue/check.sh" << EOF
#!/bin/bash
$QLOAD
D="\$(dirname "\$0")"
KEYS="\$HOME/.quest_keys"
if [ -f "\$D/vault/gem.txt" ] && [ -f "\$D/vault/gem_backup.txt" ] && [ ! -f "\$D/rubble/gem.txt" ]; then
    grep -q "TUX-3" "\$KEYS" || echo "TUX-3" >> "\$KEYS"
    qbox 40 \\
        "\${WHT}The gem is safe AND backed up. The admin nods in spirit.\${RST}" \\
        "" \\
        "\${GRN}>>> KEY FRAGMENT: TUX-3 <<<\${RST}" \\
        "" \\
        "\${WHT}Next: \${BLU}mission3_haystack\${RST}"
else
    qbox 196 \\
        "\${WHT}Not quite. The gem must be IN vault/, backed up,\${RST}" \\
        "\${WHT}and \${RED}GONE\${WHT} from rubble/. Check with ls.\${RST}"
fi
EOF
chmod +x "$A2/mission2_rescue/check.sh"

# ---- mission 3: the haystack ----
mkdir -p "$A2/mission3_haystack/logs"
for i in $(seq 1 50); do
    {
    echo "[log $i] system nominal. nothing to report."
    echo "[log $i] coffee levels: low."
    echo "[log $i] penguin sightings: $((RANDOM % 9))"
    } > "$A2/mission3_haystack/logs/server_$i.log"
done
echo "[SECURITY] ACCESS-CODE: TUX-4  (do not tell anyone)" >> "$A2/mission3_haystack/logs/server_37.log"

cat > "$A2/mission3_haystack/note.txt" << 'EOF'
An [[B]]ACCESS-CODE[[/B]] hides in ONE of these 50 log files.

Don't read. [[G]]Search:[[/G]]

   [[C]] grep "WORD" logs/* [[E]]

Take the code to [[B]]gate3[[/B]], back in the quest folder.
EOF

# ============================================================
#  GATE 3  (checks TUX-4, unlocks act3)
# ============================================================
mkdir -p "$Q/act3_locked"

cat > "$Q/gate3.sh" << EOF
#!/bin/bash
$QLOAD
Q="\$HOME/linux-quest"
KEYS="\$HOME/.quest_keys"

if [ -n "\$GUM" ] && [ -t 0 ]; then
    answer=\$("\$GUM" input --placeholder "the access code from the logs..." \\
             --prompt "🔒 gate3 > " --prompt.foreground "31" --cursor.foreground "44")
else
    echo "The last gate whispers: 'The access code. Now.'"
    read -r answer
fi

if [ "\$answer" = "TUX-4" ]; then
    if [ -n "\$GUM" ] && [ -t 0 ]; then
        "\$GUM" spin --spinner line --spinner.foreground "38" \\
            --title "heavy machinery grinding..." -- sleep 1.5
    fi
    grep -q "TUX-4" "\$KEYS" || echo "TUX-4" >> "\$KEYS"
    chmod 755 "\$Q/act3_locked" 2>/dev/null
    mv "\$Q/act3_locked" "\$Q/act3" 2>/dev/null
    qbox 40 \\
        "\${WHT}The floor shakes. \${GRN}act3\${WHT} rises from the ground.\${RST}" \\
        "" \\
        "\${WHT}The recording crackles one last time:\${RST}" \\
        "\${BLU}'Beyond this point, the system stops being\${RST}" \\
        "\${BLU} a place... and starts being ALIVE.'\${RST}"
else
    qbox 196 \\
        "\${WHT}Wrong code. It's hiding in the 50 logs.\${RST}" \\
        "\${RED}Search\${WHT}, don't read.\${RST}"
fi
EOF
chmod +x "$Q/gate3.sh"

# ============================================================
#  ACT 3 - THE DEEP     (permissions, /proc, pipes, ceremony)
# ============================================================
A3="$Q/act3_locked"

# ---- mission 1: the sealed letter ----
mkdir -p "$A3/mission1_sealed"
cat > "$A3/mission1_sealed/sealed_letter.txt" << 'EOF'
So you made it. I knew you would.

They locked this letter so no one could read it.
But you just proved something important:

   In Linux, YOU decide what can be read,
   written, and run. Permissions are not walls.
   They are doors, and you hold the keys.

   >>> KEY FRAGMENT: TUX-5 <<<

Prove you read me:  ./claim.sh
EOF

cat > "$A3/mission1_sealed/note.txt" << 'EOF'
A letter lies here, [[X]]SEALED[[/X]]. Try to read it. [[X]]Denied?[[/X]]

The lock is a permission. The locksmith is [[G]]chmod[[/G]]:

   [[C]] chmod +r sealed_letter.txt [[E]]

Read the letter. It will tell you what to do next.
EOF

cat > "$A3/mission1_sealed/claim.sh" << EOF
#!/bin/bash
$QLOAD
KEYS="\$HOME/.quest_keys"

if [ -n "\$GUM" ] && [ -t 0 ]; then
    answer=\$("\$GUM" input --placeholder "what fragment did the letter reveal?" \\
             --prompt "✉️  > " --prompt.foreground "31" --cursor.foreground "44")
else
    echo "The room asks: 'What fragment did the sealed letter reveal?'"
    read -r answer
fi

if [ "\$answer" = "TUX-5" ]; then
    grep -q "TUX-5" "\$KEYS" || echo "TUX-5" >> "\$KEYS"
    qbox 40 \\
        "\${GRN}'So you truly unsealed it. Fragment recorded.'\${RST}" \\
        "" \\
        "\${WHT}Next: \${BLU}mission2_heart\${RST}"
else
    qbox 196 \\
        "\${WHT}'No. Unseal the letter (\${RED}chmod +r\${WHT}) and READ it first.'\${RST}"
fi
EOF
chmod +x "$A3/mission1_sealed/claim.sh"

# ---- mission 2: the machine's heart ----
mkdir -p "$A3/mission2_heart"
cat > "$A3/mission2_heart/note.txt" << 'EOF'
"In Linux, [[G]]EVERYTHING is a file.[[/G]]
 Even the machine's beating heart - the [[B]]CPU[[/B]]:

   [[C]] cat /proc/cpuinfo [[E]]
   [[C]] grep -c processor /proc/cpuinfo [[E]]

 Look at it. Then answer the machine's question:"

   [[C]] ./heart.sh [[E]]
EOF

cat > "$A3/mission2_heart/heart.sh" << EOF
#!/bin/bash
$QLOAD
KEYS="\$HOME/.quest_keys"
real=\$(nproc)

if [ -n "\$GUM" ] && [ -t 0 ]; then
    answer=\$("\$GUM" input --placeholder "how many processors do I have?" \\
             --prompt "💓 > " --prompt.foreground "31" --cursor.foreground "44")
else
    echo "The machine asks: 'How many processors do I have?'"
    read -r answer
fi

if [ "\$answer" = "\$real" ]; then
    grep -q "TUX-6" "\$KEYS" || echo "TUX-6" >> "\$KEYS"
    qbox 40 \\
        "\${BLU}'Correct. You have read my heart.'\${RST}" \\
        "" \\
        "\${GRN}>>> KEY FRAGMENT: TUX-6 <<<\${RST}" \\
        "" \\
        "\${WHT}One room remains: \${BLU}mission3_final\${RST}"
else
    qbox 196 \\
        "\${WHT}'No. Look again. \${RED}Count\${WHT} the processors in /proc/cpuinfo.'\${RST}"
fi
EOF
chmod +x "$A3/mission2_heart/heart.sh"

# ---- mission 3: pipes + the final door ----
mkdir -p "$A3/mission3_final"
{
for i in $(seq 1 400); do
    echo "noise_$RANDOM garbage static $RANDOM interference"
done
echo "FINALWORD: freedom"
for i in $(seq 1 400); do
    echo "static_$RANDOM noise hiss $RANDOM crackle"
done
} > "$A3/mission3_final/transmission.txt"

cat > "$A3/mission3_final/note.txt" << 'EOF'
The last door needs the [[U]]FINALWORD[[/U]] - buried in
801 lines of static inside transmission.txt.

Join your tools with a [[G]]pipe[[/G]]. One speaks, one listens:

   [[C]] cat transmission.txt | grep "WORD" [[E]]

Found it? Then:

   [[C]] ./final_door.sh [[E]]
EOF

cat > "$A3/mission3_final/final_door.sh" << EOF
#!/bin/bash
$QLOAD
KEYS="\$HOME/.quest_keys"
NAMEF="\$HOME/.quest_name"
need="TUX-1 TUX-2 TUX-3 TUX-4 TUX-5 TUX-6"
for k in \$need; do
    if ! grep -q "\$k" "\$KEYS"; then
        qbox 196 \\
            "\${WHT}The door counts your key fragments...\${RST}" \\
            "\${WHT}one is missing: \${RED}\$k\${RST}" \\
            "" \\
            "\${WHT}Finish every mission first.\${RST}"
        exit 1
    fi
done

if [ -n "\$GUM" ] && [ -t 0 ]; then
    word=\$("\$GUM" input --placeholder "six fragments... now, the FINALWORD" \\
           --prompt "🚪 > " --prompt.foreground "31" --cursor.foreground "44")
else
    echo "The door: 'Six fragments. Impressive. The FINALWORD?'"
    read -r word
fi

if [ "\$word" != "freedom" ]; then
    qbox 196 \\
        "\${WHT}'Wrong. It hides in the transmission.\${RST}" \\
        "\${WHT} \${RED}Pipe\${WHT} your tools together.'\${RST}"
    exit 1
fi

if [ -s "\$NAMEF" ]; then
    name="\$(cat "\$NAMEF")"
else
    echo "'...Correct. State your name for the record:'"
    read -r name
fi

if [ -n "\$GUM" ] && [ -t 0 ]; then
    "\$GUM" spin --spinner pulse --spinner.foreground "40" \\
        --title "the final door opens for \$name..." -- sleep 2
fi
clear
if command -v figlet >/dev/null 2>&1; then
    if command -v lolcat >/dev/null 2>&1; then
        figlet "QUEST COMPLETE" | lolcat
    else
        figlet "QUEST COMPLETE"
    fi
fi

if [ -n "\$GUM" ]; then
    "\$GUM" style --border double --padding "1 4" --margin "1 2" --align center \\
        --border-foreground "40" --foreground "255" --bold \\
        "CERTIFIED SYSTEM EXPLORER" "" "\$name" "" \\
        "found your place - uncovered the hidden" \\
        "built, rescued, and searched" \\
        "unlocked the sealed - read the machine's heart" \\
        "joined tools into pipelines"
    "\$GUM" style --padding "0 2" --italic --foreground "44" \\
        "'This system was never abandoned." \\
        " It was waiting for you, \$name." \\
        " It is called Linux. And now it is yours.'"
else
    qbox 40 \\
        "\${GRN}CERTIFIED SYSTEM EXPLORER:\${RST}  \${BLU}\$name\${RST}" \\
        "" \\
        "\${WHT}found your place - uncovered the hidden\${RST}" \\
        "\${WHT}built, rescued, and searched\${RST}" \\
        "\${WHT}unlocked the sealed - read the machine's heart\${RST}" \\
        "\${WHT}joined tools into pipelines\${RST}" \\
        "" \\
        "\${BLU}'It was waiting for you, \$name.\${RST}" \\
        "\${BLU} It is called Linux. And now it is yours.'\${RST}"
fi

if command -v cowsay >/dev/null 2>&1; then
    echo "welcome home, \$name" | cowsay -f tux 2>/dev/null || echo "welcome home, \$name" | cowsay
fi
echo ""
echo "  (screenshot this. you earned it.)"
EOF
chmod +x "$A3/mission3_final/final_door.sh"

# ---- easter egg #2 ----
cat > "$A3/.do_not_open.txt" << 'EOF'
[[X]]AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        WHY WOULD YOU OPEN THIS
IT LITERALLY SAYS DO NOT OPEN
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[[/X]]

...fine. [[G]]🥚 EASTER EGG FOUND 🥚[[/G]]
[[B]]ACHIEVEMENT UNLOCKED: Rule Breaker[[/B]]
(the admin is proud of you, secretly)
EOF

# ============================================================
#  COLORIZE + STYLE the notes (white body text everywhere)
# ============================================================
WHT=$(printf '\033[1;38;5;255m')
CHL=$(printf '\033[48;5;235m\033[1;38;5;42m')
UND=$(printf '\033[4;38;5;44m')
GRN=$(printf '\033[1;38;5;34m')
BLU=$(printf '\033[1;38;5;38m')
RED=$(printf '\033[1;38;5;160m')
RST=$(printf '\033[0m')
find "$Q" -name "*.txt" -type f | while read -r f; do
    # every line starts white; every closer returns to white (not grey)
    sed -i "s/^/${WHT}/" "$f"
    sed -i "s/\[\[C\]\]/${CHL} /g;   s/\[\[E\]\]/ ${RST}${WHT}/g; \
            s/\[\[U\]\]/${UND}/g;    s/\[\[\/U\]\]/${RST}${WHT}/g; \
            s/\[\[G\]\]/${GRN}/g;    s/\[\[\/G\]\]/${RST}${WHT}/g; \
            s/\[\[B\]\]/${BLU}/g;    s/\[\[\/B\]\]/${RST}${WHT}/g; \
            s/\[\[X\]\]/${RED}/g;    s/\[\[\/X\]\]/${RST}${WHT}/g" "$f" 2>/dev/null
    printf '%s' "$RST" >> "$f"
done

# borders: START_HERE dark-green double; act2 notes cyan-blue; act3 notes dark green
if [ -n "$GUM" ]; then
    styled=$("$GUM" style --border double --padding "1 2" --border-foreground "28" \
             "$(cat "$Q/START_HERE.txt")" 2>/dev/null)
    [ -n "$styled" ] && printf '%s\n' "$styled" > "$Q/START_HERE.txt"
    for f in "$A2"/mission*/note.txt; do
        [ -f "$f" ] || continue
        styled=$("$GUM" style --border rounded --padding "1 2" --border-foreground "31" \
                 "$(cat "$f")" 2>/dev/null)
        [ -n "$styled" ] && printf '%s\n' "$styled" > "$f"
    done
    for f in "$A3"/mission*/note.txt; do
        [ -f "$f" ] || continue
        styled=$("$GUM" style --border rounded --padding "1 2" --border-foreground "28" \
                 "$(cat "$f")" 2>/dev/null)
        [ -n "$styled" ] && printf '%s\n' "$styled" > "$f"
    done
    # act1 door notes + diary in subtle cyan borders too - every message boxed
    for f in "$Q"/act1/note.txt "$Q"/act1/*/note.txt "$Q"/act1/east_door/.storage/diary.txt; do
        [ -f "$f" ] || continue
        styled=$("$GUM" style --border rounded --padding "0 2" --border-foreground "31" \
                 "$(cat "$f")" 2>/dev/null)
        [ -n "$styled" ] && printf '%s\n' "$styled" > "$f"
    done
else
    { echo "${GRN}=========================================================${RST}"
      cat "$Q/START_HERE.txt"
      echo "${GRN}=========================================================${RST}"
    } > "$Q/START_HERE.tmp" && mv "$Q/START_HERE.tmp" "$Q/START_HERE.txt"
fi

# lock the sealed letter and future acts (AFTER styling, so sed could reach them)
chmod 000 "$Q/act3_locked/mission1_sealed/sealed_letter.txt"
chmod 000 "$Q/act2_locked" "$Q/act3_locked"

# ============================================================
#  HELPER COMMANDS:  hint (boxed + highlighted)  +  quest-progress
# ============================================================
cat > "$BIN/hint" << EOF
#!/bin/bash
$QLOAD
D=""; C=""; C2=""
case "\$PWD" in
    *mission3_final*)  D="pipe the static through a searcher:"
                       C='cat transmission.txt | grep "FINALWORD"' ;;
    *mission2_heart*)  D="let grep count the processors for you:"
                       C='grep -c processor /proc/cpuinfo' ;;
    *mission1_sealed*) D="unseal it, read it, then claim it:"
                       C='chmod +r sealed_letter.txt'
                       C2='./claim.sh' ;;
    *haystack*)        D="search all 50 logs in one breath:"
                       C='grep "ACCESS-CODE" logs/*' ;;
    *rescue*)          D="teleport, then duplicate:"
                       C='mv rubble/gem.txt vault/'
                       C2='cp vault/gem.txt vault/gem_backup.txt' ;;
    *builder*)         D="mkdir builds rooms, touch makes empty files:"
                       C='mkdir -p workshop/tools'
                       C2='./inspect.sh   (when the workshop stands)' ;;
    *act3*)            D="three missions. take them in order."
                       C='cat note.txt   (in each mission room)' ;;
    *act2*)            D="three missions. enter each, read first."
                       C='cat note.txt' ;;
    *east_door*)       D="this room claims to be empty. ls can show ALL:"
                       C='ls -a' ;;
    *act1*)            D="enter each door, read every note. one door lies."
                       C='cd north_door'
                       C2='cat note.txt' ;;
    *linux-quest*)     D="lost? ask where you are, then look around:"
                       C='pwd'
                       C2='ls' ;;
    *)                 D="the quest lives at:"
                       C='cd ~/linux-quest' ;;
esac
lines=( "\${GRN}💡 HINT\${RST}" "" "\${WHT}\$D\${RST}" "  \${CMD} \$C \${RST}" )
[ -n "\$C2" ] && lines+=( "  \${CMD} \$C2 \${RST}" )
qbox 31 "\${lines[@]}"
EOF
chmod +x "$BIN/hint"

cat > "$BIN/quest-progress" << EOF
#!/bin/bash
$QLOAD
NAME="\$(cat "\$HOME/.quest_name" 2>/dev/null || echo unknown)"
lines=( "\${WHT}Explorer: \${BLU}\$NAME\${RST}" "\${WHT}Key fragments:\${RST}" )
if [ -s "\$HOME/.quest_keys" ]; then
    while read -r k; do lines+=( "  \${GRN}\$k\${RST}" ); done < "\$HOME/.quest_keys"
else
    lines+=( "  \${WHT}(none yet)\${RST}" )
fi
qbox 31 "\${lines[@]}"
EOF
chmod +x "$BIN/quest-progress"

# best-effort: also drop helpers somewhere already in PATH (Cloud Shell has sudo)
if sudo -n true 2>/dev/null; then
    sudo cp "$BIN/hint" "$BIN/quest-progress" /usr/local/bin/ 2>/dev/null || true
fi

# ---------- .bashrc touches (append once) ----------
if ! grep -q "LINUX_QUEST_MARK" "$HOME/.bashrc" 2>/dev/null; then
cat >> "$HOME/.bashrc" << 'EOF'

# LINUX_QUEST_MARK
export PATH="$PATH:$HOME/.local/bin:/usr/games"
echo -e "\033[1;38;5;34m[LINUX QUEST]\033[0m \033[1;38;5;255mwelcome back, \033[1;38;5;38m$(cat "$HOME/.quest_name" 2>/dev/null || echo explorer)\033[1;38;5;255m. (stuck? type: hint)\033[0m"
EOF
fi

# ---------- done ----------
if [ -n "$GUM" ]; then
    "$GUM" style --border double --padding "1 3" --margin "1 0" \
        --border-foreground "28" --foreground "255" \
        "The system has awakened, $QNAME." "" \
        "Type these three lines:" "" \
        "$(printf '\033[1;38;5;44m  source ~/.bashrc\033[0m')" \
        "$(printf '\033[1;38;5;44m  cd ~/linux-quest\033[0m')" \
        "$(printf '\033[1;38;5;44m  cat START_HERE.txt\033[0m')" "" \
        "Broke something? Re-run the setup command." \
        "The world resets. Your name and keys survive."
else
    G=$(printf '\033[1;38;5;34m'); B=$(printf '\033[1;38;5;44m'); W=$(printf '\033[1;38;5;255m'); R=$(printf '\033[0m')
    echo ""
    echo "${G}=============================================${R}"
    echo "  ${W}The system has awakened, ${B}$QNAME${W}.${R}"
    echo ""
    echo "  ${W}Type these three lines:${R}"
    echo ""
    echo "     ${B}source ~/.bashrc${R}"
    echo "     ${B}cd ~/linux-quest${R}"
    echo "     ${B}cat START_HERE.txt${R}"
    echo ""
    echo "  ${W}Broke something? Re-run the setup command.${R}"
    echo "  ${W}The world resets. Your name and keys survive.${R}"
    echo "${G}=============================================${R}"
fi
