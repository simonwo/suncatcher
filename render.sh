#!/bin/bash
set -xeuo pipefail
IFS=$'\n\t'

fmt() {
	numfmt --to=si --field='-' --suffix=W --round=nearest $1
}

read -r POWER LOAD <<EOF
$(sqlite3 -readonly -cmd '.mode tab' solar.db 'SELECT printf("%i", P_PV), printf("%i",ABS(P_LOAD)) from site ORDER BY rowid DESC LIMIT 1;')
EOF

STYLESHEET=$(if [ $POWER -lt $LOAD ]; then echo "--stylesheet=bad.css"; else echo "--stylesheet=good.css"; fi)

sed "s/POWER/$(fmt $POWER)/;s/LOAD/$(fmt $LOAD)/" display-template.svg |
	rsvg-convert --width=250 --height=122 $STYLESHEET -b white >display.png
