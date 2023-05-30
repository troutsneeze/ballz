#ifndef _FOOO
#define _FOOO

#ifdef __cplusplus
extern "C" {
#endif

void initSound(void);
HSAMPLE loadSample(const char *name);
HSAMPLE loadSampleLoop(const char *name);
void playSampleVolume(HSAMPLE s, float volume);
void playSample(HSAMPLE s);
void stopSample(HSAMPLE s);
void playMusic(bool menu);
void stopMusic(void);
void shutdownBASS(void);

#ifdef __cplusplus
}
#endif

#endif
