#!/bin/bash
# ============================================================
#  LINUX QUEST v4 - world builder (gum + color edition)
#  Palette: dark green (28/34/40) + dark cyan-blue (31/38/44)
#  Runs on: Google Cloud Shell, WSL Ubuntu, Docker, any Linux
#  Usage:   bash <(curl -sL YOURLINK/setup.sh)
#  Reset:   re-run the same command (name + keys survive)
#  Fresh:   bash setup.sh --fresh   (wipes name + keys too)
# ============================================================

Q="$HOME/linux-quest"
KEYS="$HOME/.quest_keys"
NAMEF="$HOME/.quest_name"
BIN="$HOME/.local/bin"
GUM_VER="0.14.5"

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

cat > "$Q/gate2.sh" << 'EOF'
#!/bin/bash
Q="$HOME/linux-quest"
KEYS="$HOME/.quest_keys"
GUM="$HOME/.local/bin/gum"; [ -x "$GUM" ] || GUM="$(command -v gum 2>/dev/null)"
GRN=$'\033[1;38;5;40m'; BLU=$'\033[1;38;5;44m'; RST=$'\033[0m'

if [ -n "$GUM" ] && [ -t 0 ]; then
    answer=$("$GUM" input --placeholder "speak the first key fragment..." \
             --prompt "🔒 gate2 > " --prompt.foreground "31" --cursor.foreground "44")
else
    echo "The gate hums: 'Speak the first key fragment.'"
    read -r answer
fi

if [ "$answer" = "TUX-1" ]; then
    if [ -n "$GUM" ] && [ -t 0 ]; then
        "$GUM" spin --spinner dot --spinner.foreground "38" \
            --title "the gate verifies your fragment..." -- sleep 1.5
    fi
    grep -q "TUX-1" "$KEYS" || echo "TUX-1" >> "$KEYS"
    chmod 755 "$Q/act2_locked" 2>/dev/null
    mv "$Q/act2_locked" "$Q/act2" 2>/dev/null
    echo ""
    echo "${BLU}The gate slides open. A new room appears: act2${RST}"
    echo "The admin's voice, from an old recording:"
    echo "   ${GRN}'Reading was the easy part. Now you BUILD.'${RST}"
else
    echo "The gate stays shut. Explore act1 more carefully."
    echo "(Something in the east door was hidden...)"
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

cat > "$A2/mission1_builder/inspect.sh" << 'EOF'
#!/bin/bash
B="$(dirname "$0")/workshop"
KEYS="$HOME/.quest_keys"
GRN=$'\033[1;38;5;40m'; BLU=$'\033[1;38;5;44m'; RST=$'\033[0m'
if [ -d "$B/tools" ] && [ -d "$B/blueprints" ] && [ -f "$B/secrets/badge.txt" ]; then
    grep -q "TUX-2" "$KEYS" || echo "TUX-2" >> "$KEYS"
    echo "  The workshop stands again. The dust settles."
    echo ""
    echo "     ${GRN}>>> KEY FRAGMENT: TUX-2 <<<${RST}"
    echo ""
    echo "  Next: ${BLU}mission2_rescue${RST}"
else
    echo "  Something is still missing or misplaced."
    echo "  Re-read note.txt. Check your structure with ls."
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

cat > "$A2/mission2_rescue/check.sh" << 'EOF'
#!/bin/bash
D="$(dirname "$0")"
KEYS="$HOME/.quest_keys"
GRN=$'\033[1;38;5;40m'; BLU=$'\033[1;38;5;44m'; RST=$'\033[0m'
if [ -f "$D/vault/gem.txt" ] && [ -f "$D/vault/gem_backup.txt" ] && [ ! -f "$D/rubble/gem.txt" ]; then
    grep -q "TUX-3" "$KEYS" || echo "TUX-3" >> "$KEYS"
    echo "  The gem is safe AND backed up. The admin nods in spirit."
    echo ""
    echo "     ${GRN}>>> KEY FRAGMENT: TUX-3 <<<${RST}"
    echo ""
    echo "  Next: ${BLU}mission3_haystack${RST}"
else
    echo "  Not quite. The gem must be IN vault/, backed up,"
    echo "  and GONE from rubble/. Check with ls."
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

cat > "$Q/gate3.sh" << 'EOF'
#!/bin/bash
Q="$HOME/linux-quest"
KEYS="$HOME/.quest_keys"
GUM="$HOME/.local/bin/gum"; [ -x "$GUM" ] || GUM="$(command -v gum 2>/dev/null)"
GRN=$'\033[1;38;5;40m'; BLU=$'\033[1;38;5;44m'; RST=$'\033[0m'

