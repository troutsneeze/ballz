using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.GamerServices;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Microsoft.Xna.Framework.Media;


namespace Bobby
{
    /// <summary>
    /// This is a game component that implements IUpdateable.
    /// </summary>
    public class MainGameComponent : Microsoft.Xna.Framework.DrawableGameComponent
    {
        SpriteBatch spriteBatch;
        Bobby_Game game;
        Random random;

        const int TILE_SIZE = 48;

        const float SPEED_MULT        = 100.0f / 120.0f;
        const int MAX_OBJECTS         = (Bobby_Game.WIDTH*Bobby_Game.HEIGHT);
        const float GRAVITY           = (0.00075f*SPEED_MULT);
        const float FAN_FORCE         = (1.0f*SPEED_MULT);
        const float MAGNET_FORCE      = (0.025f*SPEED_MULT);
        const float THRUST            = (0.2f*SPEED_MULT);
        const float PLAYER_MASS       = 9.0f;
        const float BALL_MASS         = 3.0f;
        const float HEAVY_BALL_MASS   = 10.0f;
        const float MAX_A             = 0.02f;
        const float A_DAMP            = (0.0007f*SPEED_MULT);
        const float MAX_V             = 3.0f;
        const float MAX_GRAVITY_V     = 1.0f;
        const float V_DAMP            = (0.002f*SPEED_MULT);

        const int FAN_REACH = 100;

        public const int EMPTY = '0';
        public const int PLAYER = '1';
        public const int BALL = '2';
        public const int SPIRAL = '3';
        public const int WALL = '4';
        public const int FAN_LEFT = '5';
        public const int FAN_RIGHT = '6';
        public const int FAN_UP = '7';
        public const int FAN_DOWN = '8';
        public const int HEAVY_BALL = 'h';
        public const int FAN_SPIN = 'f';
        public const int TRANSPORTER = 'x';
        public const int TOTALLY_EVIL_SPIRAL = 'e';
        public const int TOTALLY_GOOD_SPIRAL = 'g';
        public const int SWITCH1 = 's';
        public const int SWITCH2 = 'S';
        public const int GATE1 = '|';
        public const int GATE2 = '-';
        public const int BOUNCY_WALL = 'b';
        public const int UNBOUNCY_WALL = 'u';
        public const int MIAO_BALL = 'k';
        public const int MAGNET = 'm';

        // Groups
        const int ALL_WALLS             = 1;
        const int ALL_BALLS             = 2;
        const int ALL_FANS              = 4;
        const int ALL_BOUNCY            = 8;
        const int ALL_SPIRALS           = 16;
        const int ALL_SWITCHES          = 32;
        const int ALL_TRANSPORTER       = 64;
        const int ALL_TRANSPORTER_START = 128;
        const int ALL_TRANSPORTER_END   = 256;
        const int ALL_GATES             = 512;
        const int OTHER                 = 1024;

        static bool player_animating_out = true;
        static int player_anim_num = 0;
        int player_anim_count = 0;
        bool thrusting = false;
        int thrust_count = 0;

        static int nballs = 1; // must be > 0 for preview!
        static int nballs_start;

        Texture2D fire, rainbow;
        Color[] fire_data;
        Color[] rainbow_data;
        const int FIRE_SIZE = 100;

        public static Texture2D atlas;
        public static Rectangle switch_rect;
        public static Rectangle gate_rect;
        public static Rectangle transporter_in_rect;
        public static Rectangle transporter_out_rect;
        public static Rectangle fan_rect;
        public static Rectangle[] smoke_rects = new Rectangle[3];
        public static Rectangle totally_good_spiral_rect;
        public static Rectangle totally_evil_spiral_rect;
        public static Rectangle wall_rect;
        public static Rectangle bouncy_wall_rect;
        public static Rectangle unbouncy_wall_rect;
        public static Rectangle miao_ball_rect;
        public static Rectangle magnet_rect;
        public static Rectangle[] ball_rects = new Rectangle[4];
        public static Rectangle[] heavy_ball_rects = new Rectangle[4];
        public static Rectangle[] player_go = new Rectangle[8];
        public static Rectangle[] miao_go = new Rectangle[8];

        Entity[][] level;
        int player_x, player_y;
        bool brake_on = false;
        float brake_multiplier = 1.0f;

        DateTime start_time;

        int next_time = -1;
        TimeSpan next_smoke = TimeSpan.Zero;

        bool hit_totally_evil_spiral;

        const int NSMOKE = 100;
        Particle[] smoke = new Particle[NSMOKE];

        struct SpaceThing {
	        public int bmp_index;
	        public float x, y;
        }
        double nextSpaceThing;
        double minSpaceThingTime = 25;
        double maxSpaceThingTime = 50;
        double spaceThingInc;
        const int MAX_SPACE_THINGS = 5;
        const int AVG_SPACE_THING_TIME = 37;
        SpaceThing[] spaceThings = new SpaceThing[MAX_SPACE_THINGS];
        int numSpaceThings = 0;
        const int NUM_DIFFERENT_SPACE_THINGS = 8;
        int[] spaceThingOrder = new int[NUM_DIFFERENT_SPACE_THINGS];
        int curr_space_thing = 0;
        Texture2D[] space_bmps = new Texture2D[NUM_DIFFERENT_SPACE_THINGS];

        public bool paused = false;
        Texture2D b_bmp, x_bmp, y_bmp;

        Texture2D fan_air;
        float wave = 0.0f;

        struct Star {
	        public float x;
	        public float y;
	        public float v;
	        public Color color;
        }
        const int NUM_STARS = 100;
        Star[] starfield = new Star[NUM_STARS];

        Texture2D bg_bmp;

        int level_num;

        int disconnect_count = 0;

        public MainGameComponent(Game game, Entity[][] level, int level_num)
            : base(game)
        {
            Sound.play_music();

            this.game = (Bobby_Game)game;

            start_time = DateTime.Now;

            this.level = level;
            this.level_num = level_num;

            nballs = 0;

            for (int y = 0; y < Bobby_Game.HEIGHT; y++)
            {
                for (int x = 0; x < Bobby_Game.WIDTH; x++)
                {
                    int type = level[x][y].type;

                    int groups = get_groups(type);

			        if (type == PLAYER) {
                        player_x = x;
                        player_y = y;
			        }
			        else if (((groups & ALL_BALLS) != 0) || type == MIAO_BALL) {
				        nballs++;
			        }
			        level[x][y].groups = groups;
			        level[x][y].x = x * TILE_SIZE;
			        level[x][y].y = y * TILE_SIZE;
			        level[x][y].tx = x;
			        level[x][y].ty = y;
			        if (type == PLAYER || type == MIAO_BALL) {
				        level[x][y].mass = PLAYER_MASS;
			        }
			        if (type == PLAYER || type == MAGNET) {
				        level[x][y].angle = 90.0f;
			        }
			        else if (type == MIAO_BALL) {
				        level[x][y].angle = 0.0f;
			        }
			        else {
				        if (type == HEAVY_BALL)
					        level[x][y].mass = HEAVY_BALL_MASS;
				        else
					        level[x][y].mass = BALL_MASS;
				        if (type == FAN_LEFT) {
					        level[x][y].angle = 180;
				        }
				        else if (type == FAN_UP) {
					        level[x][y].angle = 90;
				        }
				        else if (type == FAN_DOWN) {
					        level[x][y].angle = 270;
				        }
				        else { // FAN_RIGHT and FAN_SPIN are 0 also (and miao cat)
					        level[x][y].angle = 0.0f;
				        }
			        }
			        level[x][y].scale = 1;
			        level[x][y].type = type;
			        level[x][y].live = 1;
			        level[x][y].vx = level[x][y].vy = 0;
			        level[x][y].ax = level[x][y].ay = 0;
                }

                nballs_start = nballs;
            }

            random = new Random((int)(DateTime.Now - new DateTime(1981, 4, 10, 0, 0, 0, 0)).TotalMilliseconds);

            for (int i = 0; i < NSMOKE; i++)
            {
                smoke[i] = new Particle();
            }

            spriteBatch = new SpriteBatch(game.GraphicsDevice);

            for (int i = 0; i < NUM_DIFFERENT_SPACE_THINGS; i++)
            {
                int next = (int)(random.NextDouble() * NUM_DIFFERENT_SPACE_THINGS);
                bool found;
                do
                {
                    int j;
                    found = false;
                    for (j = 0; j < i; j++)
                    {
                        if (spaceThingOrder[j] == next)
                        {
                            next++;
                            next %= NUM_DIFFERENT_SPACE_THINGS;
                            found = true;
                            break;
                        }
                    }
                } while (found);
                spaceThingOrder[i] = next;
            }
        }

