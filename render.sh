#!/bin/bash
set -xeuo pipefail
IFS=$'\n\t'

fmt() {
	numfmt --to=si --field='-' --suffix=W --round=nearest $1
}

# At most update the display every 30s
if [ -z "$(find display.png -not -newermt '30 seconds')" ]; then
	exit 0
fi

touch rowid.txt
read -d ';' -r NEW_QUERY <<EOQ
	SELECT rowid,
		   printf("%i", P_PV) AS power,
		   printf("%i", ABS(P_LOAD)) AS load
	FROM site
	ORDER BY Timestamp DESC
	LIMIT 1;
EOQ

read -d ';' -r OLD_QUERY <<EOQ
	SELECT rowid,
	       printf("%i", P_PV) as power,
		   printf("%i", ABS(P_LOAD)) AS load
	FROM site
	WHERE rowid = "$(cat rowid.txt)"
	LIMIT 1;
EOQ

read -r NEW_ROWID NEW_POWER NEW_LOAD <<EOF
$(sqlite3 -readonly -cmd '.mode tab' solar.db "$NEW_QUERY")
EOF

read -r OLD_ROWID OLD_POWER OLD_LOAD <<EOF
$(sqlite3 -readonly -cmd '.mode tab' solar.db "$OLD_QUERY")
EOF

THRESHOLD_WATTS=250
if (($OLD_POWER < ($NEW_POWER - $THRESHOLD_WATTS))) ||
   (($OLD_POWER > ($NEW_POWER + $THRESHOLD_WATTS))) ||
   (($OLD_LOAD < ($NEW_LOAD - $THRESHOLD_WATTS))) ||
   (($OLD_LOAD > ($NEW_LOAD + $THRESHOLD_WATTS))); then
    STYLESHEET=$(if [ $NEW_POWER -lt $NEW_LOAD ]; then echo "--stylesheet=bad.css"; else echo "--stylesheet=good.css"; fi)

	sed "s/POWER/$(fmt $NEW_POWER)/;s/LOAD/$(fmt $NEW_LOAD)/" display-template.svg |
		rsvg-convert --width=250 --height=122 $STYLESHEET -b white >display.png

	echo $NEW_ROWID > rowid.txt
fi
