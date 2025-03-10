#!/bin/bash

counter=0
TIMEOUT=300  # 5 minutes in seconds

while true; do
    # Check if the USB device exists
    if [[ $(/usr/bin/lsusb -d 3566:2001) ]]; then
        echo "USB device 3566:2001 detected."

        # Wait 30 seconds (wait to get ip)
        /bin/sleep 30

        # Check if the device can ping 192.168.8.1
        if ! /bin/ping -c 1 -w 5 192.168.8.1 &>/dev/null; then
            echo "No reply from 192.168.8.1. Executing commands..."

            # Execute usb_modeswitch and modprobe commands
            /usr/sbin/usb_modeswitch -v 3566 -p 2001 -X
            /sbin/modprobe option
            echo "3566 2001 ff" > /sys/bus/usb-serial/drivers/option1/new_id
        else
            echo "Ping to 192.168.1.8 successful. All ok!"
            break
        fi

        # Wait until a serial port is assigned
        echo "Waiting for serial port to appear..."
        serialPort=$(/bin/dmesg | /bin/grep "GSM modem" | /bin/grep -o 'ttyUSB[0-9]*' | /usr/bin/sort -V | /usr/bin/tail -n 1)
        while [ -z "$serialPort" ]; do
            /bin/sleep 1
            serialPort=$(/bin/dmesg | /bin/grep "GSM modem" | /bin/grep -o 'ttyUSB[0-9]*' | /usr/bin/sort -V | /usr/bin/tail -n 1)
        done

        # Make dongle stable
        /bin/sleep 3

        # Execute the final set of commands
        echo "/dev/$serialPort detected. Executing final commands..."
        if /bin/ls -la /dev/$serialPort | /bin/grep -q dialout; then
            echo "AT^RESET" > /dev/$serialPort
            /usr/bin/timeout 2 cat /dev/$serialPort
            # Give time for dongle to switch modes (30 sec)
            /bin/sleep 30
            # Reset counter
            counter=0
        else
            echo "/dev/$serialPort does not belong to the dialout group."
        fi
    else
        # Increment counter and check for timeout
        counter=$((counter + 1))
        if (( counter >= TIMEOUT )); then
            echo "USB device 3566:2001 not found. Exiting..."
            break
        fi
    fi
    /bin/sleep 1
done