#!/bin/bash
# ============================================================
#  LINUX QUEST - world builder
#  Runs on: Google Cloud Shell, WSL Ubuntu, Docker, any Linux
#  Usage:   bash <(curl -sL YOURLINK/setup.sh)
#  Reset:   re-run the same command (progress keys survive)
#  Fresh:   bash setup.sh --fresh   (wipes progress too)
# ============================================================

Q="$HOME/linux-quest"
KEYS="$HOME/.quest_keys"
BIN="$HOME/.local/bin"

# ---------- reset ----------
if [ -d "$Q" ]; then
    chmod -R 700 "$Q" 2>/dev/null
    rm -rf "$Q"
fi
[ "$1" = "--fresh" ] && rm -f "$KEYS"
touch "$KEYS"
mkdir -p "$Q" "$BIN"

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
=========================================================
              L I N U X   Q U E S T
=========================================================
You wake up inside an abandoned system.

The previous admin vanished years ago... but he left
notes everywhere. His first note is taped to the screen:

   "Rule 1: When lost, ask the system WHERE you are.
            It will print your working directory.

    Rule 2: Then LOOK around. List what surrounds you.

    Rule 3: Read everything. Trust nothing."

Somewhere near you is a room called act1.
It has four doors. One of them is lying to you.

(Stuck at any point? type:  hint )
=========================================================
EOF

cat > "$Q/act1/note.txt" << 'EOF'
Four doors. North, South, East, West.
The admin scratched into the wall:

   "To enter a door, Change Directory into it.
    To read a note, let the cat read it to you."
EOF

cat > "$Q/act1/north_door/note.txt" << 'EOF'
Empty room. Dust everywhere.
On the wall: "The EAST door lies."
EOF

cat > "$Q/act1/south_door/note.txt" << 'EOF'
A broken chair. A cold coffee mug. Nothing useful.
Someone wrote: "Went east. Never came back."
EOF

cat > "$Q/act1/west_door/note.txt" << 'EOF'
A poster of a penguin. Below it:
"His name is Tux. Remember that name."
EOF

cat > "$Q/act1/east_door/note.txt" << 'EOF'
"Nothing to see here. This room is completely empty.
 Definitely no hidden storage. Move along."

           - The Management
EOF

mkdir -p "$Q/act1/east_door/.storage"
cat > "$Q/act1/east_door/.storage/diary.txt" << 'EOF'
Day 47.
I started hiding my files by naming them with a dot.
Nobody ever finds dotfiles...
unless they ask ls to show -a-ll of them.

You found this. You're smarter than the last one.

   >>> KEY FRAGMENT: TUX-1 <<<

Go back to the quest folder. Find gate2.
It will not open without proof you found me.
EOF

# easter egg
mkdir -p "$Q/act1/.graffiti"
cat > "$Q/act1/.graffiti/wall.txt" << 'EOF'
  ACHIEVEMENT UNLOCKED: The Curious One
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
echo "The gate hums: 'Speak the first key fragment.'"
read -r answer
if [ "$answer" = "TUX-1" ]; then
    grep -q "TUX-1" "$KEYS" || echo "TUX-1" >> "$KEYS"
    chmod 755 "$Q/act2_locked" 2>/dev/null
    mv "$Q/act2_locked" "$Q/act2" 2>/dev/null
    echo ""
    echo "The gate slides open. A new room appears: act2"
    echo "The admin's voice, from an old recording:"
    echo "   'Reading was the easy part. Now you BUILD.'"
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
The admin's workshop collapsed. Rebuild it, right here,
inside mission1_builder:

   workshop/
     tools/
     blueprints/
     secrets/

Then create an empty file named  badge.txt  inside secrets/.
(The admin created empty files with a gentle touch.)

When you believe the workshop stands, run:  ./inspect.sh
EOF

cat > "$A2/mission1_builder/inspect.sh" << 'EOF'
#!/bin/bash
B="$(dirname "$0")/workshop"
KEYS="$HOME/.quest_keys"
if [ -d "$B/tools" ] && [ -d "$B/blueprints" ] && [ -f "$B/secrets/badge.txt" ]; then
    grep -q "TUX-2" "$KEYS" || echo "TUX-2" >> "$KEYS"
    echo "  The workshop stands again. The dust settles."
    echo ""
    echo "     >>> KEY FRAGMENT: TUX-2 <<<"
    echo ""
    echo "  Next: mission2_rescue"
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
An earthquake buried the admin's treasure under rubble/.

Your mission:
  1. MOVE gem.txt out of rubble/ and into vault/
     (moving is like teleporting a file: mv <from> <to>)
  2. Make a backup: COPY the gem inside vault/
     to a second file called  gem_backup.txt

Leave the trash where it is. It has feelings too.

Then run:  ./check.sh
EOF

