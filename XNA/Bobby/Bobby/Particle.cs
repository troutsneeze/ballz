using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;

namespace Bobby
{
    class Particle
    {
        public float x, y;
        public float vx, vy;
        public int life;
        public Color color;
        public int bmp_index;

        public Particle()
        {
            x = y = vx = vy = life = bmp_index = 0;
            color = Color.White;
        }
    }
}
