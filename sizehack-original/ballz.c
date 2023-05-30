#include <stdio.h>
#include <math.h>
#include <string.h>
#include <allegro.h>

#include "ballz.h"
#include "datnames.h"


DATAFILE *dat;
BITMAP *buf, *wall, *spiral;
OBJECT objs[MAX_OBJECTS];
int nobjs, nballs;
int lives, level, spiral_color, next_time;
volatile int tick = 0;
float spiral_angle;


/*
 * Routines to load and destroy levels from datafiles.
 * Levels are stored 4 bits per tile to save space.
 */
void *load_level(PACKFILE *f, long size)
{
	char *data = malloc(size*2);
	int i, c;

	for (i = 0; i < size; i++) {
		c = pack_getc(f);
		data[i*2] = (c >> 4) & 0xf;
		data[i*2+1] = c & 0xf;
	}
	
	return data;
}

void destroy_level(void *data)
{
	free(data);
}


/* routines to load and destroy text from datafiles */
void *load_text(PACKFILE *f, long size)
{
	TEXT *t;
	int i, j, n;
	char s[100];

	n = pack_getc(f);

	t = malloc(sizeof(TEXT));
	t->lines = malloc(n * sizeof(char *));
	t->nlines = n;

	for (i = 0; i < n; i++) {
		j = 0;
		do {
			s[j] = pack_getc(f);
		} while (s[j++]);
		t->lines[i] = strdup(s);
	}

	return t;
}

void destroy_text(void *data)
{
	TEXT *t = data;
	
	while (t->nlines--)
		free(t->lines[t->nlines]);
	free(t->lines);
	free(t);
}


/* arrange the current level data into a usable state */
void fix_level(void)
{
	char s[20], *p;
	int x, y, type, n;

	sprintf(s, "level%d", level);
	p = find_datafile_object(dat, s)->dat;

	for (y = 0; y < LEVEL_H; y++)
		for (x = 0; x < LEVEL_W; x++) {
			type = *p++;
			if (!type)
				continue;
			else if (type == PLAYER)
				n = 0;
			else {
				n = ++nobjs;
				if (type == BALL)
					nballs++;
			}
			memset(&objs[n], 0, sizeof(OBJECT));
			objs[n].x = x * 16;
			objs[n].y = y * 16;
			if (type == PLAYER) {
				objs[n].mass = PLAYER_MASS;
				objs[n].angle = 90.0;
			}
			else
				objs[n].mass = BALL_MASS;
			objs[n].scale = 1;
			objs[n].type = type;
			objs[n].live = 1;
		}

	nobjs++;
}


/* apply a force in a certain direction */
void apply_force(OBJECT *o, float angle, float force)
{
	o->ax += cos(RAD(angle)) * force;
	o->ay += sin(RAD(angle)) * force;
}


/* taken from Koules */
void normalize(float *x, float *y, float size)
{
	float len = sqrt((*x * *x) + (*y * *y));
	if (len == 0)
		len = 1;
	*x *= size / len;
	*y *= size / len;
}

/* o1 and o2 are colliding. change their velocity and acceleration */
void colide(OBJECT *o1, OBJECT *o2)
{
	float xp = (o2->x+8) - (o1->x+8);
	float yp = (o2->y+8) - (o1->y+8);

	if (o2->type == PLAYER || o2->type == BALL) {
		normalize(&xp, &yp, o1->mass/o2->mass*2);
		o2->vx += xp;
		o2->vy += yp;
		normalize(&xp, &yp, o2->mass/o1->mass*2);
		o1->vx -= xp;
		o1->vy -= yp;
	}
	else if (o2->type == WALL) {
		if (fabs(xp) > fabs(yp))
			o1->vx = -o1->vx;
		else if (fabs(yp) > fabs(xp))
			o1->vy = -o1->vy;
		else {
			o1->vx = -o1->vx;
			o1->vy = -o1->vy;
		}
	}
	else if (o2->type == SPIRAL) {
		o1->live = 0;
		if (o1->type == BALL) {
			if (!--nballs)
				spiral_color = 183;
		}
		else {
			if (nballs) {
				lives--;
				next_time = 200;  /* restart the level in 200 ticks (2 secs) */
			}
			else {
				level++;
				next_time = 100;
			}
		}
	}
}


/* create a swirling spiral thing */
void update_spiral(void)
{
	float a, r;

	clear(spiral);
	for (a = spiral_angle, r = 0; r < 8; a += 10, r += 0.1)
		putpixel(spiral, 8+cos(RAD(a))*r, 8+sin(RAD(a))*r, spiral_color);
	spiral_angle += 5;
}


