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
    public class StoryGameComponent : Microsoft.Xna.Framework.DrawableGameComponent
    {
        Texture2D bg;
        Bobby_Game game;
        SpriteBatch spriteBatch;
        static bool menu_music_played = false;

        float y;
        int counter;

        public StoryGameComponent(Game game)
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
            y = 640.0f;

            spriteBatch = new SpriteBatch(game.GraphicsDevice);

            base.Initialize();
        }

        protected override void LoadContent()
        {
            bg = game.Content.Load<Texture2D>("story");

            base.LoadContent();
        }

        /// <summary>
        /// Allows the game component to update itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        public override void Update(GameTime gameTime)
        {
            counter++;

            if (y > 200-64)
                y -= 0.25f;
            else
                y = 200-64;

            for (PlayerIndex p = PlayerIndex.One; p <= PlayerIndex.Four; p++)
            {
                if (GamePad.GetState(p).Buttons.Start == ButtonState.Pressed)
                {
                    //while (GamePad.GetState(p).Buttons.Start == ButtonState.Pressed)
                        ;
                    if (!menu_music_played)
                    {
                        menu_music_played = true;
                        Sound.play_menu_music();
                    }
                    game.player_index = p;
                    game.player_index_set = true;
                    Sound.play(Sound.bink);
                    game.add_helpgamecomponent();
                    return;
                }
            }

            base.Update(gameTime);
        }

        public override void Draw(GameTime gameTime)
        {
            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);
            spriteBatch.Draw(bg, new Rectangle(0, 0, 960, bg.Height * 2), Color.White);
            int yy = 50;
            int xx = 960 - (int)game.font.MeasureString("Press Start").X - 60;
            int c = counter % 256;
            if (c >= 128)
                c = 255 - c;
            spriteBatch.DrawString(game.font, "Press Start", new Vector2(xx, yy), new Color(c+128, c+128, c+128));
            spriteBatch.End();

            Rectangle backup = game.GraphicsDevice.ScissorRectangle;
            float xratio = game.GraphicsDevice.Viewport.Width / 960.0f;
            float yratio = game.GraphicsDevice.Viewport.Height / 640.0f;

            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend, SamplerState.LinearClamp, DepthStencilState.None, RasterizerState.CullNone, game.effect);
            
            RasterizerState rs = new RasterizerState();
            rs.ScissorTestEnable = true;
            game.GraphicsDevice.RasterizerState = rs;
            game.GraphicsDevice.ScissorRectangle = new Rectangle(0, (int)((bg.Height * 2) * yratio) + 1, (int)(960 * xratio), (int)((640 - bg.Height * 2) * yratio));

            spriteBatch.DrawString(game.font, "Your name is Bobby the", new Vector2(100, y), Color.White);
            spriteBatch.DrawString(game.font, "Bullet Dude. Your mission", new Vector2(100, y + 32), Color.White);
            spriteBatch.DrawString(game.font, "is to bounce all of the", new Vector2(100, y + 64), Color.White);
            spriteBatch.DrawString(game.font, "Evil Green Ball Guys into", new Vector2(100, y + 96), Color.White);
            spriteBatch.DrawString(game.font, "the Hypnotic Spiral of", new Vector2(100, y + 128), Color.White);
            spriteBatch.DrawString(game.font, "Death. Once you have done", new Vector2(100, y + 160), Color.White);
            spriteBatch.DrawString(game.font, "this, the Hypnotic Spiral", new Vector2(100, y + 192), Color.White);
            spriteBatch.DrawString(game.font, "of Death will turn into a", new Vector2(100, y + 224), Color.White);
            spriteBatch.DrawString(game.font, "Happy Portal to the Next", new Vector2(100, y + 256), Color.White);
            spriteBatch.DrawString(game.font, "Dimension. Follow the", new Vector2(100, y + 288), Color.White);
            spriteBatch.DrawString(game.font, "Happy Portal until there", new Vector2(100, y + 320), Color.White);
            spriteBatch.DrawString(game.font, "are no more Green Guys.", new Vector2(100, y + 352), Color.White);
            spriteBatch.DrawString(game.font, "That is all.", new Vector2(480-game.font.MeasureString("That is all.").X/2, y+448), Color.White);

            game.GraphicsDevice.ScissorRectangle = backup;
            rs = new RasterizerState();
            rs.ScissorTestEnable = false;
            game.GraphicsDevice.RasterizerState = rs;

            spriteBatch.End();

            game.effect.TextureEnabled = false;
            VertexPositionColor[] v = new VertexPositionColor[4];
            v[0] = new VertexPositionColor();
            v[0].Position = new Vector3(0, bg.Height*2, 0);
            v[0].Color = Color.Black;
            v[1] = new VertexPositionColor();
            v[1].Position = new Vector3(960, bg.Height*2, 0);
            v[1].Color = Color.Black;
            v[2] = new VertexPositionColor();
            v[2].Position = new Vector3(0, bg.Height*2+20, 0);
            v[2].Color = new Color(0, 0, 0, 0);
            v[3] = new VertexPositionColor();
            v[3].Position = new Vector3(960, bg.Height*2+20, 0);
            v[3].Color = new Color(0, 0, 0, 0);
            foreach (EffectPass pass in game.effect.CurrentTechnique.Passes)
            {
                pass.Apply();
                game.GraphicsDevice.DrawUserPrimitives<VertexPositionColor>(PrimitiveType.TriangleStrip, v, 0, 2);
            }
            game.effect.TextureEnabled = true;

            base.Draw(gameTime);
        }
    }
}
