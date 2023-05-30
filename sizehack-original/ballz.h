/* constants */

#ifndef PI
#define PI                3.14159265358979323846
#endif

#define LEVEL_W           20                       /* level width in tiles */
#define LEVEL_H           12
#define NUM_LEVELS        16
#define MAX_OBJECTS       (LEVEL_W*LEVEL_H)
#define GRAVITY           0.001
#define THRUST            0.04
#define PLAYER_MASS       4
#define BALL_MASS         2
#define MAX_A             0.01
#define A_DAMP            0.0005
#define MAX_V             1.5
#define V_DAMP            0.002


/* object types */

#define PLAYER   1
#define BALL     2
#define SPIRAL   3
#define WALL     4


/* helper macros */

#define RAD(d)             ((d) * PI / 180.0)
#define FIXANGLE(a)        ftofix(-(a)/360.0*256.0)

#define OBJECTS_COLLIDING(o1, o2) \
	(!(o1.x >= o2.x+16 || o2.x >= o1.x+16 || \
		o1.y >= o2.y+16 || o2.y >= o1.y+16))

#define CLAMP(v,max) \
	if (v < 0.0) { \
		if (v <= -max) \
			v = -max; \
	} \
	else { \
		if (v >= max) \
			v = max; \
	}

#define DAMPEN(x, val) \
	if (x < 0.0) { \
		x += val; \
		if (x > 0.0) x = 0.0; \
	} \
	else if (x > 0.0) { \
		x -= val; \
		if (x < 0.0) x = 0.0; \
	}


/* structures */

typedef struct {
	float x, y;       /* position */
	float angle;      /* angle */
	float vx, vy;     /* velocity */
	float ax, ay;     /* acceleration */
	float mass;
	float scale;      /* 1.0 = full size, used when hitting black hole */
	int type;         /* ball, player, wall, etc */
	int live;         /* alive? */
} OBJECT;

typedef struct {
	char **lines;
	int nlines;
} TEXT;