/* return the right bitmap for the object type */
BITMAP *object_bitmap(OBJECT *o)
{
	switch (o->type) {
		case PLAYER:
			return dat[player].dat;
		case BALL:
			return dat[ball].dat;
		case SPIRAL:
			return spiral;
		case WALL:
			return wall;
		default:
			return NULL;
	}

}


/* draw an object */
void draw_object(BITMAP *dest, OBJECT *o)
{
	BITMAP *bmp;
	int x, y;

	if ((!o->live && !o->scale) || !(bmp = object_bitmap(o)))
		return;

	x = o->x + (1.0-o->scale)*8;
	y = o->y + (1.0-o->scale)*8;

	if (o->type == PLAYER) {
		if (o->scale != 1.0)
			rotate_scaled_sprite(dest, bmp, x, y, FIXANGLE(o->angle), ftofix(o->scale));
		else
			rotate_sprite(dest, bmp, x, y, FIXANGLE(o->angle));
	}
	else {
		if (o->scale != 1.0)
			rotate_scaled_sprite(dest, bmp, x, y, FIXANGLE(o->angle), ftofix(o->scale));
		else
			draw_sprite(dest, bmp, x, y);
	}
}


/* draw everything */
void draw_everything(void)
{
	int i;

	clear(buf);

	/* draw objects */
	for (i = 0; i < nobjs; i++)
		draw_object(buf, &objs[i]);

	blit(buf, screen, 0, 0, 0, 0, 320, 200);
}


/*
 * Move movable objects based on their velocity, acceleration,
 * gravity, collisions, etc.
 */
void move_objects(void)
{
	int i, j, x, y;

	/* move the objects */
	for (i = 0; i < nobjs; i++) {
		if (objs[i].live && 
			(objs[i].type == PLAYER || objs[i].type == BALL))
		{
			/* apply gravity */
			apply_force(&objs[i], 90.0, GRAVITY);
			DAMPEN(objs[i].ax, A_DAMP);
			DAMPEN(objs[i].ay, A_DAMP);
			DAMPEN(objs[i].vx, V_DAMP);
			DAMPEN(objs[i].vy, V_DAMP);
			CLAMP(objs[i].ax, MAX_A);
			CLAMP(objs[i].ay, MAX_A);
			objs[i].vx += objs[i].ax;
			objs[i].vy += objs[i].ay;
			CLAMP(objs[i].vx, MAX_V);
			CLAMP(objs[i].vy, MAX_V);
			x = objs[i].x;
			y = objs[i].y;
			objs[i].x += objs[i].vx;
			objs[i].y += objs[i].vy;
			/* check for collisions */
			for (j = 0; j < nobjs; j++) {
				if (j == i || !objs[j].live)
					continue;
				if (OBJECTS_COLLIDING(objs[i], objs[j])) {
					colide(&objs[i], &objs[j]);
					objs[i].x = x;
					objs[i].y = y;
					break;
				}
			}
		}
	}
}


/* scale an object down and rotate if it ran into a spiral */
void update_scale(void)
{
	int i;

	for (i = 0; i < nobjs; i++)
		if (!objs[i].live && objs[i].scale > 0) {
			objs[i].scale -= 0.02;
			objs[i].angle -= 10;
		}
}


/* center text on the screen, wait for a key, and return the key */
int prompt(char *text)
{
	int k, t = tick;

	/* blank out every other line for a "halftone"ish effect */
	for (k = 0; k < 200; k += 2)
		hline(buf, 0, k, 320, 0);
	for (k = 0; k < 320; k += 2)
		vline(buf, k, 0, 200, 0);

	textprintf_centre(buf, font, 160, 100, 15, text);
	blit(buf, screen, 0, 0, 0, 0, 320, 200);
	clear_keybuf();
	k = readkey();
	tick = t;

	return k;
}


