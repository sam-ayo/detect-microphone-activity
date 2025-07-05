# Microphone activity detector on macOS

Uses [CoreAudio](https://developer.apple.com/documentation/coreaudio) to detect when the microphone is being used.

Complie with:

```bash
swiftc -o micwatcher micWatcher.swift -framework CoreAudio -framework Foundation
```
