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
    public class CreditsGameComponent : Microsoft.Xna.Framework.DrawableGameComponent
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
        Texture2D a_bmp;
        SpriteBatch spriteBatch;

        Bobby_Game game;

        public CreditsGameComponent(Game game)
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

            logo_bmp = game.Content.Load<Texture2D>("logo");

            a_bmp = game.Content.Load<Texture2D>("a");

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

            if (Input.get_a())
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

            game.black_overlay(0.6f);

            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);
            spriteBatch.DrawString(game.font, "© 2023 ILLUMINATI NORTH", new Vector2(60, 345), new Color(0xff, 0xd8, 0));
            spriteBatch.DrawString(game.font, "and Studio Dereka", new Vector2(360, 385), new Color(0xff, 0xd8, 0));
            spriteBatch.DrawString(game.font, "Thanks to Oscar Giner and", new Vector2(60, 425), new Color(200, 200, 200));
            spriteBatch.DrawString(game.font, "Kris Asick for level design", new Vector2(60, 465), new Color(200, 200, 200));
            spriteBatch.DrawString(game.font, "Jon Baken for the in-game music", new Vector2(60, 505), new Color(200, 200, 200));
            spriteBatch.DrawString(game.font, "Tony Huisman for the title track", new Vector2(60, 545), new Color(200, 200, 200));
            int xx = 480 - ((int)game.font.MeasureString("OK").X + 30) / 2;
            int yy = 640 - (int)game.font.MeasureString("OK").Y - 20;
            spriteBatch.Draw(a_bmp, new Vector2(xx, yy + 5), Color.White);
            spriteBatch.DrawString(game.font, "OK", new Vector2(xx + 30, yy), Color.White);

            spriteBatch.End();

            base.Draw(gameTime);
        }
    }
}
