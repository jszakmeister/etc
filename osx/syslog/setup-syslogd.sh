#!/bin/bash
# Enables the syslogd daemon to receive UDP packets from other sources.
cd /System/Library/LaunchDaemons
sudo /usr/libexec/PlistBuddy -c "add :Sockets:NetworkListener dict" com.apple.syslogd.plist
sudo /usr/libexec/PlistBuddy -c "add :Sockets:NetworkListener:SockServiceName string syslog" com.apple.syslogd.plist
sudo /usr/libexec/PlistBuddy -c "add :Sockets:NetworkListener:SockType string dgram" com.apple.syslogd.plist
sudo launchctl unload com.apple.syslogd.plist
sudo launchctl load com.apple.syslogd.plist
