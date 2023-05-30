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

namespace Bobby
{
    /// <summary>
    /// This is the main type for your game
    /// </summary>
    public class Bobby_Game : Microsoft.Xna.Framework.Game
    {
        GraphicsDeviceManager graphics;
        SpriteBatch spriteBatch;
        public static Microsoft.Xna.Framework.Game game;


       public static int[] order = {
            69,
            8,
            55,
            3,
            46,
            29,
            44,
            67,
            56,
            68,
            10,
            16,
            50,
            48,
            14,
            54,
            57,
            0,
            42,
            26,
            43,
            15,
            1,
            25,
            65,
            17,
            2,
            4,
            18,
            38,
            33,
            5,
            19,
            58,
            20,
            6,
            59,
            21,
            39,
            40,
            7,
            45,
            12,
            22,
            66,
            61,
            13,
            23,
            34,
            62,
            24,
            27,
            36,
            11,
            47,
            9,
            35,
            28,
            30,
            49,
            31,
            32,
            41,
            63,
            37,
            51,
            52,
            53,
            64,
            60
        };

        public PlayerIndex player_index = PlayerIndex.One;
        public bool player_index_set = false;
        //public StorageDevice save_storage_device = null;
        //public StorageDevice load_storage_device = null;

        public static bool music_enabled = true;
        public static bool sound_enabled = true;
        public static bool fullscreen_enabled = true;
        public static bool kitty_enabled = false;

        public BasicEffect effect;

        public const int WIDTH = 20;
        public const int HEIGHT = 12;

        public static int LEVELS = 70;
        public Entity[][][] levels;
        public static int[] stars = new int[LEVELS];
        public static TimeSpan[] best_times = new TimeSpan[LEVELS];
        public static TimeSpan last_time;
        public static int last_stars;
        public static int last_level;

        public float starAlpha = 1.0f;
        float starAlphaInc = 1.0f / 60.0f;

        GameComponent current_component;
        GameComponent backup_component = null;
        GameComponent backup_component2 = null;
        GameComponent backup_component3 = null;

        public SpriteFont font;

        public Bobby_Game(bool windowed)
        {
            game = this;

            if (windowed)
            {
                fullscreen_enabled = false;
            }

            graphics = new GraphicsDeviceManager(this);

            graphics.PreferredBackBufferWidth = 1280;
            graphics.PreferredBackBufferHeight = 720;
            graphics.HardwareModeSwitch = fullscreen_enabled;
            graphics.IsFullScreen = fullscreen_enabled;
            graphics.ApplyChanges();

            Content.RootDirectory = "Content";

            for (int i = 0; i < LEVELS; i++)
            {
                best_times[i] = new TimeSpan(0, 23, 59, 59, 999);
            }

            //this.Components.Add(new GamerServicesComponent(this));
        }

        /// <summary>
        /// Allows the game to perform any initialization it needs to before starting to run.
        /// This is where it can query for any required services and load any non-graphic
        /// related content.  Calling base.Initialize will enumerate through any components
        /// and initialize them as well.
        /// </summary>
        protected override void Initialize()
        {
            // create a basic shader so we can set a new orthorgraphic matrix
            effect = new BasicEffect(graphics.GraphicsDevice);
            effect.Projection = Matrix.CreateTranslation(-960 / 2, -640 / 2, 0) * Matrix.CreateOrthographic(960, 640, -1, 1) * Matrix.CreateScale(1.0f, -1.0f, 1.0f);
            effect.View = Matrix.Identity;
            effect.World = Matrix.Identity;
            effect.TextureEnabled = true;
            effect.VertexColorEnabled = true;

            // Create level arrays
            levels = new Entity[LEVELS][][];

            // Load levels
            for (int i = 1; i < LEVELS + 1; i++)
            {
                levels[i - 1] = load_level(order[i-1]+1);
            }

            current_component = new SplashGameComponent(this);
            current_component.Enabled = true;
            Components.Add(current_component);

            MainMenuGameComponent.st1_x = MainMenuGameComponent.st1_x1;
            MainMenuGameComponent.st1_y = MainMenuGameComponent.st1_y1;
            MainMenuGameComponent.st1_scale = MainMenuGameComponent.st1_scale1;
	        MainMenuGameComponent.st1_dir = 1;
	        MainMenuGameComponent.st2_x = MainMenuGameComponent.st2_x1;
            MainMenuGameComponent.st2_y = MainMenuGameComponent.st2_y1;
            MainMenuGameComponent.st2_scale = MainMenuGameComponent.st2_scale1;
	        MainMenuGameComponent.st2_dir = 1;

            Sound.init(this);

            for (int i = 0; i < LEVELS; i++)
            {
                stars[i] = 0;
            }

            base.Initialize();
        }

