#!/bin/bash

# Change directory to the location of the file
sudo cp ros2 pkg prefix turtlebot3_bringup/share/turtlebot3_bringup/script/99-turtlebot3-cdc.rules /etc/udev/rules.d/

# Start systemd-udevd daemon
sudo /lib/systemd/systemd-udevd --daemon

# Reload udev rules
sudo udevadm control --reload-rules

# Trigger udev rules
sudo udevadm trigger

# Change permissions for specific devices
sudo chmod 777 /dev/ttyUSB* /dev/video* /dev/ttyACM0

echo "setup complete."

