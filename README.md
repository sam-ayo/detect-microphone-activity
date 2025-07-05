# Microphone activity detector on macOS

Uses [CoreAudio](https://developer.apple.com/documentation/coreaudio) to detect when microphone is being used.

Pipes `active` and `inactive` to STDOUT depending on whether microphone is being used or not.

Complie with:

```bash
swiftc -o micwatcher micWatcher.swift -framework CoreAudio -framework Foundation
```

Usage:

```typescript
import { spawn } from "child_process";

const mic = spawn("./micWatcher", { stdio: ["ignore", "pipe", "inherit"] });

mic.stdout.on("data", (d) => {
  const state: string = d.toString().trim();
  console.log(state);
  // inactive or active
});

```
