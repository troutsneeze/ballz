using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Bobby
{
    public class Entity
    {
        public float x, y;       /* position */
        public float angle;      /* angle */
        public float vx, vy;     /* velocity */
        public float ax, ay;     /* acceleration */
        public float mass;
        public float scale;      /* 1.0 = full size, used when hitting black hole */
        public int type;         /* ball, player, wall, etc */
        public int live;         /* alive? */
        public int groups;
        public int tx, ty;
        public int hit_time;
        public bool ignore_coll;

        public Entity klone()
        {
            return (Entity)MemberwiseClone();
        }
    }
}
