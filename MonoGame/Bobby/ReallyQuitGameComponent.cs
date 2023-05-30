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
    public class ReallyQuitGameComponent : Microsoft.Xna.Framework.DrawableGameComponent
    {
        int selected = 0;
        Bobby_Game game;
        SpriteBatch spriteBatch;
        Texture2D selector, a_bmp, b_bmp;
        bool can_purchase;

        public ReallyQuitGameComponent(Game game)
            : base(game)
        {
            this.game = (Bobby_Game)game;
            /*
            foreach (SignedInGamer g in Gamer.SignedInGamers)
            {
                if (g.PlayerIndex == this.game.player_index)
                {
                    can_purchase = g.Privileges.AllowPurchaseContent;
                    break;
                }
            }

            if (!Guide.IsTrialMode || !can_purchase)
                selected = 1;
            */
            selected = 1;
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
            selector = game.Content.Load<Texture2D>("selection_arrow");

            a_bmp = game.Content.Load<Texture2D>("a");
            b_bmp = game.Content.Load<Texture2D>("b");

            base.LoadContent();
        }

        /// <summary>
        /// Allows the game component to update itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        public override void Update(GameTime gameTime)
        {
            if (Input.get_d())
            {
                if (selected < 2)
                {
                    Sound.play(Sound.bink);
                    selected++;
                }
            }
            else if (Input.get_u())
            {
                if (selected > 1)//((Guide.IsTrialMode && can_purchase) ? 0 : 1))
                {
                    Sound.play(Sound.bink);
                    selected--;
                }
            }

            bool a = Input.get_a();
            bool b = Input.get_b();

            if (a || b)
            {
                if (a && selected == 2)
                {
                    game.Exit();
                    return;
                }
                else
                {
                    if (a && selected == 0)
                    {
                        //Guide.ShowMarketplace(game.player_index);
                    }
                    game.restore_backupgamecomponent();
                    return;
                }
            }

            base.Update(gameTime);
        }

        public override void Draw(GameTime gameTime)
        {
            string s1 = "Buy This Game";
            string s2 = "Return to the Game";
            string s3 = "Quit the Game";
            int len1 = (int)game.font.MeasureString(s1).X;
            int len2 = (int)game.font.MeasureString(s2).X;
            int len3 = (int)game.font.MeasureString(s3).X;
            int x1 = 480 - len1 / 2;
            int x2 = 480 - len2 / 2;
            int x3 = 480 - len3 / 2;
            int height = (int)game.font.MeasureString(s1+s2+s3).Y + 10;

            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);
            spriteBatch.DrawString(game.font, "Make Your Choice", new Vector2(480 - (int)game.font.MeasureString("Make Your Choice").X / 2, 320 - 150), new Color(255, 50, 50));

            //if (Guide.IsTrialMode && can_purchase)
              //  spriteBatch.DrawString(game.font, s1, new Vector2(x1, 320 - height * 3 / 2), Color.White);

            spriteBatch.DrawString(game.font, s2, new Vector2(x2, 320 - height / 2), Color.White);
            spriteBatch.DrawString(game.font, s3, new Vector2(x3, 320 + height / 2), Color.White);
            int xx;
            int ll;
            if (selected == 0)
            {
                xx = x1;
                ll = len1;
            }
            else if (selected == 1)
            {
                xx = x2;
                ll = len2;
            }
            else
            {
                xx = x3;
                ll = len3;
            }
            int yy = -height + (selected * height);

            spriteBatch.Draw(selector, new Vector2(xx - selector.Width, 320 + yy - selector.Height / 2), Color.White);
            spriteBatch.Draw(selector, new Vector2(xx + ll, 320 + yy - selector.Height / 2), null, Color.White, 0.0f, new Vector2(0, 0), 1.0f, SpriteEffects.FlipHorizontally, 0.0f);

            int w1 = (int)game.font.MeasureString("Select").X + 30;
            int w2 = (int)game.font.MeasureString("Back").X + 30;
            int w = w1 + w2 + 20;
            yy = 640 - (int)game.font.MeasureString("SelectBack").Y - 20;
            spriteBatch.Draw(a_bmp, new Vector2(480 - w / 2, yy + 5), Color.White);
            spriteBatch.DrawString(game.font, "Select", new Vector2(480 - w / 2 + 30, yy), Color.White);
            spriteBatch.Draw(b_bmp, new Vector2(480 - w / 2 + w1 + 20, yy + 5), Color.White);
            spriteBatch.DrawString(game.font, "Back", new Vector2(480 - w / 2 + 30 + w1 + 20, yy), Color.White);
            spriteBatch.End();

            base.Draw(gameTime);
        }
    }
}