        private int get_groups(int type)
        {
            if (type == WALL || type == BOUNCY_WALL || type == UNBOUNCY_WALL || type == FAN_LEFT || type == FAN_RIGHT || type == FAN_UP || type == FAN_DOWN || type == FAN_SPIN || type == GATE1 || type == GATE2 || type == MAGNET)
            {
                int groups = 0;
                if (type == FAN_LEFT || type == FAN_RIGHT || type == FAN_UP || type == FAN_DOWN || type == FAN_SPIN)
                    groups |= ALL_FANS;
                else if (type == GATE1 || type == GATE2)
                    groups |= ALL_GATES;
                return ALL_WALLS | groups;
            }
            else if (type == BALL || type == HEAVY_BALL)
                return ALL_BALLS | ALL_BOUNCY;
            else if (type == PLAYER || type == MIAO_BALL)
                return ALL_BOUNCY;
            else if (type == SPIRAL || type == TOTALLY_EVIL_SPIRAL || type == TOTALLY_GOOD_SPIRAL)
                return ALL_SPIRALS;
            else if (type >= 'x' && type <= 'z')
                return ALL_TRANSPORTER | ALL_TRANSPORTER_START;
            else if (type >= 'X' && type <= 'Z')
                return ALL_TRANSPORTER | ALL_TRANSPORTER_END;
            else if (type == SWITCH1 || type == SWITCH2)
                return ALL_SWITCHES;
            else
                return MainGameComponent.OTHER;
        }

        /// <summary>
        /// Allows the game component to perform any initialization it needs to before starting
        /// to run.  This is where it can query for any required services and load content.
        /// </summary>
        public override void Initialize()
        {
            base.Initialize();
        }

        protected override void LoadContent()
        {
            fire = game.Content.Load<Texture2D>("data/fire");
            rainbow = game.Content.Load<Texture2D>("data/rainbow");
            fire_data = new Color[FIRE_SIZE * FIRE_SIZE];
            rainbow_data = new Color[FIRE_SIZE * FIRE_SIZE];
            fire.GetData<Color>(fire_data);
            rainbow.GetData<Color>(rainbow_data);

            space_bmps[0] = game.Content.Load<Texture2D>("data/spacestuff/fireball");
            space_bmps[1] = game.Content.Load<Texture2D>("data/spacestuff/nebula");
            space_bmps[2] = game.Content.Load<Texture2D>("data/spacestuff/blackhole");
            space_bmps[3] = game.Content.Load<Texture2D>("data/spacestuff/images");
            space_bmps[4] = game.Content.Load<Texture2D>("data/spacestuff/images2");
            space_bmps[5] = game.Content.Load<Texture2D>("data/spacestuff/images3");
            space_bmps[6] = game.Content.Load<Texture2D>("data/spacestuff/images4");
            space_bmps[7] = game.Content.Load<Texture2D>("data/spacestuff/images5");

            for (int i = 0; i < NUM_STARS; i++)
            {
                newStar(i);
            }

            spaceThingInc = 960.0 / (60 * AVG_SPACE_THING_TIME);

            bg_bmp = game.Content.Load<Texture2D>("data/bg1");

            b_bmp = game.Content.Load<Texture2D>("data/b");
            x_bmp = game.Content.Load<Texture2D>("data/x");
            y_bmp = game.Content.Load<Texture2D>("data/y");

            fan_air = new Texture2D(game.GraphicsDevice, 128, 128);

            base.LoadContent();
        }

        /// <summary>
        /// Allows the game component to update itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        public override void Update(GameTime gameTime)
        {
            if (paused)
            {
                if (Input.get_x())
                {
                    Sound.play(Sound.bink);
                    Sound.stop_music();
                    Sound.stop_boost();
                    game.add_maingamecomponent(level_num);
                    return;
                }
                else if (Input.get_start() || Input.get_b())
                {
                    Sound.play(Sound.bink);
                    paused = false;
                }
                else if (Input.get_y())
                {
                    Sound.play(Sound.bink);
                    Sound.stop_music();
                    Sound.stop_boost();
                    game.add_levelselectgamecomponent();
                    return;
                }
            }
            else
            {
                GamePadState s = GamePad.GetState(game.player_index);

                if (s.Buttons.A == ButtonState.Pressed)
                {
                    if (!thrusting)
                    {
                        thrusting = true;
                        Sound.play_boost();
                        thrust_count++;
                        player_anim_num = 0;
                        player_anim_count = 0;
                        player_animating_out = false;
                    }
                    forward(gameTime);
                }
                else
                {
                    if (thrusting)
                    {
                        thrusting = false;
                        Sound.stop_boost();
                        player_anim_num = 0;
                        player_anim_count = 0;
                        player_animating_out = true;
                    }
                }

                if (s.Buttons.B == ButtonState.Pressed)
                {
                    if (!brake_on)
                    {
                        brake_on = true;
                        //player_anim_num = 0;
                        //player_anim_count = 0;
                        player_animating_out = true;
                    }
                }
                else if (s.Buttons.B == ButtonState.Released)
                {
                    brake_on = false;
                    if (thrusting)
                    {
                        player_animating_out = false;
                    }
                }

                if (s.DPad.Left == ButtonState.Pressed || s.ThumbSticks.Left.X < -0.5)
                    left();
                else if (s.DPad.Right == ButtonState.Pressed || s.ThumbSticks.Left.X > 0.5)
                    right();

                if (Input.get_lshoulder())
                {
                    float a = level[player_x][player_y].angle;
                    while (a < 0) a += 360;
                    a %= 360.0f;
                    if (a >= 270)
                    {
                        a = 0;
                    }
                    else if (a >= 180)
                    {
                        a = 270;
                    }
                    else if (a >= 90)
                    {
                        a = 180;
                    }
                    else
                    {
                        a = 90;
                    }
                    level[player_x][player_y].angle = a;
                }
                if (Input.get_rshoulder())
                {
                    float a = level[player_x][player_y].angle;
                    while (a < 0) a += 360;
                    a %= 360.0f;
                    if (a == 0 || a > 270)
                    {
                        a = 270;
                    }
                    else if (a > 180)
                    {
                        a = 180;
                    }
                    else if (a > 90)
                    {
                        a = 90;
                    }
                    else
                    {
                        a = 0;
                    }
                    level[player_x][player_y].angle = a;
                }

                // by calling this twice we get exactly the same physics as in the PC/iOS version where the clock rate is 120hz
                move_objects(gameTime);
                move_objects(gameTime);

                if (next_time > 0)
                {
                    next_time--;
                    if (next_time <= 0)
                    {
                        /* assign stars */
                        int killed = nballs_start - nballs;

                        int nstars = -1;
                        int last_stars = 0;

                        if (nballs_start == 0)
                        {
                            if (!hit_totally_evil_spiral)
                            {
                                nstars = 3;
                                last_stars = 3;
                            }
                        }
                        else
                        {
                            if (nballs == 0 && !hit_totally_evil_spiral)
                            {
                                nstars = 3;
                                last_stars = 3;
                            }
                            else if ((float)killed / nballs_start >= 0.5)
                            {
                                if (Bobby_Game.stars[level_num] < 2)
                                    nstars = 2;
                                last_stars = 2;
                            }
                            else if ((float)killed / nballs_start >= 0.25)
                            {
                                if (Bobby_Game.stars[level_num] < 1)
                                    nstars = 1;
                                last_stars = 1;
                            }
                        }

                        if (nstars > 0)
                        {
                            Bobby_Game.stars[level_num] = nstars;
                        }

                        Bobby_Game.last_stars = last_stars;

                        DateTime now = DateTime.Now;
                        TimeSpan t = now - start_time;
                        Bobby_Game.last_time = t;
                        string time = String.Format("{0:00}:{1:00}:{2:00}", t.Hours, t.Minutes, t.Seconds);
                        Messages.add_message("Elapsed: " + time);

                        next_time = 0;
                        Sound.stop_music();
                        Sound.stop_boost();
                        game.add_levelendgamecomponent();
                        return;
                    }
                }

                if (Input.get_start())
                {
                    paused = true;
                }

                disconnect_count++;
                if (disconnect_count >= 60)
                {
                    disconnect_count = 0;
                    if (!GamePad.GetState(game.player_index).IsConnected || !game.IsActive)
                    {
                        paused = true;
                    }
                }
            }

            base.Update(gameTime);
        }

