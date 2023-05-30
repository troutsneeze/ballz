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
    public class NeedProfileGameComponent : Microsoft.Xna.Framework.DrawableGameComponent
    {
        Texture2D a_bmp;
        Texture2D b_bmp;
        Bobby_Game game;
        SpriteBatch spriteBatch;

        public NeedProfileGameComponent(Game game)
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
            a_bmp = game.Content.Load<Texture2D>("data/a");
            b_bmp = game.Content.Load<Texture2D>("data/b");

            base.LoadContent();
        }

        /// <summary>
        /// Allows the game component to update itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        public override void Update(GameTime gameTime)
        {
            if (Input.get_b())
            {
                Sound.play(Sound.bink);
                game.restore_backupgamecomponent2();
                return;
            }
            else if (Input.get_a())
            {
                Guide.ShowSignIn(1, false);
                game.restore_backupgamecomponent2();
                return;
            }

            base.Update(gameTime);
        }

        public override void Draw(GameTime gameTime)
        {
            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);
            string s = "You need to be signed in to a";
            string s2 = "Gamer Profile to do that";
            int height = (int)game.font.MeasureString(s + s2).Y;
            spriteBatch.DrawString(game.font, s, new Vector2(480 - ((int)game.font.MeasureString(s).X / 2), 320 - height), new Color(255, 50, 50));
            spriteBatch.DrawString(game.font, s2, new Vector2(480 - ((int)game.font.MeasureString(s2).X / 2), 320), new Color(255, 50, 50));
            int len = (int)game.font.MeasureString("Sign inBack").X + 80;
            int yy = 640 - (int)game.font.MeasureString("OK").Y - 20;
            spriteBatch.Draw(a_bmp, new Vector2(480 - len / 2, yy + 5), Color.White);
            spriteBatch.DrawString(game.font, "Sign in", new Vector2(480 - len / 2 + 30, yy), Color.White);
            spriteBatch.Draw(b_bmp, new Vector2(480 - len / 2 + ((int)game.font.MeasureString("Sign in").X + 50), yy + 5), Color.White);
            spriteBatch.DrawString(game.font, "Back", new Vector2(480 - len / 2 + ((int)game.font.MeasureString("Sign in").X + 80), yy), Color.White);
            spriteBatch.End();

            base.Draw(gameTime);
        }
    }
}
