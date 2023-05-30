/* constants */

#include <math.h>

#define PI M_PI

#define LOGIC_PER_SEC 120.0f
#define SPEED_MULT (100.0/LOGIC_PER_SEC)


#define PAUSE_SIZE        64
#define TILE_SIZE         48
#define LEVEL_W           20                       /* level width in tiles */
#define LEVEL_H           12

#ifndef LITE
#define NUM_LEVELS        75
#else
#define NUM_LEVELS        20
#endif

#define MAX_OBJECTS       (LEVEL_W*LEVEL_H)
#define GRAVITY           (0.00075*SPEED_MULT)
#define FAN_FORCE         (1.0*SPEED_MULT)
#define MAGNET_FORCE      (0.1*SPEED_MULT)
#define THRUST            (0.2*SPEED_MULT)
#define PLAYER_MASS       9
#define BALL_MASS         3
#define HEAVY_BALL_MASS   10
#define MAX_A             0.02
#define A_DAMP            (0.0007*SPEED_MULT)
#define MAX_V             3.0
#define MAX_GRAVITY_V     1.0
#define V_DAMP            (0.002*SPEED_MULT)


/* object types */

#define EMPTY       '0'
#define PLAYER      '1'
#define BALL        '2'
#define SPIRAL      '3'
#define WALL        '4'
#define FAN_LEFT    '5'
#define FAN_RIGHT   '6'
#define FAN_UP      '7'
#define FAN_DOWN    '8'
#define HEAVY_BALL  'h'
#define FAN_SPIN    'f'
#define TRANSPORTER 'x'
#define TOTALLY_EVIL_SPIRAL 'e'
#define TOTALLY_GOOD_SPIRAL 'g'
#define SWITCH1     's'
#define SWITCH2     'S'
#define GATE1       '|'
#define GATE2       '-'
#define BOUNCY_WALL 'b'
#define UNBOUNCY_WALL 'u'
#define MIAO_BALL   'k'
#define MAGNET      'm'


/* helper macros */

#define RAD(d)             ((d) * PI / 180.0)
#define DEG(r)             ((r) / PI * 180.0)

#define OBJECTS_COLLIDING(o1, o2) \
	(!(o1.x+4 > o2.x+TILE_SIZE-4 || o1.y+4 > o2.y+TILE_SIZE-4 || \
	o1.x+TILE_SIZE-4 < o2.x+4 || o1.y+TILE_SIZE-4 < o2.y+4))

#define WALL_COLLIDING(o1, o2) \
	(!(o1.x+4 > o2.x+TILE_SIZE || o1.y+4 > o2.y+TILE_SIZE || \
	o1.x+TILE_SIZE-4 < o2.x || o1.y+TILE_SIZE-4 < o2.y))


#define POINT_IN_BOX(x, y, x1, y1, w, h) \
    ((x) >= (x1) && (x) < (x1)+(w) && (y) >= (y1) && (y) < (y1)+(h))

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
		x += val * brake_multiplier; \
		if (x > 0.0) x = 0.0; \
	} \
	else if (x > 0.0) { \
		x -= val * brake_multiplier; \
		if (x < 0.0) x = 0.0; \
	}

#define sb(s) \
	al_draw_scaled_bitmap(s, 0, 0, \
		al_get_bitmap_width(s), al_get_bitmap_height(s) \
		0, 0, \
		al_get_bitmap_width(al_get_target_bitmap()), \
		al_get_bitmap_height(al_get_target_bitmap()))

/* structures */

#define ALL_WALLS               1
#define ALL_BALLS               2
#define ALL_FANS                4
#define ALL_BOUNCY              8
#define ALL_SPIRALS            16
#define ALL_SWITCHES           32
#define ALL_TRANSPORTER        64
#define ALL_TRANSPORTER_START 128
#define ALL_TRANSPORTER_END   256
#define ALL_GATES             512
#define OTHER                1024

#define LOCK_NONE 0
#define LOCK_VERTICAL 1
#define LOCK_HORIZONTAL 2

typedef struct {
	float x, y;       /* position */
	float angle;      /* angle */
	float vx, vy;     /* velocity */
	float ax, ay;     /* acceleration */
	float mass;
	float scale;      /* 1.0 = full size, used when hitting black hole */
	int type;         /* ball, player, wall, etc */
	int live;         /* alive? */
	int groups;
	int tx, ty;
	double hit_time;
	bool ignore_coll;
} OBJECT;

typedef struct {
	char **lines;
	int nlines;
} TEXT;
