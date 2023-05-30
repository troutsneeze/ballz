using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Content;
//using Microsoft.Xna.Framework.GamerServices;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Microsoft.Xna.Framework.Media;
//using Microsoft.Xna.Framework.Storage;
using System.IO;
using System.ComponentModel;
using System.Text;

namespace Bobby
{
    class MyException : Exception
    {
    }

    /// <summary>
    /// This is a game component that implements IUpdateable.
    /// </summary>
    public class LevelSelectGameComponent : Microsoft.Xna.Framework.DrawableGameComponent
    {
        SpriteBatch spriteBatch;

        Bobby_Game game;

        Texture2D[] previews;
        Texture2D selector_bmp;
        Texture2D tinyfont;
        Texture2D blackhole;
        Texture2D a_bmp, b_bmp, x_bmp, y_bmp;
        Texture2D lock_bmp;
        Texture2D star_bmp;

        static int selected = 0;
        static int top = 0;

        bool GameSaveRequested = false;
        bool GameLoadRequested = false;
        IAsyncResult result;

        public LevelSelectGameComponent(Game game)
            : base(game)
        {
            this.game = (Bobby_Game)game;
        }

        /// <summary>
        /// Allows the game component to perform any initialization it needs to before starting
        /// to run.  This is where it can query for any required services and load content.
        /// </summary>
        public override void Initialize()
        {
            spriteBatch = new SpriteBatch(game.GraphicsDevice);

            base.Initialize();
        }

        protected override void LoadContent()
        {
            previews = new Texture2D[Bobby_Game.LEVELS];
            for (int i = 0; i < Bobby_Game.LEVELS; i++)
            {
                previews[i] = mkpreview(i);
            }

            selector_bmp = game.Content.Load<Texture2D>("selection_arrow");

            tinyfont = game.Content.Load<Texture2D>("tinyfont");

            blackhole = game.Content.Load<Texture2D>("blackhole");

            a_bmp = game.Content.Load<Texture2D>("a");
            b_bmp = game.Content.Load<Texture2D>("b");
            x_bmp = game.Content.Load<Texture2D>("x");
            y_bmp = game.Content.Load<Texture2D>("y");

            lock_bmp = game.Content.Load<Texture2D>("lock");

            star_bmp = game.Content.Load<Texture2D>("star");

            base.LoadContent();
        }

        /// <summary>
        /// Allows the game component to update itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        public override void Update(GameTime gameTime)
        {
            int old = selected;

            if (Input.get_l() && selected > 0)
            {
                Input.l_repeat();
                selected--;
            }
            else if (Input.get_r() && selected < Bobby_Game.LEVELS - 1)
            {
                Input.r_repeat();
                selected++;
            }
            else if (Input.get_u() && selected > 1)
            {
                Input.u_repeat();
                selected -= 2;
            }
            else if (Input.get_d() && selected < Bobby_Game.LEVELS - 1)
            {
                Input.d_repeat();
                selected += 2;
                if (selected > Bobby_Game.LEVELS - 1)
                    selected--;
            }

            if (old != selected)
            {
                Sound.play(Sound.bink);
            }

            if (selected < top)
                top -= 2;
            else if (top + 4 <= selected)
                top += 2;

            if (Input.get_a())
            {
                // wait for release of A so we don't thrust off the start
                //while (GamePad.GetState(game.player_index).Buttons.A == ButtonState.Pressed)
                    ;

                bool unlocked = (selected == 0 || Bobby_Game.stars[selected - 1] >= 2);
                if (unlocked)
                {
                    Sound.play(Sound.bink);
                    game.add_maingamecomponent(selected);
                    return;
                }
                else
                {
                    Sound.play(Sound.error);
                }
            }
            else if (Input.get_b())
            {
                Sound.play(Sound.bink);
                game.add_mainmenugamecomponent();
                return;
            }

            game.updateStarAlpha();

            if (Input.get_x())
            {
                if (false)//Guide.IsTrialMode)
                {
                    Sound.play(Sound.error);
                    game.add_noticegamecomponent("Not available in trial mode");
                    return;
                }
                else
                {
                    Sound.play(Sound.bink);
                    /*
                    if (game.load_storage_device == null || !game.load_storage_device.IsConnected)
                    {
                        game.load_storage_device = null;
                        // Set the request flag
                        if ((!Guide.IsVisible) && (GameSaveRequested == false) && (GameLoadRequested == false))
                        {
                            GameLoadRequested = true;
                            result = StorageDevice.BeginShowSelector(game.player_index, null, null);
                        }
                    }
                    else
                    {
                        load(game.load_storage_device);
                    }
                    */
                    load();
                }
            }
            else if (Input.get_y())
            {
                if (false)//Guide.IsTrialMode)
                {
                    Sound.play(Sound.error);
                    game.add_noticegamecomponent("Not available in trial mode");
                    return;
                }
                else
                {
                    Sound.play(Sound.bink);
                    /*
                    if (game.save_storage_device == null || !game.save_storage_device.IsConnected)
                    {
                        game.save_storage_device = null;
                        // Set the request flag
                        if ((!Guide.IsVisible) && (GameSaveRequested == false) && (GameLoadRequested == false))
                        {
                            GameSaveRequested = true;
                            result = StorageDevice.BeginShowSelector(game.player_index, null, null);
                        }
                    }
                    else
                    {
                        save(game.save_storage_device);
                    }
                    */
                    save();
                }
            }

            // If a save is pending, save as soon as the
            // storage device is chosen
            /*
            if ((GameLoadRequested) && (result.IsCompleted))
            {
                StorageDevice device = StorageDevice.EndShowSelector(result);
                if (device != null && device.IsConnected)
                {
                    game.load_storage_device = device;
                    load(device);
                }
                // Reset the request flag
                GameLoadRequested = false;
            }
            else if ((GameSaveRequested) && (result.IsCompleted))
            {
                StorageDevice device = StorageDevice.EndShowSelector(result);
                if (device != null && device.IsConnected)
                {
                    game.save_storage_device = device;
                    save(device);
                }
                // Reset the request flag
                GameSaveRequested = false;
            }
            */

            base.Update(gameTime);
        }