        /// <summary>
        /// LoadContent will be called once per game and is the place to load
        /// all of your content.
        /// </summary>
        protected override void LoadContent()
        {
            // Create a new SpriteBatch, which can be used to draw textures.
            spriteBatch = new SpriteBatch(GraphicsDevice);

            font = Content.Load<SpriteFont>("font");

            MainGameComponent.load_atlas();
        }

        /// <summary>
        /// UnloadContent will be called once per game and is the place to unload
        /// all content.
        /// </summary>
        protected override void UnloadContent()
        {
            // TODO: Unload any non ContentManager content here
        }

        /// <summary>
        /// Allows the game to run logic such as updating the world,
        /// checking for collisions, gathering input, and playing audio.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        protected override void Update(GameTime gameTime)
        {
            // Allows the game to exit
            if (player_index_set)
            {
                Input.state = GamePad.GetState(player_index);

                if (GamePad.GetState(player_index).Buttons.Back == ButtonState.Pressed)
                {
                    if (backup_component == null)
                    {
                        if (current_component is MainGameComponent)
                        {
                            ((MainGameComponent)current_component).paused = true;
                        }
                        add_reallyquitgamecomponent();
                    }
                }
            }

            base.Update(gameTime);
        }

        /// <summary>
        /// This is called when the game should draw itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        protected override void Draw(GameTime gameTime)
        {
            GraphicsDevice.Clear(Color.Black);

            // TODO: Add your drawing code here

            base.Draw(gameTime);
        }

        private Entity[][] alloc_level()
        {
            Entity[][] level = new Entity[WIDTH][];

            for (int i = 0; i < WIDTH; i++)
                level[i] = new Entity[HEIGHT];

            for (int y = 0; y < HEIGHT; y++)
            {
                for (int x = 0; x < WIDTH; x++)
                {
                    level[x][y] = new Entity();
                }
            }

            return level;
        }

        private Entity[][] load_level(int num)
        {
            Entity[][] level = alloc_level();

            Stream s = TitleContainer.OpenStream("data/level" + num + ".txt");
            StreamReader r = new StreamReader(s);

            for (int y = 0; y < HEIGHT; y++)
            {
                string line = r.ReadLine();
                for (int x = 0; x < WIDTH; x++)
                {
                    char type = line[x];
                    level[x][y].type = type;
                }
                //System.Diagnostics.Debug.WriteLine(line);
            }

            return level;
        }

        public static long timespan_to_ticks(TimeSpan t)
        {
            return (t.Days * TimeSpan.TicksPerDay) + (t.Hours * TimeSpan.TicksPerHour) + (t.Minutes * TimeSpan.TicksPerMinute) + (t.Seconds * TimeSpan.TicksPerSecond) + (t.Milliseconds * TimeSpan.TicksPerMillisecond);
        }

        public void black_overlay(float alpha)
        {
            VertexPositionColor[] v = new VertexPositionColor[4];
            v[0] = new VertexPositionColor();
            v[0].Position = new Vector3(0, 0, 0);
            v[0].Color = new Color(0, 0, 0, alpha);
            v[1] = new VertexPositionColor();
            v[1].Position = new Vector3(960, 0, 0);
            v[1].Color = new Color(0, 0, 0, alpha);
            v[2] = new VertexPositionColor();
            v[2].Position = new Vector3(0, 640, 0);
            v[2].Color = new Color(0, 0, 0, alpha);
            v[3] = new VertexPositionColor();
            v[3].Position = new Vector3(960, 640, 0);
            v[3].Color = new Color(0, 0, 0, alpha);

            effect.TextureEnabled = false;
            foreach (EffectPass pass in effect.CurrentTechnique.Passes)
            {
                pass.Apply();
                GraphicsDevice.DrawUserPrimitives<VertexPositionColor>(PrimitiveType.TriangleStrip, v, 0, 2);
            }
            effect.TextureEnabled = true;
        }