if [ -n "$GUM" ] && [ -t 0 ]; then
    answer=$("$GUM" input --placeholder "the access code from the logs..." \
             --prompt "🔒 gate3 > " --prompt.foreground "31" --cursor.foreground "44")
else
    echo "The last gate whispers: 'The access code. Now.'"
    read -r answer
fi

if [ "$answer" = "TUX-4" ]; then
    if [ -n "$GUM" ] && [ -t 0 ]; then
        "$GUM" spin --spinner line --spinner.foreground "38" \
            --title "heavy machinery grinding..." -- sleep 1.5
    fi
    grep -q "TUX-4" "$KEYS" || echo "TUX-4" >> "$KEYS"
    chmod 755 "$Q/act3_locked" 2>/dev/null
    mv "$Q/act3_locked" "$Q/act3" 2>/dev/null
    echo ""
    echo "${BLU}The floor shakes. act3 rises from the ground.${RST}"
    echo "The recording crackles one last time:"
    echo "   ${GRN}'Beyond this point, the system stops being"
    echo "    a place... and starts being ALIVE.'${RST}"
else
    echo "Wrong code. It's hiding in the 50 logs. Search, don't read."
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
chmod 000 "$A3/mission1_sealed/sealed_letter.txt"

cat > "$A3/mission1_sealed/note.txt" << 'EOF'
A letter lies here, [[X]]SEALED[[/X]]. Try to read it. [[X]]Denied?[[/X]]

The lock is a permission. The locksmith is [[G]]chmod[[/G]]:

   [[C]] chmod +r sealed_letter.txt [[E]]

Read the letter. It will tell you what to do next.
EOF

cat > "$A3/mission1_sealed/claim.sh" << 'EOF'
#!/bin/bash
KEYS="$HOME/.quest_keys"
GUM="$HOME/.local/bin/gum"; [ -x "$GUM" ] || GUM="$(command -v gum 2>/dev/null)"
GRN=$'\033[1;38;5;40m'; BLU=$'\033[1;38;5;44m'; RST=$'\033[0m'

if [ -n "$GUM" ] && [ -t 0 ]; then
    answer=$("$GUM" input --placeholder "what fragment did the letter reveal?" \
             --prompt "✉️  > " --prompt.foreground "31" --cursor.foreground "44")
else
    echo "The room asks: 'What fragment did the sealed letter reveal?'"
    read -r answer
fi

if [ "$answer" = "TUX-5" ]; then
    grep -q "TUX-5" "$KEYS" || echo "TUX-5" >> "$KEYS"
    echo ""
    echo "  ${GRN}'So you truly unsealed it. Fragment recorded.'${RST}"
    echo ""
    echo "  Next: ${BLU}mission2_heart${RST}"
else
    echo "  'No. Unseal the letter (chmod +r) and READ it first.'"
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

cat > "$A3/mission2_heart/heart.sh" << 'EOF'
#!/bin/bash
KEYS="$HOME/.quest_keys"
GUM="$HOME/.local/bin/gum"; [ -x "$GUM" ] || GUM="$(command -v gum 2>/dev/null)"
GRN=$'\033[1;38;5;40m'; BLU=$'\033[1;38;5;44m'; RST=$'\033[0m'
real=$(nproc)

if [ -n "$GUM" ] && [ -t 0 ]; then
    answer=$("$GUM" input --placeholder "how many processors do I have?" \
             --prompt "💓 > " --prompt.foreground "31" --cursor.foreground "44")
else
    echo "The machine asks: 'How many processors do I have?'"
    read -r answer
fi

if [ "$answer" = "$real" ]; then
    grep -q "TUX-6" "$KEYS" || echo "TUX-6" >> "$KEYS"
    echo ""
    echo "  ${BLU}'Correct. You have read my heart.'${RST}"
    echo ""
    echo "     ${GRN}>>> KEY FRAGMENT: TUX-6 <<<${RST}"
    echo ""
    echo "  One room remains: ${BLU}mission3_final${RST}"
else
    echo "  'No. Look again. Count the processors in /proc/cpuinfo.'"
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

