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
    public class HelpGameComponent : Microsoft.Xna.Framework.DrawableGameComponent
    {
        Texture2D logo;
        Texture2D a_bmp, b_bmp, x_bmp, y_bmp;
        Bobby_Game game;
        SpriteBatch spriteBatch;

        public HelpGameComponent(Game game)
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
            logo = game.Content.Load<Texture2D>("logo");

            a_bmp = game.Content.Load<Texture2D>("a");
            b_bmp = game.Content.Load<Texture2D>("b");
            x_bmp = game.Content.Load<Texture2D>("x");
            y_bmp = game.Content.Load<Texture2D>("y");

            base.LoadContent();
        }

        /// <summary>
        /// Allows the game component to update itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        public override void Update(GameTime gameTime)
        {
            if (Input.get_a())
            {
                Sound.play(Sound.bink);
                game.add_mainmenugamecomponent();
                return;
            }

            game.updateStarAlpha();

            base.Update(gameTime);
        }

        public override void Draw(GameTime gameTime)
        {
            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);

            int w = (int)game.font.MeasureString("Left & Right turns").X;
            spriteBatch.DrawString(game.font, "Left & Right turns", new Vector2(480 - w / 2, (35 * 1) + logo.Height), Color.White);

            w = (int)game.font.MeasureString("Thrust forward").X + 30;
            spriteBatch.Draw(a_bmp, new Vector2(480 - w / 2, (35 * 2) + logo.Height + 5), Color.White);
            spriteBatch.DrawString(game.font, "Thrust forward", new Vector2(480 - w / 2 + 30, (35 * 2) + logo.Height), Color.White);
            
            w = (int)game.font.MeasureString("Hit the brakes").X + 30;
            spriteBatch.Draw(b_bmp, new Vector2(480 - w / 2, (35 * 3) + logo.Height + 5), Color.White);
            spriteBatch.DrawString(game.font, "Hit the brakes", new Vector2(480 - w / 2 + 30, (35 * 3) + logo.Height), Color.White);

            int w2 = (int)game.font.MeasureString("Shoulders").X + 10;
            w = (int)game.font.MeasureString("Rotate 90 degrees").X + w2;
            spriteBatch.DrawString(game.font, "Shoulders", new Vector2(480 - w / 2, (35 * 4) + logo.Height), Color.SteelBlue);
            spriteBatch.DrawString(game.font, "Rotate 90 degrees", new Vector2(480 - w / 2 + w2, (35 * 4) + logo.Height), Color.White);

            w2 = (int)game.font.MeasureString("Start").X + 10;
            w = (int)game.font.MeasureString("Pause the game").X + w2;
            spriteBatch.DrawString(game.font, "Start", new Vector2(480 - w / 2, (35 * 5) + logo.Height), Color.SteelBlue);
            spriteBatch.DrawString(game.font, "Pause the game", new Vector2(480 - w / 2 + w2, (35 * 5) + logo.Height), Color.White);

            w = (int)game.font.MeasureString("* Enter the Green Portals *").X;
            spriteBatch.DrawString(game.font, "* Enter the Green Portals *", new Vector2(480 - w / 2, (35 * 6) + logo.Height), Color.LimeGreen);

            int yy = 640 - (int)game.font.MeasureString("OK").Y - 20;
            int xx = 480 - ((int)game.font.MeasureString("OK").X + 30) / 2;
            spriteBatch.Draw(a_bmp, new Vector2(xx, yy+5), Color.White);
            spriteBatch.DrawString(game.font, "OK", new Vector2(xx + 30, yy), Color.White);

            // brighten blend logo
            spriteBatch.Draw(logo, new Vector2(480 - logo.Width / 2, 20), Color.White);
            BlendState bs = new BlendState();
            bs.ColorSourceBlend = Blend.One;
            bs.ColorDestinationBlend = Blend.One;
            game.GraphicsDevice.BlendState = bs;
            spriteBatch.Draw(logo, new Vector2(480 - logo.Width / 2, 20), new Color(game.starAlpha, game.starAlpha, game.starAlpha, game.starAlpha));
            bs = new BlendState();
            game.GraphicsDevice.BlendState = bs;

            spriteBatch.End();

            base.Draw(gameTime);
        }
    }
}
