#include <CoreMIDI/CoreMIDI.h>

int getDevice() {
    ItemCount destinations = MIDIGetNumberOfDestinations();
    for (ItemCount i = 0 ; i < destinations ; ++i) {
        MIDIEndpointRef dest = MIDIGetDestination(i);
        if (dest) {
            CFStringRef name = nil;
            MIDIObjectGetStringProperty(dest, kMIDIPropertyDisplayName, &name);

            if ([(NSString *)name isEqual: @"MD-BT01 Bluetooth"]) {
                return i;
            }
        }
    }
    return -1;
}

int main() {
    MIDIClientRef client;
    MIDIPortRef out;
    OSStatus err = noErr;

    MIDIClientCreate(CFSTR("MT-32 volume control client"), NULL, NULL, &client);
    int i = getDevice();

    MIDIEndpointRef dest = MIDIGetDestination(i);
    err = MIDIOutputPortCreate(client, CFSTR("mt32_out"), &out);
    if (err != noErr) {
        puts("Unknown error; exiting");
        exit(1);
    }

    // See: http://www.youngmonkey.ca/nose/audio_tech/synth/Roland-MT32.html
    char msg[11];
    msg[0] = 0xF0;  // start sysex
    msg[1] = 0x41;  // Roland ID
    msg[2] = 0x10;  // device ID
    msg[3] = 0x16;  // model ID
    msg[4] = 0x12;  // DTI
    msg[5] = 0x10;  // address MSB
    msg[6] = 0x00;  // address
    msg[7] = 0x16;  // address LSB
    msg[8] = 0x46;  // data - currently hardcoded to 70% (0x46)
    msg[9] = 0x14;  // checksum
    msg[10] = 0xF7; // EOX

    char buf[384];
    MIDIPacketList *packetList = (MIDIPacketList *)buf;
    MIDIPacket *packet = packetList->packet;

    packetList->numPackets = 1;
    packet->timeStamp = 0;

    packet->length = 12;
    memcpy(packet->data, msg, 11);

    MIDISend(out, dest, packetList);

    if (client) {
        MIDIClientDispose(client);
    }
}