        public void add_maingamecomponent(int lev)
        {
            last_level = lev;

            Components.Remove(current_component);

            Entity[][] entities = new Entity[WIDTH][];
            for (int i = 0; i < WIDTH; i++)
            {
                entities[i] = new Entity[HEIGHT];
            }
            for (int y = 0; y < HEIGHT; y++)
            {
                for (int x = 0; x < WIDTH; x++)
                {
                    entities[x][y] = levels[lev][x][y].klone();
                }
            }

            current_component = new MainGameComponent(this, entities, lev);
            current_component.Enabled = true;
            Components.Add(current_component);
        }

        public void add_mainmenugamecomponent()
        {
            Components.Remove(current_component);
            current_component = new MainMenuGameComponent(this);
            current_component.Enabled = true;
            Components.Add(current_component);
        }

        public void add_storygamecomponent()
        {
            Components.Remove(current_component);
            current_component = new StoryGameComponent(this);
            current_component.Enabled = true;
            Components.Add(current_component);
        }

        public void add_creditsgamecomponent()
        {
            Components.Remove(current_component);
            current_component = new CreditsGameComponent(this);
            current_component.Enabled = true;
            Components.Add(current_component);
        }

        public void add_settingsgamecomponent()
        {
            Components.Remove(current_component);
            current_component = new SettingsGameComponent(this);
            current_component.Enabled = true;
            Components.Add(current_component);
        }

        public void add_levelselectgamecomponent()
        {
            Components.Remove(current_component);
            current_component = new LevelSelectGameComponent(this);
            current_component.Enabled = true;
            Components.Add(current_component);
        }

        public void add_helpgamecomponent()
        {
            Components.Remove(current_component);
            current_component = new HelpGameComponent(this);
            current_component.Enabled = true;
            Components.Add(current_component);
        }

        public void add_reallyquitgamecomponent()
        {
            backup_component = current_component;
            Components.Remove(current_component);
            current_component = new ReallyQuitGameComponent(this);
            current_component.Enabled = true;
            Components.Add(current_component);
        }

        /*
        public void add_needprofilegamecomponent()
        {
            backup_component2 = current_component;
            Components.Remove(current_component);
            current_component = new NeedProfileGameComponent(this);
            current_component.Enabled = true;
            Components.Add(current_component);
        }
        */

        public void add_noticegamecomponent(string s)
        {
            backup_component3= current_component;
            Components.Remove(current_component);
            current_component = new NoticeGameComponent(this, s);
            current_component.Enabled = true;
            Components.Add(current_component);
        }

        public void add_levelendgamecomponent()
        {
            Components.Remove(current_component);
            current_component = new LevelEndGameComponent(this);
            current_component.Enabled = true;
            Components.Add(current_component);
        }

        public void restore_backupgamecomponent()
        {
            Components.Remove(current_component);
            current_component = backup_component;
            backup_component = null;
            current_component.Enabled = true;
            Components.Add(current_component);
        }

        public void restore_backupgamecomponent2()
        {
            Components.Remove(current_component);
            current_component = backup_component2;
            backup_component2 = null;
            current_component.Enabled = true;
            Components.Add(current_component);
        }

        public void restore_backupgamecomponent3()
        {
            Components.Remove(current_component);
            current_component = backup_component3;
            backup_component3 = null;
            current_component.Enabled = true;
            Components.Add(current_component);
        }

        public void updateStarAlpha()
        {
	        starAlpha += starAlphaInc;
	        if (starAlphaInc > 0 && starAlpha > 1.0) {
		        starAlphaInc = -starAlphaInc;
		        starAlpha = 1.0f;
	        }
	        else if (starAlphaInc < 0 && starAlpha < 0.0) {
		        starAlphaInc = -starAlphaInc;
		        starAlpha = 0.0f;
	        }
        }
    }
}
