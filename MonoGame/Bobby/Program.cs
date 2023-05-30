using System;

namespace Bobby
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>

        public static Bobby_Game game;

        static void Main(string[] args)
        {
            bool windowed = false;

            for (int i = 0; i < args.Length; i++)
            {
                if (args[i].Equals("-windowed") || args[i].Equals("+windowed"))
                {
                    windowed = true;
                    break;
                }
            }

            using (game = new Bobby_Game(windowed))
            {
                game.Run();
            }
        }
    }
}

