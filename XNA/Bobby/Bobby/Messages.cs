using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.GamerServices;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Microsoft.Xna.Framework.Media;

namespace Bobby
{
    class Messages
    {
        struct Message
        {
            public float x;
            public string message;
        }

        static List<Message> messages = new List<Message>();

        public static void add_message(string s)
        {
            Message m;
            m.x = 960;
            m.message = s;

            messages.Add(m);
        }

        public static void draw(SpriteBatch b, SpriteFont font)
        {
            if (messages.Count > 0)
            {
                b.DrawString(font, messages[0].message, new Vector2(messages[0].x, 10), Color.Yellow);
                Message m = messages[0];
                messages.RemoveAt(0);
                m.x -= 5.0f;
                if (!(m.x < -font.MeasureString(m.message).X))
                {
                    messages.Insert(0, m);
                }
            }
        }
    }
}
