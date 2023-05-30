using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Input;

namespace Bobby
{
    class Input
    {
        public static GamePadState state = new GamePadState();

        static bool start_down = false;
        static bool a_down = false;
        static bool b_down = false;
        static bool x_down = false;
        static bool y_down = false;
        static bool l_down = false;
        static bool r_down = false;
        static bool u_down = false;
        static bool d_down = false;
        static bool l_analog_down = false;
        static bool r_analog_down = false;
        static bool u_analog_down = false;
        static bool d_analog_down = false;
        static bool lshoulder_down = false;
        static bool rshoulder_down = false;

        static int l_repeat_count = 0;
        static int r_repeat_count = 0;
        static int u_repeat_count = 0;
        static int d_repeat_count = 0;

        public static bool get_start()
        {
            if (start_down)
            {
                if (state.Buttons.Start == ButtonState.Released)
                {
                    start_down = false;
                }
                return false;
            }
            else
            {
                if (state.Buttons.Start == ButtonState.Pressed)
                {
                    start_down = true;
                    return true;
                }
            }

            return false;
        }

        public static bool get_a()
        {
            if (a_down)
            {
                if (state.Buttons.A == ButtonState.Released)
                {
                    a_down = false;
                }
                return false;
            }
            else
            {
                if (state.Buttons.A == ButtonState.Pressed)
                {
                    a_down = true;
                    return true;
                }
            }

            return false;
        }

        public static bool get_b()
        {
            if (b_down)
            {
                if (state.Buttons.B == ButtonState.Released)
                {
                    b_down = false;
                }
                return false;
            }
            else
            {
                if (state.Buttons.B == ButtonState.Pressed)
                {
                    b_down = true;
                    return true;
                }
            }

            return false;
        }

        public static bool get_x()
        {
            if (x_down)
            {
                if (state.Buttons.X == ButtonState.Released)
                {
                    x_down = false;
                }
                return false;
            }
            else
            {
                if (state.Buttons.X == ButtonState.Pressed)
                {
                    x_down = true;
                    return true;
                }
            }

            return false;
        }

        public static bool get_y()
        {
            if (y_down)
            {
                if (state.Buttons.Y == ButtonState.Released)
                {
                    y_down = false;
                }
                return false;
            }
            else
            {
                if (state.Buttons.Y == ButtonState.Pressed)
                {
                    y_down = true;
                    return true;
                }
            }

            return false;
        }

        public static bool get_lshoulder()
        {
            if (lshoulder_down)
            {
                if (state.Buttons.LeftShoulder == ButtonState.Released)
                {
                    lshoulder_down = false;
                }
                return false;
            }
            else
            {
                if (state.Buttons.LeftShoulder == ButtonState.Pressed)
                {
                    lshoulder_down = true;
                    return true;
                }
            }

            return false;
        }

        public static bool get_rshoulder()
        {
            if (rshoulder_down)
            {
                if (state.Buttons.RightShoulder == ButtonState.Released)
                {
                    rshoulder_down = false;
                }
                return false;
            }
            else
            {
                if (state.Buttons.RightShoulder == ButtonState.Pressed)
                {
                    rshoulder_down = true;
                    return true;
                }
            }

            return false;
        }

        public static bool get_l()
        {
            if (l_down || l_analog_down)
            {
                if (l_repeat_count > 0)
                {
                    l_repeat_count--;
                    if (l_repeat_count <= 0)
                    {
                        l_down = l_analog_down = false;
                    }
                }
            }

            return get_ld() || get_la();
        }

        public static bool get_r()
        {
            if (r_down || r_analog_down)
            {
                if (r_repeat_count > 0)
                {
                    r_repeat_count--;
                    if (r_repeat_count <= 0)
                    {
                        r_down = r_analog_down = false;
                    }
                }
            }

            return get_rd() || get_ra();
        }

        public static bool get_u()
        {
            if (u_down || u_analog_down)
            {
                if (u_repeat_count > 0)
                {
                    u_repeat_count--;
                    if (u_repeat_count <= 0)
                    {
                        u_down = u_analog_down = false;
                    }
                }
            }

            return get_ud() || get_ua();
        }

        public static bool get_d()
        {
            if (d_down || d_analog_down)
            {
                if (d_repeat_count > 0)
                {
                    d_repeat_count--;
                    if (d_repeat_count <= 0)
                    {
                        d_down = d_analog_down = false;
                    }
                }
            }

            return get_dd() || get_da();
        }

        // digital
        public static bool get_ld()
        {
            if (l_down)
            {
                if (state.DPad.Left == ButtonState.Released)
                {
                    l_down = false;
                }
                return false;
            }
            else
            {
                if (state.DPad.Left == ButtonState.Pressed)
                {
                    l_down = true;
                    return true;
                }
            }

            return false;
        }

        public static bool get_rd()
        {
            if (r_down)
            {
                if (state.DPad.Right == ButtonState.Released)
                {
                    r_down = false;
                }
                return false;
            }
            else
            {
                if (state.DPad.Right == ButtonState.Pressed)
                {
                    r_down = true;
                    return true;
                }
            }

            return false;
        }
        
        public static bool get_ud()
        {
            if (u_down)
            {
                if (state.DPad.Up == ButtonState.Released)
                {
                    u_down = false;
                }
                return false;
            }
            else
            {
                if (state.DPad.Up == ButtonState.Pressed)
                {
                    u_down = true;
                    return true;
                }
            }

            return false;
        }

        public static bool get_dd()
        {
            if (d_down)
            {
                if (state.DPad.Down == ButtonState.Released)
                {
                    d_down = false;
                }
                return false;
            }
            else
            {
                if (state.DPad.Down == ButtonState.Pressed)
                {
                    d_down = true;
                    return true;
                }
            }

            return false;
        }

        // analog
        public static bool get_la()
        {
            if (l_analog_down)
            {
                if (state.ThumbSticks.Left.X > -0.1f)
                {
                    l_analog_down = false;
                }
                return false;
            }
            else
            {
                if (state.ThumbSticks.Left.X < -0.5f)
                {
                    l_analog_down = true;
                    return true;
                }
            }

            return false;
        }

        public static bool get_ra()
        {
            if (r_analog_down)
            {
                if (state.ThumbSticks.Left.X < 0.1f)
                {
                    r_analog_down = false;
                }
                return false;
            }
            else
            {
                if (state.ThumbSticks.Left.X > 0.5f)
                {
                    r_analog_down = true;
                    return true;
                }
            }

            return false;
        }

        public static bool get_ua()
        {
            if (u_analog_down)
            {
                if (state.ThumbSticks.Left.Y < 0.1f)
                {
                    u_analog_down = false;
                }
                return false;
            }
            else
            {
                if (state.ThumbSticks.Left.Y > 0.5f)
                {
                    u_analog_down = true;
                    return true;
                }
            }

            return false;
        }

        public static bool get_da()
        {
            if (d_analog_down)
            {
                if (state.ThumbSticks.Left.Y > -0.1f)
                {
                    d_analog_down = false;
                }
                return false;
            }
            else
            {
                if (state.ThumbSticks.Left.Y < -0.5f)
                {
                    d_analog_down = true;
                    return true;
                }
            }

            return false;
        }

        public static void l_repeat()
        {
            l_repeat_count = 20;
        }

        public static void r_repeat()
        {
            r_repeat_count = 20;
        }
        
        public static void u_repeat()
        {
            u_repeat_count = 20;
        }
        
        public static void d_repeat()
        {
            d_repeat_count = 20;
        }
    }
}