cat > "$A2/mission2_rescue/check.sh" << 'EOF'
#!/bin/bash
D="$(dirname "$0")"
KEYS="$HOME/.quest_keys"
if [ -f "$D/vault/gem.txt" ] && [ -f "$D/vault/gem_backup.txt" ] && [ ! -f "$D/rubble/gem.txt" ]; then
    grep -q "TUX-3" "$KEYS" || echo "TUX-3" >> "$KEYS"
    echo "  The gem is safe AND backed up. The admin nods in spirit."
    echo ""
    echo "     >>> KEY FRAGMENT: TUX-3 <<<"
    echo ""
    echo "  Next: mission3_haystack"
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
# bury the code in one random-ish file
echo "[SECURITY] ACCESS-CODE: TUX-4  (do not tell anyone)" >> "$A2/mission3_haystack/logs/server_37.log"

cat > "$A2/mission3_haystack/note.txt" << 'EOF'
The final gate of this floor needs an ACCESS-CODE.

It is written in ONE of these 50 log files.

You could read all 50 by hand. The admin's ghost is
watching, and he will laugh at you.

Or... he left advice:

   "When I needed a needle in a haystack of text,
    I never read. I searched. My favorite tool
    could grab any word from a thousand files:

        <tool> "WORD" logs/*                    "

Find the ACCESS-CODE. Then find gate3 in the quest folder.
EOF

# ============================================================
#  GATE 3  (checks TUX-4, unlocks act3)
# ============================================================
mkdir -p "$Q/act3_locked"

cat > "$Q/gate3.sh" << 'EOF'
#!/bin/bash
Q="$HOME/linux-quest"
KEYS="$HOME/.quest_keys"
echo "The last gate whispers: 'The access code. Now.'"
read -r answer
if [ "$answer" = "TUX-4" ]; then
    grep -q "TUX-4" "$KEYS" || echo "TUX-4" >> "$KEYS"
    chmod 755 "$Q/act3_locked" 2>/dev/null
    mv "$Q/act3_locked" "$Q/act3" 2>/dev/null
    echo ""
    echo "The floor shakes. act3 rises from the ground."
    echo "The recording crackles one last time:"
    echo "   'Beyond this point, the system stops being"
    echo "    a place... and starts being ALIVE.'"
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

Two rooms remain. Go see the machine's heart.
EOF
chmod 000 "$A3/mission1_sealed/sealed_letter.txt"

cat > "$A3/mission1_sealed/note.txt" << 'EOF'
A letter lies here, SEALED. Try to read it. Go on. Try.

Denied? Good. Now listen:

   "Every file answers three questions:
    who may READ it, WRITE it, RUN it.
    The lock is called a permission.
    The locksmith is called  chmod.

    To grant yourself reading rights:
        chmod +r <file>                "

Unseal the letter. Read it. Remember this feeling.
EOF

# ---- mission 2: the machine's heart ----
mkdir -p "$A3/mission2_heart"
cat > "$A3/mission2_heart/note.txt" << 'EOF'
The admin's strangest note:

   "In Linux, EVERYTHING is a file.
    My mouse is a file. My disk is a file.
    Even the machine's beating heart - the CPU -
    is a file you can simply read:

        /proc/cpuinfo

    Look at it. Then answer the machine's question."

Run:  ./heart.sh
EOF

cat > "$A3/mission2_heart/heart.sh" << 'EOF'
#!/bin/bash
KEYS="$HOME/.quest_keys"
real=$(nproc)
echo "The machine asks: 'How many processors do I have?'"
echo "(the heart-file knows... every processor is listed inside it)"
read -r answer
if [ "$answer" = "$real" ]; then
    grep -q "TUX-6" "$KEYS" || echo "TUX-6" >> "$KEYS"
    echo ""
    echo "  'Correct. You have read my heart.'"
    echo ""
    echo "     >>> KEY FRAGMENT: TUX-6 <<<"
    echo ""
    echo "  One room remains: mission3_final"
else
    echo "  'No. Look again. Count the processors in /proc/cpuinfo.'"
    echo "  (hint: remember the searching tool from the haystack?)"
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
The last door needs one word - the FINALWORD.

It is buried inside transmission.txt: 801 lines of static.

The admin's last lesson:

   "Alone, my tools were good.
    Connected, they were unstoppable.
    I joined them with a pipe:  |

    One tool speaks, the next one listens:

        cat <file> | <search-tool> "WORD"    "

Find the FINALWORD, then run:  ./final_door.sh
EOF

cat > "$A3/mission3_final/final_door.sh" << 'EOF'
#!/bin/bash
KEYS="$HOME/.quest_keys"
need="TUX-1 TUX-2 TUX-3 TUX-4 TUX-5 TUX-6"
for k in $need; do
    if ! grep -q "$k" "$KEYS"; then
        echo "The door counts your key fragments... one is missing: $k"
        echo "Finish every mission first."
        exit 1
    fi
done
echo "The door: 'Six fragments. Impressive. The FINALWORD?'"
read -r word
if [ "$word" != "freedom" ]; then
    echo "'Wrong. It hides in the transmission. Pipe your tools together.'"
    exit 1
fi
echo ""
echo "'...Correct. State your name for the record:'"
read -r name
clear
if command -v figlet >/dev/null 2>&1; then
    if command -v lolcat >/dev/null 2>&1; then
        figlet "QUEST COMPLETE" | lolcat
    else
        figlet "QUEST COMPLETE"
    fi
else
cat << 'ART'
  ___  _   _ _____ ____ _____    ____ ___  __  __ ____  _     _____ _____ _____
 / _ \| | | | ____/ ___|_   _|  / ___/ _ \|  \/  |  _ \| |   | ____|_   _| ____|
| | | | | | |  _| \___ \ | |   | |  | | | | |\/| | |_) | |   |  _|   | | |  _|
| |_| | |_| | |___ ___) || |   | |__| |_| | |  | |  __/| |___| |___  | | | |___
 \__\_\\___/|_____|____/ |_|    \____\___/|_|  |_|_|   |_____|_____| |_| |_____|
ART
fi
echo ""
echo "  =============================================="
echo "   CERTIFIED SYSTEM EXPLORER:  $name"
echo ""
echo "   You woke up unable to see your own location."
echo "   You leave knowing how to:"
echo "     - find your place, and look around"
echo "     - uncover what others hide"
echo "     - build, move, and rescue"
echo "     - search 50 files in one breath"
echo "     - unlock what was sealed"
echo "     - read the machine's own heart"
echo "     - join tools into pipelines"
echo ""
echo "   The admin's final message:"
echo "     'This system was never abandoned."
echo "      It was waiting for you."
echo "      It is called Linux. And now it is yours.'"
echo "  =============================================="
if command -v cowsay >/dev/null 2>&1; then
    echo "welcome home, $name" | cowsay -f tux 2>/dev/null || echo "welcome home, $name" | cowsay
fi
echo ""
echo "  (screenshot this. you earned it.)"
EOF
chmod +x "$A3/mission3_final/final_door.sh"

# easter egg in act3
cat > "$A3/.do_not_open.txt" << 'EOF'
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        WHY WOULD YOU OPEN THIS
IT LITERALLY SAYS DO NOT OPEN
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

...fine. ACHIEVEMENT UNLOCKED: Rule Breaker
(the admin is proud of you, secretly)
EOF

# lock the future acts
chmod 000 "$Q/act2_locked" "$Q/act3_locked"

# ============================================================
#  HELPER COMMANDS:  hint  +  quest-reset
# ============================================================
cat > "$BIN/hint" << 'EOF'
#!/bin/bash
case "$PWD" in
    *mission3_final*)  echo "hint: cat transmission.txt | grep \"FINALWORD\"" ;;
    *mission2_heart*)  echo "hint: grep processor /proc/cpuinfo   ...then count. or let grep -c count for you." ;;
    *mission1_sealed*) echo "hint: chmod +r sealed_letter.txt   then cat it." ;;
    *act3*)            echo "hint: three missions. take them in order. read every note.txt." ;;
    *haystack*)        echo "hint: grep \"ACCESS-CODE\" logs/*" ;;
    *rescue*)          echo "hint: mv rubble/gem.txt vault/   then   cp vault/gem.txt vault/gem_backup.txt" ;;
    *builder*)         echo "hint: mkdir makes folders (mkdir -p workshop/tools). touch makes empty files." ;;
    *act2*)            echo "hint: three missions. cd into each, read note.txt first." ;;
    *east_door*)       echo "hint: this room claims to be empty. ls has a flag that shows ALL files. try: ls -a" ;;
    *act1*)            echo "hint: cd into each door. cat every note.txt. one door is lying." ;;
    *linux-quest*)     echo "hint: start with: cat START_HERE.txt   |  lost? pwd tells you where you are, ls shows what's here." ;;
    *)                 echo "hint: the quest lives at ~/linux-quest. go there:  cd ~/linux-quest" ;;
esac
EOF
chmod +x "$BIN/hint"

cat > "$BIN/quest-progress" << 'EOF'
#!/bin/bash
echo "Key fragments collected:"
if [ -s "$HOME/.quest_keys" ]; then cat "$HOME/.quest_keys"; else echo "  (none yet)"; fi
EOF
chmod +x "$BIN/quest-progress"

# ---------- .bashrc touches (append once) ----------
if ! grep -q "LINUX_QUEST_MARK" "$HOME/.bashrc" 2>/dev/null; then
cat >> "$HOME/.bashrc" << 'EOF'

# LINUX_QUEST_MARK
export PATH="$PATH:$HOME/.local/bin:/usr/games"
echo -e "\033[1;32m[LINUX QUEST]\033[0m world loaded. cd ~/linux-quest && cat START_HERE.txt   (stuck? type: hint)"
EOF
fi
export PATH="$PATH:$BIN:/usr/games"

# ---------- done ----------
echo ""
echo "============================================="
echo "  The system has awakened."
echo ""
echo "  Type:"
echo "     cd ~/linux-quest"
echo "     cat START_HERE.txt"
echo ""
echo "  Commands you now own:"
echo "     hint            - contextual clue, anywhere"
echo "     quest-progress  - see your key fragments"
echo ""
echo "  Broke something? Re-run the setup command."
echo "  The world resets. Your keys survive."
echo "============================================="
