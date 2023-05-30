#include "bass.h"
#include "bassstuff.h"

#include <allegro5/allegro.h>

void initSound(void)
{
#ifdef __linux__XXX
	BASS_Init(-1, 44100, BASS_DEVICE_DMIX, 0, 0);
#else
	BASS_Init(-1, 44100, 0, 0, 0);
#endif
}

HSAMPLE loadSample(const char *name)
{
	return BASS_SampleLoad(false,
		name,
		0, 0, 8,
		BASS_SAMPLE_OVER_POS);
}

HSAMPLE loadSampleLoop(const char *name)
{
	return BASS_SampleLoad(false,
		name,
		0, 0, 8,
		BASS_SAMPLE_OVER_POS | BASS_SAMPLE_LOOP);
}

extern bool sound_on;

void playSampleVolume(HSAMPLE s, float vol)
{
	if (!sound_on)
		return;

	HCHANNEL chan = BASS_SampleGetChannel(s, false);
	BASS_ChannelSetAttribute(chan, BASS_ATTRIB_VOL, vol);
	BASS_ChannelPlay(chan, false);
}

void playSample(HSAMPLE s)
{
    playSampleVolume(s, 1.0);
}

void stopSample(HSAMPLE s)
{
	BASS_SampleStop(s);
}

static void CALLBACK MusicSyncProc(
	HSYNC handle, DWORD channel, DWORD data, void *user)
{
	if (!BASS_ChannelSetPosition(channel, 0, BASS_POS_BYTE))
		BASS_ChannelSetPosition(channel, 0, BASS_POS_BYTE);
}

static HSAMPLE music;

void playMusic(bool menu)
{
#ifndef LITE
	music = BASS_StreamCreateFile(false, menu ? "data/menu.ogg" : "data/Bobby.ogg", 0, 0, 0);
#else
	music = BASS_StreamCreateFile(false, menu ? "lite-data/menu.ogg" : "lite-data/Bobby.ogg", 0, 0, 0);
#endif
	BASS_ChannelSetSync(music, BASS_SYNC_END | BASS_SYNC_MIXTIME,
		0, MusicSyncProc, 0);
    BASS_ChannelSetAttribute(music, BASS_ATTRIB_VOL, 0);
	BASS_ChannelPlay(music, FALSE);
    // half second fade in
    int i;
    for (i = 0; i < 100; i++) {
        BASS_ChannelSetAttribute(music, BASS_ATTRIB_VOL, i / 100.0);
        al_rest(0.5 / 100);
    }
}

void stopMusic(void)
{
    // half second fade out
    int i;
    for (i = 0; i < 100; i++) {
        BASS_ChannelSetAttribute(music, BASS_ATTRIB_VOL, (100 - i) / 100.0);
        al_rest(0.5 / 100);
    }
	BASS_StreamFree(music);
}

void shutdownBASS(void)
{
	BASS_Free();
}
