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

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printf("Please specify a volume!\n");
        exit(1);
    }

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

    int volume = atoi(argv[1]);

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
    msg[8] = volume;  // data
    msg[9] = 0x0;  // checksum
    msg[10] = 0xF7; // EOX

    uint checksum = 0x80;
    for (int index = 5; index < 9; index++) {
        checksum -= msg[index];
    }
    msg[9] = checksum % 0x80;

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