cat > "$A3/mission3_final/final_door.sh" << 'EOF'
#!/bin/bash
KEYS="$HOME/.quest_keys"
NAMEF="$HOME/.quest_name"
GUM="$HOME/.local/bin/gum"; [ -x "$GUM" ] || GUM="$(command -v gum 2>/dev/null)"
GRN=$'\033[1;38;5;40m'; BLU=$'\033[1;38;5;44m'; RST=$'\033[0m'
need="TUX-1 TUX-2 TUX-3 TUX-4 TUX-5 TUX-6"
for k in $need; do
    if ! grep -q "$k" "$KEYS"; then
        echo "The door counts your key fragments... one is missing: ${BLU}$k${RST}"
        echo "Finish every mission first."
        exit 1
    fi
done

if [ -n "$GUM" ] && [ -t 0 ]; then
    word=$("$GUM" input --placeholder "six fragments... now, the FINALWORD" \
           --prompt "🚪 > " --prompt.foreground "31" --cursor.foreground "44")
else
    echo "The door: 'Six fragments. Impressive. The FINALWORD?'"
    read -r word
fi

if [ "$word" != "freedom" ]; then
    echo "'Wrong. It hides in the transmission. Pipe your tools together.'"
    exit 1
fi

if [ -s "$NAMEF" ]; then
    name="$(cat "$NAMEF")"
else
    echo "'...Correct. State your name for the record:'"
    read -r name
fi

if [ -n "$GUM" ] && [ -t 0 ]; then
    "$GUM" spin --spinner pulse --spinner.foreground "40" \
        --title "the final door opens for $name..." -- sleep 2
fi
clear
if command -v figlet >/dev/null 2>&1; then
    if command -v lolcat >/dev/null 2>&1; then
        figlet "QUEST COMPLETE" | lolcat
    else
        figlet "QUEST COMPLETE"
    fi
fi

if [ -n "$GUM" ]; then
    "$GUM" style --border double --padding "1 4" --margin "1 2" --align center \
        --border-foreground "40" --foreground "44" --bold \
        "CERTIFIED SYSTEM EXPLORER" "" "$name" "" \
        "found your place - uncovered the hidden" \
        "built, rescued, and searched" \
        "unlocked the sealed - read the machine's heart" \
        "joined tools into pipelines"
    "$GUM" style --padding "0 2" --italic --foreground "29" \
        "'This system was never abandoned." \
        " It was waiting for you, $name." \
        " It is called Linux. And now it is yours.'"
else
    echo ""
    echo "  =============================================="
    echo "   ${GRN}CERTIFIED SYSTEM EXPLORER:${RST}  ${BLU}$name${RST}"
    echo ""
    echo "   found your place - uncovered the hidden"
    echo "   built, rescued, and searched"
    echo "   unlocked the sealed - read the machine's heart"
    echo "   joined tools into pipelines"
    echo ""
    echo "   ${GRN}'This system was never abandoned."
    echo "    It was waiting for you, $name."
    echo "    It is called Linux. And now it is yours.'${RST}"
    echo "  =============================================="
fi

if command -v cowsay >/dev/null 2>&1; then
    echo "welcome home, $name" | cowsay -f tux 2>/dev/null || echo "welcome home, $name" | cowsay
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
#  COLORIZE + STYLE the notes
#  markers: [[C]]cmd[[E]]  [[U]]underline[[/U]]
#           [[G]]green[[/G]]  [[B]]cyan-blue[[/B]]  [[X]]red[[/X]]
# ============================================================
CHL=$(printf '\033[48;5;235m\033[1;38;5;42m')   # dark block + bold green cmd
UND=$(printf '\033[4;38;5;44m')                 # underline dark-cyan
GRN=$(printf '\033[1;38;5;34m')                 # bold dark green
BLU=$(printf '\033[1;38;5;38m')                 # bold dark cyan-blue
RED=$(printf '\033[1;38;5;160m')                # bold red (danger words)
RST=$(printf '\033[0m')
find "$Q" -name "*.txt" -type f | while read -r f; do
    sed -i "s/\[\[C\]\]/${CHL} /g; s/\[\[E\]\]/ ${RST}/g; \
            s/\[\[U\]\]/${UND}/g;  s/\[\[\/U\]\]/${RST}/g; \
            s/\[\[G\]\]/${GRN}/g;  s/\[\[\/G\]\]/${RST}/g; \
            s/\[\[B\]\]/${BLU}/g;  s/\[\[\/B\]\]/${RST}/g; \
            s/\[\[X\]\]/${RED}/g;  s/\[\[\/X\]\]/${RST}/g" "$f" 2>/dev/null
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
else
    # no-gum fallback: give START_HERE a simple green frame
    { echo "${GRN}=========================================================${RST}"
      cat "$Q/START_HERE.txt"
      echo "${GRN}=========================================================${RST}"
    } > "$Q/START_HERE.tmp" && mv "$Q/START_HERE.tmp" "$Q/START_HERE.txt"
