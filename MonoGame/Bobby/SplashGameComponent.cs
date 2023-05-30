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
    public class SplashGameComponent : Microsoft.Xna.Framework.DrawableGameComponent
    {
        Texture2D nooskewl, dereka;
        Bobby_Game game;
        int count = 0;
        const int SCR_W = 960;
        const int SCR_H = 640;
        SpriteBatch spriteBatch;

        public SplashGameComponent(Game game)
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
            nooskewl = game.Content.Load<Texture2D>("nooskewl_square");
            dereka = game.Content.Load<Texture2D>("dereka");

            base.LoadContent();
        }

        /// <summary>
        /// Allows the game component to update itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        public override void Update(GameTime gameTime)
        {
            count++;
            if (count >= 180)
            {
                this.Enabled = false;
                game.add_storygamecomponent();
                return;
            }

            base.Update(gameTime);
        }

        public override void Draw(GameTime gameTime)
        {
            int section;
            Color c;
            int elapsed = count;
            if (elapsed >= 120)
            {
                section = 2;
                elapsed -= 120;
                c = new Color(0, 0, 0, (float)elapsed/60.0f);
                game.GraphicsDevice.Clear(Color.White);
            }
            else
            {
                if (elapsed >= 60)
                {
                    section = 1;
                    elapsed -= 60;
                }
                else
                    section = 0;
                c = new Color(elapsed/60.0f, elapsed/60.0f, elapsed/60.0f, elapsed/60.0f);
                game.GraphicsDevice.Clear(Color.Black);
            }
            float w = SCR_W / 2;
            int x1 = -nooskewl.Width;
            int x2 = SCR_W;
            if (section == 0)
            {
                spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);

                spriteBatch.Draw(nooskewl, new Rectangle(x1 + (int)(w * (elapsed / 60.0f)), (SCR_H - nooskewl.Height) / 2, nooskewl.Width, nooskewl.Height), c);
                spriteBatch.Draw(dereka, new Rectangle(x2 - (int)(w * (elapsed / 60.0f)), (SCR_H - dereka.Height) / 2, dereka.Width, dereka.Height), c);

                spriteBatch.End();
            }
            else
            {
                if (section == 1)
                {
                    spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);

                    spriteBatch.Draw(nooskewl, new Rectangle(x1 + (int)w, (SCR_H - nooskewl.Height) / 2, nooskewl.Width, nooskewl.Height), Color.White);
                    spriteBatch.Draw(dereka, new Rectangle(x2 - (int)w, (SCR_H - dereka.Height) / 2, dereka.Width, dereka.Height), Color.White);

                    spriteBatch.End();
                }

                VertexPositionColor[] v = new VertexPositionColor[4];
                v[0] = new VertexPositionColor();
                v[0].Position = new Vector3(0, 0, 0);
                v[0].Color = c;
                v[1] = new VertexPositionColor();
                v[1].Position = new Vector3(960, 0, 0);
                v[1].Color = c;
                v[2] = new VertexPositionColor();
                v[2].Position = new Vector3(0, 640, 0);
                v[2].Color = c;
                v[3] = new VertexPositionColor();
                v[3].Position = new Vector3(960, 640, 0);
                v[3].Color = c;

                game.effect.TextureEnabled = false;
                foreach (EffectPass pass in game.effect.CurrentTechnique.Passes)
                {
                    pass.Apply();
                    game.GraphicsDevice.DrawUserPrimitives<VertexPositionColor>(PrimitiveType.TriangleStrip, v, 0, 2);
                }
                game.effect.TextureEnabled = true;
            }

            base.Draw(gameTime);
        }
    }
}
