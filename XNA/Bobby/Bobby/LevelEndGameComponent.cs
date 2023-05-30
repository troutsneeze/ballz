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
    public class LevelEndGameComponent : Microsoft.Xna.Framework.DrawableGameComponent
    {
        Bobby_Game game;
        Texture2D a_bmp, y_bmp, star_bmp;
        SpriteBatch spriteBatch;
        bool is_best;

        public LevelEndGameComponent(Game game)
            : base(game)
        {
            this.game = (Bobby_Game)game;

            is_best = Bobby_Game.last_time <= Bobby_Game.best_times[Bobby_Game.last_level];
            if (Bobby_Game.last_stars != 3)
                is_best = false;
        }

        void maybe_save_best()
        {
            if (is_best)
            {
                Bobby_Game.best_times[Bobby_Game.last_level] = Bobby_Game.last_time;
            }
        }

        /// <summary>
        /// Allows the game component to perform any initialization it needs to before starting
        /// to run.  This is where it can query for any required services and load content.
        /// </summary>
        public override void Initialize()
        {
            // TODO: Add your initialization code here

            base.Initialize();
        }

        protected override void LoadContent()
        {
            spriteBatch = new SpriteBatch(game.GraphicsDevice);

            a_bmp = game.Content.Load<Texture2D>("data/a");
            y_bmp = game.Content.Load<Texture2D>("data/y");
            star_bmp = game.Content.Load<Texture2D>("data/star");

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
                maybe_save_best();
                Sound.play(Sound.bink);
                game.add_levelselectgamecomponent();
                return;
            }
            else if (Input.get_y())
            {
                maybe_save_best();
                Sound.play(Sound.bink);
                game.add_maingamecomponent(Bobby_Game.last_level);
                return;
            }

            game.updateStarAlpha();

            base.Update(gameTime);
        }

        public override void Draw(GameTime gameTime)
        {
            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);

            TimeSpan t = Bobby_Game.best_times[Bobby_Game.last_level];
            string best_time = String.Format("{0:00}:{1:00}:{2:00}", t.Hours, t.Minutes, t.Seconds);
            bool is_best = Bobby_Game.last_time <= t;
            t = Bobby_Game.last_time;
            string your_time = String.Format("{0:00}:{1:00}:{2:00}", t.Hours, t.Minutes, t.Seconds);
            if (is_best)
                your_time += "!";

            string label1 = "Best time:";
            string label2 = "Your time:";

            if (Bobby_Game.last_stars == 3)
            {
                spriteBatch.DrawString(game.font, label1, new Vector2(480 - (int)game.font.MeasureString(label1).X - 10, 200), Color.White);
                spriteBatch.DrawString(game.font, best_time, new Vector2(490, 200), Color.White);
                spriteBatch.DrawString(game.font, label2, new Vector2(480 - (int)game.font.MeasureString(label2).X - 10, 230), Color.White);
                spriteBatch.DrawString(game.font, your_time, new Vector2(490, 230), is_best ? Color.LimeGreen : Color.Gray);
            }
            else
            {
                string s1 = "Not qualified for best time";
                spriteBatch.DrawString(game.font, s1, new Vector2(480 - (int)game.font.MeasureString(s1).X / 2, 210), Color.White);
            }

            string b1 = "OK";
            string b2 = "Retry";
            int x1 = 480 - ((int)game.font.MeasureString(b1 + b2).X + 80) / 2;
            int x2 = x1 + 50 + (int)game.font.MeasureString(b1).X;
            int yy = 640 - (int)game.font.MeasureString(b1 + b2).Y - 20;

            spriteBatch.Draw(a_bmp, new Vector2(x1, yy + 5), Color.White);
            spriteBatch.Draw(y_bmp, new Vector2(x2, yy + 5), Color.White);
            spriteBatch.DrawString(game.font, b1, new Vector2(x1 + 30, yy), Color.White);
            spriteBatch.DrawString(game.font, b2, new Vector2(x2 + 30, yy), Color.White);

            int w = star_bmp.Width * Bobby_Game.last_stars;

            if (w > 0)
            {
                for (int i = 0; i < Bobby_Game.last_stars; i++)
                {
                    spriteBatch.Draw(star_bmp, new Vector2(480 - w / 2 + i * star_bmp.Width, 50), Color.White);
                }
                BlendState bs = new BlendState();
                bs.ColorSourceBlend = Blend.One;
                bs.ColorDestinationBlend = Blend.One;
                game.GraphicsDevice.BlendState = bs;
                for (int i = 0; i < Bobby_Game.last_stars; i++)
                {
                    // brighten blend stars
                    spriteBatch.Draw(star_bmp, new Vector2(480 - w / 2 + i * star_bmp.Width, 50), new Color(game.starAlpha, game.starAlpha, game.starAlpha, game.starAlpha));
                }
                bs = new BlendState();
                game.GraphicsDevice.BlendState = bs;
            }
            else
            {
                spriteBatch.DrawString(game.font, "Zero Stars", new Vector2(480 - (int)game.font.MeasureString("Zero Stars").X / 2, 50), Color.Red);
            }

            spriteBatch.End();

            base.Draw(gameTime);
        }
    }
}