int main_game_loop(void)
{
	int latency = tick;

	for (;;) {

		while (latency < tick) {

			poll_keyboard();
			poll_joystick();

			/* handle input */
			if (key[KEY_LEFT] || joy_left)
				objs[0].angle += 3.0;
			if (key[KEY_RIGHT] || joy_right)
				objs[0].angle -= 3.0;
			if (key[KEY_UP] || joy_b1)
				apply_force(&objs[0], -objs[0].angle, THRUST);
			if (key[KEY_PGUP]) {
				level++;
				return 0;
			}
			if (key[KEY_PGDN] && level > 1) {
				level--;
				return 0;
			}
			if (key[KEY_P])
				prompt("Paused");
			if (key[KEY_ESC]) {
				if ((prompt("Really quit? (Y/N)") & 0xff) == 'y')
					return -1;
			}

			/* move stuff */
			move_objects();
			update_scale();
			update_spiral();

			if (next_time) {
				next_time--;
				if (!next_time)
					return 0;
			}

			latency++;
		}
		draw_everything();
	}
}


/* spin some text from the datafile onto the screen, and wait for key */
void show_text(char *name, int fg, int bg)
{
	int i, y, l = tick;
	double scale = 0, angle = 0;
	
	TEXT *text = find_datafile_object(dat, name)->dat;
	BITMAP *tmpbuf = create_bitmap(320, 200);

	/* draw text to a temporary buffer */
	clear_to_color(tmpbuf, bg);
	for (i = 0, y = 100-(5*text->nlines); i < text->nlines; i++, y += 10) {
		textprintf_centre(tmpbuf, font, 160, y+1, 230, text->lines[i]);
		textprintf_centre(tmpbuf, font, 161, y, fg, text->lines[i]);
	}

	/*
	 * This takes about two seconds. The text is scaled in from 0 to 100%,
	 * and rotated two full rotations.
	 */
	while (scale < 1.0) {
		while (l < tick) {
			scale += 0.005;
			angle += 3.6;
			if (angle > 720)  /* so it doesn't go over and look odd */
				angle = 720;
			l++;
		}
		/* draw the text scaled and rotated */
		clear_to_color(buf, bg);
		rotate_scaled_sprite(buf, tmpbuf, 0, 0, FIXANGLE(angle), ftofix(scale));
		blit(buf, screen, 0, 0, 0, 0, 320, 200);
	}

	/* draw the unmodified version, so there aren't any artifacts */
	blit(tmpbuf, screen, 0, 0, 0, 0, 320, 200);
	destroy_bitmap(tmpbuf);

	/* wait for a keypress or joystick button 1 press */
	clear_keybuf();
	while (!keypressed() && !joy_b1)
		poll_joystick();
}


void start_the_game(void)
{
	level = 1;
	lives = 5;

	show_text("intro", 15, 0);

	while (level <= NUM_LEVELS) {
		clear(screen);
		textprintf_centre(screen, font, 160, 100, 15, "Level %d", level);
		textprintf_centre(screen, font, 160, 110, 15, "%d %s left", lives, (lives > 1) ? "lives" : "life");
		rest(2000);
		nobjs = 0;
		nballs = 0;
		spiral_color = 14;
		next_time = 0;
		fix_level();
		if (main_game_loop() < 0)
			break;
		if (!lives) {
			show_text("gameover", 49, 43);
			break;
		}
	}

	if (level > NUM_LEVELS)
		show_text("wingame", 69, 172);
}


/* called 100 times/second. keeps the game running at a steady pace */
void timer_proc(void)
{
	tick++;
}
END_OF_FUNCTION(timer_proc);


int main(int argc, char **argv)
{
	int i;

	/* initialize Allegro */
	allegro_init();
	set_gfx_mode(GFX_SAFE, 320, 200, 0, 0);
	install_timer();
	install_keyboard();
	install_joystick(JOY_TYPE_AUTODETECT);
	install_sound(DIGI_AUTODETECT, MIDI_NONE, NULL);

	buf = create_bitmap(320, 200);
	spiral = create_bitmap(16, 16);
	wall = create_bitmap(16, 16);

	/* create a sprite for the walls */
	clear(wall);
	for (i = 1; i < 8; i++)
		rectfill(wall, i, i, 15-i, 15-i, 135-i);
	
	register_datafile_object(DAT_ID('L','E','V',' '), load_level, destroy_level);
	register_datafile_object(DAT_ID('T','E','X','T'), load_text, destroy_text);
	dat = load_datafile("ballz.dat");

	set_palette(dat[palette].dat);
	text_mode(-1);

	/* install the timer */
	LOCK_VARIABLE(tick);
	LOCK_FUNCTION(timer_proc);
	install_int_ex(timer_proc, BPS_TO_TIMER(100));

	start_the_game();

	/* free up memory */
	unload_datafile(dat);
	destroy_bitmap(buf);
	destroy_bitmap(wall);
	destroy_bitmap(spiral);

	return 0;
}
END_OF_MAIN();

