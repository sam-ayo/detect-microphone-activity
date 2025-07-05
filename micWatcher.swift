import Foundation
import CoreAudio

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
        print("Microphone is \(isRunning.boolValue ? "ACTIVE" : "INACTIVE")")
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
    
    if status == noErr {
        print("Listening for mic usage on device ID: \(deviceID)")
    } else {
        print("Failed to register mic listener")
    }
    
    RunLoop.current.run()
}

monitorMicrophoneUsage()
