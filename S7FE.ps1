#!/usr/bin/env pwsh
#cleaner screen sharing for my 16:10 Tablet to 16:9

adb shell wm size 1080x1920 -s R52W2061SHB
#scrcpy --tcpip=192.168.178.32:5555 --fullscreen --video-bit-rate=10M --audio-encoder=c2.android.opus.encoder
scrcpy --fullscreen --video-bit-rate=10M --audio-encoder=c2.android.opus.encoder --display 2
#scrcpy -s R52W2061SHB -S --window-borderless --video-bit-rate=10M --audio-encoder=c2.android.opus.encoder
adb shell wm size 1600x2560 -s R52W2061SHB