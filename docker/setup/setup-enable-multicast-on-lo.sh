#!/bin/bash

if [ ! -f "/etc/systemd/system/multicast-lo.service" ]; then

sudo tee /etc/systemd/system/multicast-lo.service > /dev/null << 'EOF'
[Unit]
Description=Enable Multicast on Loopback

[Service]
Type=oneshot
ExecStart=/usr/sbin/ip link set lo multicast on

[Install]
WantedBy=multi-user.target
EOF

fi

sudo systemctl daemon-reload
sudo systemctl enable multicast-lo.service
sudo systemctl start multicast-lo.service