        public override void Draw(GameTime gameTime)
        {
            draw_fan_air();

            Viewport old_vp = game.GraphicsDevice.Viewport;
            float w = old_vp.Width * 0.85f;
            float h = old_vp.Height * 0.85f;
            Viewport new_vp = new Viewport();
            new_vp.X = (int)((old_vp.Width - w) / 2);
            new_vp.Y = (int)((old_vp.Height - h) / 2);
            new_vp.Width = (int)w;
            new_vp.Height = (int)h;
            game.GraphicsDevice.Viewport = new_vp;

            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);
            spriteBatch.Draw(bg_bmp, new Vector2(0, 0), Color.White);
            spriteBatch.End();

            // Everything below here is drawn down 64 pixels from the top of the screen
            Matrix backup = game.effect.View;
            game.effect.View *= Matrix.CreateTranslation(new Vector3(0, 64, 0));

            game.effect.TextureEnabled = false;
            foreach (EffectPass pass in game.effect.CurrentTechnique.Passes)
            {
                pass.Apply();
                drawStars();
            }
            game.effect.TextureEnabled = true;

            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);
            drawSpaceStuff();
            spriteBatch.End();

            // darken background
            game.black_overlay(0.4f);

            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);

            for (int y = 0; y < Bobby_Game.HEIGHT; y++)
            {
                for (int x = 0; x < Bobby_Game.WIDTH; x++)
                {
                    draw_object(x, y, Color.White, gameTime);
                }
            }

            if (level[player_x][player_y].scale == 1.0)
            {
                for (int i = 0; i < NSMOKE; i++)
                {
                    if (smoke[i].life > 0)
                    {
                        float alpha = smoke[i].life / 1000.0f;
                        if (alpha < 0.0f) alpha = 0.0f;
                        //System.Diagnostics.Debug.WriteLine("" + alpha);
                        spriteBatch.Draw(atlas, new Rectangle((int)(smoke[i].x - TILE_SIZE / 2), (int)(smoke[i].y - TILE_SIZE / 2), TILE_SIZE, TILE_SIZE),
                            smoke_rects[smoke[i].bmp_index], new Color((int)(smoke[i].color.R*alpha), (int)(smoke[i].color.G*alpha), (int)(smoke[i].color.B*alpha), (int)(alpha*255)));
                    }
                }
            }
            spriteBatch.End();


            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);
            for (int y = 0; y < Bobby_Game.HEIGHT; y++)
            {
                for (int x = 0; x < Bobby_Game.WIDTH; x++)
                {
                    draw_fan(level[x][y]);
                }
            }
            spriteBatch.End();

            // restore transformation

            game.effect.View = backup;

            // Draw a black rectangle over top status area
            VertexPositionColor[] v = new VertexPositionColor[4];
            v[0] = new VertexPositionColor();
            v[0].Position = new Vector3(0, 0, 0);
            v[0].Color = new Color(0, 0, 0);
            v[1] = new VertexPositionColor();
            v[1].Position = new Vector3(960, 0, 0);
            v[1].Color = new Color(0, 0, 0);
            v[2] = new VertexPositionColor();
            v[2].Position = new Vector3(0, 64, 0);
            v[2].Color = new Color(0, 0, 0);
            v[3] = new VertexPositionColor();
            v[3].Position = new Vector3(960, 64, 0);
            v[3].Color = new Color(0, 0, 0);
            game.effect.TextureEnabled = false;
            foreach (EffectPass pass in game.effect.CurrentTechnique.Passes)
            {
                pass.Apply();
                GraphicsDevice.DrawUserPrimitives<VertexPositionColor>(PrimitiveType.TriangleStrip, v, 0, 2);
            }
            game.effect.TextureEnabled = true;
            // draw scrolling message
            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);
            Messages.draw(spriteBatch, game.font);
            spriteBatch.End();

            if (paused)
            {
                game.black_overlay(0.6f);

                int len1 = (int)game.font.MeasureString("Restart level").X + 30;
                int len2 = (int)game.font.MeasureString("Resume game").X + 30;
                int len3 = (int)game.font.MeasureString("Quit").X + 30;

                spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);

                int xx = 480 - len1 / 2;
                spriteBatch.Draw(x_bmp, new Vector2(xx, 320 - 55), Color.White);
                spriteBatch.DrawString(game.font, "Restart level", new Vector2(xx + 30, 320 - 60), Color.White);

                xx = 480 - len2 / 2;
                spriteBatch.Draw(b_bmp, new Vector2(xx, 320 - 5), Color.White);
                spriteBatch.DrawString(game.font, "Resume game", new Vector2(xx + 30, 320 - 10), Color.White);

                xx = 480 - len3 / 2;
                spriteBatch.Draw(y_bmp, new Vector2(xx, 320 + 45), Color.White);
                spriteBatch.DrawString(game.font, "Quit", new Vector2(xx + 30, 320 + 40), Color.White);

                spriteBatch.End();
            }

            game.GraphicsDevice.Viewport = old_vp;

            base.Draw(gameTime);
        }

        public static void load_atlas()
        {
            atlas = Bobby.Program.game.Content.Load<Texture2D>("data/atlas");

            switch_rect = create_padded_rectangle(96, 96, 48, 48);
            gate_rect = create_padded_rectangle(96, 144, 48, 48);
            transporter_in_rect = create_padded_rectangle(96, 192, 48, 48);
            transporter_out_rect = create_padded_rectangle(96, 240, 48, 48);
            fan_rect = create_padded_rectangle(96, 288, 48, 48);
            smoke_rects[0] = create_padded_rectangle(96, 336, 48, 48);
            smoke_rects[1] = create_padded_rectangle(96, 384, 48, 48);
            smoke_rects[2] = create_padded_rectangle(96, 432, 48, 48);
            totally_good_spiral_rect = create_padded_rectangle(144, 96, 48, 48);
            totally_evil_spiral_rect = create_padded_rectangle(144, 144, 48, 48);
            wall_rect = create_padded_rectangle(144, 192, 48, 48);
            bouncy_wall_rect = create_padded_rectangle(144, 240, 48, 48);
            unbouncy_wall_rect = create_padded_rectangle(144, 288, 48, 48);
            miao_ball_rect = create_padded_rectangle(144, 336, 48, 48);
            magnet_rect = create_padded_rectangle(192, 0, 48, 48);

            ball_rects[0] = create_padded_rectangle(0, 0, TILE_SIZE, TILE_SIZE);
            ball_rects[1] = create_padded_rectangle(TILE_SIZE, 0, TILE_SIZE, TILE_SIZE);
            ball_rects[2] = create_padded_rectangle(TILE_SIZE * 2, 0, TILE_SIZE, TILE_SIZE);
            ball_rects[3] = create_padded_rectangle(TILE_SIZE * 3, 0, TILE_SIZE, TILE_SIZE);

            heavy_ball_rects[0] = create_padded_rectangle(0, 48, TILE_SIZE, TILE_SIZE);
            heavy_ball_rects[1] = create_padded_rectangle(TILE_SIZE, 48, TILE_SIZE, TILE_SIZE);
            heavy_ball_rects[2] = create_padded_rectangle(TILE_SIZE * 2, 48, TILE_SIZE, TILE_SIZE);
            heavy_ball_rects[3] = create_padded_rectangle(TILE_SIZE * 3, 48, TILE_SIZE, TILE_SIZE);

            player_go[0] = create_padded_rectangle(TILE_SIZE, 96, TILE_SIZE, TILE_SIZE);
            player_go[1] = create_padded_rectangle(TILE_SIZE, TILE_SIZE + 96, TILE_SIZE, TILE_SIZE);
            player_go[2] = create_padded_rectangle(TILE_SIZE, TILE_SIZE * 2 + 96, TILE_SIZE, TILE_SIZE);
            player_go[3] = create_padded_rectangle(TILE_SIZE, TILE_SIZE * 3 + 96, TILE_SIZE, TILE_SIZE);
            player_go[4] = create_padded_rectangle(0, 96, TILE_SIZE, TILE_SIZE);
            player_go[5] = create_padded_rectangle(0, TILE_SIZE + 96, TILE_SIZE, TILE_SIZE);
            player_go[6] = create_padded_rectangle(0, TILE_SIZE * 2 + 96, TILE_SIZE, TILE_SIZE);
            player_go[7] = create_padded_rectangle(0, TILE_SIZE * 3 + 96, TILE_SIZE, TILE_SIZE);

            miao_go[0] = create_padded_rectangle(TILE_SIZE, 288, TILE_SIZE, TILE_SIZE);
            miao_go[1] = create_padded_rectangle(TILE_SIZE, TILE_SIZE + 288, TILE_SIZE, TILE_SIZE);
            miao_go[2] = create_padded_rectangle(TILE_SIZE, TILE_SIZE * 2 + 288, TILE_SIZE, TILE_SIZE);
            miao_go[3] = create_padded_rectangle(TILE_SIZE, TILE_SIZE * 3 + 288, TILE_SIZE, TILE_SIZE);
            miao_go[4] = create_padded_rectangle(0, 288, TILE_SIZE, TILE_SIZE);
            miao_go[5] = create_padded_rectangle(0, TILE_SIZE + 288, TILE_SIZE, TILE_SIZE);
            miao_go[6] = create_padded_rectangle(0, TILE_SIZE * 2 + 288, TILE_SIZE, TILE_SIZE);
            miao_go[7] = create_padded_rectangle(0, TILE_SIZE * 3 + 288, TILE_SIZE, TILE_SIZE);
        }

        private static Rectangle entity_rectangle(int type, Entity entity, GameTime time)
        {
	        if (type >= 'x' && type <= 'z') 
		        return transporter_in_rect;
	        if (type >= 'X' && type <= 'Z')
		        return transporter_out_rect;

            switch (type)
            {
                case PLAYER:
                    {
                        Rectangle[] p = (Bobby_Game.kitty_enabled ? miao_go : player_go);
                        if (!player_animating_out)
                        {
                            int frame = player_anim_num;
                            if (frame > 7) frame = 7;
                            return p[frame];
                        }
                        else
                        {
                            int frame = 7 - player_anim_num;
                            if (frame < 0) frame = 0;
                            return p[frame];
                        }
                    }
                case MIAO_BALL:
                    return miao_ball_rect;
                case BALL:
                case HEAVY_BALL:
                    {
                        Rectangle[] arr = (type == BALL ? ball_rects : heavy_ball_rects);
                        if (entity == null) return arr[3];
                        int t = time.TotalGameTime.Milliseconds - entity.hit_time;
                        int frame;
                        if (t < 750 && t >= 0)
                            frame = t / 250;
                        else
                            frame = 3;
                        return arr[frame];
                    }
                case SPIRAL:
                    if (nballs <= 0)
                        return totally_good_spiral_rect;
                    else
                        return totally_evil_spiral_rect;
                case TOTALLY_EVIL_SPIRAL:
                    return totally_evil_spiral_rect;
                case TOTALLY_GOOD_SPIRAL:
                    return totally_good_spiral_rect;
                case WALL:
                    return wall_rect;
                case BOUNCY_WALL:
                    return bouncy_wall_rect;
                case UNBOUNCY_WALL:
                    return unbouncy_wall_rect;
                case SWITCH1:
                case SWITCH2:
                    return switch_rect;
                case GATE1:
                case GATE2:
                    return gate_rect;
                case FAN_LEFT:
                case FAN_RIGHT:
                case FAN_UP:
                case FAN_DOWN:
                case FAN_SPIN:
                    return fan_rect;
                case MAGNET:
                    return magnet_rect;
                default:
                    return wall_rect;
            }
        }

        private void draw_object(int tx, int ty, Color tint, GameTime game_time)
        {
            Entity o = level[tx][ty];

            if (o.type == '0')
                return;

            Rectangle r = entity_rectangle(o.type, o, game_time);

            int x, y;

            if ((o.live == 0) && o.scale <= 0)
                return;

//            x = (int)(o.x + o.scale * (TILE_SIZE / 2));
  //          y = (int)(o.y + o.scale * (TILE_SIZE / 2));
            x = (int)(o.x +  (TILE_SIZE / 2));
            y = (int)(o.y +  (TILE_SIZE / 2));

            if (o.scale != 1.0)
            {
                spriteBatch.Draw(atlas, new Vector2(x, y), r, tint, MathHelper.ToRadians(o.angle), new Vector2(TILE_SIZE/2, TILE_SIZE/2), new Vector2(o.scale, o.scale), SpriteEffects.None, 0.0f);
            }
            else if (((o.groups & ALL_BOUNCY) != 0) || ((o.groups & ALL_FANS) != 0) || ((o.groups & ALL_SPIRALS) != 0) || (o.type == MAGNET))
            {
                float angle = -o.angle;
                if (((o.groups & ALL_BALLS) != 0) && Math.Sqrt(o.vx * o.vx + o.vy * o.vy) > 1)
                {
                    angle = angle * (Bobby_Game.timespan_to_ticks(game_time.TotalGameTime) / (float)TimeSpan.TicksPerSecond) * 60.0f;
                }
                spriteBatch.Draw(atlas, new Vector2(x, y), r, tint, MathHelper.ToRadians(angle), new Vector2(TILE_SIZE/2, TILE_SIZE/2), new Vector2(1.0f, 1.0f), SpriteEffects.None, 0.0f);
            }
            else
            {
                spriteBatch.Draw(atlas, new Vector2(x, y), r, tint, 0.0f, new Vector2(TILE_SIZE/2, TILE_SIZE/2), new Vector2(1.0f, 1.0f), SpriteEffects.None, 0.0f);
            }
        }

        private static Rectangle create_padded_rectangle(int x, int y, int w, int h)
        {
            int tx = (x / TILE_SIZE);
            int ty = (y / TILE_SIZE);

            return new Rectangle(x + (tx + 1) * 2, y + (ty + 1) * 2, w, h);
        }

        private bool POINT_IN_BOX(float x, float y, float x1, float y1, float w, float h)
        {
            return ((x) >= (x1) && (x) < (x1)+(w) && (y) >= (y1) && (y) < (y1)+(h));
        }

        private bool POINT_IN_OBJ(float x, float y, float ox1, float oy1)
        {
		        return POINT_IN_BOX(x, y, ox1, oy1, TILE_SIZE-8, TILE_SIZE-8);
        }

        private bool WALL_COLLIDING(Entity o1, Entity o2)
        {
	        return (!(o1.x+4 > o2.x+TILE_SIZE || o1.y+4 > o2.y+TILE_SIZE || o1.x+TILE_SIZE-4 < o2.x || o1.y+TILE_SIZE-4 < o2.y));
        }

        private bool IN_BOUNDS(float x, float y)
        {
            return ((x) >= 0 && (x) < Bobby_Game.WIDTH && (y) >= 0 && (y) < Bobby_Game.HEIGHT);
        }

        private void CLAMP(ref float v, float max)
        {
	        if (v < 0.0) {
		        if (v <= -max)
			        v = -max;
	        }
	        else {
		        if (v >= max)
			        v = max;
	        }
        }

        private void DAMPEN(ref float x, float val)
        {
	        if (x < 0.0f) {
		        x += val * brake_multiplier;
		        if (x > 0.0f) x = 0.0f;
	        }
	        else if (x > 0.0f) {
		        x -= val * brake_multiplier;
		        if (x < 0.0f) x = 0.0f;
	        }
        }

        private bool OBJECTS_COLLIDING(Entity o1, Entity o2)
        {
	        return (!(o1.x+4 > o2.x+TILE_SIZE-4 || o1.y+4 > o2.y+TILE_SIZE-4 || o1.x+TILE_SIZE-4 < o2.x+4 || o1.y+TILE_SIZE-4 < o2.y+4));
        }

        private bool object_colliding(Entity o, ref Entity[] ret, out int count, out int groups)
        {
	        count = 0;
	        groups = 0;
	        int x, y;
	
	        for (y = 0; y < Bobby_Game.HEIGHT; y++) {
		        for (x = 0; x < Bobby_Game.WIDTH; x++) {
			        if ((level[x][y].tx == o.tx && level[x][y].ty == o.ty) || (level[x][y].live == 0) || level[x][y].type == EMPTY || level[x][y].groups == ALL_WALLS || level[x][y].groups == (ALL_TRANSPORTER | ALL_TRANSPORTER_END))
				        continue;
			        if (OBJECTS_COLLIDING(o, level[x][y])) {
				        ret[count] = level[x][y];
				        count = count + 1;
				        groups |= level[x][y].groups;
			        }
		        }
	        }
	
	        return count > 0;
        }

        private bool wall_colliding(Entity o, ref Entity[] ret, out int count, out int groups)
        {
	        count = 0;
	        groups = 0;
	        int x, y;
	
	        for (y = 0; y < Bobby_Game.HEIGHT; y++) {
		        for (x = 0; x < Bobby_Game.WIDTH; x++) {
			        if ((level[x][y].tx == o.tx && level[x][y].ty == o.ty) || ((level[x][y].groups & ALL_WALLS) == 0))
				        continue;
			        if (WALL_COLLIDING(o, level[x][y])) {
				        ret[count] = level[x][y];
				        count = count + 1;
				        groups |= level[x][y].groups;
			        }
		        }
	        }
	
	        return count > 0;
        }

        private void dampen(ref Entity o)
        {
            if (brake_on)
                brake_multiplier = 5000.0f;
            else
                brake_multiplier = 1.0f;

            DAMPEN(ref o.ax, A_DAMP);
            DAMPEN(ref o.ay, A_DAMP);
            DAMPEN(ref o.vx, V_DAMP);
            DAMPEN(ref o.vy, V_DAMP);
        }

        private void collide(ref Entity o1, ref Entity o2, GameTime game_time)
        {
	        float xp = (o2.x+(TILE_SIZE/2)) - (o1.x+(TILE_SIZE/2));
	        float yp = (o2.y+(TILE_SIZE/2)) - (o1.y+(TILE_SIZE/2));

	        if ((o2.groups & ALL_BOUNCY) != 0) {
		        o1.hit_time = game_time.TotalGameTime.Milliseconds;
		        o2.hit_time = game_time.TotalGameTime.Milliseconds;
		        Sound.play(Sound.boing);
		        normalize(ref xp, ref yp, o1.mass/o2.mass*2);
		        o2.vx += xp;
		        o2.vy += yp;
		        normalize(ref xp, ref yp, o2.mass/o1.mass*2);
		        o1.vx -= xp;
		        o1.vy -= yp;
		        // spin balls randomly
                if (o1.type != PLAYER && o1.type != MIAO_BALL)
                    o1.angle = (float)((random.NextDouble() * 10) - 5);
		        if (o2.type != PLAYER && o2.type != MIAO_BALL)
                    o2.angle = (float)((random.NextDouble() * 10) - 5);
                // dampen enemies if brakes on
		        if (o1.type == PLAYER) {
			        dampen(ref o2);
		        }
		        else if (o2.type == PLAYER) {
			        dampen(ref o1);
		        }
	        }
	        else if ((o2.groups & ALL_SPIRALS) != 0) {
		        Sound.play(Sound.spiral);
		        o1.live = 0;
		        if (o1.type == MIAO_BALL) {
			        Sound.play(Sound.meow);
		        }
		        if ((((o1.groups & ALL_BALLS) != 0) || o1.type == MIAO_BALL) && (level[player_x][player_y].live != 0)) {
		            nballs--;
		        }
		        else {
		            next_time = 120;
		            if (o2.type == TOTALLY_EVIL_SPIRAL)
			            hit_totally_evil_spiral = true;
		            else
			            hit_totally_evil_spiral = false;
		        }
	        }
        }

        private void single_wall_collide(ref Entity o, Entity w, float multiplier_x, float multiplier_y)
        {
	        float[] wxs = new float[4];
            float[] wys = new float[4];
	        wxs[0] = w.x;
	        wxs[1] = w.x+TILE_SIZE;
	        wxs[2] = wxs[1];
	        wxs[3] = wxs[0];
	        wys[0] = w.y;
	        wys[1] = wys[0];
	        wys[2] = w.y+TILE_SIZE;
	        wys[3] = wys[2];

	        float ox1 = o.x+(4);
	        float oy1 = o.y+(4);

	        if (o.vx == 0 && o.vy == 0) {
		        return;
	        }
	        else if (o.vx == 0) {
		        o.vy = -o.vy * multiplier_y;
		        return;
	        }
	        else if (o.vy == 0) {
		        o.vx = -o.vx * multiplier_x;
		        return;
	        }

            // corner depths
            float depx, depy, depx_inv, depy_inv;
            depx = o.x % TILE_SIZE;
            depy = o.y % TILE_SIZE;
            depx_inv = TILE_SIZE - depx;
            depy_inv = TILE_SIZE - depy;

            if (o.vx > 0)
            {
		        if (o.vy > 0) {
			        if (POINT_IN_OBJ(wxs[1], wys[1], ox1, oy1)) {
				        o.vy = -o.vy * multiplier_y;
				        return;
			        }
			        else if (POINT_IN_OBJ(wxs[3], wys[3], ox1, oy1)) {
				        o.vx = -o.vx * multiplier_x;
				        return;
			        }
                    else if (POINT_IN_OBJ(wxs[0], wys[0], ox1, oy1))
                    {
                        if (depx >= depy * 2)
                        {
                            o.vy = -o.vy * multiplier_y;
                        }
                        else if (depy >= depx * 2)
                        {
                            o.vx = -o.vx * multiplier_x;
                        }
                        else
                        {
                            o.vx = -o.vx * multiplier_x;
                            o.vy = -o.vy * multiplier_y;
                        }
				        return;
			        }
		        }
		        else if (o.vy < 0) {
			        if (POINT_IN_OBJ(wxs[0], wys[0], ox1, oy1)) {
				        o.vx = -o.vx * multiplier_x;
				        return;
			        }
			        else if (POINT_IN_OBJ(wxs[2], wys[2], ox1, oy1)) {
				        o.vy = -o.vy * multiplier_y;
				        return;
			        }
			        else if (POINT_IN_OBJ(wxs[3], wys[3], ox1, oy1)) {
                        if (depx >= depy_inv * 2)
                        {
                            o.vy = -o.vy * multiplier_y;
                        }
                        else if (depy_inv >= depx * 2)
                        {
                            o.vx = -o.vx * multiplier_x;
                        }
                        else
                        {
                            o.vx = -o.vx * multiplier_x;
                            o.vy = -o.vy * multiplier_y;
                        }
				        return;
			        }
		        }
	        }
	        else if (o.vx < 0) {
		        if (o.vy > 0) {
			        if (POINT_IN_OBJ(wxs[0], wys[0], ox1, oy1)) {
				        o.vy = -o.vy * multiplier_y;
				        return;
			        }
			        else if (POINT_IN_OBJ(wxs[2], wys[2], ox1, oy1)) {
				        o.vx = -o.vx * multiplier_x;
				        return;
			        }
			        else if (POINT_IN_OBJ(wxs[1], wys[1], ox1, oy1)) {
                        if (depx_inv >= depy * 2)
                        {
                            o.vy = -o.vy * multiplier_y;
                        }
                        else if (depy >= depx_inv * 2)
                        {
                            o.vx = -o.vx * multiplier_x;
                        }
                        else
                        {
                            o.vx = -o.vx * multiplier_x;
                            o.vy = -o.vy * multiplier_y;
                        }
				        return;
			        }
		        }
		        else if (o.vy < 0) {
			        if (POINT_IN_OBJ(wxs[1], wys[1], ox1, oy1)) {
				        o.vx = -o.vx * multiplier_x;
				        return;
			        }
			        else if (POINT_IN_OBJ(wxs[3], wys[3], ox1, oy1)) {
				        o.vy = -o.vy * multiplier_y;
				        return;
			        }
			        else if (POINT_IN_OBJ(wxs[2], wys[2], ox1, oy1)) {
                        if (depx_inv >= depy_inv * 2)
                        {
                            o.vy = -o.vy * multiplier_y;
                        }
                        else if (depy_inv >= depx_inv * 2)
                        {
                            o.vx = -o.vx * multiplier_x;
                        }
                        else
                        {
                            o.vx = -o.vx * multiplier_x;
                            o.vy = -o.vy * multiplier_y;
                        }
				        return;
			        }
		        }
	        }

	        o.vx = -o.vx * multiplier_x;
	        o.vy = -o.vy * multiplier_y;
        }

        private void get_multipliers(Entity o, List<Entity> c, out float multiplier_x, out float multiplier_y)
        {
	        multiplier_x = 1.0f;
	        multiplier_y = 1.0f;

	        int i;
	        for (i = 0; i < c.Count; i++) {
		        if (c[i].type == BOUNCY_WALL) {
			        if (o.type == PLAYER) {
				        multiplier_x = 1.5f;
				        multiplier_y = 1.5f;
			        }
			        else {
				        multiplier_x = 3.0f;
				        multiplier_y = 3.0f;
			        }
			        break;
		        }
		        else if (c[i].type == UNBOUNCY_WALL) {
			        multiplier_x = -5000;
			        multiplier_y = -5000;
		        }
	        }
	
	        if (o.type == PLAYER || o.type == MIAO_BALL) { // less bounce off walls
		        multiplier_x *= 0.5f;
		        multiplier_y *= 0.5f;
	        }
        }

        private bool wall_collide(Entity o)
        {
            List<Entity> c = new List<Entity>();
	        int x, y;
	        float multiplier_x, multiplier_y;

	        for (y = 0; y < Bobby_Game.HEIGHT; y++) {
		        for (x = 0; x < Bobby_Game.WIDTH; x++) {
			        if ((level[x][y].groups & ALL_WALLS) != 0) {
				        if (WALL_COLLIDING((o), level[x][y])) {
                            c.Add(level[x][y]);
				        }
			        }
		        }
	        }
	
	        get_multipliers(o, c, out multiplier_x, out multiplier_y);
	        if (Math.Abs(o.vx * multiplier_x) < 0.25f) {
		        if (Math.Abs(o.vx) != 0)
			        multiplier_x = Math.Abs(0.25f / o.vx);
	        }
	        if (Math.Abs(o.vy * multiplier_y) < 0.25f) {
		        if (Math.Abs(o.vy) != 0)
			        multiplier_y = Math.Abs(0.25f / o.vy);
	        }
	
	        if (c.Count == 3) {
		        o.vx = -o.vx * multiplier_x;
		        o.vy = -o.vy * multiplier_y;
		        return true;
	        }
	        else if (c.Count == 2) {
		        if (c[0].tx != c[1].tx && c[0].ty != c[1].ty) {
			        o.vx = -o.vx * multiplier_x;
			        o.vy = -o.vy * multiplier_y;
			        return true;
		        }
		        else if (c[0].tx == c[1].tx) {
			        o.vx = -o.vx * multiplier_x;
			        return true;
		        }
		        else if (c[0].ty == c[1].ty) {
			        o.vy = -o.vy * multiplier_y;
			        return true;
		        }
	        }
	        else if (c.Count == 1) {
		        int xx1 = c[0].tx-1;
		        int xx2 = c[0].tx+1;
		        int yy1 = c[0].ty-1;
		        int yy2 = c[0].ty+1;

		        // if hit top or bottom and it's a straight line horizontally
		        if (
		            (o.x+4 > c[0].x && o.x+TILE_SIZE-4 < c[0].x+TILE_SIZE) &&
		            ((IN_BOUNDS(xx1, c[0].ty) && ((level[xx1][c[0].ty].groups & ALL_WALLS) != 0)) ||
		            (IN_BOUNDS(xx2, c[0].ty) && ((level[xx2][c[0].ty].groups & ALL_WALLS) != 0))))
		        {
			        o.vy = -o.vy * multiplier_y;
			        return true;
		        }		
		        // "" left or right "" vertically
		        else if (
		            (o.y+4 > c[0].y && o.y+TILE_SIZE-4 < c[0].y+TILE_SIZE) &&
		            ((IN_BOUNDS(c[0].tx, yy1) && ((level[c[0].tx][yy1].groups & ALL_WALLS) != 0)) ||
		            (IN_BOUNDS(c[0].tx, yy2) && ((level[c[0].tx][yy2].groups & ALL_WALLS) != 0))))
		        {
			        o.vx = -o.vx * multiplier_x;
			        return true;
		        }
		
		        single_wall_collide(ref o, c[0], multiplier_x, multiplier_y);
		        return true;
	        }
	
	        return false;
        }

        static bool top_speed_achieved = false;

        private void apply_force(Entity o, float angle, float force)
        {
            o.ax += (float)Math.Cos(MathHelper.ToRadians(angle)) * force;
            o.ay += (float)Math.Sin(MathHelper.ToRadians(angle)) * force;
        }

        private void normalize(ref float x, ref float y, float size)
        {
            float len = (float)Math.Sqrt((x * x) + (y * y));
            if (len == 0)
                len = 1;
            x *= size / len;
            y *= size / len;
        }

        /* scale an object down and rotate if it ran into a spiral */
        private void update_scale()
        {
	        int x, y;

	        for (y = 0; y < Bobby_Game.HEIGHT; y++) {
		        for (x = 0; x < Bobby_Game.WIDTH; x++) {
			        if ((level[x][y].live == 0) && level[x][y].scale > 0) {
				        level[x][y].scale -= 1.0f/100.0f * SPEED_MULT; // 2 second duration
				        level[x][y].angle -= 10 * SPEED_MULT;
			        }
		        }
	        }
        }

        /*
         * Move movable objects based on their velocity, acceleration,
         * gravity, collisions, etc.
         */
        private void move_objects(GameTime game_time)
        {
	        player_anim_count++;
            if (player_anim_count >= 6)
            {
                player_anim_count = 0;
                player_anim_num++;
            }

	        int x, y, i, j;
	        float save_x, save_y, save_vx, save_vy, save_ax, save_ay;
	
	        /* move the objects */
	        for (y = 0; y < Bobby_Game.HEIGHT; y++) {
		        for (x = 0; x < Bobby_Game.WIDTH; x++) {
			        if ((level[x][y].live != 0) && 
				        ((level[x][y].groups & ALL_BOUNCY) != 0))
			        {
				        // check for top speed achievement
				        if (level[x][y].type == PLAYER && !top_speed_achieved) {
					        if (Math.Abs(level[x][y].vx)+0.01f >= MAX_V && Math.Abs(level[x][y].vy)+0.01f >= MAX_V) {
						        top_speed_achieved = true;
						        //reportAchievementIdentifier(MaximumVelocityID, MaximumVelocityS);
					        }
				        }
				
				        Entity[] c = new Entity[50];
				        int count;
				        int groups;
				
				        // apply fans
				        if (level[x][y].type != HEAVY_BALL) {
					        int xx, yy;
					        for (yy = 0; yy < Bobby_Game.HEIGHT; yy++) {
						        for (xx = 0; xx < Bobby_Game.WIDTH; xx++) {
							        if ((level[xx][yy].groups & ALL_FANS) != 0) {
								        float dx = level[x][y].x - level[xx][yy].x;
								        float dy = level[x][y].y - level[xx][yy].y;
								        float a = -MathHelper.ToDegrees((float)Math.Atan2(dy, dx));
								        while (a < 0) a += 360.0f;
								        if (Math.Abs(a-level[xx][yy].angle) <= 22.5) {
									        float dist = (float)Math.Sqrt(dx*dx + dy*dy);
									        if (dist < FAN_REACH) {
										        float force = (float)Math.Sin((FAN_REACH-dist)/FAN_REACH*Math.PI/2) * FAN_FORCE;
										        float angle;
										        if (level[xx][yy].type == FAN_LEFT)
											        angle = -180;
										        else if (level[xx][yy].type == FAN_RIGHT)
											        angle = -0;
										        else if (level[xx][yy].type == FAN_UP)
											        angle = -90;
										        else if (level[xx][yy].type == FAN_DOWN)
											        angle = -270;
										        else
											        angle = -level[xx][yy].angle;
										        apply_force(level[x][y], angle, force);
									        }
								        }
							        }
						        }
					        }
				        }

				        // apply magnets
				        if (level[x][y].type == PLAYER) {
					        int xx, yy;
					        for (yy = 0; yy < Bobby_Game.HEIGHT; yy++) {
						        for (xx = 0; xx < Bobby_Game.WIDTH; xx++) {
							        if (level[xx][yy].type == MAGNET) {
								        float dx = level[x][y].x - level[xx][yy].x;
								        float dy = level[x][y].y - level[xx][yy].y;
								        float dist = (float)Math.Sqrt(dx*dx + dy*dy);
								        if (dist < 256) {
									        float force = -(256-dist)/256.0f * MAGNET_FORCE;
									        float angle = MathHelper.ToDegrees((float)Math.Atan2(dy, dx));
									        apply_force(level[x][y], angle, force);
								        }
							        }
						        }
					        }
				        }

				        /* apply gravity */
				        if (level[x][y].vy < MAX_GRAVITY_V)
					        apply_force(level[x][y], 90.0f, GRAVITY);
				        if (x == player_x && y == player_y && brake_on)
					        brake_multiplier = 15;
				        else
					        brake_multiplier = 1.0f;
				        DAMPEN(ref level[x][y].ax, A_DAMP);
				        DAMPEN(ref level[x][y].ay, A_DAMP);
				        DAMPEN(ref level[x][y].vx, V_DAMP);
				        DAMPEN(ref level[x][y].vy, V_DAMP);
                        CLAMP(ref level[x][y].ax, MAX_A);
				        CLAMP(ref level[x][y].ay, MAX_A);
				        level[x][y].vx += level[x][y].ax;
				        level[x][y].vy += level[x][y].ay;
				        CLAMP(ref level[x][y].vx, MAX_V);
				        CLAMP(ref level[x][y].vy, MAX_V);
				        save_x = level[x][y].x;
				        save_y = level[x][y].y;
				        save_vx = level[x][y].vx;
				        save_vy = level[x][y].vy;
				        save_ax = level[x][y].ax;
				        save_ay = level[x][y].ay;
				        level[x][y].x += level[x][y].vx;
				        level[x][y].y += level[x][y].vy;

				        bool wcoll = wall_collide(level[x][y]);
				        if (wcoll && ((level[x][y].groups & ALL_BALLS) != 0)) {
					        level[x][y].hit_time = game_time.TotalGameTime.Milliseconds;
				        }

				        /* check for collisions */
				        if (object_colliding(level[x][y], ref c, out count, out groups)) {
					        for (j = 0; j < count; j++) {
						        if (!(c[j].groups == (ALL_TRANSPORTER_START | ALL_TRANSPORTER))) {
							        collide(ref level[x][y], ref c[j], game_time);
							        if ((c[j].groups & ALL_SPIRALS) != 0)
								        break;
						        }
					        }

					        if ((groups & ALL_TRANSPORTER_START) != 0) {
						        int look_for = '0';
						        for (j = 0; j < count; j++) {
							        if ((c[j].groups & ALL_TRANSPORTER_START) != 0) {
								        look_for = (int)Char.ToUpper((char)c[j].type);
								        break;
							        }
						        }
						        int xx, yy;
						        for (yy = 0; yy < Bobby_Game.HEIGHT; yy++) {
							        for (xx = 0; xx < Bobby_Game.WIDTH; xx++) {
								        if (level[xx][yy].type == look_for) {
									        Entity tmp = new Entity();
									        tmp.x = level[xx][yy].x;
									        tmp.y = level[xx][yy].y;
									        tmp.live = 1;
									        tmp.tx = level[xx][yy].tx;
									        tmp.ty = level[xx][yy].ty;
									        Entity[] c2 = new Entity[100];
									        int count2;
									        int groups2;
									        if (!object_colliding(tmp, ref c2, out count2, out groups2) || (groups == (ALL_TRANSPORTER_END | ALL_TRANSPORTER))) {
										        Sound.play(Sound.spiral);
										        level[x][y].angle = 90;
										        level[x][y].x = level[xx][yy].x;
										        level[x][y].y = level[xx][yy].y;
										        level[x][y].ax = level[x][y].ay = level[x][y].vx = level[x][y].vy = 0;
									        }
									        break;
								        }
							        }
						        }
					        }
					        else {
						        level[x][y].x = save_x;
						        level[x][y].y = save_y;
					        }

					        if (level[x][y].type == PLAYER && ((groups & ALL_SWITCHES) != 0)) {
						        int[] rm = new int[2];
						        for (j = 0; j < count; j++) {
							        if (c[j].type == SWITCH1) {
								        rm[0] = SWITCH1;
                                        rm[1] = GATE1;
								        break;
							        }
							        else if (c[j].type == SWITCH2) {
                                        rm[0] = SWITCH2;
                                        rm[1] = GATE2;
								        break;
							        }
						        }
						        int xx, yy;
						        for (yy = 0; yy < Bobby_Game.HEIGHT; yy++) {
							        for (xx = 0; xx < Bobby_Game.WIDTH; xx++) {
								        if (level[xx][yy].type == rm[0] || level[xx][yy].type == rm[1]) {
									        Sound.play(Sound.switch_sample);
									        level[xx][yy].type = EMPTY;
									        level[xx][yy].groups = OTHER;
									        level[xx][yy].live = 0;
								        }
							        }
						        }
					        }
				        }
				        else if (wcoll) {
					        level[x][y].x = save_x;
					        level[x][y].y = save_y;
				        }
			        }
			        else if (level[x][y].type == FAN_SPIN) {
				        level[x][y].angle += 0.4f * SPEED_MULT;
				        if (level[x][y].angle >= 360.0) level[x][y].angle -= 360.0f;
			        }
			        else if ((level[x][y].groups & ALL_SPIRALS) != 0) {
				        level[x][y].angle += 2;
			        }
		        }
	        }
	

	        // move smoke
	        for (i = 0; i < NSMOKE ; i++) {
		        if (smoke[i].life > 0) {
			        smoke[i].life -= 1000 / 60;
			        smoke[i].x += smoke[i].vx;
			        smoke[i].y += smoke[i].vy;
		        }
	        }

	        // move air currents
	        wave -= 10 * SPEED_MULT;

            update_scale();

            updateStars();
            updateSpaceStuff(game_time);
        }

        private void forward(GameTime game_time)
        {
	        apply_force(level[player_x][player_y], -level[player_x][player_y].angle, THRUST);
	        if (game_time.TotalGameTime >= next_smoke) {
                next_smoke = TimeSpan.FromTicks(Bobby_Game.timespan_to_ticks(game_time.TotalGameTime) + (1000 / 60) * TimeSpan.TicksPerMillisecond);
		        int i;
		        for (i = 0; i < NSMOKE; i++) {
			        if (smoke[i].life <= 0) {
				        smoke[i].life = 1000;
                        int r = (int)(random.NextDouble() * 5);
				        if (r == 0)
					        smoke[i].bmp_index = 0;
				        else if (r == 1)
					        smoke[i].bmp_index = 1;
				        else
					        smoke[i].bmp_index = 2;
				        float x =
					        (float)Math.Cos(MathHelper.ToRadians(level[player_x][player_y].angle));
				        float y =
					        (float)Math.Sin(MathHelper.ToRadians(level[player_x][player_y].angle));
				        smoke[i].x = (level[player_x][player_y].x + TILE_SIZE/2) -
					        x * TILE_SIZE*3/4;
				        smoke[i].y = (level[player_x][player_y].y + TILE_SIZE/2) +
					        y * TILE_SIZE*3/4;
				        float da = (float)(random.NextDouble() * 60 - 30);
				        smoke[i].vx =
					        (float)(-Math.Cos(MathHelper.ToRadians(level[player_x][player_y].angle+da)) * 0.75 * SPEED_MULT);
				        smoke[i].vy =
					        (float)(Math.Sin(MathHelper.ToRadians(level[player_x][player_y].angle+da)) * 0.75 * SPEED_MULT);
				        int xx = (int)(random.NextDouble() * 100);
                        int yy = (int)(random.NextDouble() * 100);
				        if (Bobby_Game.kitty_enabled) {
					        smoke[i].color = rainbow_data[yy*100+xx];
				        }
				        else {
					        smoke[i].color = fire_data[yy*100+xx];
				        }
				        break;
			        }
                    //System.Diagnostics.Debug.WriteLine("i=" + i);
		        }
	        }
        }

        private void left()
        {
	        level[player_x][player_y].angle += 3.0f * SPEED_MULT;
        }

        private void right()
        {
	        level[player_x][player_y].angle -= 3.0f * SPEED_MULT;
        }

        private void drawSpaceStuff()
        {
	        int i;

	        // draw galaxies etc
	        for (i = 0; i < numSpaceThings; i++) {
                spriteBatch.Draw(space_bmps[spaceThings[i].bmp_index], new Rectangle((int)spaceThings[i].x, (int)spaceThings[i].y, space_bmps[spaceThings[i].bmp_index].Width, space_bmps[spaceThings[i].bmp_index].Height), Color.White);
	        }
        }

        private void updateSpaceStuff(GameTime game_time)
        {
	        if (nextSpaceThing < Bobby_Game.timespan_to_ticks(game_time.TotalGameTime) && numSpaceThings < MAX_SPACE_THINGS-1) {
		        nextSpaceThing = Bobby_Game.timespan_to_ticks(game_time.TotalGameTime) + (minSpaceThingTime*TimeSpan.TicksPerSecond )+ (random.NextDouble()*((maxSpaceThingTime-minSpaceThingTime)*TimeSpan.TicksPerSecond));
		        spaceThings[numSpaceThings].x = 960+(float)(random.NextDouble()*50);
		        spaceThings[numSpaceThings].y = (float)(random.NextDouble()*(Bobby_Game.HEIGHT*TILE_SIZE)-50);
		        spaceThings[numSpaceThings].bmp_index = spaceThingOrder[curr_space_thing++];
		        curr_space_thing %= NUM_DIFFERENT_SPACE_THINGS;
		        numSpaceThings++;
	        }
	        int k;
	        for (k = 0; k < numSpaceThings; k++) {
		        spaceThings[k].x -= (float)spaceThingInc;
		        if (spaceThings[k].x < -space_bmps[spaceThings[k].bmp_index].Width) {
			        int l;
			        for (l = k; l < MAX_SPACE_THINGS-1; l++) {
				        spaceThings[l] = spaceThings[l+1];
			        }
			        numSpaceThings--;
			        k--;
		        }
	        }
        }

        private void newStar(int i)
        {
            starfield[i] = new Star();
	        starfield[i].x = (float)(random.NextDouble() * 960);
	        starfield[i].y = (float)(random.NextDouble() *(Bobby_Game.HEIGHT*TILE_SIZE));
	        starfield[i].v = (float)-(random.NextDouble() * 10 * (1.0 / 60));
	        int r = (int)((random.NextDouble() * 100) + 125);
	        int g = r + 30;
	        int b = 255;
	        starfield[i].color = new Color(
			    r, g, b
		    );
        }

        private void updateStars()
        {
	        int i;
	        for (i = 0; i < NUM_STARS; i++) {
		        starfield[i].x += starfield[i].v;
		        if (starfield[i].x < 0) {
			        newStar(i);
			        starfield[i].x = 960;
		        }
	        }
        }

        private void drawStars()
        {
            VertexPositionColor[] v = new VertexPositionColor[NUM_STARS*2];
	
	        for (int i = 0; i < NUM_STARS; i++) {
		        int x = (int)starfield[i].x;
		        int y = (int)starfield[i].y;
                v[i * 2] = new VertexPositionColor();
                v[i * 2].Position = new Vector3(x, y, 0);
                v[i * 2].Color = starfield[i].color;
                v[i * 2 + 1] = new VertexPositionColor();
                v[i * 2 + 1].Position = new Vector3(x + 1, y, 0);
                v[i * 2 + 1].Color = starfield[i].color;
            }

            GraphicsDevice.DrawUserPrimitives<VertexPositionColor>(PrimitiveType.LineList, v, 0, NUM_STARS);
        }

        private static bool[] cached;
        private static Color[] cached_colors;
        private static bool cache_initialized = false;

        public static Color get_tile_color(int type)
        {
            if (!cache_initialized)
            {
                cache_initialized = true;
                cached = new bool[256];
                for (int i = 0; i < 256; i++)
                    cached[i] = false;
                cached_colors = new Color[256];
            }

            if (type == EMPTY)
                return Color.Black;

            if (cached[type])
                return cached_colors[type];

            Entity e = new Entity();
            e.hit_time = 0;

            int total = MainGameComponent.TILE_SIZE * MainGameComponent.TILE_SIZE;

            Color[] data = new Color[total];

            atlas.GetData<Color>(0, entity_rectangle(type, e, new GameTime(TimeSpan.Zero, TimeSpan.Zero)), data, 0, total);

            int rcount = 0;
            int gcount = 0;
            int bcount = 0;
            int count = 0;

            for (int i = 0; i < total; i++)
            {
                if (data[i].A == 0)
                    continue;
                rcount += data[i].R;
                gcount += data[i].G;
                bcount += data[i].B;
                count++;
            }

            cached[type] = true;
            cached_colors[type] = new Color(rcount / count, gcount / count, bcount / count);
            return cached_colors[type];
        }

        private void draw_fan_air()
        {
            for (int i = 0; i < 16; i++)
            {
                game.GraphicsDevice.Textures[i] = null;
            }

            Color[] data = new Color[128*128];

            for (int i = 0; i < 128*128; i++)
            {
                data[i] = new Color(0, 0, 0, 0);
            }

		    int x = 0;
		    int y = 64;

		    float air_angle =  22.5f;
		    const int num_jets = 3;
		    float wave_add = 0.0f;
		    float jinc = 0.5f;
		
		    for (int i = 0; i < num_jets; i++) {
			    for (float j = 0; j < FAN_REACH; j += jinc) {
				    float alpha = (1.0f - ((float)j/FAN_REACH)) * 0.5f;
				    wave_add -= 10;
				    float xx = (float)(x + Math.Cos(MathHelper.ToRadians(-air_angle)) * j + Math.Cos(MathHelper.ToRadians(-air_angle)) * (TILE_SIZE/2));
				    float yy = (float)(y + Math.Sin(MathHelper.ToRadians((wave+wave_add+air_angle))) * 3 + Math.Sin(MathHelper.ToRadians(-air_angle)) * j + Math.Sin(MathHelper.ToRadians(-air_angle)) * (TILE_SIZE/2));
                    if (xx >= 0 && yy >= 0 && xx < 128 && yy < 128) {
                        data[(int)yy * 128 + (int)xx] = new Color(alpha, alpha, alpha, alpha);
				    }
			    }
			    air_angle -= (45.0f/(num_jets-1));
		    }

            fan_air.SetData<Color>(data);
        }

        private void draw_fan(Entity e)
        {
            if ((e.groups & ALL_FANS) == 0)
            {
                return;
            }
	
	        int x = (int)e.x + TILE_SIZE / 2;
	        int y = (int)e.y + TILE_SIZE / 2;

            spriteBatch.Draw(fan_air, new Vector2(x, y), null, Color.White, MathHelper.ToRadians(-e.angle), new Vector2(0, 64), 1.0f, SpriteEffects.None, 0.0f);
        }
    }
}
