apt install arp-scan sqlite3 librsvg2-bin curl jq python3

python3 -m venv .venv
source .venv/bin/activate
pip3 install sqlite-utils adafruit-circuitpython-epd

cp *.units /etc/systemd/user/
systemctl daemon-reload
systemctl enable /etc/systemd/user/*.path /etc/systemd/user/*.timer /etc/system/user/*.service
systemctl start /etc/system/user/*.path /etc/systemd/user/*.timer
