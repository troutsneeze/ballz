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


namespace Bobby
{
    /// <summary>
    /// This is a game component that implements IUpdateable.
    /// </summary>
    public class MainMenuGameComponent : Microsoft.Xna.Framework.DrawableGameComponent
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
        public static float st1_x, st1_y, st1_scale;
        public static int st1_dir;

        public const int st2_x1 = 90;
        public const int st2_y1 = 400;
        public const int st2_x2 = 0;
        public const int st2_y2 = 450;
        public const float st2_scale1 = 0.5f;
        public const float st2_scale2 = 1.0f;
        public const float st2_xinc = (st2_x2 - st2_x1) / 30.0f / 4.0f;
        public const float st2_yinc = (st2_y2 - st2_y1) / 30.0f / 4.0f;
        public const float st2_scaleinc = (st2_scale2 - st2_scale1) / 30.0f / 4.0f;
        public static float st2_x, st2_y, st2_scale;
        public static int st2_dir;

        Texture2D menu_bmp, bg_bmp, space1_bmp, space2_bmp;
        Texture2D blue_button_bmp, continue_bmp, settings_bmp, credits_bmp, logo_bmp;
        Texture2D selector_bmp;
        Texture2D a_bmp, y_bmp;
        SpriteBatch spriteBatch;

        int selection = 0;

        Bobby_Game game;

        public MainMenuGameComponent(Game game)
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
            menu_bmp = game.Content.Load<Texture2D>("menu-image");
            bg_bmp = game.Content.Load<Texture2D>("bg1");
            space1_bmp = game.Content.Load<Texture2D>("images2");
            space2_bmp = game.Content.Load<Texture2D>("images5");

            blue_button_bmp = game.Content.Load<Texture2D>("blue_button");
            continue_bmp = game.Content.Load<Texture2D>("continue_txt");
            settings_bmp = game.Content.Load<Texture2D>("settings_txt");
            credits_bmp = game.Content.Load<Texture2D>("credits_txt");
            logo_bmp = game.Content.Load<Texture2D>("logo");

            selector_bmp = game.Content.Load<Texture2D>("selection_arrow");

            a_bmp = game.Content.Load<Texture2D>("a");
            y_bmp = game.Content.Load<Texture2D>("y");

            base.LoadContent();
        }

        /// <summary>
        /// Allows the game component to update itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        public override void Update(GameTime gameTime)
        {
            game.updateStarAlpha();

            if (st1_dir == 1)
            {
                st1_x += st1_xinc;
                st1_y += st1_yinc;
                st1_scale += st1_scaleinc;
                if (st1_xinc < 0)
                {
                    if (st1_x < st1_x2)
                    {
                        st1_dir = -st1_dir;
                    }
                }
                else
                {
                    if (st1_x > st1_x2)
                    {
                        st1_dir = -st1_dir;
                    }
                }
            }
            else
            {
                st1_x -= st1_xinc;
                st1_y -= st1_yinc;
                st1_scale -= st1_scaleinc;
                if (st1_xinc < 0)
                {
                    if (st1_x > st1_x1)
                    {
                        st1_dir = -st1_dir;
                    }
                }
                else
                {
                    if (st1_x < st1_x1)
                    {
                        st1_dir = -st1_dir;
                    }
                }
            }
            if (st2_dir == 1)
            {
                st2_x += st2_xinc;
                st2_y += st2_yinc;
                st2_scale += st2_scaleinc;
                if (st2_xinc < 0)
                {
                    if (st2_x < st2_x2)
                    {
                        st2_dir = -st2_dir;
                    }
                }
                else
                {
                    if (st2_x > st2_x2)
                    {
                        st2_dir = -st2_dir;
                    }
                }
            }
            else
            {
                st2_x -= st2_xinc;
                st2_y -= st2_yinc;
                st2_scale -= st2_scaleinc;
                if (st2_xinc < 0)
                {
                    if (st2_x > st2_x1)
                    {
                        st2_dir = -st2_dir;
                    }
                }
                else
                {
                    if (st2_x < st2_x1)
                    {
                        st2_dir = -st2_dir;
                    }
                }
            }

            int sel = selection;

            if (selection > 0 && Input.get_u())
                selection--;
            else if (selection < 2 && Input.get_d())
                selection++;

            if (sel != selection)
                Sound.play(Sound.bink);

            if (Input.get_a())
            {
                Sound.play(Sound.bink);
                if (selection == 0)
                {
                    game.add_levelselectgamecomponent();
                    return;
                }
                else if (selection == 1)
                {
                    game.add_settingsgamecomponent();
                    return;
                }
                else if (selection == 2)
                {
                    game.add_creditsgamecomponent();
                    return;
                }
            }
            else if (Input.get_y())
            {
                Sound.play(Sound.bink);
                game.add_helpgamecomponent();
                return;
            }

            base.Update(gameTime);
        }

        public override void Draw(GameTime gameTime)
        {
            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);

            spriteBatch.Draw(bg_bmp, new Vector2(0, 0), Color.White);

            spriteBatch.Draw(space2_bmp, new Rectangle((int)st1_x, (int)st1_y, (int)(space2_bmp.Width * st1_scale), (int)(space2_bmp.Height * st1_scale)), Color.White);
            spriteBatch.Draw(space1_bmp, new Rectangle((int)st2_x, (int)st2_y, (int)(space1_bmp.Width * st2_scale), (int)(space1_bmp.Height * st2_scale)), Color.White);

            spriteBatch.Draw(menu_bmp, new Vector2(0, 0), Color.White);

            int xx = 480 - ((int)game.font.MeasureString("SelectHelpBackQuit").X + 110) / 2;
            int xx2 = xx + 50 + (int)game.font.MeasureString("Select").X;
            int xx3 = xx2 + 50 + (int)game.font.MeasureString("Help").X;
            int yy = 640 - (int)game.font.MeasureString("Select").Y - 20;
            spriteBatch.Draw(a_bmp, new Vector2(xx, yy + 5), Color.White);
            spriteBatch.DrawString(game.font, "Select", new Vector2(xx + 30, yy), Color.White);
            spriteBatch.Draw(y_bmp, new Vector2(xx2, yy + 5), Color.White);
            spriteBatch.DrawString(game.font, "Help", new Vector2(xx2 + 30, yy), Color.White);
            spriteBatch.DrawString(game.font, "Back", new Vector2(xx3, yy), Color.SteelBlue);
            spriteBatch.DrawString(game.font, "Quit", new Vector2(xx3 + 10 + (int)game.font.MeasureString("Back").X, yy), Color.White);

            spriteBatch.Draw(blue_button_bmp, new Vector2(576, 345), Color.White);
            spriteBatch.Draw(blue_button_bmp, new Vector2(576, 412), Color.White);
            spriteBatch.Draw(blue_button_bmp, new Vector2(576, 481), Color.White);
            spriteBatch.Draw(continue_bmp, new Vector2(576 + blue_button_bmp.Width / 2 - continue_bmp.Width / 2, 350), Color.White);
            spriteBatch.Draw(settings_bmp, new Vector2(576 + blue_button_bmp.Width / 2 - settings_bmp.Width / 2, 417), Color.White);
            spriteBatch.Draw(credits_bmp, new Vector2(576 + blue_button_bmp.Width / 2 - credits_bmp.Width / 2, 486), Color.White);

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
            game.GraphicsDevice.BlendState = bs;

            spriteBatch.End();

            base.Draw(gameTime);
        }
    }
}
