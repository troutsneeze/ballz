using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;


namespace Bobby
{
    class Sound
    {
        public static SoundEffect music;
        public static SoundEffect menu_music;

        public static SoundEffect start;
        public static SoundEffect boing;
        public static SoundEffect spiral;
        public static SoundEffect bink;
        public static SoundEffect boost;
        public static SoundEffect switch_sample;
        public static SoundEffect meow;
        public static SoundEffect error;

        private static SoundEffectInstance music_inst;
        private static SoundEffectInstance menu_music_inst;
        private static SoundEffectInstance boost_inst;

        private static Random random;
        private static long next_boing;
        private static DateTime start_time;

        public static void init(Game game)
        {
            music = game.Content.Load<SoundEffect>("data/Bobby");
            menu_music = game.Content.Load<SoundEffect>("data/menu_music");

            start = game.Content.Load<SoundEffect>("data/start");
            boing = game.Content.Load<SoundEffect>("data/boing");
            spiral = game.Content.Load<SoundEffect>("data/spiral");
            bink = game.Content.Load<SoundEffect>("data/bink");
            boost = game.Content.Load<SoundEffect>("data/boost");
            switch_sample = game.Content.Load<SoundEffect>("data/switch");
            meow = game.Content.Load<SoundEffect>("data/meow");
            error = game.Content.Load<SoundEffect>("data/error");

            start_time = DateTime.Now;
            random = new Random((int)(DateTime.Now - new DateTime(1981, 4, 10, 0, 0, 0, 0)).TotalMilliseconds);
            next_boing = current_time_millis();
        }

        public static void play_music()
        {
            if (!Bobby_Game.music_enabled)
                return;

            stop_menu_music();

            music_inst = music.CreateInstance();
            music_inst.IsLooped = true;
            music_inst.Play();
        }

        public static void play_menu_music()
        {
            if (!Bobby_Game.music_enabled)
                return;

            menu_music_inst = menu_music.CreateInstance();
            menu_music_inst.IsLooped = true;
            menu_music_inst.Play();
        }

        public static void stop_music()
        {
            if (!Bobby_Game.music_enabled)
                return;

            if (music_inst == null)
                return;

            music_inst.Stop();
            music_inst = null;

            play_menu_music();
        }

        public static void stop_menu_music()
        {
            if (!Bobby_Game.music_enabled)
                return;

            if (menu_music_inst == null)
                return;

            menu_music_inst.Stop();
            menu_music_inst = null;
        }

        public static void play_boost()
        {
            if (!Bobby_Game.sound_enabled)
                return;

            boost_inst = boost.CreateInstance();
            boost_inst.IsLooped = true;
            boost_inst.Play();
        }

        public static void stop_boost()
        {
            if (!Bobby_Game.sound_enabled)
                return;

            if (boost_inst == null)
                return;

            boost_inst.Stop();
            boost_inst = null;
        }

        public static void play(SoundEffect s)
        {
            if (!Bobby_Game.sound_enabled)
                return;

            if (s == boing)
            {
                if (current_time_millis() >= next_boing)
                {
                    next_boing = current_time_millis() + 100;
                    boing.Play();
                }
            }
            else
            {
                s.Play();
            }
        }

        public static long current_time_millis()
        {
            TimeSpan span = DateTime.Now - start_time;
            return (long)span.TotalMilliseconds;
        }
    }
}