        public override void Draw(GameTime gameTime)
        {
            const int PREVIEW_H = 150;
            const int PREVIEW_W = (int)(PREVIEW_H * 960 / 640.0f);
            const int xgap = (960 - PREVIEW_W * 2) / 3;
            const int ygap = ((640-64) - PREVIEW_H * 2) / 3;
            const int x1 = xgap;
            const int x2 = x1 + PREVIEW_W + xgap;
            const int y1 = 64 + ygap + 10;
            const int y2 = y1 + PREVIEW_H + ygap - 10;

            Viewport old_vp = game.GraphicsDevice.Viewport;
            float w = old_vp.Width * 0.85f;
            float h = old_vp.Height * 0.85f;
            Viewport new_vp = new Viewport();
            new_vp.X = (int)((old_vp.Width - w) / 2);
            new_vp.Y = (int)((old_vp.Height - h) / 2);
            new_vp.Width = (int)w;
            new_vp.Height = (int)h;
            game.GraphicsDevice.Viewport = new_vp;

            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.PointClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);

            spriteBatch.Draw(blackhole, new Vector2(480 - blackhole.Width / 2, 320 - blackhole.Height / 2), Color.White);

            int row = 0;
            int col = 0;

            for (int i = top; i < top + 4; i++)
            {
                if (i >= Bobby_Game.LEVELS)
                    break;

                int x = (col == 0 ? x1 : x2);
                int y = (row == 0 ? y1 : y2);

                Color color;
                bool unlocked = (i == 0 || Bobby_Game.stars[i - 1] >= 2);
                if (unlocked)
                    color = Color.White;
                else
                    color = new Color(100, 100, 100);

                spriteBatch.Draw(previews[i], new Rectangle(x, y, PREVIEW_W, PREVIEW_H), color);

                draw_number(x - 45, y, i + 1);

                col++;
                if (col == 2)
                {
                    row++;
                    col = 0;
                }
            }


            spriteBatch.End();

            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);

            Messages.draw(spriteBatch, game.font);

            row = 0;
            col = 0;
            for (int i = top; i < top + 4; i++)
            {
                if (i >= Bobby_Game.LEVELS)
                    break;

                int x = (col == 0 ? x1 : x2);
                int y = (row == 0 ? y1 : y2);
                if (i == selected)
                {
                    int yy = y + PREVIEW_H / 2 - selector_bmp.Height / 2;
                    spriteBatch.Draw(selector_bmp, new Vector2(x - selector_bmp.Width, yy), Color.White);
                    spriteBatch.Draw(selector_bmp, new Vector2(x + PREVIEW_W, yy), new Rectangle(0, 0, selector_bmp.Width, selector_bmp.Height), Color.White, 0.0f, new Vector2(0.0f, 0.0f), 1.0f, SpriteEffects.FlipHorizontally, 0.0f);
                }

                bool unlocked = (i == 0 || Bobby_Game.stars[i - 1] >= 2);
                if (!unlocked)
                {
                    spriteBatch.Draw(lock_bmp, new Vector2(x + PREVIEW_W - lock_bmp.Width - 5, y + PREVIEW_H - lock_bmp.Height - 5), Color.White);
                }
                else
                {
                    int stars = Bobby_Game.stars[i];
                    for (int j = 0; j < stars; j++)
                    {
                        int xx = x + PREVIEW_W - star_bmp.Width * (j + 1);
                        int yy = y - star_bmp.Height;
                        spriteBatch.Draw(star_bmp, new Vector2(xx, yy), Color.White);
                    }
                }

                col++;
                if (col == 2)
                {
                    row++;
                    col = 0;
                }
            }

