import CoreAudio
import Darwin
import Foundation

setbuf(stdout, nil)

let MIC_ACTIVE = "active"
let MIC_INACTIVE = "inactive"

func getDefaultInputDeviceID() -> AudioDeviceID? {
    var defaultDeviceID = AudioDeviceID()
    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultInputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )

    var dataSize = UInt32(MemoryLayout<AudioDeviceID>.size)
    let status = AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &propertyAddress,
        0,
        nil,
        &dataSize,
        &defaultDeviceID
    )

    return (status == noErr) ? defaultDeviceID : nil
}

func micUsageChanged(
    inDeviceID: AudioObjectID,
    numberAddresses: UInt32,
    addresses: UnsafePointer<AudioObjectPropertyAddress>,
    clientData: UnsafeMutableRawPointer?
) -> OSStatus {

    var isRunning = DarwinBoolean(false)
    var dataSize = UInt32(MemoryLayout<UInt32>.size)

    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyDeviceIsRunningSomewhere,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )

    let status = AudioObjectGetPropertyData(
        inDeviceID,
        &propertyAddress,
        0,
        nil,
        &dataSize,
        &isRunning
    )

    if status == noErr {
        print(isRunning.boolValue ? MIC_ACTIVE : MIC_INACTIVE)
    } else {
        print("Failed to read mic usage")
    }

    return noErr
}

func monitorMicrophoneUsage() {
    guard let deviceID = getDefaultInputDeviceID() else {
        print("Could not get default input device")
        return
    }

    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyDeviceIsRunningSomewhere,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )

    let status = AudioObjectAddPropertyListener(
        deviceID,
        &propertyAddress,
        micUsageChanged,
        nil
    )

    if status != noErr {
        fputs("Failed to register mic listener\n", stderr)
    }

    RunLoop.current.run()
}

monitorMicrophoneUsage()