fi

# lock the future acts (AFTER styling)
chmod 000 "$Q/act2_locked" "$Q/act3_locked"

# ============================================================
#  HELPER COMMANDS:  hint  +  quest-progress
# ============================================================
cat > "$BIN/hint" << 'EOF'
#!/bin/bash
BLU=$'\033[1;38;5;38m'; RST=$'\033[0m'
h() { echo "${BLU}hint:${RST} $1"; }
case "$PWD" in
    *mission3_final*)  h 'cat transmission.txt | grep "FINALWORD"' ;;
    *mission2_heart*)  h 'grep -c processor /proc/cpuinfo   gives you the count directly.' ;;
    *mission1_sealed*) h 'chmod +r sealed_letter.txt -> cat it -> then ./claim.sh' ;;
    *act3*)            h 'three missions. take them in order. read every note.txt.' ;;
    *haystack*)        h 'grep "ACCESS-CODE" logs/*' ;;
    *rescue*)          h 'mv rubble/gem.txt vault/   then   cp vault/gem.txt vault/gem_backup.txt' ;;
    *builder*)         h 'mkdir makes folders (mkdir -p workshop/tools). touch makes empty files. then ./inspect.sh' ;;
    *act2*)            h 'three missions. cd into each, read note.txt first.' ;;
    *east_door*)       h 'this room claims to be empty. ls has a flag that shows ALL files. try: ls -a' ;;
    *act1*)            h 'cd into each door. cat every note.txt. one door is lying.' ;;
    *linux-quest*)     h 'start with: cat START_HERE.txt   |  lost? pwd tells you where, ls shows what.' ;;
    *)                 h 'the quest lives at ~/linux-quest. go there:  cd ~/linux-quest' ;;
esac
EOF
chmod +x "$BIN/hint"

cat > "$BIN/quest-progress" << 'EOF'
#!/bin/bash
GUM="$HOME/.local/bin/gum"; [ -x "$GUM" ] || GUM="$(command -v gum 2>/dev/null)"
NAME="$(cat "$HOME/.quest_name" 2>/dev/null || echo unknown)"
if [ -s "$HOME/.quest_keys" ]; then FRAGS="$(cat "$HOME/.quest_keys")"; else FRAGS="(none yet)"; fi
if [ -n "$GUM" ]; then
    "$GUM" style --border rounded --padding "0 2" --border-foreground "31" --foreground "40" \
        "Explorer: $NAME" "Key fragments:" "$FRAGS"
else
    GRN=$'\033[1;38;5;40m'; RST=$'\033[0m'
    echo "Explorer: $NAME"
    echo "Key fragments collected:"
    echo "${GRN}$FRAGS${RST}"
fi
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
echo -e "\033[1;38;5;34m[LINUX QUEST]\033[0m welcome back, \033[1;38;5;38m$(cat "$HOME/.quest_name" 2>/dev/null || echo explorer)\033[0m. (stuck? type: hint)"
EOF
fi

# ---------- done ----------
if [ -n "$GUM" ]; then
    "$GUM" style --border double --padding "1 3" --margin "1 0" \
        --border-foreground "28" --foreground "38" \
        "The system has awakened, $QNAME." "" \
        "Type these three lines:" "" \
        "  source ~/.bashrc" \
        "  cd ~/linux-quest" \
        "  cat START_HERE.txt" "" \
        "Broke something? Re-run the setup command." \
        "The world resets. Your name and keys survive."
else
    G=$(printf '\033[1;38;5;34m'); B=$(printf '\033[1;38;5;38m'); R=$(printf '\033[0m')
    echo ""
    echo "${G}=============================================${R}"
    echo "  The system has awakened, ${B}$QNAME${R}."
    echo ""
    echo "  Type these three lines:"
    echo ""
    echo "     ${B}source ~/.bashrc${R}"
    echo "     ${B}cd ~/linux-quest${R}"
    echo "     ${B}cat START_HERE.txt${R}"
    echo ""
    echo "  Broke something? Re-run the setup command."
    echo "  The world resets. Your name and keys survive."
    echo "${G}=============================================${R}"
fi