            string s = "Select a level (" + (selected+1) + "/70)";
            spriteBatch.DrawString(game.font, s, new Vector2(480 - game.font.MeasureString(s).X / 2, 64 + ygap / 2 - game.font.MeasureString(s).Y), Color.White);

            int xx1 = 480 - ((int)game.font.MeasureString("SelectBackLoadSave").X + 180) / 2;
            int xx2 = xx1 + 50 + (int)game.font.MeasureString("Select").X;
            int xx3 = xx2 + 50 + (int)game.font.MeasureString("Load").X;
            int xx4 = xx3 + 50 + (int)game.font.MeasureString("Save").X;
            int yyy = 640 - (int)game.font.MeasureString("SelectBack").Y - 15;

            spriteBatch.Draw(a_bmp, new Vector2(xx1, yyy + 5), Color.White);
            spriteBatch.DrawString(game.font, "Select", new Vector2(xx1 + 30, yyy), Color.White);

            spriteBatch.Draw(b_bmp, new Vector2(xx2, yyy + 5), Color.White);
            spriteBatch.DrawString(game.font, "Back", new Vector2(xx2 + 30, yyy), Color.White);

            spriteBatch.Draw(x_bmp, new Vector2(xx3, yyy + 5), Color.White);
            spriteBatch.DrawString(game.font, "Load", new Vector2(xx3 + 30, yyy), Color.White);

            spriteBatch.Draw(y_bmp, new Vector2(xx4, yyy + 5), Color.White);
            spriteBatch.DrawString(game.font, "Save", new Vector2(xx4 + 30, yyy), Color.White);

            // brighten blend stars
            BlendState bs = new BlendState();
            bs.ColorSourceBlend = Blend.One;
            bs.ColorDestinationBlend = Blend.One;
            game.GraphicsDevice.BlendState = bs;
            row = 0;
            col = 0;
            for (int i = top; i < top + 4; i++)
            {
                if (i >= Bobby_Game.LEVELS)
                    break;

                int x = (col == 0 ? x1 : x2);
                int y = (row == 0 ? y1 : y2);

                bool unlocked = (i == 0 || Bobby_Game.stars[i - 1] >= 2);
                if (unlocked)
                {
                    int stars = Bobby_Game.stars[i];
                    for (int j = 0; j < stars; j++)
                    {
                        int xx = x + PREVIEW_W - star_bmp.Width * (j + 1);
                        int yy = y - star_bmp.Height;
                        spriteBatch.Draw(star_bmp, new Vector2(xx, yy), new Color(game.starAlpha, game.starAlpha, game.starAlpha, game.starAlpha));
                    }
                }

                col++;
                if (col == 2)
                {
                    row++;
                    col = 0;
                }

            }
            bs = new BlendState();
            game.GraphicsDevice.BlendState = bs;

            spriteBatch.End();

            game.GraphicsDevice.Viewport = old_vp;

