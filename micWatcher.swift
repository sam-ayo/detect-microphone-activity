import CoreAudio
import Darwin
import Foundation

setbuf(stdout, nil)

let MIC_ACTIVE = "active"
let MIC_INACTIVE = "inactive"

let ERROR_MESSAGE = "Failed to read mic usage"
let DEFAULT_DEVICE_ERROR_MESSAGE = "Could not get default input device"

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
        print(ERROR_MESSAGE)
    }

    return noErr
}

func checkFirstTimeMicUsage(
    deviceID: AudioObjectID, propertyAddress: UnsafePointer<AudioObjectPropertyAddress>
) {
    var isRunning = DarwinBoolean(false)
    var dataSize = UInt32(MemoryLayout<UInt32>.size)

    let status = AudioObjectGetPropertyData(
        deviceID,
        propertyAddress,
        0,
        nil,
        &dataSize,
        &isRunning
    )

    if status == noErr {
        print(isRunning.boolValue ? MIC_ACTIVE : MIC_INACTIVE)
    } else {
        print(ERROR_MESSAGE)
    }
}

func monitorMicrophoneUsage() {
    guard let deviceID = getDefaultInputDeviceID() else {
        print(DEFAULT_DEVICE_ERROR_MESSAGE)
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

    checkFirstTimeMicUsage(deviceID: deviceID, propertyAddress: &propertyAddress)

    if status != noErr {
        print(ERROR_MESSAGE)
    }

    RunLoop.current.run()
}

monitorMicrophoneUsage()
