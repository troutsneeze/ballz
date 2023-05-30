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
    public class SettingsGameComponent : Microsoft.Xna.Framework.DrawableGameComponent
    {
        // space things moving around
        public const int st1_x1 = 0;
        public const int st1_y1 = 0;
        public const int st1_x2 = 50;
        public const int st1_y2 = 90;
        public const float st1_scale1 = 1.2f;
        public const float st1_scale2 = 1.0f;
        public const float st1_xinc = (st1_x2 - st1_x1) / 30.0f / 6.0f;
        public const float st1_yinc = (st1_y2 - st1_y1) / 30.0f / 6.0f;
        public const float st1_scaleinc = (st1_scale2 - st1_scale1) / 30.0f / 6.0f;
        public const int st2_x1 = 90;
        public const int st2_y1 = 400;
        public const int st2_x2 = 0;
        public const int st2_y2 = 450;
        public const float st2_scale1 = 0.5f;
        public const float st2_scale2 = 1.0f;
        public const float st2_xinc = (st2_x2 - st2_x1) / 30.0f / 4.0f;
        public const float st2_yinc = (st2_y2 - st2_y1) / 30.0f / 4.0f;
        public const float st2_scaleinc = (st2_scale2 - st2_scale1) / 30.0f / 4.0f;

        Texture2D menu_bmp, bg_bmp, space1_bmp, space2_bmp;
        Texture2D logo_bmp;
        Texture2D blue_button_bmp, orange_button_bmp, music_bmp, sounds_bmp, kitty_bmp;
        Texture2D selector_bmp;
        Texture2D a_bmp, b_bmp;
        Texture2D orange_icon, blue_icon;
        SpriteBatch spriteBatch;

        int selection = 0;
        bool kitty_unlocked;

        Bobby_Game game;

        public SettingsGameComponent(Game game)
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

		// Find level 26
	    int n;
	    for (n = 0; n < Bobby_Game.order.Count(); n++) {
	    	if (Bobby_Game.order[n] == 26)
			break;
	    }

            kitty_unlocked = Bobby_Game.stars[n] >= 3;

            base.Initialize();
        }

        protected override void LoadContent()
        {
            menu_bmp = game.Content.Load<Texture2D>("data/menu");
            bg_bmp = game.Content.Load<Texture2D>("data/bg1");
            space1_bmp = game.Content.Load<Texture2D>("data/spacestuff/images2");
            space2_bmp = game.Content.Load<Texture2D>("data/spacestuff/images5");

            logo_bmp = game.Content.Load<Texture2D>("data/logo");

            blue_button_bmp = game.Content.Load<Texture2D>("data/blue_button");
            orange_button_bmp = game.Content.Load<Texture2D>("data/orange_button");
            music_bmp = game.Content.Load<Texture2D>("data/music_txt");
            sounds_bmp = game.Content.Load<Texture2D>("data/sounds_txt");
            kitty_bmp = game.Content.Load<Texture2D>("data/kitty_txt");

            selector_bmp = game.Content.Load<Texture2D>("data/selection_arrow");

            a_bmp = game.Content.Load<Texture2D>("data/a");
            b_bmp = game.Content.Load<Texture2D>("data/b");

            orange_icon = game.Content.Load<Texture2D>("data/orange_icon");
            blue_icon = game.Content.Load<Texture2D>("data/blue_icon");

            base.LoadContent();
        }

        /// <summary>
        /// Allows the game component to update itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        public override void Update(GameTime gameTime)
        {
            game.updateStarAlpha();

            if (MainMenuGameComponent.st1_dir == 1)
            {
                MainMenuGameComponent.st1_x += MainMenuGameComponent.st1_xinc;
                MainMenuGameComponent.st1_y += MainMenuGameComponent.st1_yinc;
                MainMenuGameComponent.st1_scale += MainMenuGameComponent.st1_scaleinc;
                if (MainMenuGameComponent.st1_xinc < 0)
                {
                    if (MainMenuGameComponent.st1_x < MainMenuGameComponent.st1_x2)
                    {
                        MainMenuGameComponent.st1_dir = -MainMenuGameComponent.st1_dir;
                    }
                }
                else
                {
                    if (MainMenuGameComponent.st1_x > MainMenuGameComponent.st1_x2)
                    {
                        MainMenuGameComponent.st1_dir = -MainMenuGameComponent.st1_dir;
                    }
                }
            }
            else
            {
                MainMenuGameComponent.st1_x -= MainMenuGameComponent.st1_xinc;
                MainMenuGameComponent.st1_y -= MainMenuGameComponent.st1_yinc;
                MainMenuGameComponent.st1_scale -= MainMenuGameComponent.st1_scaleinc;
                if (MainMenuGameComponent.st1_xinc < 0)
                {
                    if (MainMenuGameComponent.st1_x > MainMenuGameComponent.st1_x1)
                    {
                        MainMenuGameComponent.st1_dir = -MainMenuGameComponent.st1_dir;
                    }
                }
                else
                {
                    if (MainMenuGameComponent.st1_x < MainMenuGameComponent.st1_x1)
                    {
                        MainMenuGameComponent.st1_dir = -MainMenuGameComponent.st1_dir;
                    }
                }
            }
            if (MainMenuGameComponent.st2_dir == 1)
            {
                MainMenuGameComponent.st2_x += MainMenuGameComponent.st2_xinc;
                MainMenuGameComponent.st2_y += MainMenuGameComponent.st2_yinc;
                MainMenuGameComponent.st2_scale += MainMenuGameComponent.st2_scaleinc;
                if (MainMenuGameComponent.st2_xinc < 0)
                {
                    if (MainMenuGameComponent.st2_x < MainMenuGameComponent.st2_x2)
                    {
                        MainMenuGameComponent.st2_dir = -MainMenuGameComponent.st2_dir;
                    }
                }
                else
                {
                    if (MainMenuGameComponent.st2_x > MainMenuGameComponent.st2_x2)
                    {
                        MainMenuGameComponent.st2_dir = -MainMenuGameComponent.st2_dir;
                    }
                }
            }
            else
            {
                MainMenuGameComponent.st2_x -= MainMenuGameComponent.st2_xinc;
                MainMenuGameComponent.st2_y -= MainMenuGameComponent.st2_yinc;
                MainMenuGameComponent.st2_scale -= MainMenuGameComponent.st2_scaleinc;
                if (MainMenuGameComponent.st2_xinc < 0)
                {
                    if (MainMenuGameComponent.st2_x > MainMenuGameComponent.st2_x1)
                    {
                        MainMenuGameComponent.st2_dir = -MainMenuGameComponent.st2_dir;
                    }
                }
                else
                {
                    if (MainMenuGameComponent.st2_x < MainMenuGameComponent.st2_x1)
                    {
                        MainMenuGameComponent.st2_dir = -MainMenuGameComponent.st2_dir;
                    }
                }
            }

            int sel = selection;
            int max = kitty_unlocked ? 2 : 1;

            if (selection > 0 && Input.get_u())
                selection--;
            else if (selection < max && Input.get_d())
                selection++;

            if (sel != selection)
                Sound.play(Sound.bink);

            if (Input.get_a())
            {
                if (selection == 0)
                {
                    if (Bobby_Game.music_enabled)
                    {
                        Sound.stop_menu_music();
                    }
                    Bobby_Game.music_enabled = !Bobby_Game.music_enabled;
                    if (Bobby_Game.music_enabled)
                    {
                        Sound.play_menu_music();
                    }
                    Sound.play(Sound.bink);
                }
                else if (selection == 1)
                {
                    Bobby_Game.sound_enabled = !Bobby_Game.sound_enabled;
                    Sound.play(Sound.bink);
                }
                else
                {
                    Bobby_Game.kitty_enabled = !Bobby_Game.kitty_enabled;
                    Sound.play(Sound.bink);
                }
            }

            if (Input.get_b())
            {
                Sound.play(Sound.bink);
                game.add_mainmenugamecomponent();
                return;
            }

            base.Update(gameTime);
        }

        public override void Draw(GameTime gameTime)
        {
            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);

            spriteBatch.Draw(bg_bmp, new Vector2(0, 0), Color.White);

            spriteBatch.Draw(space2_bmp, new Rectangle((int)MainMenuGameComponent.st1_x, (int)MainMenuGameComponent.st1_y, (int)(space2_bmp.Width * MainMenuGameComponent.st1_scale), (int)(space2_bmp.Height * MainMenuGameComponent.st1_scale)), Color.White);
            spriteBatch.Draw(space1_bmp, new Rectangle((int)MainMenuGameComponent.st2_x, (int)MainMenuGameComponent.st2_y, (int)(space1_bmp.Width * MainMenuGameComponent.st2_scale), (int)(space1_bmp.Height * MainMenuGameComponent.st2_scale)), Color.White);

            spriteBatch.Draw(menu_bmp, new Vector2(0, 0), Color.White);

            int xx1 = 80;//480 - ((int)game.font.MeasureString("ToggleBack").X + 80) / 2;
            int xx2 = xx1 + 50 + (int)game.font.MeasureString("Toggle").X;
            int yy = 640 - (int)game.font.MeasureString("ToggleBack").Y - 20;
            spriteBatch.Draw(a_bmp, new Vector2(xx1, yy + 5), Color.White);
            spriteBatch.DrawString(game.font, "Toggle", new Vector2(xx1 + 30, yy), Color.White);
            spriteBatch.Draw(b_bmp, new Vector2(xx2, yy + 5), Color.White);
            spriteBatch.DrawString(game.font, "Back", new Vector2(xx2 + 30, yy), Color.White);
            int xx = 960 - 80 - (80 + (int)game.font.MeasureString("OnOff").X);
            spriteBatch.Draw(orange_icon, new Vector2(xx, yy+5), Color.White);
            spriteBatch.DrawString(game.font, "On", new Vector2(xx + 30, yy), Color.White);
            xx += 50 + (int)game.font.MeasureString("On").X;
            spriteBatch.Draw(blue_icon, new Vector2(xx, yy+5), Color.White);
            spriteBatch.DrawString(game.font, "Off", new Vector2(xx + 30, yy), Color.White);

            Texture2D t1 = Bobby_Game.music_enabled ? orange_button_bmp : blue_button_bmp;
            Texture2D t2 = Bobby_Game.sound_enabled ? orange_button_bmp : blue_button_bmp;
            Texture2D t3 = Bobby_Game.kitty_enabled ? orange_button_bmp : blue_button_bmp;

            spriteBatch.Draw(t1, new Vector2(576, 345), Color.White);
            spriteBatch.Draw(t2, new Vector2(576, 412), Color.White);
            spriteBatch.Draw(music_bmp, new Vector2(576 + blue_button_bmp.Width / 2 - music_bmp.Width / 2, 350), Color.White);
            spriteBatch.Draw(sounds_bmp, new Vector2(576 + blue_button_bmp.Width / 2 - sounds_bmp.Width / 2, 417), Color.White);

            if (kitty_unlocked)
            {
                spriteBatch.Draw(t3, new Vector2(576, 481), Color.White);
                spriteBatch.Draw(kitty_bmp, new Vector2(576 + blue_button_bmp.Width / 2 - kitty_bmp.Width / 2, 486), Color.White);
            }

            spriteBatch.Draw(selector_bmp, new Vector2(576 - selector_bmp.Width, 347 + (selection * 67)), Color.White);
            spriteBatch.Draw(selector_bmp, new Vector2(576 + blue_button_bmp.Width, 347 + (selection * 67)), null, Color.White, 0.0f, new Vector2(0.0f, 0.0f), new Vector2(1.0f, 1.0f), SpriteEffects.FlipHorizontally, 0.0f);

            spriteBatch.Draw(logo_bmp, new Vector2(370, 60), Color.White);

            // brighten blend logo
            BlendState bs = new BlendState();
            bs.ColorSourceBlend = Blend.One;
            bs.ColorDestinationBlend = Blend.One;
            game.GraphicsDevice.BlendState = bs;
            spriteBatch.Draw(logo_bmp, new Vector2(370, 60), new Color(game.starAlpha, game.starAlpha, game.starAlpha, game.starAlpha));
            bs = new BlendState();
            bs.ColorSourceBlend = Blend.SourceAlpha;
            bs.ColorDestinationBlend = Blend.InverseSourceAlpha;
            game.GraphicsDevice.BlendState = bs;

            spriteBatch.End();

            base.Draw(gameTime);
        }
    }
}