            base.Draw(gameTime);
        }

        private Texture2D mkpreview(int level)
        {
            Texture2D t = new Texture2D(game.GraphicsDevice, Bobby_Game.WIDTH, Bobby_Game.HEIGHT);

            const int w = Bobby_Game.WIDTH;
            const int h = Bobby_Game.HEIGHT;

            Color[] data = new Color[w * h];

            for (int y = 0; y < h; y++)
            {
                for (int x = 0; x < w; x++)
                {
                    data[y * w + x] = MainGameComponent.get_tile_color(game.levels[level][x][y].type);
                }
            }

            t.SetData<Color>(data);

            return t;
        }

        private void draw_tinychar(int x, int y, int n)
        {
            int xo = (n == 0 ? 180 : (n-1) * 20);
            spriteBatch.Draw(tinyfont, new Vector2(x, y), new Rectangle(xo, 0, 20, 20), Color.Yellow);
        }

        private void draw_number(int x, int y, int n)
        {
            int hi = (n / 10);
            int lo = (n % 10);
            draw_tinychar(x, y, hi);
            draw_tinychar(x + 20, y, lo);
        }

        /*
        private long readLong(Stream s)
        {
            UInt64 l = 0;

            for (int i = 0; i < 8; i++) // 8 bytes (64 bits) in a long
            {
                int b = (byte)s.ReadByte();
                if (b == -1)
                    throw new MyException();
                l |= (UInt64)b << (i * 8);
            }

            return (long)l;
        }
        
        private void writeLong(long l, Stream s)
        {
            for (int i = 0; i < 8; i++)
            {
                byte b = (byte)(l & 0xff);
                l >>= 8;
                s.WriteByte(b);
            }
        }
        */

        private void save()
        {
            String path;

            OperatingSystem os = Environment.OSVersion;
            PlatformID pid = os.Platform;

	    if (pid == PlatformID.Unix) {
		    path = System.Environment.GetEnvironmentVariable("HOME");
		    path = path + "/.config";
		    System.IO.Directory.CreateDirectory(path);
		    path = path + "/ILLUMINATI NORTH";
		    System.IO.Directory.CreateDirectory(path);
		    path = path + "/Bobby";
		    System.IO.Directory.CreateDirectory(path);
		    path = path + "/save.dat";
	    }
	    else {
		    path = System.Environment.GetEnvironmentVariable("USERPROFILE");
		    path = path + "/Saved Games";
		    System.IO.Directory.CreateDirectory(path);
		    path = path + "/Bobby";
		    System.IO.Directory.CreateDirectory(path);
		    path = path + "/save.dat";
	    }

            using (var stream = File.Open(path, FileMode.Create))
            {
                using (var writer = new BinaryWriter(stream, Encoding.UTF8, false))
                {
                    byte me = Bobby_Game.music_enabled ? (byte)1 : (byte)0;
                    byte se = Bobby_Game.sound_enabled ? (byte)1 : (byte)0;
                    byte ke = Bobby_Game.kitty_enabled ? (byte)1 : (byte)0;

                    writer.Write(me);
                    writer.Write(se);
                    writer.Write(ke);

                    // Save some extra space for new levels
                    for (int i = 0; i < 1000; i++)
                    {
                        byte b;
                        if (i < Bobby_Game.LEVELS)
                        {
                            b = (byte)Bobby_Game.stars[i];
                        }
                        else
                            b = 0;
                        writer.Write(b);
                    }

                    for (int i = 0; i < 1000; i++)
                    {
                        if (i < Bobby_Game.LEVELS)
                        {
                            TimeSpan t = Bobby_Game.best_times[i] - new TimeSpan();
                            long l = (long)t.TotalMilliseconds;
                            writer.Write((Int64)l);
                        }
                        else
                            writer.Write((long)0);
                    }
                }
            }

            game.add_noticegamecomponent("Your game has been saved");
        }

        private void load()
        {
            String path;

            OperatingSystem os = Environment.OSVersion;
            PlatformID pid = os.Platform;

	    if (pid == PlatformID.Unix) {
		    path = System.Environment.GetEnvironmentVariable("HOME");
		    path = path + "/.config";
		    System.IO.Directory.CreateDirectory(path);
		    path = path + "/ILLUMINATI NORTH";
		    System.IO.Directory.CreateDirectory(path);
		    path = path + "/Bobby";
		    System.IO.Directory.CreateDirectory(path);
		    path = path + "/save.dat";
	    }
	    else {
		    path = System.Environment.GetEnvironmentVariable("USERPROFILE");
		    path = path + "/Saved Games";
		    System.IO.Directory.CreateDirectory(path);
		    path = path + "/Bobby";
		    System.IO.Directory.CreateDirectory(path);
		    path = path + "/save.dat";
	    }

            if (File.Exists(path))
            {
                using (var stream = File.Open(path, FileMode.Open))
                {
                    using (var reader = new BinaryReader(stream, Encoding.UTF8, false))
                    {
                        byte me = reader.ReadByte();
                        byte se = reader.ReadByte();
                        byte ke = reader.ReadByte();

                        if (me == (byte)0)
                        {
                            Sound.stop_menu_music();
                        }

                        Bobby_Game.music_enabled = me == (byte)1 ? true : false;
                        Bobby_Game.sound_enabled = se == (byte)1 ? true : false;
                        Bobby_Game.kitty_enabled = ke == (byte)1 ? true : false;

                        for (int i = 0; i < 1000; i++)
                        {
                            byte b = reader.ReadByte();
                            if (i < Bobby_Game.LEVELS)
                            {
                                Bobby_Game.stars[i] = (int)b;
                            }
                        }

                        for (int i = 0; i < 1000; i++)
                        {
                            if (i < Bobby_Game.LEVELS)
                            {
                                long l = (long)reader.ReadInt64();
                                Bobby_Game.best_times[i] = TimeSpan.FromMilliseconds(l);
                            }
                        }
                    }
                }
                game.add_noticegamecomponent("Your game has been loaded");
            }
            else
            {
                game.add_noticegamecomponent("No save data found!");
            }
        }

        /*
        private void save(StorageDevice device)
        {
            try
            {
                // Open a storage container.
                IAsyncResult result =
                    device.BeginOpenContainer("BOBBY", null, null);

                // Wait for the WaitHandle to become signaled.
                result.AsyncWaitHandle.WaitOne();

                StorageContainer container = device.EndOpenContainer(result);

                // Close the wait handle.
                result.AsyncWaitHandle.Close();

                string filename = "savegame.sav";

                // Check to see whether the save exists.
                if (container.FileExists(filename))
                    // Delete it so that we can create one fresh.
                    container.DeleteFile(filename);

                // Create the file.
                Stream stream = container.CreateFile(filename);

                // ----- Save here ----
                stream.WriteByte((byte)(Bobby_Game.music_enabled == true ? 1 : 0));
                stream.WriteByte((byte)(Bobby_Game.sound_enabled == true ? 1 : 0));
                stream.WriteByte((byte)(Bobby_Game.kitty_enabled == true ? 1 : 0));

                // Save some extra space for new levels
                for (int i = 0; i < 1000; i++)
                {
                    byte b;
                    if (i < Bobby_Game.LEVELS)
                    {
                        b = (byte)Bobby_Game.stars[i];
                    }
                    else
                        b = 0;
                    stream.WriteByte(b);
                }

                for (int i = 0; i < 1000; i++)
                {
                    if (i < Bobby_Game.LEVELS)
                    {
                        TimeSpan t = Bobby_Game.best_times[i] - new TimeSpan();
                        long l = (long)t.TotalMilliseconds;
                        writeLong(l, stream);
                    }
                    else
                        writeLong(0, stream);
                }

                stream.Close();
                container.Dispose();

                game.add_noticegamecomponent("Your game has been saved");
            }
            catch (GamerPrivilegeException e)
            {
                Sound.play(Sound.error);
                game.add_needprofilegamecomponent();
                return;
            }
            catch (InvalidOperationException e)
            {
            }
        }

        private void load(StorageDevice device)
        {
            try
            {
                // Open a storage container.
                IAsyncResult result =
                    device.BeginOpenContainer("BOBBY", null, null);

                // Wait for the WaitHandle to become signaled.
                result.AsyncWaitHandle.WaitOne();

                StorageContainer container = device.EndOpenContainer(result);

                // Close the wait handle.
                result.AsyncWaitHandle.Close();

                string filename = "savegame.sav";

                // Check to see whether the save exists.
                if (container.FileExists(filename))
                {
                    // Open the file.
                    Stream stream = container.OpenFile(filename, FileMode.Open);

                    // ----- Load here ----
                    Bobby_Game.music_enabled = (stream.ReadByte() == 0 ? false : true);
                    Bobby_Game.sound_enabled = (stream.ReadByte() == 0 ? false : true);
                    Bobby_Game.kitty_enabled = (stream.ReadByte() == 0 ? false : true);

                    for (int i = 0; i < 1000; i++)
                    {
                        byte b = (byte)stream.ReadByte();
                        if (i < Bobby_Game.LEVELS)
                        {
                            Bobby_Game.stars[i] = (int)b;
                        }
                    }

                    try
                    {
                        for (int i = 0; i < 1000; i++)
                        {
                            if (i < Bobby_Game.LEVELS)
                            {
                                long l = readLong(stream);
                                Bobby_Game.best_times[i] = TimeSpan.FromMilliseconds(l);
                            }
                        }
                    }
                    catch (MyException e)
                    {
                    }

                    stream.Close();
                }

                container.Dispose();
            }
            catch (GamerPrivilegeException e)
            {
                Sound.play(Sound.error);
                game.add_needprofilegamecomponent();
                return;
            }
            catch (InvalidOperationException e)
            {
            }
        }
        */
    }
}
