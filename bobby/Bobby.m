//#define MY_DEBUG


#include <stdio.h>
#include <math.h>
#include <string.h>
#include <sys/stat.h>
#include <ctype.h>

#ifdef MACOSX
#import <Foundation/NSURL.h>
#import <AppKit/AppKit.h>
#endif

#include <allegro5/allegro.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro_font.h>
#include <allegro5/allegro_ttf.h>
#include <allegro5/allegro_primitives.h>
#include <allegro5/internal/aintern_list.h>
#include <allegro5/allegro_shader.h>
#ifndef ALLEGRO_WINDOWS
#include <allegro5/allegro_shader_glsl.h>
#endif

#ifdef ALLEGRO_IPHONE
#import <UIKit/UIKit.h>
#include <allegro5/allegro_iphone.h>
#include <allegro5/allegro_iphone_objc.h>
#import <MediaPlayer/MediaPlayer.h>
#import <GameKit/GameKit.h>
#import "MyUIViewController.h"
#import <Foundation/Foundation.h>
#endif

static double lastleftright90 = 0;

static bool should_find_devices = true;

static bool hide_controls = false;
static bool sb_on, sb_l, sb_r, sb_u, sb_d, sb_1, sb_2, sb_3, sb_l1, sb_r1;




/** FIXME: due to NDA, I can't include 60beat GamePad SDK code! **/




#include "cursor.h"

#if defined ALLEGRO_IPHONE || defined ALLEGRO_MACOSX
#include "joypad_handler.h"
joypad_handler *joypad;
#endif
bool waiting_for_pause_release = false;
bool waiting_for_key_release = false;


typedef int32_t HSAMPLE;
#include "bassstuff.h"
HSAMPLE start, boing, spiral, bink, boost, switch_sample, meow;
#include "Bobby.h"

ALLEGRO_TRANSFORM unmodified_trans;

// stupid
//void ASSERT(bool b);
//void ASSERT(bool b) { (void)b; }

#define NUM_ACHIEVEMENTS 11
#define AUL                         "Achievement Unlocked: "
#define PerseveringPlayerID         @"0001"
#define PerseveringPlayerS          AUL "Persevering Player"
#define MaximumVelocityID           @"0002"
#define MaximumVelocityS            AUL "Maximum Velocity"
#define TwentyTwoAndFeelingBlueID   @"0003"
#define TwentyTwoAndFeelingBlueS    AUL "Twenty Two and Feeling Blue"
#define BallzChampionID             @"0004"
#define BallzChampionS              AUL "Ballz Champion"
#define OneThrustID                 @"0005"
#define OneThrustS                  AUL "One Thrust"
#define FiveInFiveID                @"0006"
#define FiveInFiveS                 AUL "5 in 5"
#define WarriorID                   @"0007"
#define WarriorS                    AUL "Warrior"
#define DedicatedID                 @"0008"
#define DedicatedS                  AUL "Dedicated"
#define SixtyInSecondsID            @"0009"
#define SixtyInSecondsS             AUL "Sixty in Seconds"
#define QuickOneID                  @"0010"
#define QuickOneS                   AUL "Quick One"
#define MagneticMarvelID            @"0011"
#define MagneticMarvelS             AUL "Magnetic Marvel"


#ifndef ALLEGRO_IPHONE
ALLEGRO_BITMAP *tmp_bigbuf;

char *pc_achievements[NUM_ACHIEVEMENTS] = {
	PerseveringPlayerS,
	MaximumVelocityS,
	TwentyTwoAndFeelingBlueS,
	BallzChampionS,
	OneThrustS,
	FiveInFiveS,
	WarriorS,
	DedicatedS,
	SixtyInSecondsS,
	QuickOneS,
	MagneticMarvelS
};
bool achieved[NUM_ACHIEVEMENTS] = { false, };
#endif

//bool has_full_border;

int keysDown = 0;

typedef struct {
	float x;
	float y;
	float v;
	ALLEGRO_COLOR color;
} Star;
#define NUM_STARS 100
Star starfield[NUM_STARS];

int player_anim = 0; // go, stop
double player_anim_time;

// for 5 in 5 achievement
double last5starts[5] = { -1.0, };
int last5levels[5] = { -1, };
int last5stars[5] = { 0, };

float starAlpha = 1.0;
float starAlphaInc = 1.0 / LOGIC_PER_SEC;

bool noMusic = false;

bool controls_on_top = false;

double gameStartTime;
double gameElapsedTime;

bool is_fullscreen;

typedef struct {
	int bmp_index;
	float x, y;
} SpaceThing;
double nextSpaceThing;
double minSpaceThingTime = 25;
double maxSpaceThingTime = 50;
double spaceThingInc;
#define MAX_SPACE_THINGS 5
#define AVG_SPACE_THING_TIME 37
SpaceThing spaceThings[MAX_SPACE_THINGS];
int numSpaceThings = 0;
#define NUM_DIFFERENT_SPACE_THINGS 8
int spaceThingOrder[NUM_DIFFERENT_SPACE_THINGS];
int curr_space_thing = 0;

_AL_LIST *scrolling_strings;

#ifdef ALLEGRO_IPHONE
NSMutableDictionary *achievementsDictionary;
#endif

// for dedicated
bool levelPlayed[NUM_LEVELS] = { -1, };
int dedicatedTally = 0;

#ifndef ALLEGRO_IPHONE
bool z_pressed, l_pressed, r_pressed, u_pressed, d_pressed, esc_pressed;
#endif

int sw, sh;
static bool switched_out = false;
static bool display_closed = false;

bool hit_totally_evil_spiral;

const int FAN_REACH = 100;
int OFFSET;
int BUTTON_SIZE;
float scr_scale_x;
float scr_scale_y;
int SCR_W = 960;
int SCR_H = 640;
float wave = 0.0;

double pause_time;
bool paused = false;
bool waiting_for_key = false;

bool brake_on = false;

typedef struct {
	float x, y;
	float vx, vy;
	double life;
	ALLEGRO_COLOR color;
	int bmp_index;
} Particle;

#define NSMOKE 100
Particle smoke[NSMOKE] = { { 0, 0, 0, 0, 0 }, };

ALLEGRO_BITMAP *bg_bmp, *menu_bmp, *story_bmp, *menu_button_bmp, *retry_button_bmp, *retry_bmp;
ALLEGRO_BITMAP *blue_button_bmp, *orange_button_bmp, *continue_bmp, *settings_bmp, *credits_bmp, *logo_bmp,
	*music_bmp, *sound_bmp, *arrow_bmp, *kitty_bmp, *fullscreen_bmp;
ALLEGRO_BITMAP *wall_bmp, *bouncy_wall_bmp, *pause_bmp,
	*fan_bmp, *totally_evil_spiral_bmp, *switch_bmp,
	*totally_good_spiral_bmp, *gate_bmp, *transporter_in_bmp,
	*transporter_out_bmp, *star_bmp, *smoke_bmps[3], *gradient_bmp, *rainbow_bmp, *magnet_bmp,
	*splash1, *splash2, *game_center_bmp, *unbouncy_wall_bmp,
*lock_bmp, *quit_bmp, *info_bmp;//, *border_bmp;
ALLEGRO_BITMAP *abort_bmp, *resume_bmp, *achievements_bmp;
ALLEGRO_BITMAP *player_go[8];
ALLEGRO_BITMAP *miao_go[8];
ALLEGRO_BITMAP *ball_bmps[4], *heavy_ball_bmps[4];
ALLEGRO_BITMAP *miao_ball_bmp;
ALLEGRO_BITMAP *_ball_bmp;
ALLEGRO_BITMAP *_heavy_ball_bmp;
ALLEGRO_BITMAP *_player_bmp;
ALLEGRO_BITMAP *_miao_bmp;
ALLEGRO_BITMAP *atlas;
ALLEGRO_BITMAP *cursor_bmp;
ALLEGRO_BITMAP *help_bmp;


ALLEGRO_BITMAP *space_bmps[NUM_DIFFERENT_SPACE_THINGS];

OBJECT objs[LEVEL_W][LEVEL_H];
int player_x, player_y; // spot in objs
int nballs, nballs_start;
int lives, level;
float next_time;
typedef struct TOUCH
{
	int ident;
	int x, y;
} TOUCH;

_AL_LIST *touch_list;
ALLEGRO_DISPLAY *display;
ALLEGRO_EVENT_QUEUE *queue;
ALLEGRO_EVENT_QUEUE *input_queue;
ALLEGRO_FONT *font;
ALLEGRO_BITMAP *tinyfont;
ALLEGRO_MUTEX *input_mutex;
ALLEGRO_MUTEX *switched_out_mutex;
ALLEGRO_TIMER *logic_timer, *draw_timer;

float next_smoke;

typedef struct {
	int ident;
	ALLEGRO_COLOR color;
} objColor;

int good_levels = 0;
bool bad_levels[1000] = { false, };
int stars[1000] = { 0, };
ALLEGRO_BITMAP *previews[1000] = { NULL, };
int good_level_nums[1000];
int uninterrupted_stars[NUM_LEVELS] = { 0, };

#ifdef ALLEGRO_WINDOWS
#define mkdir(a, b) mkdir(a)
#endif

bool in_game = false;

#ifndef MAX_PATH
#define MAX_PATH 2000
#endif

#ifndef ALLEGRO_IPHONE
ALLEGRO_JOYSTICK *joy;
bool joy_l, joy_r, joy_u, joy_d, joy_a, joy_b, joy_pause;
void configure_joysticks(void)
{
	if (al_get_num_joysticks() > 0)
		joy = al_get_joystick(0);
	else
		joy = NULL;
}
#endif

static int mouse_x, mouse_y;

void set_mouse_xy(ALLEGRO_DISPLAY *d, int x, int y)
{
#ifdef IPHONE
	mouse_x = x;
	mouse_y = y;
#else
	al_set_mouse_xy(d, x, y);
#endif
}

void flip_display(void)
{
#ifdef ALLEGRO_IPHONE
	if (((joypad && joypad->connected) || sb_on) && (!in_game || paused)) {
		ALLEGRO_MOUSE_STATE st;
		st.x = mouse_x;
		st.y = mouse_y;
		st.x /= scr_scale_x;
		st.y /= scr_scale_y;
		al_draw_bitmap(cursor_bmp, st.x-al_get_bitmap_width(cursor_bmp)/2, st.y-al_get_bitmap_height(cursor_bmp)/2, 0);
	}
#endif
	al_flip_display();
}

static bool curs_enter, curs_l, curs_r, curs_u, curs_d;
static bool on_scrollbar;

void cursor_enter(bool v)
{
	curs_enter = v;
	if (v == false) {
		_AL_LIST_ITEM *item = _al_list_front(touch_list);
		while (item) {
			TOUCH *t = _al_list_item_data(item);
			if (t->ident == 1001) {
				free(t);
				break;
			}
			item = _al_list_next(touch_list, item);
		}
		_al_list_erase(touch_list, item);
		on_scrollbar = false;
	}
}
void cursor_left(bool v)
{
	curs_l = v;
}
void cursor_right(bool v)
{
	curs_r = v;
}
void cursor_up(bool v)
{
	curs_u = v;
}
void cursor_down(bool v)
{
	curs_d = v;
}

static double pause_pressed = 0.0;
static void do_unpause(void)
{
	paused = false;
	waiting_for_pause_release = false;
	playSample(bink);
	pause_pressed = al_get_time();
#if defined ALLEGRO_IPHONE || defined ALLEGRO_MACOSX
	[joypad performSelectorOnMainThread: @selector(stop_finding_devices) withObject:nil waitUntilDone:YES];
#endif
}

#ifdef ALLEGRO_IPHONE
static bool is_ipad(void)
{
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 30200)
	if ([[UIDevice currentDevice] respondsToSelector: @selector(userInterfaceIdiom)])
		return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
#endif
	return false;
}
#endif

#ifdef ALLEGRO_IPHONE
static void begin_text_draw(void) {}
static void end_text_draw(void) {}
#else
ALLEGRO_BITMAP *text_draw_bitmap_backup;
static void begin_text_draw(void)
{
#ifndef ALLEGRO_WINDOWS
	text_draw_bitmap_backup = al_get_target_bitmap();
	al_set_target_bitmap(tmp_bigbuf);
	al_clear_to_color(al_map_rgba(0, 0, 0, 0));
#endif
}

static void end_text_draw(void)
{
#ifndef ALLEGRO_WINDOWS
	al_set_target_bitmap(text_draw_bitmap_backup);
	al_draw_bitmap(tmp_bigbuf, 0, 0, 0);
#endif
}
#endif

static char *userResourcePath()
{
	static char path[MAX_PATH];

	#ifdef ALLEGRO_IPHONE
	ALLEGRO_PATH *user_path = al_get_standard_path(ALLEGRO_USER_DOCUMENTS_PATH);
	#else
	ALLEGRO_PATH *user_path = al_get_standard_path(ALLEGRO_USER_SETTINGS_PATH);
	#endif

	sprintf(path, "%s/", al_path_cstr(user_path, '/'));
	al_destroy_path(user_path);
	return path;
}

static void createUserResourcePath(void)
{
	char userDir[1000];
	sprintf(userDir, "%s", userResourcePath());

	ALLEGRO_PATH *path = al_create_path(userDir);

	char buf[1000];
	strcpy(buf, al_path_cstr(path, ALLEGRO_NATIVE_PATH_SEP));
#ifdef ALLEGRO_WINDOWS
	while (buf[strlen(buf)-1] == '\\' || buf[strlen(buf)-1] == '/')
		buf[strlen(buf)-1] = 0;
#endif

	if (userDir[0] && !al_filename_exists(buf)) {
		mkdir(userDir, 0755);
		if (!al_filename_exists(buf)) {
			printf("Couldn't create user resource path\n");
			exit(1);			
		}
	}

#ifdef ALLEGRO_WINDOWS
	int len = strlen(buf);
	buf[len] = '\\';
	buf[len+1] = 0;
	al_destroy_path(path);
	path = al_create_path(buf);
#endif

	al_destroy_path(path);
}

static void newStar(int i)
{
	starfield[i].x = rand() % SCR_W;
	starfield[i].y = rand() % (LEVEL_H*TILE_SIZE);
	starfield[i].v = -(rand() % RAND_MAX) / (float)RAND_MAX * 10 * (1.0 / LOGIC_PER_SEC);
	int r = rand() % 100 + 125;
	int g = r + 30;
	int b = 255;
	starfield[i].color = al_map_rgb(
					r, g, b
					);
}

static void updateStars(void)
{
	int i;
	for (i = 0; i < NUM_STARS; i++) {
		starfield[i].x += starfield[i].v;
		if (starfield[i].x < 0) {
			newStar(i);
			starfield[i].x = SCR_W;
		}
	}
}

static void drawStars(void)
{
	int i, count = 0;
	ALLEGRO_VERTEX v[NUM_STARS*6];
	
	for (i = 0; i < NUM_STARS; i++) {
		int x = (int)starfield[i].x;
		int y = (int)starfield[i].y;
		v[count].x = x;
		v[count].y = y;
		v[count].z = 0;
		v[count].color = starfield[i].color;
		count++;
		v[count].x = x+2;
		v[count].y = y;
		v[count].z = 0;
		v[count].color = starfield[i].color;
		count++;
		v[count].x = x;
		v[count].y = y+2;
		v[count].z = 0;
		v[count].color = starfield[i].color;
		count++;
		v[count].x = x+2;
		v[count].y = y;
		v[count].z = 0;
		v[count].color = starfield[i].color;
		count++;
		v[count].x = x;
		v[count].y = y+2;
		v[count].z = 0;
		v[count].color = starfield[i].color;
		count++;
		v[count].x = x+2;
		v[count].y = y+2;
		v[count].z = 0;
		v[count].color = starfield[i].color;
		count++;
	}
	
	al_draw_prim(v, 0, 0, 0, count, ALLEGRO_PRIM_TRIANGLE_LIST);
}

const int TINY_FONT_SIZE = 20;

static void draw_num(int num, int x, int y, ALLEGRO_COLOR color)
{
	int xo = num == 0 ? 9*TINY_FONT_SIZE : (num-1)*TINY_FONT_SIZE;

	al_draw_tinted_bitmap_region(tinyfont, color, xo, 0, TINY_FONT_SIZE-1, TINY_FONT_SIZE, x, y, 0);
}

static void draw_tiny_text(int x, int y, int num, ALLEGRO_COLOR color)
{
	int a = num / 10;
	int b = num % 10;

	draw_num(a, x, y, color);
	draw_num(b, x+TINY_FONT_SIZE, y, color);
}

// Game Center stuff
#ifndef WITHOUT_GAMECENTER
#define NOTYET 2
int is_authenticated = NOTYET;

BOOL isGameCenterAPIAvailable()
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Check for presence of GKLocalPlayer class.
	BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
	
	// The device must be running iOS 4.1 or later.
	NSString *reqSysVer = @"4.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	
	[pool drain];
	
	return (localPlayerClassAvailable && osVersionSupported);
}

void loadAchievements(void)
{
	if (!isGameCenterAPIAvailable() || !is_authenticated)
		return;

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	achievementsDictionary = [[NSMutableDictionary alloc] init];
	[GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error)
	 {
		 if (error == nil)
		 {
			 for (GKAchievement* achievement in achievements) {
				 [achievementsDictionary setObject: achievement forKey: achievement.identifier];
			 }
		 }
	 }];
	 
	 [pool drain];
}

NSString *achievements_backlog[NUM_ACHIEVEMENTS];
int num_backlog_achievements = 0;

void reportAchievementIdentifier(NSString* identifier, char *notification);

void authenticatePlayer(void)
{
	if (!isGameCenterAPIAvailable()) {
		is_authenticated = 0;
		return;
	}

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];

	[localPlayer authenticateWithCompletionHandler:^(NSError *error) {
		if (localPlayer.isAuthenticated)
		{
			// Perform additional tasks for the authenticated player.
			is_authenticated = 1;
			loadAchievements();
			int i;
			int n = num_backlog_achievements;
			for (i = 0; i < n; i++) {
				NSString *s = achievements_backlog[0];
				int j;
				for (j = 1; j < num_backlog_achievements; j++) {
					achievements_backlog[j-1] = achievements_backlog[j];
				}
				num_backlog_achievements--;
				reportAchievementIdentifier(s, NULL);
				[s release];
			}
		}
		else
			is_authenticated = 0;
	}];
	
	[pool drain];
}

bool reset_complete = false;

void resetAchievements(void)
{
	int i;
	for (i = 0; i < 5; i++) {
		last5starts[i] = -1.0;
		last5levels[i] = -1;
		last5stars[i] = 0;
	}

#ifdef ALLEGRO_IPHONE
	[achievementsDictionary removeAllObjects];
#else
	memset(achieved, 0, NUM_ACHIEVEMENTS);
#endif

	if (!isGameCenterAPIAvailable() || !is_authenticated)
		return;

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// Clear all locally saved achievement objects.
	achievementsDictionary = [[NSMutableDictionary alloc] init];

	// Clear all progress saved on Game Center
	[GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
	 {
		 if (error != nil) {
			 // handle errors
		 }
		 reset_complete = true;
	 }];
	 
	 [pool drain];
}

void reportAchievementIdentifier(NSString* identifier, char *notification)
{
	if (!isGameCenterAPIAvailable() || !is_authenticated)
		return;

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	if ([achievementsDictionary objectForKey:identifier] != nil) {
		[pool drain];
		return;
	}
	// check the backlog!
	int i;
	for (i = 0; i < num_backlog_achievements; i++) {
		if (NSOrderedSame == [achievements_backlog[i] compare:identifier]) {
			// already there
			[pool drain];
			return;
		}
	}
	
	float percent = 100;
	
	if (notification)
		_al_list_push_back(scrolling_strings, strdup(notification));

	GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier: identifier] autorelease];
	if (achievement)
	{
		[achievementsDictionary setObject:achievement forKey:identifier];
		achievement.percentComplete = percent;
		[achievement reportAchievementWithCompletionHandler:^(NSError *error)
		 {
			 if (error != nil)
			 {
				 // Retain the achievement object and try again later (not shown).
				 if (num_backlog_achievements < NUM_ACHIEVEMENTS) {
					 achievements_backlog[num_backlog_achievements] = [[NSString alloc] initWithString:identifier];
					 num_backlog_achievements++;
				 }
			 }
		 }];
	}
	
	[pool drain];
}

bool modalViewShowing = false;

#endif

bool scrolling = false;
float scroll_done = 0;
float scroll_inc = 1.5;

static void update_scroll(void)
{
	if (_al_list_size(scrolling_strings) <= 0)
		return;

	if (!scrolling) {
		scrolling = true;
	}

	_AL_LIST_ITEM *item = _al_list_front(scrolling_strings);
	char *s = _al_list_item_data(item);
	int w = al_get_text_width(font, s) + SCR_W;
	
	scroll_done += scroll_inc;
	if (scroll_done > w) {
		scrolling = false;
		_AL_LIST_ITEM *item = _al_list_front(scrolling_strings);
		char *s = _al_list_item_data(item);
		free(s);
		_al_list_pop_front(scrolling_strings);
		scroll_done = 0;
	}
}

static void draw_scroll(void)
{
	al_set_target_backbuffer(display);
	
	if (_al_list_size(scrolling_strings) <= 0)
		return;

	int x, y, w, h;
	al_get_clipping_rectangle(&x, &y, &w, &h);
	al_set_clipping_rectangle(64*scr_scale_x, 0, sw-128*scr_scale_x, 64*scr_scale_x);
	
	_AL_LIST_ITEM *item = _al_list_front(scrolling_strings);
	char *s = _al_list_item_data(item);
	
	int xo = SCR_W - scroll_done;
	
	begin_text_draw();
	al_draw_text(font, al_map_rgb(255, 255, 0), xo, 4, 0, s);
	end_text_draw();
	
	ALLEGRO_VERTEX v[4];
	v[0].x = 64;
	v[0].y = 0;
	v[0].z = 0;
	v[0].color = al_map_rgba(0, 0, 0, 255);
	v[1].x = 128;
	v[1].y = 0;
	v[1].z = 0;
	v[1].color = al_map_rgba(0, 0, 0, 0);
	v[2].x = 128;
	v[2].y = 64;
	v[2].z = 0;
	v[2].color = al_map_rgba(0, 0, 0, 0);
	v[3].x = 64;
	v[3].y = 64;
	v[3].z = 0;
	v[3].color = al_map_rgba(0, 0, 0, 255);
	al_draw_prim(v, 0, 0, 0, 4, ALLEGRO_PRIM_TRIANGLE_FAN);
	v[0].x = SCR_W-64;
	v[0].y = 0;
	v[0].z = 0;
	v[0].color = al_map_rgba(0, 0, 0, 255);
	v[1].x = SCR_W-128;
	v[1].y = 0;
	v[1].z = 0;
	v[1].color = al_map_rgba(0, 0, 0, 0);
	v[2].x = SCR_W-128; 
	v[2].y = 64;
	v[2].z = 0;
	v[2].color = al_map_rgba(0, 0, 0, 0);
	v[3].x = SCR_W-64;
	v[3].y = 64;
	v[3].z = 0;
	v[3].color = al_map_rgba(0, 0, 0, 255);
	al_draw_prim(v, 0, 0, 0, 4, ALLEGRO_PRIM_TRIANGLE_FAN);
	
	al_set_clipping_rectangle(x, y, w, h);
}

#if !defined(ALLEGRO_IPHONE)
static void saveGame(void)
{
	char saveState[1000];
	sprintf(saveState, "%s/save.dat", userResourcePath());
	FILE *f = fopen(saveState, "wb");
	if (!f) return;
	int i;
	for (i = 0; i < NUM_ACHIEVEMENTS; i++) {
		fputc(achieved[i], f);
	}
	fclose(f);
}

static void reportAchievementIdentifierPC(char *notification)
{
	int i;
	for (i = 0; i < NUM_ACHIEVEMENTS; i++) {
		if (!strcmp(notification, pc_achievements[i])) {
			if (achieved[i])
				return;
			achieved[i] = true;
			break;
		}
	}

	saveGame();
	
	_al_list_push_back(scrolling_strings, strdup(notification));
}

static void loadPCAchievements(void)
{	
	char saveState[1000];
	sprintf(saveState, "%s/save.dat", userResourcePath());
	FILE *f = fopen(saveState, "rb");
	if (!f) return;
	int i;
	for (i = 0; i < NUM_ACHIEVEMENTS; i++) {
		int c = fgetc(f);
		if (c == EOF) break;
		achieved[i] = c;
	}
	fclose(f);
}

#define reportAchievementIdentifier(identifier, notification) \
	reportAchievementIdentifierPC(notification)

#endif

static int get_groups(int type)
{
	if (type == WALL || type == BOUNCY_WALL || type == UNBOUNCY_WALL || type == FAN_LEFT || type == FAN_RIGHT || type == FAN_UP || type == FAN_DOWN || type == FAN_SPIN || type == GATE1 || type == GATE2 || type == MAGNET) {
		int groups = 0;
		if (type == FAN_LEFT || type == FAN_RIGHT || type == FAN_UP || type == FAN_DOWN || type == FAN_SPIN)
			groups |= ALL_FANS;
		else if (type == GATE1 || type == GATE2)
			groups |= ALL_GATES;
		return ALL_WALLS | groups;
	}
	else if (type == BALL || type == HEAVY_BALL)
		return ALL_BALLS | ALL_BOUNCY;
	else if (type == PLAYER || type == MIAO_BALL)
		return ALL_BOUNCY;
	else if (type == SPIRAL || type == TOTALLY_EVIL_SPIRAL || type == TOTALLY_GOOD_SPIRAL)
		return ALL_SPIRALS;
	else if (type >= 'x' && type <= 'z')
		return ALL_TRANSPORTER | ALL_TRANSPORTER_START;
		else if (type >= 'X' && type <= 'Z')
		return ALL_TRANSPORTER | ALL_TRANSPORTER_END;
	else if (type == SWITCH1 || type == SWITCH2)
		return ALL_SWITCHES;
	else
		return OTHER;
}

static const char *save_path(void)
{
	static char path[5000];
	#ifdef ALLEGRO_IPHONE
	ALLEGRO_PATH *user_path = al_get_standard_path(ALLEGRO_USER_DOCUMENTS_PATH);
	#else
	ALLEGRO_PATH *user_path = al_get_standard_path(ALLEGRO_USER_SETTINGS_PATH);
	#endif

	sprintf(path, "%s", al_path_cstr(user_path, '/'));
	if (path[strlen(path)-1] == '\\' || path[strlen(path)-1] == '/')
		path[strlen(path)-1] = 0;
	char part[5000];
	strcpy(part, path);
	while (part[strlen(part)-1] != '/' && part[strlen(part)-1] != '\\')
		part[strlen(part)-1] = 0;
	part[strlen(part)-1] = 0;
	mkdir(part, 0755);
	mkdir(path, 0755);
	sprintf(path, "%s/save.txt", al_path_cstr(user_path, '/'));
	al_destroy_path(user_path);
	return path;
}

bool sound_on = true, music_on = true, use_kitty = false;

static void load_save(void)
{
	FILE *f = fopen(save_path(), "rb");
	if (!f) return;

	sound_on = fgetc(f);
	music_on = fgetc(f);
	use_kitty = fgetc(f);

	memset(stars, 0, 1000*sizeof(stars[0]));
	
	int i;
	int c;
	for (i = 0; i < NUM_LEVELS; i++) {
#ifdef MY_DEBUG
		stars[i] = 3;
#else
		c = fgetc(f);
		if (c == EOF)
			break;
		if (c >= 0 && c <= 3)
			stars[i] = c;
		else
			stars[i] = 0;
#endif
	}
	
	// read fullscreen status
	if (c != EOF) {
		c = fgetc(f);
		if (c != EOF)
			is_fullscreen = c;
	}
	
	fclose(f);
}

static void save_save(void)
{
	FILE *f = fopen(save_path(), "wb");

	fputc(sound_on, f);
	fputc(music_on, f);
	fputc(use_kitty, f);
	
	int i;
	for (i = 0; i < NUM_LEVELS; i++) {
		fputc(stars[i], f);
	}
	
	fputc(is_fullscreen, f);

	fclose(f);
}

const int PREVIEW_W = 256;

#ifdef ALLEGRO_IPHONE
static bool isMultitaskingSupported(void)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	char buf[100];
	strcpy(buf, [[[UIDevice currentDevice] systemVersion] UTF8String]);
	if (atof(buf) < 4.0) return false;
	
	[pool drain];
	
	return [[UIDevice currentDevice] isMultitaskingSupported];
}
#endif

static void destroy_everything(void)
{
	int i;

	al_destroy_bitmap(switch_bmp);
	al_destroy_bitmap(gate_bmp);
	al_destroy_bitmap(transporter_in_bmp);
	al_destroy_bitmap(transporter_out_bmp);
	al_destroy_bitmap(fan_bmp);
	al_destroy_bitmap(smoke_bmps[0]);
	al_destroy_bitmap(smoke_bmps[1]);
	al_destroy_bitmap(smoke_bmps[2]);
	al_destroy_bitmap(totally_evil_spiral_bmp);
	al_destroy_bitmap(totally_good_spiral_bmp);
	al_destroy_bitmap(wall_bmp);
	al_destroy_bitmap(bouncy_wall_bmp);
	al_destroy_bitmap(unbouncy_wall_bmp);
	al_destroy_bitmap(miao_ball_bmp);
	al_destroy_bitmap(star_bmp);
	al_destroy_bitmap(tinyfont);
	al_destroy_bitmap(blue_button_bmp);
	al_destroy_bitmap(orange_button_bmp);
	al_destroy_bitmap(continue_bmp);
	al_destroy_bitmap(settings_bmp);
	al_destroy_bitmap(credits_bmp);
	al_destroy_bitmap(help_bmp);
	al_destroy_bitmap(music_bmp);
	al_destroy_bitmap(sound_bmp);
	al_destroy_bitmap(fullscreen_bmp);
	al_destroy_bitmap(logo_bmp);
	al_destroy_bitmap(arrow_bmp);
	al_destroy_bitmap(lock_bmp);
	al_destroy_bitmap(magnet_bmp);
	al_destroy_bitmap(cursor_bmp);
	
	for (i = 0; i < good_levels; i++) {
		al_destroy_bitmap(previews[i]);
		previews[i] = NULL;
	}

	al_destroy_bitmap(player_go[0]);
	al_destroy_bitmap(player_go[1]);
	al_destroy_bitmap(player_go[2]);
	al_destroy_bitmap(player_go[3]);
	al_destroy_bitmap(player_go[4]);
	al_destroy_bitmap(player_go[5]);
	al_destroy_bitmap(player_go[6]);
	al_destroy_bitmap(player_go[7]);
	al_destroy_bitmap(ball_bmps[0]);
	al_destroy_bitmap(ball_bmps[1]);
	al_destroy_bitmap(ball_bmps[2]);
	al_destroy_bitmap(ball_bmps[3]);
	al_destroy_bitmap(heavy_ball_bmps[0]);
	al_destroy_bitmap(heavy_ball_bmps[1]);
	al_destroy_bitmap(heavy_ball_bmps[2]);
	al_destroy_bitmap(heavy_ball_bmps[3]);
#ifdef ALLEGRO_IPHONE
	al_destroy_bitmap(pause_bmp);
	al_destroy_bitmap(info_bmp);
	al_destroy_bitmap(quit_bmp);
#endif
#ifndef WITHOUT_GAMECENTER
	al_destroy_bitmap(game_center_bmp);
#endif
	al_destroy_bitmap(retry_button_bmp);
	al_destroy_bitmap(menu_button_bmp);
	
	al_destroy_display(display);
}

ALLEGRO_BITMAP *object_bitmap(int, OBJECT *o);

static ALLEGRO_COLOR get_tile_color(int type)
{
	static bool gotten[256] = { false, };
	static ALLEGRO_COLOR colors[256];
	
	if (gotten[type])
		return colors[type];
	
	ALLEGRO_BITMAP *bmp = object_bitmap(type, NULL);
	if (!bmp) return al_map_rgb(0, 0, 0);
	al_lock_bitmap(bmp, ALLEGRO_PIXEL_FORMAT_ANY, ALLEGRO_LOCK_READONLY);
	
	float r = 0, g = 0, b = 0;
	int count = 0;
	
	int x, y;
	for (y = 0; y < TILE_SIZE; y++) {
		for (x = 0; x < TILE_SIZE; x++) {
			ALLEGRO_COLOR c = al_get_pixel(bmp, x, y);
			if (c.a != 0.0) {
				count++;
				r += c.r;
				g += c.g;
				b += c.b;
			}
		}
	}
	
	ALLEGRO_COLOR c = al_map_rgb_f(r/count, g/count, b/count);
	gotten[type] = true;
	colors[type] = c;
	
	al_unlock_bitmap(bmp);
	
	return c;
}

static char *resourcePath(void)
{
	char tmp[MAX_PATH];
	static char result[MAX_PATH];

#ifdef INDIECITY
	strcpy(tmp, ".");
#else
	ALLEGRO_PATH *resource_path = al_get_standard_path(ALLEGRO_RESOURCES_PATH);
	strcpy(tmp, al_path_cstr(resource_path, ALLEGRO_NATIVE_PATH_SEP));
	al_destroy_path(resource_path);
#endif

#ifndef LITE
	sprintf(result, "%s/data/", tmp);
#else
	sprintf(result, "%s/lite-data/", tmp);
#endif

	return result;
}

static const char *getResource(const char *fmt, ...)
{
	va_list ap;
	static char name[MAX_PATH];

	strcpy(name, resourcePath());
	va_start(ap, fmt);
	vsnprintf(name+strlen(name), (sizeof(name)/sizeof(*name))-1, fmt, ap);
	va_end(ap);
	return name;
}

static void load_level(int level)
{
	char s[MAX_PATH];
	int x, y, type;

	strcpy(s, getResource("level%d.txt", level));
	FILE *f = fopen(s, "r");

	for (y = 0; y < LEVEL_H; y++) {
		for (x = 0; x < LEVEL_W; x++) {
			while (isspace(type = fgetc(f)))
				;
			int groups = get_groups(type);
			if (type == PLAYER) {
				player_x = x, player_y = y;
			}
			else if ((groups & ALL_BALLS) || type == MIAO_BALL) {
				nballs++;
			}
			objs[x][y].groups = groups;
			objs[x][y].x = x * TILE_SIZE;
			objs[x][y].y = y * TILE_SIZE;
			objs[x][y].tx = x;
			objs[x][y].ty = y;
			if (type == PLAYER || type == MIAO_BALL) {
				objs[x][y].mass = PLAYER_MASS;
			}
			if (type == PLAYER || type == MAGNET) {
				objs[x][y].angle = 90.0;
			}
			else if (type == MIAO_BALL) {
				objs[x][y].angle = 0.0;
			}
			else {
				if (type == HEAVY_BALL)
					objs[x][y].mass = HEAVY_BALL_MASS;
				else
					objs[x][y].mass = BALL_MASS;
				if (type == FAN_LEFT) {
					objs[x][y].angle = 180;
				}
				else if (type == FAN_UP) {
					objs[x][y].angle = 90;
				}
				else if (type == FAN_DOWN) {
					objs[x][y].angle = 270;
				}
				else { // FAN_RIGHT and FAN_SPIN are 0 also (and miao cat)
					objs[x][y].angle = 0.0;
				}
			}
			objs[x][y].scale = 1;
			objs[x][y].type = type;
			objs[x][y].live = 1;
			objs[x][y].vx = objs[x][y].vy = 0;
			objs[x][y].ax = objs[x][y].ay = 0;
			//objs[x][y].in_tunnel = false;
			//objs[x][y].lock = LOCK_NONE;
		}
	}
	
	nballs_start = nballs;
	
	fclose(f);
}

static ALLEGRO_BITMAP *mkpreview(int level_num)
{
	ALLEGRO_BITMAP *bmp = al_create_bitmap(LEVEL_W, LEVEL_H);
	al_set_target_bitmap(bmp);
	al_lock_bitmap(bmp, ALLEGRO_PIXEL_FORMAT_ANY, ALLEGRO_LOCK_WRITEONLY);
	
	load_level(level_num);
	
	int x, y;
	for (y = 0; y < LEVEL_H; y++) {
		for (x = 0; x < LEVEL_W; x++) {
			ALLEGRO_COLOR c = get_tile_color(objs[x][y].type);
			al_put_pixel(x, y, c);
		}
	}
	
	al_unlock_bitmap(bmp);
	return bmp;
}

static void load_previews(void)
{
	int i, j;
	
	OBJECT backup_objs[LEVEL_W][LEVEL_H];
	int px = player_x;
	int py = player_y;
	
	for (j = 0; j < LEVEL_W; j++) {
		for (i = 0; i < LEVEL_H; i++) {
			backup_objs[j][i] = objs[j][i];
		}
	}

	for (i = 0; i < 1000; i++) {
		if (previews[i])
			continue;
		char filename[1000];
		strcpy(filename, getResource("level%d.txt", (i+1)));
		if (!al_filename_exists(filename))
			break;
		previews[i] = mkpreview(i+1);
		if (!previews[i])
			bad_levels[i] = true;
		else {
			good_level_nums[good_levels] = i;
			good_levels++;
			bad_levels[i] = false;
		}
	}
	
	player_x = px;
	player_y = py;
	for (j = 0; j < LEVEL_W; j++) {
		for (i = 0; i < LEVEL_H; i++) {
			objs[j][i] = backup_objs[j][i];
		}
	}
}

static ALLEGRO_BITMAP *my_create_sub_bitmap(ALLEGRO_BITMAP *bmp, int x, int y, int w, int h)
{
	int tx = x / TILE_SIZE;
	int ty = y / TILE_SIZE;

	int newx = x + (tx+1)*2;
	int newy = y + (ty+1)*2;

	return al_create_sub_bitmap(bmp, newx, newy, w, h);
}

static void load_atlas(void)
{
	atlas = al_load_bitmap(getResource("atlas.png"));
	
	switch_bmp = my_create_sub_bitmap(atlas, 96, 96, 48, 48);
	gate_bmp = my_create_sub_bitmap(atlas, 96, 144, 48, 48);
	transporter_in_bmp = my_create_sub_bitmap(atlas, 96, 192, 48, 48);
	transporter_out_bmp = my_create_sub_bitmap(atlas, 96, 240, 48, 48);
	fan_bmp = my_create_sub_bitmap(atlas, 96, 288, 48, 48);
	smoke_bmps[0] = my_create_sub_bitmap(atlas, 96, 336, 48, 48);
	smoke_bmps[1] = my_create_sub_bitmap(atlas, 96, 384, 48, 48);
	smoke_bmps[2] = my_create_sub_bitmap(atlas, 96, 432, 48, 48);
	totally_good_spiral_bmp = my_create_sub_bitmap(atlas, 144, 96, 48, 48);
	totally_evil_spiral_bmp = my_create_sub_bitmap(atlas, 144, 144, 48, 48);
	wall_bmp = my_create_sub_bitmap(atlas, 144, 192, 48, 48);
	bouncy_wall_bmp = my_create_sub_bitmap(atlas, 144, 240, 48, 48);
	unbouncy_wall_bmp = my_create_sub_bitmap(atlas, 144, 288, 48, 48);
	miao_ball_bmp = my_create_sub_bitmap(atlas, 144, 336, 48, 48);
	magnet_bmp = my_create_sub_bitmap(atlas, 192, 0, 48, 48);
	
	int x = 0, y = 0;

	ALLEGRO_BITMAP *sheet = atlas;
	ball_bmps[0] = my_create_sub_bitmap(sheet, x+0, y+0, TILE_SIZE, TILE_SIZE);
	ball_bmps[1] = my_create_sub_bitmap(sheet, x+TILE_SIZE, y+0, TILE_SIZE, TILE_SIZE);
	ball_bmps[2] = my_create_sub_bitmap(sheet, x+TILE_SIZE*2, y+0, TILE_SIZE, TILE_SIZE);
	ball_bmps[3] = my_create_sub_bitmap(sheet, x+TILE_SIZE*3, y+0, TILE_SIZE, TILE_SIZE);
	
	heavy_ball_bmps[0] = my_create_sub_bitmap(sheet, x+0, y+0+48, TILE_SIZE, TILE_SIZE);
	heavy_ball_bmps[1] = my_create_sub_bitmap(sheet, x+TILE_SIZE, y+0+48, TILE_SIZE, TILE_SIZE);
	heavy_ball_bmps[2] = my_create_sub_bitmap(sheet, x+TILE_SIZE*2, y+0+48, TILE_SIZE, TILE_SIZE);
	heavy_ball_bmps[3] = my_create_sub_bitmap(sheet, x+TILE_SIZE*3, y+0+48, TILE_SIZE, TILE_SIZE);
	
	player_go[0] = my_create_sub_bitmap(sheet, x+TILE_SIZE, y+0+96, TILE_SIZE, TILE_SIZE);
	player_go[1] = my_create_sub_bitmap(sheet, x+TILE_SIZE, y+TILE_SIZE+96, TILE_SIZE, TILE_SIZE);
	player_go[2] = my_create_sub_bitmap(sheet, x+TILE_SIZE, y+TILE_SIZE*2+96, TILE_SIZE, TILE_SIZE);
	player_go[3] = my_create_sub_bitmap(sheet, x+TILE_SIZE, y+TILE_SIZE*3+96, TILE_SIZE, TILE_SIZE);
	player_go[4] = my_create_sub_bitmap(sheet, x+0, y+0+96, TILE_SIZE, TILE_SIZE);
	player_go[5] = my_create_sub_bitmap(sheet, x+0, y+TILE_SIZE+96, TILE_SIZE, TILE_SIZE);
	player_go[6] = my_create_sub_bitmap(sheet, x+0, y+TILE_SIZE*2+96, TILE_SIZE, TILE_SIZE);
	player_go[7] = my_create_sub_bitmap(sheet, x+0, y+TILE_SIZE*3+96, TILE_SIZE, TILE_SIZE);
	
	miao_go[0] = my_create_sub_bitmap(sheet, x+TILE_SIZE, y+0+288, TILE_SIZE, TILE_SIZE);
	miao_go[1] = my_create_sub_bitmap(sheet, x+TILE_SIZE, y+TILE_SIZE+288, TILE_SIZE, TILE_SIZE);
	miao_go[2] = my_create_sub_bitmap(sheet, x+TILE_SIZE, y+TILE_SIZE*2+288, TILE_SIZE, TILE_SIZE);
	miao_go[3] = my_create_sub_bitmap(sheet, x+TILE_SIZE, y+TILE_SIZE*3+288, TILE_SIZE, TILE_SIZE);
	miao_go[4] = my_create_sub_bitmap(sheet, x+0, y+0+288, TILE_SIZE, TILE_SIZE);
	miao_go[5] = my_create_sub_bitmap(sheet, x+0, y+TILE_SIZE+288, TILE_SIZE, TILE_SIZE);
	miao_go[6] = my_create_sub_bitmap(sheet, x+0, y+TILE_SIZE*2+288, TILE_SIZE, TILE_SIZE);
	miao_go[7] = my_create_sub_bitmap(sheet, x+0, y+TILE_SIZE*3+288, TILE_SIZE, TILE_SIZE);	
}

static void clear_all_mouse_events(void)
{
	_AL_LIST_ITEM *item = _al_list_front(touch_list);
	while (item) {
		TOUCH *t = _al_list_item_data(item);
		free(t);
		item = _al_list_next(touch_list, item);
	}
	_al_list_clear(touch_list);
}

static void set_transform(void)
{
	ALLEGRO_TRANSFORM rotate;
	al_identity_transform(&rotate);
	al_compose_transform(&rotate, &unmodified_trans);
	
#ifdef ALLEGRO_IPHONE
	if (is_ipad()) {
		al_scale_transform(&rotate, 1024.0/960.0, 768.0/640.0);
	}
	else
#endif
		al_scale_transform(&rotate, sw/960.0, sh/640.0);
	
	al_use_transform(&rotate);
}

#ifndef ALLEGRO_IPHONE
int default_adapter = 0;
#endif

static void set_fullscreen(void)
{
#ifndef IPHONE
	al_toggle_display_flag(display, ALLEGRO_FULLSCREEN_WINDOW, is_fullscreen);
	clear_all_mouse_events();
	if (is_fullscreen) {
		sw = al_get_display_width(display);
		sh = al_get_display_height(display);
	}
	else {
		sw = 960;
		sh = 640;
	}
#endif

	scr_scale_x = sw / 960.0;
	scr_scale_y = sh / 640.0;
	
	set_mouse_xy(display, sw/2, sh/2);
	mouse_x = sw/2;
	mouse_y = sh/2;

#if !defined(ALLEGRO_IPHONE) && !defined(ALLEGRO_WINDOWS)
	if (tmp_bigbuf)
		al_destroy_bitmap(tmp_bigbuf);
#endif

	al_set_new_bitmap_flags(ALLEGRO_MIN_LINEAR | ALLEGRO_MAG_LINEAR);	

#if !defined(ALLEGRO_IPHONE) && !defined(ALLEGRO_WINDOWS)
	tmp_bigbuf = al_create_bitmap(sw, sh);
#endif
}

static void create_gfx_stuff(void)
{
#ifdef ALLEGRO_IPHONE
	al_set_new_display_option(ALLEGRO_SUPPORTED_ORIENTATIONS, ALLEGRO_DISPLAY_ORIENTATION_LANDSCAPE, ALLEGRO_REQUIRE);
#else
#ifndef ALLEGRO_WINDOWS
	al_set_new_display_option(ALLEGRO_COLOR_SIZE, 16, ALLEGRO_SUGGEST);
#endif
#endif	
	
	//al_set_new_display_option(ALLEGRO_VSYNC, 1, ALLEGRO_SUGGEST);

#ifdef ALLEGRO_IPHONE
	ALLEGRO_MONITOR_INFO mi;
	al_get_monitor_info(0, &mi);
	sw = mi.y2 - mi.y1;
	sh = mi.x2 - mi.x1;
#else
	sw = 960;
	sh = 640;
#ifdef ALLEGRO_WINDOWS
	al_set_new_display_adapter(default_adapter);
#endif
#endif

	display = al_create_display(sw, sh);
	
	al_copy_transform(&unmodified_trans, al_get_current_transform());
	
	font = al_load_ttf_font(getResource("font.ttf"), 28, 0);

	set_fullscreen();

#if 0
	if (al_get_display_flags(display) & ALLEGRO_USE_PROGRAMMABLE_PIPELINE) {
		static const char *default_vertex_source =
		"attribute vec4 pos;\n"
		"attribute vec4 color;\n"
		"attribute vec2 texcoord;\n"
		"uniform mat4 proj_matrix;\n"
		"uniform mat4 view_matrix;\n"
		"varying vec4 varying_color;\n"
		"varying vec2 varying_texcoord;\n"
		"void main()\n"
		"{\n"
		"   varying_color = color;\n"
		"   varying_texcoord = texcoord;\n"
		"   gl_Position = proj_matrix * view_matrix * pos;\n"
		"}\n";

		static const char *main_pixel_source =
#ifdef ALLEGRO_IPHONE
		"precision mediump float;\n"
#endif
		"uniform bool use_tex;\n"
		"uniform sampler2D tex;\n"
		//"uniform bool use_tex_matrix;\n"
		//"uniform lowp mat4 tex_matrix;\n"
		"varying lowp vec4 varying_color;\n"
		"varying vec2 varying_texcoord;\n"
		"void main()\n"
		"{\n"
		"  lowp vec4 tmp = varying_color;\n"
		"  if (use_tex) {\n"
		//"     vec4 coord = vec4(varying_texcoord, 0.0, 1.0);\n"
		//"     if (use_tex_matrix) {\n"
		//"        coord *= tex_matrix;\n"
		//"     }\n"
		//"     lowp vec4 sample = texture2D(tex, coord.st);\n"
		"     lowp vec4 sample = texture2D(tex, varying_texcoord);\n"
		"     tmp *= sample;\n"
		"  }\n"
		"  gl_FragColor = tmp;\n"
		"}\n";

		ALLEGRO_SHADER *default_shader = al_create_shader(ALLEGRO_SHADER_GLSL);

		al_attach_shader_source(
					default_shader,
					ALLEGRO_VERTEX_SHADER,
					default_vertex_source
					);
		al_attach_shader_source(
					default_shader,
					ALLEGRO_PIXEL_SHADER,
					main_pixel_source
					);
		al_link_shader(default_shader);
		al_set_opengl_program_object(display, al_get_opengl_program_object(default_shader));
	}
#endif
	
	al_register_event_source(queue, al_get_display_event_source(display));
	al_register_event_source(input_queue, al_get_display_event_source(display));

	set_transform();
	
	load_atlas();

#ifdef ALLEGRO_IPHONE
	pause_bmp = al_load_bitmap(getResource("pause.png"));
	info_bmp = al_load_bitmap(getResource("info.png"));
	quit_bmp = al_load_bitmap(getResource("quit.png"));
#endif
#ifndef WITHOUT_GAMECENTER
	game_center_bmp = al_load_bitmap(getResource("game_center.png"));
#endif
	
	star_bmp = al_load_bitmap(getResource("star.png"));
	lock_bmp = al_load_bitmap(getResource("lock.png"));
	blue_button_bmp = al_load_bitmap(getResource("blue_button.png"));
	orange_button_bmp = al_load_bitmap(getResource("orange_button.png"));
	continue_bmp = al_load_bitmap(getResource("continue_txt.png"));
	settings_bmp = al_load_bitmap(getResource("settings_txt.png"));
	credits_bmp = al_load_bitmap(getResource("credits_txt.png"));
	help_bmp = al_load_bitmap(getResource("help_txt.png"));
	music_bmp = al_load_bitmap(getResource("music_txt.png"));
	sound_bmp = al_load_bitmap(getResource("sounds_txt.png"));
	kitty_bmp = al_load_bitmap(getResource("kitty_txt.png"));
	fullscreen_bmp = al_load_bitmap(getResource("fullscreen_txt.png"));
	abort_bmp = al_load_bitmap(getResource("abort_txt.png"));
	resume_bmp = al_load_bitmap(getResource("resume_txt.png"));
	achievements_bmp = al_load_bitmap(getResource("achievements_txt.png"));
	logo_bmp = al_load_bitmap(getResource("logo.png"));
	arrow_bmp = al_load_bitmap(getResource("arrow.png"));
	retry_button_bmp = al_load_bitmap(getResource("retry_button.png"));
	menu_button_bmp = al_load_bitmap(getResource("menu_button.png"));
	cursor_bmp = al_load_bitmap(getResource("cursor.png"));
	
	//al_set_new_bitmap_flags(flags);
	
	tinyfont = al_load_bitmap(getResource("tinyfont.png"));
	//_bmp = al_load_bitmap(getResource("border.png"));

	al_set_new_bitmap_flags(0);
	load_previews();
	al_set_new_bitmap_flags(ALLEGRO_MIN_LINEAR | ALLEGRO_MAG_LINEAR);
	
	al_set_target_backbuffer(display);
}

static void pause_game(bool play_sample)
{
#if defined ALLEGRO_IPHONE || defined ALLEGRO_MACOSX
	if (should_find_devices)
		[joypad performSelectorOnMainThread: @selector(find_devices) withObject:nil waitUntilDone:YES];
#endif
	pause_time = al_get_time();
	paused = true;
	if (play_sample)
		playSample(bink);
	pause_pressed = al_get_time();
}

static void switch_game_out(bool halt_drawing)
{
#ifdef ALLEGRO_IPHONE
	should_find_devices = false;
	if (in_game)
		pause_game(false);
	should_find_devices = true;
	if (halt_drawing) {
		al_stop_timer(logic_timer);
		al_stop_timer(draw_timer);
		al_lock_mutex(switched_out_mutex);
		sb_on = false;
		/** FIXME: 60beat GamePad needs to be released here **/
		stopMusic();
		switched_out = true;
		al_lock_mutex(input_mutex);
		memset(uninterrupted_stars, 0, sizeof(int)*NUM_LEVELS);
		while (_al_list_size(touch_list) > 0)
			_al_list_pop_front(touch_list);
		al_unlock_mutex(input_mutex);
		al_unlock_mutex(switched_out_mutex);
		if (isMultitaskingSupported()) {
			// screen gets messed up unless we do this
			al_set_target_backbuffer(display);
			al_draw_filled_rectangle(0, 0, SCR_W, SCR_H, al_map_rgb(0, 0, 0));
			al_clear_to_color(al_map_rgb(0, 0, 0));
			flip_display();
			al_draw_filled_rectangle(0, 0, SCR_W, SCR_H, al_map_rgb(0, 0, 0));
			al_clear_to_color(al_map_rgb(0, 0, 0));
			flip_display();
			
			al_acknowledge_drawing_halt(display);
			while (switched_out) {
				al_rest(0.01);
				if (display_closed) {
					destroy_everything();
					exit(0);
				}
			}
			if (display_closed) {
				destroy_everything();
				exit(0);
			}
			al_start_timer(logic_timer);
			al_start_timer(draw_timer);
		}
	}
	else {
		stopMusic();
		switched_out = true;
	}
#endif
}

static void switch_game_in(void)
{
#ifdef ALLEGRO_IPHONE
	while (!switched_out) {
		al_rest(0.001);
	}
	if (!noMusic && music_on) {
		playMusic(!in_game);
	}
	/** FIXME: 60beat GamePad needs to be re-inited here! **/
	switched_out = false;
#endif
}

static TEXT *load_text(const char *name)
{
	TEXT *t;
	int i, j, n;
	char s[100];

	FILE *f = fopen(name, "rb");

	n = fgetc(f);

	t = malloc(sizeof(TEXT));
	t->lines = malloc(n * sizeof(char *));
	t->nlines = n;

	for (i = 0; i < n; i++) {
		j = 0;
		do {
			s[j] = fgetc(f);
		} while (s[j++]);
		t->lines[i] = strdup(s);
	}

	fclose(f);

	return t;
}

static void destroy_text(TEXT *t)
{
	while (t->nlines--)
		free(t->lines[t->nlines]);
	free(t->lines);
	free(t);
}

/* apply a force in a certain direction */
static void apply_force(OBJECT *o, float angle, float force)
{
	o->ax += cos(RAD(angle)) * force;
	o->ay += sin(RAD(angle)) * force;
}

static void normalize(float *x, float *y, float size)
{
	float len = sqrt((*x * *x) + (*y * *y));
	if (len == 0)
		len = 1;
	*x *= size / len;
	*y *= size / len;
}

static bool object_colliding(OBJECT *o, OBJECT **ret, int *count, int *groups)
{
	*count = 0;
	*groups = 0;
	int x, y;
	
	for (y = 0; y < LEVEL_H; y++) {
		for (x = 0; x < LEVEL_W; x++) {
			if ((objs[x][y].tx == o->tx && objs[x][y].ty == o->ty) || !objs[x][y].live || objs[x][y].type == EMPTY || objs[x][y].groups == ALL_WALLS || objs[x][y].groups == (ALL_TRANSPORTER | ALL_TRANSPORTER_END))
				continue;
			if (OBJECTS_COLLIDING((*o), objs[x][y])) {
				ret[*count] = &objs[x][y];
				*count = *count + 1;
				(*groups) |= objs[x][y].groups;
			}
		}
	}
	
	return *count > 0;
}

static bool wall_colliding(OBJECT *o, OBJECT **ret, int *count, int *groups)
{
	*count = 0;
	*groups = 0;
	int x, y;
	
	for (y = 0; y < LEVEL_H; y++) {
		for (x = 0; x < LEVEL_W; x++) {
			if ((objs[x][y].tx == o->tx && objs[x][y].ty == o->ty) || !(objs[x][y].groups & ALL_WALLS))
				continue;
			if (WALL_COLLIDING((*o), objs[x][y])) {
				ret[*count] = &objs[x][y];
				*count = *count + 1;
				(*groups) |= objs[x][y].groups;
			}
		}
	}
	
	return *count > 0;
}

/* o1 and o2 are colliding. change their velocity and acceleration */
// return false to not reset to original position

#define IN_BOUNDS(x, y) ((x) >= 0 && (x) < LEVEL_W && (y) >= 0 && (y) < LEVEL_H)

static void collide(OBJECT *o1, OBJECT *o2)
{
	float xp = (o2->x+(TILE_SIZE/2)) - (o1->x+(TILE_SIZE/2));
	float yp = (o2->y+(TILE_SIZE/2)) - (o1->y+(TILE_SIZE/2));

	if (o2->groups & ALL_BOUNCY) {
		o1->hit_time = al_get_time();
		o2->hit_time = al_get_time();
		playSample(boing);
		normalize(&xp, &yp, o1->mass/o2->mass*2);
		o2->vx += xp;
		o2->vy += yp;
		normalize(&xp, &yp, o2->mass/o1->mass*2);
		o1->vx -= xp;
		o1->vy -= yp;
		// spin balls randomly
		if (o1->type != PLAYER && o1->type != MIAO_BALL)
			o1->angle = ((rand()%RAND_MAX)/(float)RAND_MAX)*10-5;
		if (o2->type != PLAYER && o2->type != MIAO_BALL)
			o2->angle = ((rand()%RAND_MAX)/(float)RAND_MAX)*10-5;
		// dampen enemies if brakes on
		OBJECT *dampen = NULL;
		if (o1->type == PLAYER) {
			dampen = o2;
		}
		else if (o2->type == PLAYER) {
			dampen = o1;
		}
		if (dampen) {
			float brake_multiplier;
			if (brake_on)
				brake_multiplier = 5000.0;
			else
				brake_multiplier = 1.0;
			DAMPEN(dampen->ax, A_DAMP);
			DAMPEN(dampen->ay, A_DAMP);
			DAMPEN(dampen->vx, V_DAMP);
			DAMPEN(dampen->vy, V_DAMP);
		}
	}
	else if (o2->groups & ALL_SPIRALS) {
		playSample(spiral);
		o1->live = 0;
		if (o1->type == MIAO_BALL) {
			playSample(meow);
		}
		if (((o1->groups & ALL_BALLS) || o1->type == MIAO_BALL) && objs[player_x][player_y].live) {
		    nballs--;
		}
		else if (o1->type == PLAYER) {
		    next_time = 2;
		    if (o2->type == TOTALLY_EVIL_SPIRAL)
			hit_totally_evil_spiral = true;
		    else
			hit_totally_evil_spiral = false;
		}
	}
}

/* return the right bitmap for the object type */
ALLEGRO_BITMAP *object_bitmap(int type, OBJECT *o)
{
	if (type >= 'x' && type <= 'z') 
		return transporter_in_bmp;
	if (type >= 'X' && type <= 'Z')
		return transporter_out_bmp;

	switch (type) {
		case PLAYER: {
			ALLEGRO_BITMAP **p = (use_kitty ? miao_go : player_go);
			if (player_anim == 0) {
				int frame = player_anim_time;
				if (frame > 7) frame = 7;
				return p[frame];
			}
			else {
				int frame = 7 - player_anim_time;
				if (frame < 0) frame = 0;
				return p[frame];
			}
		}
		case MIAO_BALL:
			return miao_ball_bmp;
		case BALL:
		case HEAVY_BALL: {
			ALLEGRO_BITMAP **arr = (type == BALL ? ball_bmps : heavy_ball_bmps);
			if (o == NULL) return arr[3];
			double now;
			now = al_get_time();
			double t = now - o->hit_time;
			int frame = 3;
			if (t < 0.75) {
				t = t * (4.0 / 0.75);
				frame = (int)t;
			}
			return arr[frame];
		}
		case SPIRAL:
			if (nballs <= 0) 
				return totally_good_spiral_bmp;
			else
				return totally_evil_spiral_bmp;
		case TOTALLY_EVIL_SPIRAL:
			return totally_evil_spiral_bmp;
		case TOTALLY_GOOD_SPIRAL:
			return totally_good_spiral_bmp;
		case WALL:
			return wall_bmp;
		case BOUNCY_WALL:
			return bouncy_wall_bmp;
		case UNBOUNCY_WALL:
			return unbouncy_wall_bmp;
		case SWITCH1:
		case SWITCH2:
			return switch_bmp;
		case GATE1:
		case GATE2:
			return gate_bmp;
		case FAN_LEFT:
		case FAN_RIGHT:
		case FAN_UP:
		case FAN_DOWN:
		case FAN_SPIN:
			return fan_bmp;
		case MAGNET:
			return magnet_bmp;
		default:
			return NULL;
	}

}

bool thrusting = false;

/* draw an object */
static void draw_object(OBJECT *o, ALLEGRO_COLOR tint)
{
	ALLEGRO_BITMAP *bmp;
	int x, y;

	if ((!o->live && o->scale <= 0) || !(bmp = object_bitmap(o->type, o)))
		return;

	x = o->x + o->scale*(TILE_SIZE/2);
	y = o->y + o->scale*(TILE_SIZE/2);

	if (o->scale != 1.0) {
		if (o->live) {
			al_draw_tinted_scaled_rotated_bitmap(bmp, tint,
				TILE_SIZE/2, TILE_SIZE/2,
				(int)x, (int)y, o->scale, o->scale,
				RAD(o->angle), 0);
		}
		else {
			al_draw_tinted_scaled_rotated_bitmap(bmp, tint,
				TILE_SIZE/2, TILE_SIZE/2,
				(int)o->x+TILE_SIZE/2, (int)o->y+TILE_SIZE/2, o->scale, o->scale,
				RAD(o->angle), 0);
		}
	}
	else if ((o->groups & ALL_BOUNCY) || (o->groups & ALL_FANS) || (o->groups & ALL_SPIRALS) || (o->type == MAGNET)) {
		float angle = -o->angle;
		int offsx = 0;
		int offsy = 0;
		if (o->groups & ALL_BALLS && sqrt(o->vx*o->vx + o->vy*o->vy) > 1) {
			double now;
			if (paused)
				now = pause_time;
			else
				now = al_get_time();
			angle = angle * (now-gameStartTime) * LOGIC_PER_SEC;
		}
		else if (o->type == PLAYER) {
			if (brake_on && thrusting) {
				if (rand() % 2)
					offsx = (rand() % 3) - 1;
				else
					offsy = (rand() % 3) - 1;
			}
		}
		al_draw_tinted_rotated_bitmap(bmp, tint,
			TILE_SIZE/2, TILE_SIZE/2,
			(int)x+offsx, (int)y+offsy, RAD(angle), 0);
	}
	else {
		al_draw_tinted_bitmap(bmp, tint, (int)o->x, (int)o->y, 0);
	}
}


ALLEGRO_BITMAP *air_bitmap = NULL;
bool fan_first;

/* draw an object */
static void draw_fan_air(OBJECT *o)
{
	if (!(o->groups & ALL_FANS)) {
		return;
	}
	
	if (air_bitmap == NULL) {
		air_bitmap = al_create_bitmap(128, 128);
	}
	
	bool first = fan_first;
	fan_first = false;

	if (first) {
		ALLEGRO_STATE state;
		al_store_state(&state, ALLEGRO_STATE_TARGET_BITMAP);
		al_set_target_bitmap(air_bitmap);
		al_clear_to_color(al_map_rgba_f(0, 0, 0, 0));

		static ALLEGRO_VERTEX *fan_verts = NULL;
		static int fan_vert_array_size = 512;
		int fan_vert_count = 0;

		if (fan_verts == NULL)
			fan_verts = malloc(512 * sizeof(ALLEGRO_VERTEX));
		
		int x, y;

		x = 0;
		y = 64;

		float air_angle =  22.5; //o->angle + 22.5;
		const int num_jets = 3;
		int i;
		float j;
		float wave_add = 0.0;

		float jinc = sw > 320 ? 0.5 : 0.75;
		
		for (i = 0; i < num_jets; i++) {
			for (j = 0; j < FAN_REACH; j += jinc) {
				float alpha = (1.0 - ((float)j/FAN_REACH)) * 0.5;
				wave_add -= 10;
				float xx = x + cos(RAD(-air_angle)) * j + cos(RAD(-air_angle)) * (TILE_SIZE/2);
				float yy = y + sin(RAD((wave+wave_add+air_angle))) * 3 + sin(RAD(-air_angle)) * j + sin(RAD(-air_angle)) * (TILE_SIZE/2);
				fan_verts[fan_vert_count].x = xx;
				fan_verts[fan_vert_count].y = yy;
				fan_verts[fan_vert_count].z = 0;
				fan_verts[fan_vert_count].color = al_map_rgba_f(alpha, alpha, alpha, alpha);
				fan_vert_count++;
				fan_verts[fan_vert_count].x = xx;
				fan_verts[fan_vert_count].y = yy+1;
				fan_verts[fan_vert_count].z = 0;
				fan_verts[fan_vert_count].color = al_map_rgba_f(alpha, alpha, alpha, alpha);
				fan_vert_count++;
				if (fan_vert_count >= fan_vert_array_size) {
					fan_vert_array_size += 512;
					fan_verts = realloc(fan_verts, fan_vert_array_size * sizeof(ALLEGRO_VERTEX));
				}
			}
			air_angle -= (45.0/(num_jets-1));
		}
		
		al_draw_prim(fan_verts, 0, 0, 0, fan_vert_count, ALLEGRO_PRIM_LINE_LIST);
		
		al_restore_state(&state);
		
		al_hold_bitmap_drawing(true);
	}
	
	int x = o->x + TILE_SIZE/2;
	int y = o->y + TILE_SIZE/2;
	
	al_draw_rotated_bitmap(
			       air_bitmap,
			       0, 64,
			       x, y,
			       RAD(-o->angle),
			       0
			       );
}

static void drawSpaceStuff(void)
{
	int i;

	// draw galaxies etc
	for (i = 0; i < numSpaceThings; i++) {
		al_draw_scaled_bitmap(
				      space_bmps[spaceThings[i].bmp_index],
				      0, 0, al_get_bitmap_width(space_bmps[spaceThings[i].bmp_index]), al_get_bitmap_height(space_bmps[spaceThings[i].bmp_index]),
				      (int)spaceThings[i].x, (int)spaceThings[i].y,
				      (int)(al_get_bitmap_width(space_bmps[spaceThings[i].bmp_index])),
				      (int)(al_get_bitmap_height(space_bmps[spaceThings[i].bmp_index])),
				      0);
	}

}

/* draw everything */
static void draw_everything(ALLEGRO_BITMAP *buffer, bool draw_extra)
{
	int i;
	
	al_set_target_bitmap(buffer);
	al_clear_to_color(al_map_rgb(0, 0, 0));

	al_draw_bitmap(bg_bmp, 0, 0, 0);

	/* Translate and clip (used to use sub-bitmap) */
	ALLEGRO_TRANSFORM oldTrans, newTrans;
	al_copy_transform(&oldTrans, al_get_current_transform());
	al_copy_transform(&newTrans, &oldTrans);
	al_translate_transform(&newTrans, 0, (SCR_H-(LEVEL_H*TILE_SIZE))*scr_scale_y);
	al_use_transform(&newTrans);

	drawStars();

	drawSpaceStuff();

	al_draw_filled_rectangle(0, 0, SCR_W, SCR_H, al_map_rgba_f(0, 0, 0, 0.6));

	// fill the top status with black (it's translated before)
	al_draw_filled_rectangle(0, -64, SCR_W, 32, al_map_rgba_f(0, 0, 0, 1));

	/* draw objects */
	al_hold_bitmap_drawing(true);

	int x, y;
	ALLEGRO_COLOR white = al_map_rgb(255, 255, 255);
	
	// draw all non-moving stuff first
	for (y = 0; y < LEVEL_H; y++) {
		for (x = 0; x < LEVEL_W; x++) {
			if (!(objs[x][y].groups & ALL_BOUNCY))
				draw_object(&objs[x][y], white);
		}
	}
	// now all moving stuff
	for (y = 0; y < LEVEL_H; y++) {
		for (x = 0; x < LEVEL_W; x++) {
			if ((objs[x][y].groups & ALL_BOUNCY))
				draw_object(&objs[x][y], white);
		}
	}

	// draw smoke
	if (objs[player_x][player_y].scale == 1.0) {
		for (i = 0; i < NSMOKE; i++) {
			if (smoke[i].life > 0) {
				float alpha = smoke[i].life / 1.0;
				al_draw_tinted_bitmap(
					smoke_bmps[smoke[i].bmp_index],
					al_map_rgba_f(
						smoke[i].color.r*alpha,
						smoke[i].color.g*alpha,
						smoke[i].color.b*alpha,
						alpha
					),
					smoke[i].x-al_get_bitmap_width(smoke_bmps[0])/2,
					smoke[i].y-al_get_bitmap_height(smoke_bmps[0])/2,
					0
				);
			}
		}
	}

	al_hold_bitmap_drawing(false);
	
	/* draw fan air */
	if (draw_extra) {
		fan_first = true;
		for (y = 0; y < LEVEL_H; y++) {
			for (x = 0; x < LEVEL_W; x++) {
				draw_fan_air(&objs[x][y]);
			}
		}
		al_hold_bitmap_drawing(false); // set true in draw_fan_air

#ifdef ALLEGRO_IPHONE
		const int SH = (LEVEL_H*TILE_SIZE);
		//int yy = -(SH-BUTTON_SIZE-OFFSET*2);
		int yy = ((BUTTON_SIZE/2+OFFSET)-SH)+BUTTON_SIZE/2;
		if (!controls_on_top) yy = 0;
		int o = BUTTON_SIZE+1;
		
		if (!(joypad && joypad->connected) && !sb_on) {
			
			al_draw_triangle(
						OFFSET+10,
						yy+SH-OFFSET-BUTTON_SIZE/2,
						OFFSET+BUTTON_SIZE-1-5,
						yy+SH-OFFSET-BUTTON_SIZE+10,
						OFFSET+BUTTON_SIZE-1-5,
						yy+SH-OFFSET-10,
						al_map_rgba(50, 50, 50, 50),
						10
						);
			
			al_draw_triangle(
						o+OFFSET+BUTTON_SIZE-10,
						yy+SH-OFFSET-BUTTON_SIZE/2,
						o+OFFSET+1+5,
						yy+SH-OFFSET-BUTTON_SIZE+10,
						o+OFFSET+1+5,
						yy+SH-OFFSET-10,
						al_map_rgba(50, 50, 50, 50),
						10
						);
			
			al_draw_circle(SCR_W-OFFSET-BUTTON_SIZE/2,
					      yy+SH-OFFSET-BUTTON_SIZE/2, BUTTON_SIZE/2-5,
					      al_map_rgba(100, 50, 50, 50), 10);
			
			al_draw_circle(
					      SCR_W-OFFSET-BUTTON_SIZE*3/2,
					      yy+SH-OFFSET-BUTTON_SIZE/2,
					      BUTTON_SIZE/2-5, al_map_rgba(50, 100, 50, 50), 10);
		}
#endif

	}

	al_use_transform(&oldTrans);
}

static void single_wall_collide(OBJECT *o, OBJECT *w, float multiplier_x, float multiplier_y)
{
	float wxs[4], wys[4];
	wxs[0] = w->x;
	wxs[1] = w->x+TILE_SIZE;
	wxs[2] = wxs[1];
	wxs[3] = wxs[0];
	wys[0] = w->y;
	wys[1] = wys[0];
	wys[2] = w->y+TILE_SIZE;
	wys[3] = wys[2];

	float ox1 = o->x+(4);
	float oy1 = o->y+(4);

	if (o->vx == 0 && o->vy == 0) {
		return;
	}
	else if (o->vx == 0) {
		o->vy = -o->vy * multiplier_y;
		return;
	}
	else if (o->vy == 0) {
		o->vx = -o->vx * multiplier_x;
		return;
	}

	#define POINT_IN_OBJ(x, y, ox1, oy1) \
		POINT_IN_BOX(x, y, ox1, oy1, TILE_SIZE-8, TILE_SIZE-8)

    
	// corner depths
	float depx, depy, depx_inv, depy_inv;
	depx = fmod(o->x, TILE_SIZE);
	depy = fmod(o->y, TILE_SIZE);
	depx_inv = TILE_SIZE - depx;
	depy_inv = TILE_SIZE - depy;

	if (o->vx > 0)
	{
		if (o->vy > 0) {
			if (POINT_IN_OBJ(wxs[1], wys[1], ox1, oy1)) {
				o->vy = -o->vy * multiplier_y;
				return;
			}
			else if (POINT_IN_OBJ(wxs[3], wys[3], ox1, oy1)) {
				o->vx = -o->vx * multiplier_x;
				return;
		}
	    else if (POINT_IN_OBJ(wxs[0], wys[0], ox1, oy1))
	    {
		if (depx >= depy * 2)
		{
		    o->vy = -o->vy * multiplier_y;
		}
		else if (depy >= depx * 2)
		{
		    o->vx = -o->vx * multiplier_x;
		}
		else
		{
		    o->vx = -o->vx * multiplier_x;
		    o->vy = -o->vy * multiplier_y;
		}
				return;
			}
		}
		else if (o->vy < 0) {
			if (POINT_IN_OBJ(wxs[0], wys[0], ox1, oy1)) {
				o->vx = -o->vx * multiplier_x;
				return;
			}
			else if (POINT_IN_OBJ(wxs[2], wys[2], ox1, oy1)) {
				o->vy = -o->vy * multiplier_y;
				return;
			}
			else if (POINT_IN_OBJ(wxs[3], wys[3], ox1, oy1)) {
		if (depx >= depy_inv * 2)
		{
		    o->vy = -o->vy * multiplier_y;
		}
		else if (depy_inv >= depx * 2)
		{
		    o->vx = -o->vx * multiplier_x;
		}
		else
		{
		    o->vx = -o->vx * multiplier_x;
		    o->vy = -o->vy * multiplier_y;
		}
				return;
			}
		}
	}
	else if (o->vx < 0) {
		if (o->vy > 0) {
			if (POINT_IN_OBJ(wxs[0], wys[0], ox1, oy1)) {
				o->vy = -o->vy * multiplier_y;
				return;
			}
			else if (POINT_IN_OBJ(wxs[2], wys[2], ox1, oy1)) {
				o->vx = -o->vx * multiplier_x;
				return;
			}
			else if (POINT_IN_OBJ(wxs[1], wys[1], ox1, oy1)) {
		if (depx_inv >= depy * 2)
		{
		    o->vy = -o->vy * multiplier_y;
		}
		else if (depy >= depx_inv * 2)
		{
		    o->vx = -o->vx * multiplier_x;
		}
		else
		{
		    o->vx = -o->vx * multiplier_x;
		    o->vy = -o->vy * multiplier_y;
		}
				return;
			}
		}
		else if (o->vy < 0) {
			if (POINT_IN_OBJ(wxs[1], wys[1], ox1, oy1)) {
				o->vx = -o->vx * multiplier_x;
				return;
			}
			else if (POINT_IN_OBJ(wxs[3], wys[3], ox1, oy1)) {
				o->vy = -o->vy * multiplier_y;
				return;
			}
			else if (POINT_IN_OBJ(wxs[2], wys[2], ox1, oy1)) {
				if (depx_inv >= depy_inv * 2)
				{
				    o->vy = -o->vy * multiplier_y;
				}
				else if (depy_inv >= depx_inv * 2)
				{
				    o->vx = -o->vx * multiplier_x;
				}
				else
				{
				    o->vx = -o->vx * multiplier_x;
				    o->vy = -o->vy * multiplier_y;
				}
				return;
			}
		}
	}

	o->vx = -o->vx * multiplier_x;
	o->vy = -o->vy * multiplier_y;
}

static void get_multipliers(OBJECT *o, OBJECT **c, int nc, float *multiplier_x, float *multiplier_y)
{
	*multiplier_x = 1.0;
	*multiplier_y = 1.0;

	int i;
	for (i = 0; i < nc; i++) {
		if (c[i]->type == BOUNCY_WALL) {
			if (o->type == PLAYER) {
				*multiplier_x = 1.5;
				*multiplier_y = 1.5;
			}
			else {
				*multiplier_x = 3.0;
				*multiplier_y = 3.0;
			}
			break;
		}
		else if (c[i]->type == UNBOUNCY_WALL) {
			*multiplier_x = -5000;
			*multiplier_y = -5000;
		}
	}
	
	if (o->type == PLAYER || o->type == MIAO_BALL) { // less bounce off walls
		*multiplier_x *= 0.5;
		*multiplier_y *= 0.5;
	}
}

static bool wall_collide(OBJECT *o)
{
	OBJECT *c[5];
	int nc = 0;
	int x, y;
	float multiplier_x, multiplier_y;

	for (y = 0; y < LEVEL_H; y++) {
		for (x = 0; x < LEVEL_W; x++) {
			if (objs[x][y].groups & ALL_WALLS) {
				if (WALL_COLLIDING((*o), objs[x][y])) {
					c[nc] = &objs[x][y];
					nc++;

				}
			}
		}
	}
	
	get_multipliers(o, c, nc, &multiplier_x, &multiplier_y);
	if (fabs(o->vx * multiplier_x) < 0.25) {
		if (fabs(o->vx) != 0)
			multiplier_x = fabs(0.25 / o->vx);
	}
	if (fabs(o->vy * multiplier_y) < 0.25) {
		if (fabs(o->vy) != 0)
			multiplier_y = fabs(0.25 / o->vy);
	}
	
	if (nc == 3) {
		o->vx = -o->vx * multiplier_x;
		o->vy = -o->vy * multiplier_y;
		return true;
	}
	else if (nc == 2) {
		if (c[0]->tx != c[1]->tx && c[0]->ty != c[1]->ty) {
			o->vx = -o->vx * multiplier_x;
			o->vy = -o->vy * multiplier_y;
			return true;
		}
		else if (c[0]->tx == c[1]->tx) {
			o->vx = -o->vx * multiplier_x;
			return true;
		}
		else if (c[0]->ty == c[1]->ty) {
			o->vy = -o->vy * multiplier_y;
			return true;
		}
	}
	else if (nc == 1) {
		int xx1 = c[0]->tx-1;
		int xx2 = c[0]->tx+1;
		int yy1 = c[0]->ty-1;
		int yy2 = c[0]->ty+1;

		// if hit top or bottom and it's a straight line horizontally
		if (
		    (o->x+4 > c[0]->x && o->x+TILE_SIZE-4 < c[0]->x+TILE_SIZE) &&
		    ((IN_BOUNDS(xx1, c[0]->ty) && (objs[xx1][c[0]->ty].groups & ALL_WALLS)) ||
		    (IN_BOUNDS(xx2, c[0]->ty) && (objs[xx2][c[0]->ty].groups & ALL_WALLS))))
		{
			o->vy = -o->vy * multiplier_y;
			return true;
		}		
		// "" left or right "" vertically
		else if (
		    (o->y+4 > c[0]->y && o->y+TILE_SIZE-4 < c[0]->y+TILE_SIZE) &&
		    ((IN_BOUNDS(c[0]->tx, yy1) && (objs[c[0]->tx][yy1].groups & ALL_WALLS)) ||
		    (IN_BOUNDS(c[0]->tx, yy2) && (objs[c[0]->tx][yy2].groups & ALL_WALLS))))
		{
			o->vx = -o->vx * multiplier_x;
			return true;
		}
		
		single_wall_collide(o, c[0], multiplier_x, multiplier_y);
		return true;
	}
	
	return false;
}

static bool top_speed_achieved = false;

/*
 * Move movable objects based on their velocity, acceleration,
 * gravity, collisions, etc.
 */
static void move_objects(void)
{
	player_anim_time += (10.0 / 1.0) * (1.0 / 60.0);

	int x, y, i, j;
	float save_x, save_y, save_vx, save_vy, save_ax, save_ay;
	
	/* move the objects */
	for (y = 0; y < LEVEL_H; y++) {
		for (x = 0; x < LEVEL_W; x++) {
			if (objs[x][y].live && 
				(objs[x][y].groups & ALL_BOUNCY))
			{
				// check for top speed achievement
				if (objs[x][y].type == PLAYER && !top_speed_achieved) {
					if (fabs(objs[x][y].vx)+0.01 >= MAX_V && fabs(objs[x][y].vy)+0.01 >= MAX_V) {
						top_speed_achieved = true;
#ifndef LITE
						reportAchievementIdentifier(MaximumVelocityID, MaximumVelocityS);
#endif
					}
				}
				
				OBJECT *c[50];
				int count;
				int groups;
				
				// apply fans
				if (objs[x][y].type != HEAVY_BALL) {
					int xx, yy;
					for (yy = 0; yy < LEVEL_H; yy++) {
						for (xx = 0; xx < LEVEL_W; xx++) {
							if (objs[xx][yy].groups & ALL_FANS) {
								float dx = objs[x][y].x - objs[xx][yy].x;
								float dy = objs[x][y].y - objs[xx][yy].y;
								float a = -DEG(atan2(dy, dx));
								while (a < 0) a += 360.0;
								if (abs(a-objs[xx][yy].angle) <= 22.5) {
									float dist = sqrt(dx*dx + dy*dy);
									if (dist < FAN_REACH) {
										float force = sin((FAN_REACH-dist)/FAN_REACH*M_PI/2) * FAN_FORCE;
										float angle;
										if (objs[xx][yy].type == FAN_LEFT)
											angle = -180;
										else if (objs[xx][yy].type == FAN_RIGHT)
											angle = -0;
										else if (objs[xx][yy].type == FAN_UP)
											angle = -90;
										else if (objs[xx][yy].type == FAN_DOWN)
											angle = -270;
										else
											angle = -objs[xx][yy].angle;
										apply_force(&objs[x][y], angle, force);
									}
								}
							}
						}
					}
				}

				// apply magnets
				if (objs[x][y].type == PLAYER) {
					int xx, yy;
					for (yy = 0; yy < LEVEL_H; yy++) {
						for (xx = 0; xx < LEVEL_W; xx++) {
							if (objs[xx][yy].type == MAGNET) {
								float dx = objs[x][y].x - objs[xx][yy].x;
								float dy = objs[x][y].y - objs[xx][yy].y;
								float dist = sqrt(dx*dx + dy*dy);
								if (dist < 256) {
									float force = -(256-dist)/256.0 * MAGNET_FORCE;
									float angle = DEG(atan2(dy, dx));
									apply_force(&objs[x][y], angle, force);
								}
							}
						}
					}
				}

				/* apply gravity */
				if (objs[x][y].vy < MAX_GRAVITY_V)
					apply_force(&objs[x][y], 90.0, GRAVITY);
				float brake_multiplier;
				if (x == player_x && y == player_y && brake_on)
					brake_multiplier = 15;
				else
					brake_multiplier = 1.0;
				DAMPEN(objs[x][y].ax, A_DAMP);
				DAMPEN(objs[x][y].ay, A_DAMP);
				DAMPEN(objs[x][y].vx, V_DAMP);
				DAMPEN(objs[x][y].vy, V_DAMP);
				CLAMP(objs[x][y].ax, MAX_A);
				CLAMP(objs[x][y].ay, MAX_A);
				objs[x][y].vx += objs[x][y].ax;
				objs[x][y].vy += objs[x][y].ay;
				CLAMP(objs[x][y].vx, MAX_V);
				CLAMP(objs[x][y].vy, MAX_V);
				save_x = objs[x][y].x;
				save_y = objs[x][y].y;
				save_vx = objs[x][y].vx;
				save_vy = objs[x][y].vy;
				save_ax = objs[x][y].ax;
				save_ay = objs[x][y].ay;
				objs[x][y].x += objs[x][y].vx;
				objs[x][y].y += objs[x][y].vy;

				bool wcoll = wall_collide(&objs[x][y]);
				if (wcoll && (objs[x][y].groups & ALL_BALLS)) {
					objs[x][y].hit_time = al_get_time();
				}

				/* check for collisions */
				if (object_colliding(&objs[x][y], c, &count, &groups)) {
					for (j = 0; j < count; j++) {
						if (!(c[j]->groups == (ALL_TRANSPORTER_START | ALL_TRANSPORTER))) {
							collide(&objs[x][y], c[j]);
							if (c[j]->groups & ALL_SPIRALS)
								break;
						}
					}

					if (groups & ALL_TRANSPORTER_START) {
						int look_for;
						for (j = 0; j < count; j++) {
							if (c[j]->groups & ALL_TRANSPORTER_START) {
								look_for = toupper(c[j]->type);
								break;
							}
						}
						int xx, yy;
						for (yy = 0; yy < LEVEL_H; yy++) {
							for (xx = 0; xx < LEVEL_W; xx++) {
								if (objs[xx][yy].type == look_for) {
									OBJECT tmp;
									tmp.x = objs[xx][yy].x;
									tmp.y = objs[xx][yy].y;
									tmp.live = true;
									tmp.tx = objs[xx][yy].tx;
									tmp.ty = objs[xx][yy].ty;
									OBJECT *c[100];
									int count;
									int groups;
									if (!object_colliding(&tmp, c, &count, &groups) || (groups == (ALL_TRANSPORTER_END | ALL_TRANSPORTER))) {
										playSample(spiral);
										objs[x][y].angle = 90;
										objs[x][y].x = objs[xx][yy].x;
										objs[x][y].y = objs[xx][yy].y;
										objs[x][y].ax = objs[x][y].ay = objs[x][y].vx = objs[x][y].vy = 0;
									}
									break;
								}
							}
						}
					}
					else {
						objs[x][y].x = save_x;
						objs[x][y].y = save_y;
					}

					if (objs[x][y].type == PLAYER && (groups & ALL_SWITCHES)) {
						char rm[2];
						for (j = 0; j < count; j++) {
							if (c[j]->type == SWITCH1) {
								rm[0] = SWITCH1, rm[1] = GATE1;
								break;
							}
							else if (c[j]->type == SWITCH2) {
								rm[0] = SWITCH2, rm[1] = GATE2;
								break;
							}
						}
						int xx, yy;
						for (yy = 0; yy < LEVEL_H; yy++) {
							for (xx = 0; xx < LEVEL_W; xx++) {
								if (objs[xx][yy].type == rm[0] || objs[xx][yy].type == rm[1]) {
									playSample(switch_sample);
									objs[xx][yy].type = EMPTY;
									objs[xx][yy].groups = OTHER;
									objs[xx][yy].live = 0;
								}
							}
						}
					}
				}
				else if (wcoll) {
					objs[x][y].x = save_x;
					objs[x][y].y = save_y;
				}
			}
			else if (objs[x][y].type == FAN_SPIN) {
				objs[x][y].angle += 0.4 * SPEED_MULT;
				if (objs[x][y].angle >= 360.0) objs[x][y].angle -= 360.0;
			}
			else if (objs[x][y].groups & ALL_SPIRALS) {
				objs[x][y].angle += 2;
			}
		}
	}
	

	// move smoke
	for (i = 0; i < NSMOKE ; i++) {
		if (smoke[i].life > 0) {
			smoke[i].life -= 1.0/LOGIC_PER_SEC;
			smoke[i].x += smoke[i].vx;
			smoke[i].y += smoke[i].vy;
		}
	}

	// move air currents
	wave -= 10 * SPEED_MULT;
}


/* scale an object down and rotate if it ran into a spiral */
static void update_scale(void)
{
	int x, y;

	for (y = 0; y < LEVEL_H; y++) {
		for (x = 0; x < LEVEL_W; x++) {
			if (!objs[x][y].live && objs[x][y].scale > 0) {
				objs[x][y].scale -= 1.0/100.0 * SPEED_MULT; // 2 second duration
				objs[x][y].angle -= 10 * SPEED_MULT;
			}
		}
	}
}


static int pixel_in_box(int x1, int y1, int w, int h, int x, int y)
{
	if (x >= x1 && x < x1+w && y >= y1 && y < y1+h)
		return true;
	return false;
}

static int right_icon_pressed(void)
{
    int ret = 0;
    _AL_LIST_ITEM *item = _al_list_front(touch_list);
    while (item) {
        TOUCH *t = _al_list_item_data(item);
        //int SH = SCR_H;
        if (pixel_in_box(SCR_W-PAUSE_SIZE, 0, PAUSE_SIZE, PAUSE_SIZE, t->x, t->y)) {
            ret = 1;
            break;
        }
        item = _al_list_next(touch_list, item);
    }
    return ret;
}

static int left_icon_pressed(void)
{
	int ret = 0;
	_AL_LIST_ITEM *item = _al_list_front(touch_list);
	while (item) {
		TOUCH *t = _al_list_item_data(item);
		//int SH = SCR_H;
		if (pixel_in_box(0, 0, PAUSE_SIZE, PAUSE_SIZE, t->x, t->y)) {
			ret = 1;
			break;
		}
		item = _al_list_next(touch_list, item);
	}
	return ret;
}

static void halftone(void)
{
	al_draw_filled_rectangle(
				 0, 0, SCR_W, SCR_H, al_map_rgba_f(0, 0, 0, 0.6)
				 );
}

static void draw_game_corners(void)
{
#ifdef ALLEGRO_IPHONE
	al_draw_bitmap(pause_bmp, SCR_W-PAUSE_SIZE+(PAUSE_SIZE-50)/2, (PAUSE_SIZE-50)/2, 0);
	if (paused) {
		al_draw_bitmap(quit_bmp, 0, (PAUSE_SIZE-40)/2, 0);
	}
#endif
}

/* center text on the screen, wait for a key, and return the key */
static void draw_pause(char *text)
{
	al_set_target_backbuffer(display);
    
	draw_everything(al_get_backbuffer(display), true);
	draw_scroll();

	halftone();
	
	draw_game_corners();

	int texty = SCR_H/2-al_get_font_line_height(font)-20;
	
	int w = al_get_bitmap_width(blue_button_bmp);
	int h = al_get_bitmap_height(blue_button_bmp);
	int yy = SCR_H/2+30-h*2-10;
	al_draw_bitmap(blue_button_bmp, 480-w/2, yy, 0);
	al_draw_bitmap(blue_button_bmp, 480-w/2, yy+h+5, 0);
	al_draw_bitmap(resume_bmp, 480-al_get_bitmap_width(resume_bmp)/2, yy, 0);
	al_draw_bitmap(abort_bmp, 480-al_get_bitmap_width(abort_bmp)/2, yy+h+5, 0);
	texty -= h*2 + 10;

	begin_text_draw();
	al_draw_text(font, al_map_rgb(255, 255, 255),
		SCR_W/2,
		texty,
		ALLEGRO_ALIGN_CENTRE, text);	
	end_text_draw();

	al_draw_bitmap(retry_button_bmp, SCR_W/2-al_get_bitmap_width(retry_button_bmp)/2,
		       SCR_H/2+30, 0);

	flip_display();
}

#if defined ALLEGRO_IPHONE
static void openWebsite(void)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	const char *url_ascii = "http://www.nooskewl.com";
	NSString *u = [[NSString alloc] initWithCString:url_ascii encoding:NSUTF8StringEncoding];
	CFURLRef url = CFURLCreateWithString(NULL, (CFStringRef)u, NULL);
	[[UIApplication sharedApplication] openURL:(NSURL *)url];
	[u release];
	CFRelease(url);
	
	[pool drain];
	
	exit(0);
}
#elif defined ALLEGRO_MACOSX
static void openWebsite(void)
{
	NSURL *url = [[NSURL alloc] initWithString:@"http://www.nooskewl.com"];
	[[NSWorkspace sharedWorkspace] openURL:url];
	[url release];
	exit(0);
}
#elif defined ALLEGRO_WINDOWS
static void openWebsite(void)
{
	STARTUPINFO si;
	PROCESS_INFORMATION pi;

        memset(&si, 0, sizeof(si));
        memset(&pi, 0, sizeof(pi));

	si.cb = sizeof(si);
	
	char cmdline[100];
	strcpy(cmdline, "rundll32 url.dll,FileProtocolHandler http://www.nooskewl.com");

	CreateProcess(
	  NULL,
	  cmdline,
	  NULL,
	  NULL,
	  false,
	  NORMAL_PRIORITY_CLASS,
	  NULL,
	  NULL,
	  &si,
	  &pi
	);

	CloseHandle(pi.hProcess);
	CloseHandle(pi.hThread);

	exit(0);
}
#else
static void openWebsite(void)
{
}
#endif

static void forward(void)
{
	apply_force(&objs[player_x][player_y], -objs[player_x][player_y].angle, THRUST);
	if (al_get_time() > next_smoke) {
		next_smoke = al_get_time() + 1.0 / NSMOKE;
		int i;
		for (i = 0; i < NSMOKE; i++) {
			if (smoke[i].life <= 0) {
				smoke[i].life = 1.0;
				int r = rand() % 5;
				if (r == 0)
					smoke[i].bmp_index = 0;
				else if (r == 1)
					smoke[i].bmp_index = 1;
				else
					smoke[i].bmp_index = 2;
				float x =
					cos(RAD(objs[player_x][player_y].angle));
				float y =
					sin(RAD(objs[player_x][player_y].angle));
				smoke[i].x = (objs[player_x][player_y].x + TILE_SIZE/2) -
					x * TILE_SIZE*3/4;
				smoke[i].y = (objs[player_x][player_y].y + TILE_SIZE/2) +
					y * TILE_SIZE*3/4;
				float da = ((rand() % 100) / 100.0) * 60 - 30;
				smoke[i].vx =
					-cos(RAD(objs[player_x][player_y].angle+da)) * 0.75 * SPEED_MULT;
				smoke[i].vy =
					sin(RAD(objs[player_x][player_y].angle+da)) * 0.75 * SPEED_MULT;
				int xx = rand() % 100;
				int yy = rand() % 100;
				if (use_kitty) {
					smoke[i].color = al_get_pixel(rainbow_bmp, xx, yy);
				}
				else {
					smoke[i].color = al_get_pixel(gradient_bmp, xx, yy);
				}
				break;
			}
		}
	}
}
static void left(void)
{
	objs[player_x][player_y].angle += 3.0 * SPEED_MULT;
}
static void right(void)
{
	objs[player_x][player_y].angle -= 3.0 * SPEED_MULT;
}

static void left90(void)
{
	    float a = objs[player_x][player_y].angle;
	    while (a < 0) a += 360;
	    a = fmod(a, 360.0f);
	    if (a >= 270)
	    {
		a = 0;
	    }
	    else if (a >= 180)
	    {
		a = 270;
	    }
	    else if (a >= 90)
	    {
		a = 180;
	    }
	    else
	    {
		a = 90;
	    }
	    objs[player_x][player_y].angle = a;
}

static void right90(void)
{
	    float a = objs[player_x][player_y].angle;
	    while (a < 0) a += 360;
	    a = fmod(a, 360.0f);
	    if (a == 0 || a > 270)
	    {
		a = 270;
	    }
	    else if (a > 180)
	    {
		a = 180;
	    }
	    else if (a > 90)
	    {
		a = 90;
	    }
	    else
	    {
		a = 0;
	    }
	    objs[player_x][player_y].angle = a;
}

int thrust_count;

// return false to abort game
static bool handle_input(void)
{
	if (switched_out)
		return true;

	brake_on = false;

	bool stop_sample = true;

	bool on_left = false;
	bool on_right = false;
	
	al_lock_mutex(input_mutex);
	_AL_LIST_ITEM *item = _al_list_front(touch_list);
	while (item) {
		TOUCH *t = _al_list_item_data(item);
		if (in_game) {
			if (t->y < (SCR_H/2)) {
				controls_on_top = true;
			}
			else {
				controls_on_top = false;
			}
		}
		if (!paused && right_icon_pressed() && al_get_time()-pause_pressed >= 0.5) {
			pause_game(true);
		}
		else if (paused && left_icon_pressed()) {
			al_unlock_mutex(input_mutex);
			al_rest(0.5);
			return false;
		}
		
		if (!paused) {
#ifdef ALLEGRO_IPHONE
			int yy = controls_on_top ? SCR_H-(LEVEL_H*TILE_SIZE) : SCR_H-(BUTTON_SIZE+OFFSET);

			if (pixel_in_box(OFFSET, yy,
				BUTTON_SIZE, BUTTON_SIZE, t->x, t->y)) {
				on_left = true;
			}
			if (pixel_in_box(BUTTON_SIZE+OFFSET*2, yy,
				BUTTON_SIZE, BUTTON_SIZE, t->x, t->y)) {
				on_right = true;
			}
			if (pixel_in_box(SCR_W-BUTTON_SIZE-OFFSET,
				yy, BUTTON_SIZE, BUTTON_SIZE,
				t->x, t->y)) {
				brake_on = true;
			}
			if (pixel_in_box(SCR_W-BUTTON_SIZE*2-OFFSET, yy, BUTTON_SIZE, BUTTON_SIZE, t->x, t->y)) {
				stop_sample = false;
				if (!thrusting) {
					thrusting = true;
					playSampleVolume(boost, 0.5);
					thrust_count++;
					player_anim = 0;
					player_anim_time = 0;
				}
				forward();
			}
#endif
		}
		item = _al_list_next(touch_list, item);
	}
	
	if (lastleftright90 < al_get_time()-0.25) {
		if (on_left && on_right) {
			right90();
			lastleftright90 = al_get_time();
		}
		else if (on_left) {
			left();
		}
		else if (on_right) {
			right();
		}
	}
	
	al_unlock_mutex(input_mutex);
	
	
#if defined ALLEGRO_IPHONE || defined ALLEGRO_MACOSX
	if (joypad && joypad->connected) {
		if (joypad->bl)
			hide_controls = true;
		if (joypad->br)
			hide_controls = false;
		if (joypad->by) {
			if (!paused && al_get_time()-pause_pressed >= 0.5) {
				pause_game(true);
				return true;
			}
			else if (al_get_time()-pause_pressed >= 0.5)
			{
				al_lock_mutex(input_mutex);
				do_unpause();
				al_unlock_mutex(input_mutex);
			}
		}
		if (!paused) {
			if (joypad->ba) {
				stop_sample = false;
				if (!thrusting) {
					thrusting = true;
					playSampleVolume(boost, 0.5);
					thrust_count++;
					player_anim = 0;
					player_anim_time = 0;
				}
				forward();
			}
			if (joypad->left) {
				left();
			}
			if (joypad->right) {
				right();
			}
			if (joypad->bb) {
				brake_on = true;
				player_anim = 0;
			}
			if (!joypad->bl && !joypad->br) {
				lastleftright90 = 0;
			}
			else if (lastleftright90 < al_get_time()-0.25) {
				if (joypad->bl) {
					left90();
					lastleftright90 = al_get_time();
				}
				if (joypad->br) {
					right90();
					lastleftright90 = al_get_time();
				}
			}
		}
	}

	if (sb_on) {
		if (sb_3) {
			if (!paused && al_get_time()-pause_pressed >= 0.5) {
				pause_game(true);
				return true;
			}
			else if (al_get_time()-pause_pressed >= 0.5)
			{
				al_lock_mutex(input_mutex);
				do_unpause();
				al_unlock_mutex(input_mutex);
			}
		}
		if (!paused) {
			if (sb_1) {
				stop_sample = false;
				if (!thrusting) {
					thrusting = true;
					playSampleVolume(boost, 0.5);
					thrust_count++;
					player_anim = 0;
					player_anim_time = 0;
				}
				forward();
			}
			if (sb_l) {
				left();
			}
			if (sb_r) {
				right();
			}
			if (sb_2) {
				brake_on = true;
				player_anim = 0;
			}
			if (!sb_l1 && !sb_r1) {
				lastleftright90 = 0;
			}
			else if (lastleftright90 < al_get_time()-0.25) {
				if (sb_l1) {
					left90();
					lastleftright90 = al_get_time();
				}
				if (sb_r1) {
					right90();
					lastleftright90 = al_get_time();
				}
			}
		}
	}
#endif


#ifndef ALLEGRO_IPHONE
	if (joy) {
		if (joy_pause) {
			if (!paused && al_get_time()-pause_pressed >= 0.5) {
				pause_game(true);
				return true;
			}
			else if (al_get_time()-pause_pressed >= 0.5)
			{
				al_lock_mutex(input_mutex);
				do_unpause();
				al_unlock_mutex(input_mutex);
			}
		}
		if (!paused) {
			if (joy_a) {
				stop_sample = false;
				if (!thrusting) {
					thrusting = true;
					playSampleVolume(boost, 0.5);
					thrust_count++;
					player_anim = 0;
					player_anim_time = 0;
				}
				forward();
			}
			if (joy_l) {
				left();
			}
			if (joy_r) {
				right();
			}
			if (joy_b) {
				brake_on = true;
				player_anim = 0;
			}
		}
	}


	if (!paused && esc_pressed && al_get_time()-pause_pressed >= 0.5) {
		pause_game(true);
		return true;
	}
	if (!paused) {
		if (z_pressed) {
			stop_sample = false;
			if (!thrusting) {
				thrusting = true;
				playSampleVolume(boost, 0.5);
				thrust_count++;
				player_anim = 0;
				player_anim_time = 0;
			}
			forward();
		}
		if (l_pressed) {
			left();
		}
		if (r_pressed) {
			right();
		}
		if (d_pressed) {
			brake_on = true;
			player_anim = 0;
		}
	}
#endif

	if (stop_sample) {
		if (thrusting) {
			thrusting = false;
			stopSample(boost);
			player_anim = 1;
			player_anim_time = 0;
		}
	}
	
	return true;
}

int waiting_for_key_x;
int waiting_for_key_y;

static void *input_thread(void *data)
{
	for (;;) {
		ALLEGRO_EVENT event;
        
		bool got_event = al_wait_for_event_timed(input_queue, &event, 1.0/60.0);

		// mouse emulation
		if (!got_event && (!in_game || paused)) {
			const int sp = 8;
			static bool entered = false;
			if (curs_l) {
				mouse_x -= sp;
				set_mouse_xy(display, mouse_x, mouse_y);
			}
			if (curs_r) {
				mouse_x += sp;
				set_mouse_xy(display, mouse_x, mouse_y);
			}
			if (curs_u) {
				mouse_y -= sp;
				set_mouse_xy(display, mouse_x, mouse_y);
			}
			if (curs_d) {
				mouse_y += sp;
				set_mouse_xy(display, mouse_x, mouse_y);
			}
			if (curs_enter && !entered) {
				TOUCH *t = malloc(sizeof(TOUCH));
				t->ident = 1001;
				t->x = mouse_x / scr_scale_x;
				t->y = mouse_y / scr_scale_y;
				_al_list_push_back(touch_list, t);
				entered = true;
			}
			else if (!curs_enter && entered) {
				entered = false;
			}
			else if (curs_enter) {
				_AL_LIST_ITEM *item = _al_list_front(touch_list);
				while (item) {
					TOUCH *t = _al_list_item_data(item);
					if (t->ident == 1001) {
						t->x = mouse_x / scr_scale_x;
						t->y = mouse_y / scr_scale_y;
						break;
					}
					item = _al_list_next(touch_list, item);
				}
			}
		}

		if (got_event) {
			if (switched_out) {
				if (event.type == ALLEGRO_EVENT_DISPLAY_SWITCH_IN || event.type == ALLEGRO_EVENT_DISPLAY_RESUME_DRAWING) {
					switch_game_in();
				}
				continue;
			}
		}
		
		
		al_lock_mutex(input_mutex);
		
		if (got_event) {
       
#ifndef ALLEGRO_IPHONE 
			if (event.type == ALLEGRO_EVENT_DISPLAY_CLOSE) {
				display_closed = true;
				save_save();
				exit(0);
			}
#endif
			if (event.type == ALLEGRO_EVENT_TOUCH_BEGIN || event.type == ALLEGRO_EVENT_TOUCH_MOVE) {
				mouse_x = event.touch.x;
				mouse_y = event.touch.y;
			}
			#ifndef ALLEGRO_IPHONE
			if (event.type == ALLEGRO_EVENT_MOUSE_AXES) {
				mouse_x = event.mouse.x;
				mouse_y = event.mouse.y;
			}
			#endif
			if (event.type == ALLEGRO_EVENT_TOUCH_BEGIN) {
				TOUCH *t = malloc(sizeof(TOUCH));
				t->ident = event.touch.id;
				t->x = event.touch.x / scr_scale_x;
				t->y = event.touch.y / scr_scale_y;
				_al_list_push_back(touch_list, t);
			}
			else if (event.type == ALLEGRO_EVENT_TOUCH_MOVE) {
				_AL_LIST_ITEM *item = _al_list_front(touch_list);
				while (item) {
					TOUCH *t = _al_list_item_data(item);
					if (t->ident == event.touch.id) {
						t->x = event.touch.x / scr_scale_x;
						t->y = event.touch.y / scr_scale_y;
						break;
					}
					item = _al_list_next(touch_list, item);
				}
			}
			else if (event.type == ALLEGRO_EVENT_TOUCH_END || event.type == ALLEGRO_EVENT_TOUCH_CANCEL) {
				_AL_LIST_ITEM *item = _al_list_front(touch_list);
				while (item) {
					TOUCH *t = _al_list_item_data(item);
					if (t->ident == event.touch.id) {
						free(t);
						break;
					}
					item = _al_list_next(touch_list, item);
				}
				_al_list_erase(touch_list, item);
			}
#ifndef ALLEGRO_IPHONE
			else if (event.type == ALLEGRO_EVENT_MOUSE_BUTTON_DOWN) {
				_al_list_clear(touch_list);
				TOUCH *t = malloc(sizeof(TOUCH));
				t->ident = 1;
				t->x = event.mouse.x / scr_scale_x;
				t->y = event.mouse.y / scr_scale_y;
				_al_list_push_back(touch_list, t);
			}
			else if (event.type == ALLEGRO_EVENT_MOUSE_AXES) {
				if (_al_list_size(touch_list) > 0) {
					_AL_LIST_ITEM *item = _al_list_front(touch_list);
					TOUCH *t = _al_list_item_data(item);
					t->x = event.mouse.x / scr_scale_x;
					t->y = event.mouse.y / scr_scale_y;
				}
			}
			else if (event.type == ALLEGRO_EVENT_MOUSE_BUTTON_UP) {
				clear_all_mouse_events();
			}
			else if (event.type == ALLEGRO_EVENT_KEY_DOWN) {
				keysDown++;
				switch (event.keyboard.keycode) {
					case ALLEGRO_KEY_SPACE: // ok, it's not Z
						z_pressed = true;
						cursor_enter(true);
						break;
					case ALLEGRO_KEY_LEFT:
						l_pressed = true;
						cursor_left(true);
						break;
					case ALLEGRO_KEY_RIGHT:
						r_pressed = true;
						cursor_right(true);
						break;
					case ALLEGRO_KEY_UP:
						u_pressed = true;
						cursor_up(true);
						break;
					case ALLEGRO_KEY_DOWN:
						d_pressed = true;
						cursor_down(true);
						break;
					case ALLEGRO_KEY_ESCAPE:
						esc_pressed = true;
						break;
				}
				if (lastleftright90 < al_get_time()-0.25) {
					if (event.keyboard.keycode == ALLEGRO_KEY_OPENBRACE) {
						left90();
						lastleftright90 = al_get_time();
					}
					else if (event.keyboard.keycode == ALLEGRO_KEY_CLOSEBRACE) {
						right90();
						lastleftright90 = al_get_time();
					}
				}
			}
			else if (event.type == ALLEGRO_EVENT_KEY_UP) {
				keysDown--;
				switch (event.keyboard.keycode) {
					case ALLEGRO_KEY_SPACE:
						z_pressed = false;
						cursor_enter(false);
						break;
					case ALLEGRO_KEY_LEFT:
						l_pressed = false;
						cursor_left(false);
						break;
					case ALLEGRO_KEY_RIGHT:
						r_pressed = false;
						cursor_right(false);
						break;
					case ALLEGRO_KEY_UP:
						u_pressed = false;
						cursor_up(false);
						break;
					case ALLEGRO_KEY_DOWN:
						d_pressed = false;
						cursor_down(false);
						break;
					case ALLEGRO_KEY_ESCAPE:
						esc_pressed = false;
						break;
				}
			}
#endif

#ifndef ALLEGRO_IPHONE
			if (event.type == ALLEGRO_EVENT_JOYSTICK_CONFIGURATION)
			{
				al_reconfigure_joysticks();
				configure_joysticks();
			}
			else if (event.type == ALLEGRO_EVENT_JOYSTICK_BUTTON_DOWN)
			{
				if (event.joystick.button == 0)
				{
					joy_a = true;
					cursor_enter(true);
				}
				else if (event.joystick.button == 1)
				{
					joy_b = true;
				}
				else if (event.joystick.button == 2)
				{
					joy_pause = true;
				}
				else if (event.joystick.button == 3) {
					if (lastleftright90 < al_get_time()-0.25) {
						right90();
						lastleftright90 = al_get_time();
					}
				}
			}
			else if (event.type == ALLEGRO_EVENT_JOYSTICK_BUTTON_UP)
			{
				if (event.joystick.button == 0)
				{
					joy_a = false;
					cursor_enter(false);
				}
				else if (event.joystick.button == 1)
				{
					joy_b = false;
				}
				else if (event.joystick.button == 2)
				{
					joy_pause = false;
				}
			}
			else if (event.type == ALLEGRO_EVENT_JOYSTICK_AXIS)
			{
				if (event.joystick.axis == 0) {
					if (event.joystick.pos < -0.5) {
						joy_l = true;
						cursor_left(true);
					}
					else {
						joy_l = false;
						cursor_left(false);
					}
					if (event.joystick.pos > 0.5) {
						joy_r = true;
						cursor_right(true);
					}
					else {
						joy_r = false;
						cursor_right(false);
					}
				}
				if (event.joystick.axis == 1) {
					if (event.joystick.pos < -0.5) {
						joy_u = true;
						cursor_up(true);
					}
					else {
						joy_u = false;
						cursor_up(false);
					}
					if (event.joystick.pos > 0.5) {
						joy_d = true;
						cursor_down(true);
					}
					else {
						joy_d = false;
						cursor_down(false);
					}
				}
			}
#endif
		}

		if (paused && al_get_time()-pause_pressed >= 0.5) {
#ifdef ALLEGRO_IPHONE
			if (right_icon_pressed()) {
#else
			if (esc_pressed) {
#endif
				do_unpause();
			}
		}
		
		if (waiting_for_key) {
			if (waiting_for_key_release) {
#ifdef ALLEGRO_IPHONE
				if (_al_list_size(touch_list) <= 0) {
#else
				if (!z_pressed) {
#endif
					waiting_for_key = false;
					waiting_for_key_release = false;
					al_start_timer(logic_timer);
					al_start_timer(draw_timer);
					playSample(bink);
				}
			}
			else {
#ifdef ALLEGRO_IPHONE
				if (_al_list_size(touch_list) > 0) {
					_AL_LIST_ITEM *item = _al_list_front(touch_list);
					TOUCH *t = _al_list_item_data(item);
					waiting_for_key_x = t->x;
					waiting_for_key_y = t->y;
#else
				if (_al_list_size(touch_list) > 0) {
					_AL_LIST_ITEM *item = _al_list_front(touch_list);
					TOUCH *t = _al_list_item_data(item);
					waiting_for_key_x = t->x;
					waiting_for_key_y = t->y;
				}
				else if (z_pressed) {
#endif
					waiting_for_key_release = true;
				}
			}
		}
                
				al_unlock_mutex(input_mutex);
    }
    
    return NULL;
}

static void updateStarAlpha(void)
{
	starAlpha += starAlphaInc;
	if (starAlphaInc > 0 && starAlpha > 1.0) {
		starAlphaInc = -starAlphaInc;
		starAlpha = 1.0;
	}
	else if (starAlphaInc < 0 && starAlpha < 0.0) {
		starAlphaInc = -starAlphaInc;
		starAlpha = 0.0;
	}
}

static void updateSpaceStuff(void)
{
	if (nextSpaceThing < al_get_time() && numSpaceThings < MAX_SPACE_THINGS-1) {
		nextSpaceThing = al_get_time() + minSpaceThingTime + ((rand()%RAND_MAX)/(float)RAND_MAX)*(maxSpaceThingTime-minSpaceThingTime);
		spaceThings[numSpaceThings].x = SCR_W+rand()%50;
		spaceThings[numSpaceThings].y = rand()%(LEVEL_H*TILE_SIZE)-50;
		spaceThings[numSpaceThings].bmp_index = spaceThingOrder[curr_space_thing++];
		curr_space_thing %= NUM_DIFFERENT_SPACE_THINGS;
		numSpaceThings++;
	}
	int k;
	for (k = 0; k < numSpaceThings; k++) {
		spaceThings[k].x -= spaceThingInc;
		if (spaceThings[k].x < -al_get_bitmap_width(space_bmps[spaceThings[k].bmp_index])) {
			int l;
			for (l = k; l < MAX_SPACE_THINGS-1; l++) {
				spaceThings[l] = spaceThings[l+1];
			}
			numSpaceThings--;
			k--;
		}
	}
}

const int RETRY_RETRY = 1;
const int RETRY_MENU = 2;
const int RETRY_CLOSE = 3;

static void load_retry_bitmaps(void)
{
#ifdef ALLEGRO_IPHONE
	al_set_new_bitmap_format(ALLEGRO_PIXEL_FORMAT_RGB_565);
#endif
	retry_bmp = al_load_bitmap(getResource("retry.png"));
#ifdef ALLEGRO_IPHONE
	al_set_new_bitmap_format(ALLEGRO_PIXEL_FORMAT_RGBA_4444);	
#endif
}

static void destroy_retry_bitmaps(void)
{
	al_destroy_bitmap(retry_bmp);
}

static int retry(void)
{
	load_retry_bitmaps();

	al_start_timer(logic_timer);
	al_start_timer(draw_timer);

	bool redraw = true;
	
	al_set_target_backbuffer(display);
	
	while (true) {
		ALLEGRO_EVENT event;
		
		while (!al_event_queue_is_empty(queue)) {
			al_get_next_event(queue, &event);
			
#ifdef ALLEGRO_IPHONE
			if (event.type == ALLEGRO_EVENT_DISPLAY_SWITCH_OUT) {
				switch_game_out(false);
				redraw = true;
			}
			else if (event.type == ALLEGRO_EVENT_DISPLAY_HALT_DRAWING) {
				switch_game_out(true);
				redraw = true;
				if (!isMultitaskingSupported())
					exit(0);
				continue;
			}
			else
#endif
				if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == logic_timer) {		
					al_lock_mutex(input_mutex);
					// go through list
					_AL_LIST_ITEM *item = _al_list_front(touch_list);
					while (item) {
						TOUCH *t = _al_list_item_data(item);

						int tx = t->x;
						int ty = t->y;
						
						if (POINT_IN_BOX(tx, ty, SCR_W/2-10-al_get_bitmap_width(retry_button_bmp), SCR_H/2-al_get_bitmap_height(retry_button_bmp)/2, al_get_bitmap_width(retry_button_bmp), al_get_bitmap_height(retry_button_bmp))) {
							destroy_retry_bitmaps();
							al_unlock_mutex(input_mutex);
							playSample(bink);
							al_rest(0.5);
							return RETRY_RETRY;
						}
						else if (POINT_IN_BOX(tx, ty, SCR_W/2+10, SCR_H/2-al_get_bitmap_height(menu_button_bmp)/2, al_get_bitmap_width(menu_button_bmp), al_get_bitmap_height(menu_button_bmp))) {
							destroy_retry_bitmaps();
							al_unlock_mutex(input_mutex);
							playSample(bink);
							al_rest(0.5);
							return RETRY_MENU;
						}
						item = _al_list_next(touch_list, item);
					}
					al_unlock_mutex(input_mutex);
				}
				else if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == draw_timer) {
					redraw = true;
				}
		}
		
		al_lock_mutex(switched_out_mutex);
		if (redraw && !switched_out) {
			al_draw_bitmap(retry_bmp, 0, 0, 0);
			al_draw_bitmap(retry_button_bmp, SCR_W/2-10-al_get_bitmap_width(retry_button_bmp), SCR_H/2-al_get_bitmap_height(retry_button_bmp)/2, 0);
			al_draw_bitmap(menu_button_bmp, SCR_W/2+10, SCR_H/2-al_get_bitmap_height(menu_button_bmp)/2, 0);
			flip_display();
		}
		al_unlock_mutex(switched_out_mutex);
		
		al_rest(0.001);
	}
}

const int MAIN_CLOSE = 0;
const int MAIN_MENU = 1;
const int MAIN_QUIT = 2;
const int MAIN_RETRY = 3;

static void load_main_bitmaps(void)
{
#ifdef ALLEGRO_IPHONE
	al_set_new_bitmap_format(ALLEGRO_PIXEL_FORMAT_RGB_565);
#endif
	bg_bmp = al_load_bitmap(getResource("bg1.png"));
#ifdef ALLEGRO_IPHONE
	al_set_new_bitmap_format(ALLEGRO_PIXEL_FORMAT_RGBA_4444);
#endif
	
}

static void destroy_main_bitmaps(void)
{
	al_destroy_bitmap(bg_bmp);
}

static int main_game_loop(void)
{
	load_main_bitmaps();

	if (!noMusic && music_on) {
		stopMusic(); // menu music
		playMusic(false);
	}
	
	bool redraw = false;
	gameStartTime = al_get_time();
	gameElapsedTime = 0.0;
    
	for (;;) {
		int timer_ticks = 0;

		ALLEGRO_EVENT event;

		while (!al_event_queue_is_empty(queue)) {
			al_get_next_event(queue, &event);

#ifdef ALLEGRO_IPHONE
			if (event.type == ALLEGRO_EVENT_DISPLAY_SWITCH_OUT) {
				draw_pause("Press pause to resume");
				switch_game_out(false);
			}
			else if (event.type == ALLEGRO_EVENT_DISPLAY_HALT_DRAWING) {
				switch_game_out(true);
				redraw = true;
				if (!isMultitaskingSupported())
					exit(0);
				continue;
			}
			else
#endif
			if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == logic_timer) {
				timer_ticks++;
			}
			else if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == draw_timer) {
				redraw = true;
			}
		}

		timer_ticks = timer_ticks > 10 ? 10 : timer_ticks;
		int i;
		for (i = 0; i < timer_ticks; i++) {
			updateStarAlpha();
			updateStars();
			
			gameElapsedTime += 1.0/LOGIC_PER_SEC;

			if (!handle_input()) {
				playSample(bink);
				paused = false;
				next_time = 0;
				if (music_on) {
					stopMusic();
					playMusic(true);
				}
				destroy_main_bitmaps();
				return MAIN_QUIT;
			}

			if (!paused && !waiting_for_key) {
				/* move stuff */
				move_objects();
				update_scale();
			
				updateSpaceStuff();
				
				update_scroll();

				if (next_time > 0) {
					next_time -= 1.0/LOGIC_PER_SEC;
					if (next_time <= 0) {
						next_time = 0;
						if (music_on) {
							stopMusic();
							playMusic(true);
						}
						destroy_main_bitmaps();
						return MAIN_MENU;
					}
				}
			}
			else if (paused) {
				al_lock_mutex(input_mutex);
				_AL_LIST_ITEM *item = _al_list_front(touch_list);
				while (item) {
					TOUCH *t = _al_list_item_data(item);
					
					int tx = t->x;
					int ty = t->y;
					
					int yyy = SCR_H/2+30-al_get_bitmap_height(blue_button_bmp)*2-10;
					
					if (POINT_IN_BOX(tx, ty, SCR_W/2-al_get_bitmap_width(retry_button_bmp)/2,
							 SCR_H/2+30, al_get_bitmap_width(retry_button_bmp),
							 al_get_bitmap_height(retry_button_bmp))) {
						destroy_main_bitmaps();
						al_unlock_mutex(input_mutex);
						playSample(bink);
						paused = false;
						next_time = 0;
						if (music_on)
							stopMusic();
						al_rest(0.5);
						return MAIN_RETRY;
					}
					else if (POINT_IN_BOX(tx, ty, SCR_W/2-al_get_bitmap_width(blue_button_bmp)/2,
							 yyy, al_get_bitmap_width(blue_button_bmp),
							 al_get_bitmap_height(blue_button_bmp))) {
						al_rest(0.5);
						do_unpause();
						break;
					}
					else if (POINT_IN_BOX(tx, ty, SCR_W/2-al_get_bitmap_width(blue_button_bmp)/2,
							 yyy+al_get_bitmap_height(blue_button_bmp)+5,
							 al_get_bitmap_width(blue_button_bmp),
							 al_get_bitmap_height(blue_button_bmp))) {
						playSample(bink);
						paused = false;
						next_time = 0;
						if (music_on) {
							stopMusic();
							playMusic(true);
						}
						destroy_main_bitmaps();
						al_unlock_mutex(input_mutex);
						return MAIN_QUIT;
					}
		
					item = _al_list_next(touch_list, item);
				}
				al_unlock_mutex(input_mutex);
			}
		}

		al_lock_mutex(switched_out_mutex);
		if (!waiting_for_key && !paused && !switched_out && redraw) {
			redraw = false;
			draw_everything(al_get_backbuffer(display), true);
			draw_scroll();
			draw_game_corners();
			flip_display();
		}
		else if (paused && !switched_out && redraw) {
#ifdef ALLEGRO_IPHONE
			draw_pause("Press pause to resume");
#else
			draw_pause("Press escape to resume");
#endif
		}
		else
			al_rest(0.001);
		al_unlock_mutex(switched_out_mutex);
	}

	if (music_on)
		stopMusic();
	
	destroy_main_bitmaps();
	return MAIN_MENU;
}

static bool start_the_game(void)
{
top:
#if defined ALLEGRO_IPHONE || defined ALLEGRO_MACOSX
	[joypad performSelectorOnMainThread: @selector(stop_finding_devices) withObject:nil waitUntilDone:YES];
#endif

	player_anim_time = 0;
	player_anim = 0;

	thrust_count = 0;
	
	load_atlas();

	int i;
	for (i = 0; i < NUM_STARS; i++) {
		newStar(i);
	}
	
	space_bmps[0] = al_load_bitmap(getResource("spacestuff/fireball.png"));
	space_bmps[1] = al_load_bitmap(getResource("spacestuff/nebula.png"));
	space_bmps[2] = al_load_bitmap(getResource("spacestuff/blackhole.png"));
	space_bmps[3] = al_load_bitmap(getResource("spacestuff/images.png"));
	space_bmps[4] = al_load_bitmap(getResource("spacestuff/images2.png"));
	space_bmps[5] = al_load_bitmap(getResource("spacestuff/images3.png"));
	space_bmps[6] = al_load_bitmap(getResource("spacestuff/images4.png"));
	space_bmps[7] = al_load_bitmap(getResource("spacestuff/images5.png"));

	nextSpaceThing = al_get_time();
	numSpaceThings = 0;

	for (i = 0; i < NUM_DIFFERENT_SPACE_THINGS; i++) {
		int next = rand() % NUM_DIFFERENT_SPACE_THINGS;
		bool found;
		do {
			int j;
			found = false;
			for (j = 0; j < i; j++) {
				if (spaceThingOrder[j] == next) {
					next++;
					next %= NUM_DIFFERENT_SPACE_THINGS;
					found = true;
					break;
				}
			}
		} while (found);
		spaceThingOrder[i] = next;
	}
	
	for (i = 0; i < 4; i++) {
		last5starts[i] = last5starts[i+1];
		last5levels[i] = last5levels[i+1];
		last5stars[i] = last5stars[i+1];
	}
	last5starts[4] = al_get_time();
	last5levels[4] = level;
	
	al_start_timer(logic_timer);
	al_start_timer(draw_timer);
	
	nballs = 0;
	next_time = 0;
	playSample(start);
	load_level(level);

	in_game = true;
	int ret = main_game_loop();
	in_game = false;
	
	if (ret == MAIN_CLOSE) {
		for (i = 0; i < NUM_DIFFERENT_SPACE_THINGS; i++)
			al_destroy_bitmap(space_bmps[i]);
		return false;
	}

	int killed = nballs_start - nballs;
	level--;
	
	int nstars = -1;
	
	if (nballs_start == 0) {
		if (!hit_totally_evil_spiral)
			nstars = 3;
	}
	else if (!hit_totally_evil_spiral) {
		if (nballs == 0) {
			nstars = 3;
		}
		else if ((float)killed/nballs_start >= 0.5 && stars[level] < 2) {
			nstars = 2;
		}
		else if ((float)killed/nballs_start >= 0.25 && stars[level] < 1) {
			nstars = 1;
		}
	}
	
	if (ret != MAIN_RETRY && ret != MAIN_QUIT && (nstars != 3 && stars[level] != 3)) {
		int r = retry();
		if (r == RETRY_CLOSE) {
			for (i = 0; i < NUM_DIFFERENT_SPACE_THINGS; i++)
				al_destroy_bitmap(space_bmps[i]);
			return false;
		}
		else if (r == RETRY_MENU)
			ret = MAIN_MENU;
		else
			ret = MAIN_RETRY;
	}
	
	if (nstars > 0)
		stars[level] = nstars;
	
	last5stars[4] = nstars;
	uninterrupted_stars[level] = nstars;

#ifndef LITE
	/* Check for some achievements */
	// Ballz Champion
	for (i = 0; i < 16; i++) {
		if (stars[i] != 3)
			break;
	}
	if (i == 16) {
		reportAchievementIdentifier(BallzChampionID, BallzChampionS);
	}
	// PerseveringPlayer
	for (i = 0; i < 65; i++) {
		if (stars[i] != 3)
			break;
	}
	if (i == 65) {
		reportAchievementIdentifier(PerseveringPlayerID, PerseveringPlayerS);
	}
	// Magnetic Marvel
	for (i = 65; i < 75; i++) {
		if (stars[i] != 3)
			break;
	}
	if (i == 75) {
		reportAchievementIdentifier(MagneticMarvelID, MagneticMarvelS);
	}
	// TwentyTwoAndFeelingBlue
	if (level == 21 && gameElapsedTime <= 120 && nballs == 0) {
		reportAchievementIdentifier(TwentyTwoAndFeelingBlueID, TwentyTwoAndFeelingBlueS);
	}
	// SixtyInSeconds
	if (level == 59 && gameElapsedTime <= 150 && nballs == 0) {
		reportAchievementIdentifier(SixtyInSecondsID, SixtyInSecondsS);
	}
	// QuickOne
	if (level == 0 && gameElapsedTime <= 15 && nballs == 0) {
		reportAchievementIdentifier(QuickOneID, QuickOneS);
	}
	// OneThrust
	if (thrust_count == 1 && nstars == 3) {
		reportAchievementIdentifier(OneThrustID, OneThrustS);
	}
	// 5 in 5
	if (last5starts[0] >= 0) {
		if (al_get_time()-last5starts[0] <= 5*60) {
			int i, j;
			bool found = false;
			for (i = 0; i < 5; i++) {
				for (j = 0; j < 5; j++) {
					if (i == j)
						continue;
					if (last5levels[i] == last5levels[j]) {
						found = true;
						break;
					}
				}
				if (found)
					break;
			}
			if (!found) {
				found = false;
				for (i = 0; i < 5; i++) {
					if (last5stars[i] < 2) {
						found = true;
						break;
					}
				}
				if (!found) {
					reportAchievementIdentifier(FiveInFiveID, FiveInFiveS);
				}
			}
		}
	}
	// Warrior
	for (i = 0; i < NUM_LEVELS; i++) {
		if (uninterrupted_stars[i] < 2)
			break;
	}
	if (i == NUM_LEVELS) {
		reportAchievementIdentifier(WarriorID, WarriorS);
	}
	// Dedicated
	if (!levelPlayed[level]) {
		levelPlayed[level] = true;
		dedicatedTally += nstars;
		if (dedicatedTally >= 25) {
			reportAchievementIdentifier(DedicatedID, DedicatedS);
		}
	}
#endif

	char buf[200];
	int mins = (int)gameElapsedTime/60;
	int secs = gameElapsedTime - (mins*60);
	sprintf(buf, "Elapsed time: %d %s %d %s", mins, mins == 1 ? "minute" : "minutes", secs, secs == 1 ? "second" : "seconds");
	_al_list_push_back(scrolling_strings, strdup(buf));
		
	save_save();

	for (i = 0; i < NUM_DIFFERENT_SPACE_THINGS; i++)
		al_destroy_bitmap(space_bmps[i]);
	//destroy_atlas();
	
	if (ret == MAIN_RETRY) {
		level++;
		goto top;
	}

	return true;
}

const int LEVSEL_COLS = 2;

static void draw_level_worker(int yy, int top, int selected)
{
	int PREVIEW_H = 256 * ((float)SCR_H/SCR_W);
	int hgap = (SCR_W - PREVIEW_W * LEVSEL_COLS) / 3;
	int vgap = ((LEVEL_H*TILE_SIZE) - PREVIEW_H * 2) / 5;

	int x, y;
	for (y = 0; y < 3; y++) {
		for (x = 0; x < 2; x++) {
			int add = y*2+x;
			if (top+add >= good_levels || top+add < 0) {
				continue;
			}
//#ifdef ALLEGRO_IPHONE
#if 1
			int xx = x == 0 ? hgap : hgap*2 + PREVIEW_W;
#else
			int xx = x == 0 ? hgap-45/2 : hgap*2-45/2 + PREVIEW_W;
#endif
			int drawy;
			if (y == 0) {
				drawy = yy + vgap;
			}
			else if (y == 1) {
				drawy = yy + vgap*3 + PREVIEW_H;
			}
			else {
				drawy = yy + vgap*5 + PREVIEW_H*2;
			}
			al_draw_scaled_bitmap(
					      previews[good_level_nums[top+add]],
					      0, 0, LEVEL_W, LEVEL_H,
					      xx, drawy, PREVIEW_W, PREVIEW_H,
					      0
					      );
					      /*
			draw_tiny_text(xx-TINY_FONT_SIZE*2, drawy, top+add+1,/* top+add == selected ? al_map_rgb(0, 0, 0) :*/ al_map_rgb(255, 255, 255));
			
			int i;
			for (i = 0; i < stars[good_level_nums[top+add]]; i++) {
				al_draw_bitmap(star_bmp, xx+PREVIEW_W-36*3+36*i, drawy-40, 0);
				ALLEGRO_STATE blend_state;
				al_store_state(&blend_state, ALLEGRO_STATE_BLENDER);
				al_set_blender(ALLEGRO_ADD, ALLEGRO_ONE, ALLEGRO_ONE);
				al_draw_tinted_bitmap(star_bmp, al_map_rgba_f(starAlpha, starAlpha, starAlpha, starAlpha),
						      xx+PREVIEW_W-36*3+36*i, drawy-40, 0);
				al_restore_state(&blend_state);
			}
			
			if (!(good_level_nums[top+add] == 0 || stars[good_level_nums[top+add]-1] >= 2)) {
				al_draw_filled_rectangle(xx, drawy, xx+PREVIEW_W, drawy+PREVIEW_H, al_map_rgba(0, 0, 0, 128));
				al_draw_bitmap(lock_bmp, xx+PREVIEW_W-al_get_bitmap_width(lock_bmp)-2, drawy+PREVIEW_H-al_get_bitmap_height(lock_bmp)-2, 0);
			}
		}
	}
}
				
//#ifdef ALLEGRO_IPHONE
#if 1
static void draw_levels(int top, int selected, float scrolly)
{
	(void)top;
	
	int PREVIEW_H = 256 * ((float)SCR_H/SCR_W);
	int vgap = ((LEVEL_H*TILE_SIZE) - PREVIEW_H * 2) / 5;
	int yoffs = ((int)scrolly) % (PREVIEW_H + vgap*2) - vgap;
	int SH = (LEVEL_H*TILE_SIZE);
	
	int top_level = (int)(scrolly / (PREVIEW_H + vgap*2)) * 2;
	
	int x, y, w, h;
	al_get_clipping_rectangle(&x, &y, &w, &h);
	//al_set_clipping_rectangle(0, 0, (SH-50)*scr_scale_x, sh);
	al_set_clipping_rectangle(0, (50+64)*scr_scale_y+1, sw, SH*scr_scale_y);
	//al_set_clipping_rectangle(0, (50+64), sw, SH);
	
	draw_level_worker(-yoffs, top_level, selected);
	
	ALLEGRO_VERTEX v[4];
	v[0].x = 0;
	v[0].y = 50;
	v[0].z = 0;
	v[0].color = al_map_rgb(0, 0, 0);
	v[1].x = SCR_W;
	v[1].y = 50;
	v[1].z = 0;
	v[1].color = al_map_rgb(0, 0, 0);
	v[2].x = SCR_W;
	v[2].y = 70;
	v[2].z = 0;
	v[2].color = al_map_rgba(0, 0, 0, 0);
	v[3].x = 0;
	v[3].y = 70;
	v[3].z = 0;
	v[3].color = al_map_rgba(0, 0, 0, 0);
	al_draw_prim(v, 0, 0, 0, 4, ALLEGRO_PRIM_TRIANGLE_FAN);
	v[0].x = 0;
	v[0].y = SH-20;
	v[0].z = 0;
	v[0].color = al_map_rgba(0, 0, 0, 0);
	v[1].x = SCR_W;
	v[1].y = SH-20;
	v[1].z = 0;
	v[1].color = al_map_rgba(0, 0, 0, 0);
	v[2].x = SCR_W;
	v[2].y = SH;
	v[2].z = 0;
	v[2].color = al_map_rgb(0, 0, 0);
	v[3].x = 0;
	v[3].y = SH;
	v[3].z = 0;
	v[3].color = al_map_rgb(0, 0, 0);
	al_draw_prim(v, 0, 0, 0, 4, ALLEGRO_PRIM_TRIANGLE_FAN);
	
	al_set_clipping_rectangle(x, y, w, h);
}
#else
void draw_levels(int top, int selected)
{
	int PREVIEW_H = 256 * ((float)SCR_H/SCR_W);
	int hgap = (SCR_W - PREVIEW_W * LEVSEL_COLS) / 3;
	int vgap = ((LEVEL_H*TILE_SIZE) - PREVIEW_H * 2) / 3;

	int yy = vgap+10 - (vgap*3)/5;
	
	draw_level_worker(yy, top, selected);
}
#endif

static float get_barh(void)
{
	float topgap = SCR_H-(LEVEL_H*TILE_SIZE);
	float barh = SCR_H-topgap-10;
	return barh;
}

static float get_tabsize(void)
{
	const float minimum = 10;
	float p = 2.0 / ((good_levels / 2.0) + good_levels % 2);
	float tabsize = get_barh() * p;
	if (tabsize < minimum) tabsize = minimum;
	return tabsize;
}

static void draw_scrollbar(float p)
{
#ifdef ALLEGRO_IPHONE
	if ((!joypad || !joypad->connected) && !sb_on) {
		return;
	}
#endif
	int SH = (LEVEL_H*TILE_SIZE);

	al_draw_filled_rectangle(SCR_W-40, 5, SCR_W-5, SH-5, al_map_rgb(120, 50, 100));

	float tabsize = get_tabsize();
	float range = get_barh();
	float pos = range * p;

	if (pos < tabsize/2) pos = tabsize/2;
	if (pos > range-tabsize/2-1) pos = range-tabsize/2-1;
	pos += 5;

	al_draw_filled_rectangle(SCR_W-38, pos-tabsize/2, SCR_W-7, pos+tabsize/2, al_map_rgb(255, 255, 255));
}
                
//#ifdef ALLEGRO_IPHONE
#if 1
static int get_touched_level(float scrolly, int tx, int ty)
{
	int PREVIEW_H = 256 * ((float)SCR_H/SCR_W);
	int hgap = (SCR_W - PREVIEW_W * LEVSEL_COLS) / 3;
	int vgap = ((LEVEL_H*TILE_SIZE) - PREVIEW_H * 2) / 5;
	
	int top_level = (int)(scrolly / (PREVIEW_H + vgap*2)) * 2;
	int yoffs = -(((int)scrolly) % (PREVIEW_H + vgap*2)) + vgap;

	ty -= SCR_H-(LEVEL_H*TILE_SIZE);
	
	int x, y;
	for (y = 0; y < 3; y++) {
		for (x = 0; x < 2; x++) {
			int y1 = (vgap*((y*2)+1)) + (PREVIEW_H*y) + yoffs;
			int x1 = x == 0 ? hgap : hgap*2 + PREVIEW_W;
			if (POINT_IN_BOX(tx, ty, x1, y1, PREVIEW_W, PREVIEW_H)) {
				return top_level + x + (y*2);
			}
		}
	}
	
	return -1;
}
#else
int get_touched_level(int top, int tx, int ty)
{	
	int SH = (LEVEL_H*TILE_SIZE);
	
	int PREVIEW_H = 256 * ((float)SCR_H/SCR_W);
	float x_space_size = (SCR_W-PREVIEW_W*2) / 3;
	float y_space_size = (SH-PREVIEW_H*2) / 3;
	int x1 = x_space_size;
	int x2 = x1 + x_space_size + PREVIEW_W;
	const int yoffs = (SCR_H-(LEVEL_H*TILE_SIZE));
	int y1 = y_space_size+10+yoffs;
	int y2 = y_space_size*2 + PREVIEW_H + yoffs;
	int go = -1;
	if (POINT_IN_BOX(tx, ty, x1, y1, PREVIEW_W, PREVIEW_H)) {
		go = top;
	}
	else if (POINT_IN_BOX(tx, ty, x2, y1, PREVIEW_W, PREVIEW_H)) {
		go = top+1;
	}
	else if (POINT_IN_BOX(tx, ty, x1, y2, PREVIEW_W, PREVIEW_H)) {
		go = top+2;
	}
	else if (POINT_IN_BOX(tx, ty, x2, y2, PREVIEW_W, PREVIEW_H)) {
		go = top+3;
	}
	
	return go;
}
#endif
		
float scrolly;
#ifndef ALLEGRO_IPHONE
//static int selected = 0;
#endif
static int top = 0;
// return -1 or level
static int select_level(void)
{
	bool redraw = false;
	int SH = (LEVEL_H*TILE_SIZE);
	int PREVIEW_H = 256 * ((float)SCR_H/SCR_W);
	float vgap = (SH-PREVIEW_H*2) / 5;
#ifndef ALLEGRO_IPHONE
	//bool need_release = false;
#endif
#ifndef WITHOUT_GAMECENTER
	bool need_pause_release = false;
	double pause_pressed_time;
#endif
	bool touch_down = false;
	int touch_id = -1;
	int first_touched;
	int touchx, touchy;
	int last_touchx, last_touchy;
	int pixels_moved;
	int firsty;
	double first_down_time;
	float velocity = 0;
			
	int nrows = good_levels / 2 + (good_levels % 2);
	float total_height = nrows * (PREVIEW_H+vgap*2) + vgap;
	float scrollbar_p = 0;
	
	al_start_timer(logic_timer);
	al_start_timer(draw_timer);
	
#if defined ALLEGRO_IPHONE || defined ALLEGRO_MACOSX
	[joypad performSelectorOnMainThread: @selector(find_devices) withObject:nil waitUntilDone:YES];
#endif
	
	space_bmps[1] = al_load_bitmap(getResource("spacestuff/nebula.png"));

	while (true) {
		ALLEGRO_EVENT event;
        
		while (!al_event_queue_is_empty(queue)) {
			al_get_next_event(queue, &event);

#ifdef ALLEGRO_IPHONE
			if (event.type == ALLEGRO_EVENT_DISPLAY_SWITCH_OUT) {
				switch_game_out(false);
				redraw = true;
			}
			else if (event.type == ALLEGRO_EVENT_DISPLAY_HALT_DRAWING) {
				switch_game_out(true);
				redraw = true;
				if (!isMultitaskingSupported())
					exit(0);
				continue;
			}
			else
#endif
			if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == logic_timer) {
				update_scroll();
				updateStarAlpha();
				al_lock_mutex(input_mutex);
				
				if (_al_list_size(touch_list) == 0) {
					if (touch_down) {
						touch_down = false;
						int go = get_touched_level(scrolly, last_touchx, last_touchy);
						if (pixels_moved < 10 && go >= 0 && first_touched == go && (go == 0 || stars[good_level_nums[go-1]] >= 2)) {
							al_unlock_mutex(input_mutex);
							playSample(bink);
							al_destroy_bitmap(space_bmps[1]);
							return go+1;
						}
						float travelled = firsty - last_touchy;
						float MAGIC_NUMBER = 100;
						velocity = travelled / (al_get_time()-first_down_time) / MAGIC_NUMBER;
						if (fabs(velocity) > 50) {
							if (velocity < 0)
								velocity = -50;
							else
								velocity = 50;
						}
					}
				}
				else {
					velocity = 0.0;
					_AL_LIST_ITEM *item = _al_list_front(touch_list);
					while (item) {
						TOUCH *t = _al_list_item_data(item);
						
						int tx = t->x;
						int ty = t->y;

#ifndef ALLEGRO_IPHONE
						if (tx > SCR_W-40) {
#else
						if (((joypad && joypad->connected) || sb_on) && tx > SCR_W-40) {
#endif
							if (tx > SCR_W-40 && tx < SCR_W-5 && ty >= 5+64 && ty <= SCR_H-5) {
								scrollbar_p = (ty-5-64)/(float)(SH-10);
								scrolly = scrollbar_p * (total_height - (vgap*4+PREVIEW_H*2));
								on_scrollbar = true;
							}
						}
						else {
							int go = get_touched_level(scrolly, tx, ty);
							
							if (!touch_down) {
								first_touched = go;
								touch_id = t->ident;
								touch_down = true;
								touchx = tx;
								touchy = ty;
								firsty = ty;
								pixels_moved = 0;
								first_down_time = al_get_time();
							}
							else if (touch_down && t->ident == touch_id) {
								last_touchx = tx;
								last_touchy = ty;
								int dy = ty - touchy;
								touchy = ty;
								scrolly += -dy;
								pixels_moved += abs(dy);
							}
						}
						item = _al_list_next(touch_list, item);
					}
				}
				al_unlock_mutex(input_mutex);
			}

			scrolly += velocity;
			if (velocity < 0) {
				velocity += 0.3;
				if (velocity > 0)
					velocity = 0;
			}
			else if (velocity > 0) {
				velocity -= 0.3;
				if (velocity < 0)
					velocity = 0;
			}
			
			// force scrolly into bounds
			if (scrolly < 0)
				scrolly = 0;
			else if (scrolly > total_height - (vgap*4+PREVIEW_H*2))
				scrolly = total_height - (vgap*4+PREVIEW_H*2);					

#ifdef ALLEGRO_IPHONE	
			if (left_icon_pressed()) {
				playSample(bink);
				al_destroy_bitmap(space_bmps[1]);
				return -2;
			}
#endif
#ifndef WITHOUT_GAMECENTER
			else if (!need_pause_release && right_icon_pressed() && is_authenticated && !on_scrollbar) {
				need_pause_release = true;
				pause_pressed_time = al_get_time();
			}
			else if (need_pause_release && pause_pressed_time+3 < al_get_time()) {
				need_pause_release = false;
				// clear input cause dialog stops touch up event
				al_lock_mutex(input_mutex);
				while (_al_list_size(touch_list) > 0)
					_al_list_pop_front(touch_list);
				al_unlock_mutex(input_mutex);
				al_stop_timer(logic_timer);
				al_stop_timer(draw_timer);
				int result = CreateModalDialog(@"Attention", @"Clear all achievements?", @"OK", @"Cancel");
				if (result == 1) {
					reset_complete = false;
					resetAchievements();
					while (!reset_complete)
						al_rest(0.001);
				}
				al_start_timer(logic_timer);
				al_start_timer(draw_timer);
			}
			else if (need_pause_release && !right_icon_pressed()) {
				if (isGameCenterAPIAvailable() || !is_authenticated) {
					need_pause_release = false;
					UIWindow *window = al_iphone_get_window(display);
					UIView *view = al_iphone_get_view(display);
					MyUIViewController *uv = [[MyUIViewController alloc] initWithNibName:nil bundle:nil];
					al_stop_timer(logic_timer);
					al_stop_timer(draw_timer);
					[uv performSelectorOnMainThread: @selector(showAchievements) withObject:nil waitUntilDone:YES];
					while (modalViewShowing) {
						al_rest(0.001);
					}
					al_start_timer(logic_timer);
					al_start_timer(draw_timer);
					[uv release];
					[window bringSubviewToFront:view];
				}
			}
#endif
		}
		if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == draw_timer) {
			redraw = true;
		}
#if defined ALLEGRO_IPHONE
		if ((joypad && joypad->connected && joypad->by) || (sb_on && sb_3)) {
#elif defined ALLEGRO_MACOSX
		if (esc_pressed || joy_pause || (joypad && joypad->connected && joypad->by)) {
#else
		if (esc_pressed || joy_pause) {
#endif
			playSample(bink);
			al_destroy_bitmap(space_bmps[1]);
			al_rest(0.5);
			return -2;
		}

		al_lock_mutex(switched_out_mutex);
		bool rest = false;
#if defined(ALLEGRO_IPHONE) && !defined(WITHOUT_GAMECENTER)
		if (!waiting_for_key && !switched_out && redraw && !modalViewShowing) {
#else
		if (!waiting_for_key && !switched_out && redraw) {
#endif
			redraw = false;

			al_set_target_backbuffer(display);
			al_clear_to_color(al_map_rgb(0, 0, 0));

#ifdef ALLEGRO_IPHONE
#ifndef WITHOUT_GAMECENTER
			if (is_authenticated) {
				al_draw_bitmap(game_center_bmp, SCR_W-al_get_bitmap_width(info_bmp), (PAUSE_SIZE-40)/2, 0);
			}
#endif
			al_draw_bitmap(quit_bmp, 0, (PAUSE_SIZE-40)/2, 0);
#endif

			ALLEGRO_TRANSFORM oldTrans, newTrans;
			al_copy_transform(&oldTrans, al_get_current_transform());
			al_copy_transform(&newTrans, &oldTrans);
			al_translate_transform(&newTrans, 0, (SCR_H-(LEVEL_H*TILE_SIZE))*scr_scale_y);

			al_use_transform(&newTrans);

			al_draw_tinted_bitmap(space_bmps[1], al_map_rgba_f(0.35, 0.35, 0.35, 0.35),
				       SCR_W/2-al_get_bitmap_width(space_bmps[1])/2,
				       SH/2-al_get_bitmap_height(space_bmps[1])/2, 0);
				
			
			begin_text_draw();
			al_draw_text(
				     font,
				     al_map_rgb(255, 255, 255),
				     SCR_W/2, 5, ALLEGRO_ALIGN_CENTRE,
				     "Select a Level");
			end_text_draw();
			
//#ifdef ALLEGRO_IPHONE
#if 1
			draw_levels(top, -1, scrolly);
#else
			draw_levels(top, selected);
#endif
			draw_scrollbar(scrollbar_p);

			al_use_transform(&oldTrans);
			
			draw_scroll();
			
			flip_display();
		}
		else {
			rest = true;
		}
		al_unlock_mutex(switched_out_mutex);
		if (rest) {
			al_rest(0.001);
		}
	}
}

#define CONTINUE 0
#define SETTINGS 1
#define CREDITS  2

// space things moving around
#define st1_x1 0
#define st1_y1 0
#define st1_x2 50
#define st1_y2 90
#define st1_scale1 1.2
#define st1_scale2 1.0
const float st1_xinc = (st1_x2 - st1_x1) / 60.0 / 6.0;
const float st1_yinc = (st1_y2 - st1_y1) / 60.0 / 6.0;
const float st1_scaleinc = (st1_scale2 - st1_scale1) / 60.0 / 6.0;
float st1_x, st1_y, st1_scale;
int st1_dir;

#define st2_x1 90
#define st2_y1 400
#define st2_x2 0
#define st2_y2 450
#define st2_scale1 0.5
#define st2_scale2 1.0
const float st2_xinc = (st2_x2 - st2_x1) / 60.0 / 4.0;
const float st2_yinc = (st2_y2 - st2_y1) / 60.0 / 4.0;
const float st2_scaleinc = (st2_scale2 - st2_scale1) / 60.0 / 4.0;
float st2_x, st2_y, st2_scale;
int st2_dir;

static int help(void)
{
	al_start_timer(logic_timer);
	al_start_timer(draw_timer);

	bool redraw = true;
	
	#ifdef ALLEGRO_MACOSX
	[joypad performSelectorOnMainThread: @selector(find_devices) withObject:nil waitUntilDone:YES];
	#endif
	
	while (true) {
		ALLEGRO_EVENT event;
		
		while (!al_event_queue_is_empty(queue)) {
			al_get_next_event(queue, &event);
			
			if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == logic_timer) {
				updateStarAlpha();
				
				if (st1_dir == 1) {
					st1_x += st1_xinc;
					st1_y += st1_yinc;
					st1_scale += st1_scaleinc;
					if (st1_xinc < 0) {
						if (st1_x < st1_x2) {
							st1_dir = -st1_dir;
						}
					}
					else {
						if (st1_x > st1_x2) {
							st1_dir = -st1_dir;
						}
					}
				}
				else {
					st1_x -= st1_xinc;
					st1_y -= st1_yinc;
					st1_scale -= st1_scaleinc;
					if (st1_xinc < 0) {
						if (st1_x > st1_x1) {
							st1_dir = -st1_dir;
						}
					}
					else {
						if (st1_x < st1_x1) {
							st1_dir = -st1_dir;
						}
					}
				}
				if (st2_dir == 1) {
					st2_x += st2_xinc;
					st2_y += st2_yinc;
					st2_scale += st2_scaleinc;
					if (st2_xinc < 0) {
						if (st2_x < st2_x2) {
							st2_dir = -st2_dir;
						}
					}
					else {
						if (st2_x > st2_x2) {
							st2_dir = -st2_dir;
						}
					}
				}
				else {
					st2_x -= st2_xinc;
					st2_y -= st2_yinc;
					st2_scale -= st2_scaleinc;
					if (st2_xinc < 0) {
						if (st2_x > st2_x1) {
							st2_dir = -st2_dir;
						}
					}
					else {
						if (st2_x < st2_x1) {
							st2_dir = -st2_dir;
						}
					}
				}
				
				al_lock_mutex(input_mutex);
				if (_al_list_size(touch_list) != 0) {
					al_unlock_mutex(input_mutex);
					playSample(bink);
					al_rest(0.5);
					return 0;

				}
#if defined ALLEGRO_IPHONE || defined ALLEGRO_MACOSX
				if (keysDown > 0 || (sb_on && sb_1) || (joypad && joypad->connected && joypad->ba)) {
#else
				if (keysDown > 0) {
#endif
					al_unlock_mutex(input_mutex);
					playSample(bink);
					al_rest(0.5);
					return 0;

				}
				al_unlock_mutex(input_mutex);
			}
			else if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == draw_timer) {
				redraw = true;
			}
		}
		
		al_lock_mutex(switched_out_mutex);
		if (redraw && !switched_out) {
			al_draw_bitmap(bg_bmp, 0, 0, 0);
			al_draw_scaled_bitmap(
					      space_bmps[7],
					      0, 0, al_get_bitmap_width(space_bmps[7]), al_get_bitmap_height(space_bmps[7]),
					      st1_x, st1_y, 
					      al_get_bitmap_width(space_bmps[7])*st1_scale, al_get_bitmap_height(space_bmps[7])*st1_scale,
					      0
					      );
			al_draw_scaled_bitmap(
					      space_bmps[4],
					      0, 0, al_get_bitmap_width(space_bmps[4]), al_get_bitmap_height(space_bmps[4]),
					      st2_x, st2_y, 
					      al_get_bitmap_width(space_bmps[4])*st2_scale, al_get_bitmap_height(space_bmps[4])*st2_scale,
					      0
					      );
			al_draw_bitmap(menu_bmp, 0, 0, 0);
			al_draw_bitmap(logo_bmp, 390, 60, 0);
			ALLEGRO_STATE blend_state;
			al_store_state(&blend_state, ALLEGRO_STATE_BLENDER);
			al_set_blender(ALLEGRO_ADD, ALLEGRO_ONE, ALLEGRO_ONE);
			al_draw_tinted_bitmap(logo_bmp, al_map_rgba_f(starAlpha, starAlpha, starAlpha, starAlpha), 390, 60, 0);
			al_restore_state(&blend_state);
			al_draw_filled_rectangle(0, 0, SCR_W, SCR_H, al_map_rgba_f(0, 0, 0, 0.8));
			
			/* draw instructions */
#if defined ALLEGRO_IPHONE
			int x1 = 65;
			int x2 = x1+260;
			int x3 = x2+190;
			int x4 = x3+190;
			int y0 = 20;
			int y1 = 80;
			int y2 = 120;
			int y3 = 160;
			int y4 = 200;
			int y5 = 240;
			int y6 = 280;
			int y7 = 320;
			al_draw_text(font, al_map_rgb(255, 255, 0), SCR_W/2, y0, ALLEGRO_ALIGN_CENTRE, "Controls");
			al_draw_text(font, al_map_rgb(150, 150, 150), x2+95, y1, ALLEGRO_ALIGN_CENTRE, "Joypad");
			al_draw_text(font, al_map_rgb(150, 150, 150), x3+95, y1, ALLEGRO_ALIGN_CENTRE, "60beat");
			al_draw_text(font, al_map_rgb(150, 150, 150), x4+95, y1, ALLEGRO_ALIGN_CENTRE, "Touch");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y2, 0, "Rotate");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y3, 0, "Thrust");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y4, 0, "Brake");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y5, 0, "Escape");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y6, 0, "90° Left");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y7, 0, "90° Right");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+95, y2, ALLEGRO_ALIGN_CENTRE, "DPad");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+95, y2, ALLEGRO_ALIGN_CENTRE, "DPad");
			al_draw_text(font, al_map_rgb(255, 255, 255), x4+95, y2, ALLEGRO_ALIGN_CENTRE, "Arrows");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+95, y3, ALLEGRO_ALIGN_CENTRE, "A");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+95, y3, ALLEGRO_ALIGN_CENTRE, "1");
			al_draw_text(font, al_map_rgb(255, 255, 255), x4+95, y3, ALLEGRO_ALIGN_CENTRE, "Green");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+95, y4, ALLEGRO_ALIGN_CENTRE, "B");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+95, y4, ALLEGRO_ALIGN_CENTRE, "2");
			al_draw_text(font, al_map_rgb(255, 255, 255), x4+95, y4, ALLEGRO_ALIGN_CENTRE, "Red");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+95, y5, ALLEGRO_ALIGN_CENTRE, "Y");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+95, y5, ALLEGRO_ALIGN_CENTRE, "3");
			al_draw_text(font, al_map_rgb(255, 255, 255), x4+95, y5, ALLEGRO_ALIGN_CENTRE, "Tap");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+95, y6, ALLEGRO_ALIGN_CENTRE, "L");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+95, y6, ALLEGRO_ALIGN_CENTRE, "L1");
			al_draw_text(font, al_map_rgb(255, 255, 255), x4+95, y6, ALLEGRO_ALIGN_CENTRE, "(none)");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+95, y7, ALLEGRO_ALIGN_CENTRE, "R");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+95, y7, ALLEGRO_ALIGN_CENTRE, "R1");
			al_draw_text(font, al_map_rgb(255, 255, 255), x4+95, y7, ALLEGRO_ALIGN_CENTRE, "L+R");
			al_draw_line(x1, y2, SCR_W-x1, y2, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x1, y3, SCR_W-x1, y3, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x1, y4, SCR_W-x1, y4, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x1, y5, SCR_W-x1, y5, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x1, y6, SCR_W-x1, y6, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x1, y7, SCR_W-x1, y7, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x2, y1, x2, y7+al_get_font_line_height(font), al_map_rgb(50, 50, 50), 3);
			al_draw_line(x3, y1, x3, y7+al_get_font_line_height(font), al_map_rgb(50, 50, 50), 3);
			al_draw_line(x4, y1, x4, y7+al_get_font_line_height(font), al_map_rgb(50, 50, 50), 3);
			al_draw_bitmap(arrow_bmp, SCR_W-80, SCR_H-80, ALLEGRO_FLIP_HORIZONTAL);
#elif defined ALLEGRO_MACOSX
			int x1 = 50;
			int x2 = x1+260;
			int x3 = x2+200;
			int x4 = x3+200;
			int y0 = 20;
			int y1 = 80;
			int y2 = 120;
			int y3 = 160;
			int y4 = 200;
			int y5 = 240;
			int y6 = 280;
			int y7 = 320;
			al_draw_text(font, al_map_rgb(255, 255, 0), SCR_W/2, y0, ALLEGRO_ALIGN_CENTRE, "Controls");
			al_draw_text(font, al_map_rgb(150, 150, 150), x2+100, y1, ALLEGRO_ALIGN_CENTRE, "Joypad");
			al_draw_text(font, al_map_rgb(150, 150, 150), x3+100, y1, ALLEGRO_ALIGN_CENTRE, "Gamepad");
			al_draw_text(font, al_map_rgb(150, 150, 150), x4+100, y1, ALLEGRO_ALIGN_CENTRE, "Keys");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y2, 0, "Rotate");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y3, 0, "Thrust");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y4, 0, "Brake");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y5, 0, "Escape");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y6, 0, "90° Left");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y7, 0, "90° Right");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+100, y2, ALLEGRO_ALIGN_CENTRE, "DPad");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+100, y2, ALLEGRO_ALIGN_CENTRE, "Stick 1");
			al_draw_text(font, al_map_rgb(255, 255, 255), x4+100, y2, ALLEGRO_ALIGN_CENTRE, "Arrows");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+100, y3, ALLEGRO_ALIGN_CENTRE, "A");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+100, y3, ALLEGRO_ALIGN_CENTRE, "B1");
			al_draw_text(font, al_map_rgb(255, 255, 255), x4+100, y3, ALLEGRO_ALIGN_CENTRE, "Space");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+100, y4, ALLEGRO_ALIGN_CENTRE, "B");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+100, y4, ALLEGRO_ALIGN_CENTRE, "B2");
			al_draw_text(font, al_map_rgb(255, 255, 255), x4+100, y4, ALLEGRO_ALIGN_CENTRE, "Down");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+100, y5, ALLEGRO_ALIGN_CENTRE, "Y");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+100, y5, ALLEGRO_ALIGN_CENTRE, "B3");
			al_draw_text(font, al_map_rgb(255, 255, 255), x4+100, y5, ALLEGRO_ALIGN_CENTRE, "Escape");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+100, y6, ALLEGRO_ALIGN_CENTRE, "L");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+100, y6, ALLEGRO_ALIGN_CENTRE, "(none)");
			al_draw_text(font, al_map_rgb(255, 255, 255), x4+100, y6, ALLEGRO_ALIGN_CENTRE, "[");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+100, y7, ALLEGRO_ALIGN_CENTRE, "R");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+100, y7, ALLEGRO_ALIGN_CENTRE, "B4");
			al_draw_text(font, al_map_rgb(255, 255, 255), x4+100, y7, ALLEGRO_ALIGN_CENTRE, "]");
			al_draw_line(x1, y2, SCR_W-x1, y2, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x1, y3, SCR_W-x1, y3, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x1, y4, SCR_W-x1, y4, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x1, y5, SCR_W-x1, y5, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x1, y6, SCR_W-x1, y6, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x1, y7, SCR_W-x1, y7, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x2, y1, x2, y7+al_get_font_line_height(font), al_map_rgb(50, 50, 50), 3);
			al_draw_line(x3, y1, x3, y7+al_get_font_line_height(font), al_map_rgb(50, 50, 50), 3);
			al_draw_line(x4, y1, x4, y7+al_get_font_line_height(font), al_map_rgb(50, 50, 50), 3);
			al_draw_bitmap(arrow_bmp, SCR_W-80, SCR_H-80, ALLEGRO_FLIP_HORIZONTAL);
#else
			int x1 = 150;
			int x2 = x1+260;
			int x3 = x2+200;
			int y0 = 20;
			int y1 = 80;
			int y2 = 120;
			int y3 = 160;
			int y4 = 200;
			int y5 = 240;
			int y6 = 280;
			int y7 = 320;
			al_draw_text(font, al_map_rgb(255, 255, 0), SCR_W/2, y0, ALLEGRO_ALIGN_CENTRE, "Controls");
			al_draw_text(font, al_map_rgb(150, 150, 150), x2+100, y1, ALLEGRO_ALIGN_CENTRE, "Gamepad");
			al_draw_text(font, al_map_rgb(150, 150, 150), x3+100, y1, ALLEGRO_ALIGN_CENTRE, "Keys");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y2, 0, "Rotate");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y3, 0, "Thrust");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y4, 0, "Brake");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y5, 0, "Escape");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y6, 0, "90° Left");
			al_draw_text(font, al_map_rgb(150, 150, 150), x1, y7, 0, "90° Right");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+100, y2, ALLEGRO_ALIGN_CENTRE, "Stick 1");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+100, y2, ALLEGRO_ALIGN_CENTRE, "Arrows");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+100, y3, ALLEGRO_ALIGN_CENTRE, "B1");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+100, y3, ALLEGRO_ALIGN_CENTRE, "Space");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+100, y4, ALLEGRO_ALIGN_CENTRE, "B2");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+100, y4, ALLEGRO_ALIGN_CENTRE, "Down");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+100, y5, ALLEGRO_ALIGN_CENTRE, "B3");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+100, y5, ALLEGRO_ALIGN_CENTRE, "Escape");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+100, y6, ALLEGRO_ALIGN_CENTRE, "(none)");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+100, y6, ALLEGRO_ALIGN_CENTRE, "[");
			al_draw_text(font, al_map_rgb(255, 255, 255), x2+100, y7, ALLEGRO_ALIGN_CENTRE, "B4");
			al_draw_text(font, al_map_rgb(255, 255, 255), x3+100, y7, ALLEGRO_ALIGN_CENTRE, "]");
			al_draw_line(x1, y2, SCR_W-x1, y2, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x1, y3, SCR_W-x1, y3, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x1, y4, SCR_W-x1, y4, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x1, y5, SCR_W-x1, y5, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x1, y6, SCR_W-x1, y6, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x1, y7, SCR_W-x1, y7, al_map_rgb(50, 50, 50), 3);
			al_draw_line(x2, y1, x2, y7+al_get_font_line_height(font), al_map_rgb(50, 50, 50), 3);
			al_draw_line(x3, y1, x3, y7+al_get_font_line_height(font), al_map_rgb(50, 50, 50), 3);
			al_draw_bitmap(arrow_bmp, SCR_W-80, SCR_H-80, ALLEGRO_FLIP_HORIZONTAL);
#endif			
			flip_display();
		}
		al_unlock_mutex(switched_out_mutex);
		
		al_rest(0.001);
	}
}

#if !defined(ALLEGRO_IPHONE)

static int achievements(void)
{
	al_start_timer(logic_timer);
	al_start_timer(draw_timer);

	bool redraw = true;
	
	#ifdef ALLEGRO_MACOSX
	[joypad performSelectorOnMainThread: @selector(find_devices) withObject:nil waitUntilDone:YES];
	#endif
	
	while (true) {
		ALLEGRO_EVENT event;
		
		while (!al_event_queue_is_empty(queue)) {
			al_get_next_event(queue, &event);
			
			if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == logic_timer) {
				updateStarAlpha();
				
				if (st1_dir == 1) {
					st1_x += st1_xinc;
					st1_y += st1_yinc;
					st1_scale += st1_scaleinc;
					if (st1_xinc < 0) {
						if (st1_x < st1_x2) {
							st1_dir = -st1_dir;
						}
					}
					else {
						if (st1_x > st1_x2) {
							st1_dir = -st1_dir;
						}
					}
				}
				else {
					st1_x -= st1_xinc;
					st1_y -= st1_yinc;
					st1_scale -= st1_scaleinc;
					if (st1_xinc < 0) {
						if (st1_x > st1_x1) {
							st1_dir = -st1_dir;
						}
					}
					else {
						if (st1_x < st1_x1) {
							st1_dir = -st1_dir;
						}
					}
				}
				if (st2_dir == 1) {
					st2_x += st2_xinc;
					st2_y += st2_yinc;
					st2_scale += st2_scaleinc;
					if (st2_xinc < 0) {
						if (st2_x < st2_x2) {
							st2_dir = -st2_dir;
						}
					}
					else {
						if (st2_x > st2_x2) {
							st2_dir = -st2_dir;
						}
					}
				}
				else {
					st2_x -= st2_xinc;
					st2_y -= st2_yinc;
					st2_scale -= st2_scaleinc;
					if (st2_xinc < 0) {
						if (st2_x > st2_x1) {
							st2_dir = -st2_dir;
						}
					}
					else {
						if (st2_x < st2_x1) {
							st2_dir = -st2_dir;
						}
					}
				}
				
				al_lock_mutex(input_mutex);
				if (_al_list_size(touch_list) != 0) {
					al_unlock_mutex(input_mutex);
					playSample(bink);
					al_rest(0.5);
					return 0;

				}
				if (keysDown > 0) {
					al_unlock_mutex(input_mutex);
					playSample(bink);
					al_rest(0.5);
					return 0;

				}
				al_unlock_mutex(input_mutex);
			}
			else if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == draw_timer) {
				redraw = true;
			}
		}
		
		al_lock_mutex(switched_out_mutex);
		if (redraw && !switched_out) {
			al_draw_bitmap(bg_bmp, 0, 0, 0);
			al_draw_scaled_bitmap(
					      space_bmps[7],
					      0, 0, al_get_bitmap_width(space_bmps[7]), al_get_bitmap_height(space_bmps[7]),
					      st1_x, st1_y, 
					      al_get_bitmap_width(space_bmps[7])*st1_scale, al_get_bitmap_height(space_bmps[7])*st1_scale,
					      0
					      );
			al_draw_scaled_bitmap(
					      space_bmps[4],
					      0, 0, al_get_bitmap_width(space_bmps[4]), al_get_bitmap_height(space_bmps[4]),
					      st2_x, st2_y, 
					      al_get_bitmap_width(space_bmps[4])*st2_scale, al_get_bitmap_height(space_bmps[4])*st2_scale,
					      0
					      );
			al_draw_bitmap(menu_bmp, 0, 0, 0);
			al_draw_bitmap(logo_bmp, 390, 60, 0);
			ALLEGRO_STATE blend_state;
			al_store_state(&blend_state, ALLEGRO_STATE_BLENDER);
			al_set_blender(ALLEGRO_ADD, ALLEGRO_ONE, ALLEGRO_ONE);
			al_draw_tinted_bitmap(logo_bmp, al_map_rgba_f(starAlpha, starAlpha, starAlpha, starAlpha), 390, 60, 0);
			al_restore_state(&blend_state);
			al_draw_filled_rectangle(0, 0, SCR_W, SCR_H, al_map_rgba_f(0, 0, 0, 0.8));
			/* draw achievements */
			begin_text_draw();
			al_draw_text(font, al_map_rgb(255, 255, 0), SCR_W/2, 10, ALLEGRO_ALIGN_CENTRE, "Achievements");
			int i;
			for (i = 0; i < NUM_ACHIEVEMENTS; i++) {
			char text[1000];
			sprintf(text, "%s", pc_achievements[i]+strlen(AUL));
			al_draw_text(font, al_map_rgb(200, 200, 200), 10, 50+i*30, 0, text);
			int w = al_get_text_width(font, "Check");
			if (achieved[i]) {
				al_draw_text(font, al_map_rgb(0, 255, 0), SCR_W-10-w, 50+i*30, 0, "Check");
			}
			else {
				al_draw_text(font, al_map_rgb(200, 200, 200), SCR_W-10-w, 50+i*30, 0, "-");
			}
			}
			end_text_draw();
			
			flip_display();
		}
		al_unlock_mutex(switched_out_mutex);
		
		al_rest(0.001);
	}
}
#endif

static void load_menu_bitmaps(void)
{
	menu_bmp = al_load_bitmap(getResource("menu.png"));
#ifdef ALLEGRO_IPHONE
	al_set_new_bitmap_format(ALLEGRO_PIXEL_FORMAT_RGB_565);
#endif
	bg_bmp = al_load_bitmap(getResource("bg1.png"));
#ifdef ALLEGRO_IPHONE
	al_set_new_bitmap_format(ALLEGRO_PIXEL_FORMAT_RGBA_4444);
#endif
	
	space_bmps[4] = al_load_bitmap(getResource("spacestuff/images2.png"));
	space_bmps[7] = al_load_bitmap(getResource("spacestuff/images5.png"));
}

static void destroy_menu_bitmaps(void)
{
	al_destroy_bitmap(menu_bmp);
	al_destroy_bitmap(bg_bmp);
	al_destroy_bitmap(space_bmps[4]);
	al_destroy_bitmap(space_bmps[7]);
}

static void draw_menu(void)
{
	al_draw_bitmap(bg_bmp, 0, 0, 0);
	al_draw_scaled_bitmap(
		space_bmps[7],
		0, 0, al_get_bitmap_width(space_bmps[7]), al_get_bitmap_height(space_bmps[7]),
		st1_x, st1_y, 
		al_get_bitmap_width(space_bmps[7])*st1_scale, al_get_bitmap_height(space_bmps[7])*st1_scale,
		0
	);
	al_draw_scaled_bitmap(
		space_bmps[4],
		0, 0, al_get_bitmap_width(space_bmps[4]), al_get_bitmap_height(space_bmps[4]),
		st2_x, st2_y, 
		al_get_bitmap_width(space_bmps[4])*st2_scale, al_get_bitmap_height(space_bmps[4])*st2_scale,
		0
	);

	al_draw_bitmap(menu_bmp, 0, 0, 0);

#ifdef ALLEGRO_IPHONE
	al_draw_bitmap(blue_button_bmp, 576, 345, 0);
	al_draw_bitmap(blue_button_bmp, 576, 412, 0);
	al_draw_bitmap(blue_button_bmp, 576, 479, 0);
	al_draw_bitmap(blue_button_bmp, 576, 546, 0);
	al_draw_bitmap(continue_bmp, 576+al_get_bitmap_width(blue_button_bmp)/2-al_get_bitmap_width(continue_bmp)/2, 345+5, 0);
	al_draw_bitmap(settings_bmp, 576+al_get_bitmap_width(blue_button_bmp)/2-al_get_bitmap_width(settings_bmp)/2, 412+5, 0);
	al_draw_bitmap(credits_bmp, 576+al_get_bitmap_width(blue_button_bmp)/2-al_get_bitmap_width(credits_bmp)/2, 479+5, 0);
	al_draw_bitmap(help_bmp, 576+al_get_bitmap_width(blue_button_bmp)/2-al_get_bitmap_width(help_bmp)/2, 546+5, 0);
#else
	float mid = 576+al_get_bitmap_width(blue_button_bmp)/2;
	al_draw_bitmap(blue_button_bmp, mid-al_get_bitmap_width(blue_button_bmp), 345, 0);
	al_draw_bitmap(blue_button_bmp, mid-al_get_bitmap_width(blue_button_bmp), 412, 0);
	al_draw_bitmap(blue_button_bmp, mid-al_get_bitmap_width(blue_button_bmp), 479, 0);
	al_draw_bitmap(blue_button_bmp, mid, 345, 0);
#ifndef LITE
	al_draw_bitmap(blue_button_bmp, mid, 412, 0);
#endif
	al_draw_bitmap(continue_bmp, mid-al_get_bitmap_width(blue_button_bmp)/2-al_get_bitmap_width(continue_bmp)/2, 345+5, 0);
	al_draw_bitmap(settings_bmp, mid-al_get_bitmap_width(blue_button_bmp)/2-al_get_bitmap_width(settings_bmp)/2, 412+5, 0);
	al_draw_bitmap(credits_bmp, mid-al_get_bitmap_width(blue_button_bmp)/2-al_get_bitmap_width(credits_bmp)/2, 479+5, 0);
	al_draw_bitmap(help_bmp, mid+al_get_bitmap_width(blue_button_bmp)/2-al_get_bitmap_width(help_bmp)/2, 345+5, 0);
#ifndef LITE
	al_draw_bitmap(achievements_bmp, mid+al_get_bitmap_width(blue_button_bmp)/2-al_get_bitmap_width(achievements_bmp)/2, 412+5, 0);
#endif
#endif

	al_draw_bitmap(logo_bmp, 390, 60, 0);
	ALLEGRO_STATE blend_state;
	al_store_state(&blend_state, ALLEGRO_STATE_BLENDER);
	al_set_blender(ALLEGRO_ADD, ALLEGRO_ONE, ALLEGRO_ONE);
	al_draw_tinted_bitmap(logo_bmp, al_map_rgba_f(starAlpha, starAlpha, starAlpha, starAlpha), 390, 60, 0);
	al_restore_state(&blend_state);
}
	
static int menu(void)
{
	load_menu_bitmaps();

	al_start_timer(logic_timer);
	al_start_timer(draw_timer);
	
#if defined ALLEGRO_IPHONE || defined ALLEGRO_MACOSX
	[joypad performSelectorOnMainThread: @selector(find_devices) withObject:nil waitUntilDone:YES];
#endif

	bool redraw = true;

	while (true) {
		ALLEGRO_EVENT event;
        
		while (!al_event_queue_is_empty(queue)) {
			al_get_next_event(queue, &event);

#ifdef ALLEGRO_IPHONE
			if (event.type == ALLEGRO_EVENT_DISPLAY_SWITCH_OUT) {
				switch_game_out(false);
				redraw = true;
			}
			else if (event.type == ALLEGRO_EVENT_DISPLAY_HALT_DRAWING) {
				switch_game_out(true);
				redraw = true;
				if (!isMultitaskingSupported())
					exit(0);
				continue;
			}
			else
#endif
			if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == logic_timer) {
#ifndef ALLEGRO_IPHONE
				if (esc_pressed) {
					display_closed = true;
					save_save();
					exit(0);
				}
#endif

				updateStarAlpha();

				if (st1_dir == 1) {
					st1_x += st1_xinc;
					st1_y += st1_yinc;
					st1_scale += st1_scaleinc;
					if (st1_xinc < 0) {
						if (st1_x < st1_x2) {
							st1_dir = -st1_dir;
						}
					}
					else {
						if (st1_x > st1_x2) {
							st1_dir = -st1_dir;
						}
					}
				}
				else {
					st1_x -= st1_xinc;
					st1_y -= st1_yinc;
					st1_scale -= st1_scaleinc;
					if (st1_xinc < 0) {
						if (st1_x > st1_x1) {
							st1_dir = -st1_dir;
						}
					}
					else {
						if (st1_x < st1_x1) {
							st1_dir = -st1_dir;
						}
					}
				}
				if (st2_dir == 1) {
					st2_x += st2_xinc;
					st2_y += st2_yinc;
					st2_scale += st2_scaleinc;
					if (st2_xinc < 0) {
						if (st2_x < st2_x2) {
							st2_dir = -st2_dir;
						}
					}
					else {
						if (st2_x > st2_x2) {
							st2_dir = -st2_dir;
						}
					}
				}
				else {
					st2_x -= st2_xinc;
					st2_y -= st2_yinc;
					st2_scale -= st2_scaleinc;
					if (st2_xinc < 0) {
						if (st2_x > st2_x1) {
							st2_dir = -st2_dir;
						}
					}
					else {
						if (st2_x < st2_x1) {
							st2_dir = -st2_dir;
						}
					}
				}

				al_lock_mutex(input_mutex);
				if (_al_list_size(touch_list) != 0) {
					_AL_LIST_ITEM *item = _al_list_front(touch_list);
					while (item) {
						TOUCH *t = _al_list_item_data(item);
						
						int tx = t->x;
						int ty = t->y;
						
						#ifdef ALLEGRO_IPHONE
						int x1 = 576;
						int x2 = 576;
						int y1 = 345;
						int y2 = y1+67;
						int y3 = y2+67;
						int y4 = y3+67;
						#else
						float mid = 576+al_get_bitmap_width(blue_button_bmp)/2;
						int x1 = mid-al_get_bitmap_width(blue_button_bmp);
						int x2 = mid;
						int y1 = 345;
						int y2 = y1+67;
						int y3 = y2+67;
						int y4 = y1;
						int y5 = y2;
						#endif

						if (POINT_IN_BOX(tx, ty, x1, y1, 172, 57)) {
							al_unlock_mutex(input_mutex);
							playSample(bink);
							al_rest(0.5);
							destroy_menu_bitmaps();
							return CONTINUE;
						}
						else if (POINT_IN_BOX(tx, ty, x1, y2, 172, 57)) {
							al_unlock_mutex(input_mutex);
							playSample(bink);
							al_rest(0.5);
							destroy_menu_bitmaps();
							return SETTINGS;
						}
						else if (POINT_IN_BOX(tx, ty, x1, y3, 172, 57)) {
							al_unlock_mutex(input_mutex);
							playSample(bink);
							al_rest(0.5);
							destroy_menu_bitmaps();
							return CREDITS;
						}
						else if (POINT_IN_BOX(tx, ty, x2, y4, 172, 57)) {
							playSample(bink);
							al_unlock_mutex(input_mutex);
							int i;
							for (i = 0; i < 10; i++) {
								draw_menu();
								#endif
								al_draw_filled_rectangle(0, 0, SCR_W, SCR_H, al_map_rgba_f(0, 0, 0, ((float)(i+1)/10.0) * 0.8));
								flip_display();
								al_rest(0.5/10);
							}
							help();
							break;
						}
#if !defined(ALLEGRO_IPHONE) && !defined(LITE)
						else if (POINT_IN_BOX(tx, ty, x2, y5, 172, 57)) {
							playSample(bink);
							// really hackish fade
							al_unlock_mutex(input_mutex);
							int i;
							for (i = 0; i < 10; i++) {
								draw_menu();
								#endif
								al_draw_filled_rectangle(0, 0, SCR_W, SCR_H, al_map_rgba_f(0, 0, 0, ((float)(i+1)/10.0) * 0.8));
								flip_display();
								al_rest(0.5/10);
							}

							achievements();
							break;
						}
#endif
						else if (POINT_IN_BOX(tx, ty, 839, 566, 124, 68)) {
							openWebsite();
						}

						item = _al_list_next(touch_list, item);
					}
				}
				al_unlock_mutex(input_mutex);
			}
			else if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == draw_timer) {
				redraw = true;
			}
		}

		al_lock_mutex(switched_out_mutex);
		if (redraw && !switched_out) {
			draw_menu();
			flip_display();
		}
		al_unlock_mutex(switched_out_mutex);
		
		al_rest(0.001);
	}
}

static void load_settings_bitmaps(void)
{
	menu_bmp = al_load_bitmap(getResource("menu.png"));
#ifdef ALLEGRO_IPHONE
	al_set_new_bitmap_format(ALLEGRO_PIXEL_FORMAT_RGB_565);
#endif
	bg_bmp = al_load_bitmap(getResource("bg1.png"));
#ifdef ALLEGRO_IPHONE
	al_set_new_bitmap_format(ALLEGRO_PIXEL_FORMAT_RGBA_4444);
#endif
	
	space_bmps[4] = al_load_bitmap(getResource("spacestuff/images2.png"));
	space_bmps[7] = al_load_bitmap(getResource("spacestuff/images5.png"));
}

static void destroy_settings_bitmaps(void)
{
	al_destroy_bitmap(menu_bmp);
	al_destroy_bitmap(bg_bmp);

	al_destroy_bitmap(space_bmps[4]);
	al_destroy_bitmap(space_bmps[7]);
}

static int settings(void)
{
	load_settings_bitmaps();

	al_start_timer(logic_timer);
	al_start_timer(draw_timer);
	
#if defined ALLEGRO_IPHONE || defined ALLEGRO_MACOSX
	[joypad performSelectorOnMainThread: @selector(find_devices) withObject:nil waitUntilDone:YES];
#endif
	
	bool redraw = true;

	bool kitty_unlocked = stars[29] == 3;
	
	while (true) {
		ALLEGRO_EVENT event;
		
		while (!al_event_queue_is_empty(queue)) {
			al_get_next_event(queue, &event);
			
#ifdef ALLEGRO_IPHONE
			if (event.type == ALLEGRO_EVENT_DISPLAY_SWITCH_OUT) {
				switch_game_out(false);
				redraw = true;
			}
			else if (event.type == ALLEGRO_EVENT_DISPLAY_HALT_DRAWING) {
				switch_game_out(true);
				redraw = true;
				if (!isMultitaskingSupported())
					exit(0);
				continue;
			}
			else
#endif
				if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == logic_timer) {
					updateStarAlpha();
					
					if (st1_dir == 1) {
						st1_x += st1_xinc;
						st1_y += st1_yinc;
						st1_scale += st1_scaleinc;
						if (st1_xinc < 0) {
							if (st1_x < st1_x2) {
								st1_dir = -st1_dir;
							}
						}
						else {
							if (st1_x > st1_x2) {
								st1_dir = -st1_dir;
							}
						}
					}
					else {
						st1_x -= st1_xinc;
						st1_y -= st1_yinc;
						st1_scale -= st1_scaleinc;
						if (st1_xinc < 0) {
							if (st1_x > st1_x1) {
								st1_dir = -st1_dir;
							}
						}
						else {
							if (st1_x < st1_x1) {
								st1_dir = -st1_dir;
							}
						}
					}
					if (st2_dir == 1) {
						st2_x += st2_xinc;
						st2_y += st2_yinc;
						st2_scale += st2_scaleinc;
						if (st2_xinc < 0) {
							if (st2_x < st2_x2) {
								st2_dir = -st2_dir;
							}
						}
						else {
							if (st2_x > st2_x2) {
								st2_dir = -st2_dir;
							}
						}
					}
					else {
						st2_x -= st2_xinc;
						st2_y -= st2_yinc;
						st2_scale -= st2_scaleinc;
						if (st2_xinc < 0) {
							if (st2_x > st2_x1) {
								st2_dir = -st2_dir;
							}
						}
						else {
							if (st2_x < st2_x1) {
								st2_dir = -st2_dir;
							}
						}
					}

					al_lock_mutex(input_mutex);
					bool unlock = true;
					if (_al_list_size(touch_list) != 0) {
						_AL_LIST_ITEM *item = _al_list_front(touch_list);
						while (item) {
							TOUCH *t = _al_list_item_data(item);
							
							int tx = t->x;
							int ty = t->y;
							
#ifdef IPHONE
							if (POINT_IN_BOX(tx, ty, 576, 345, 172, 57)) {
								// toggle music
								al_unlock_mutex(input_mutex);
								unlock = false;
								music_on = !music_on;
								playSample(bink);
								if (!music_on) {
									stopMusic();
								}
								else {
									playMusic(true);
								}
								al_rest(0.5);
								break;
							}
							else if (POINT_IN_BOX(tx, ty, 576, 412, 172, 57)) {
								// toggle sound
								al_unlock_mutex(input_mutex);
								unlock = false;
								sound_on = !sound_on;
								playSample(bink);
								al_rest(0.5);
								break;
							}
							else if (kitty_unlocked && POINT_IN_BOX(tx, ty, 576, 481, 172, 57)) {
								// toggle sound
								al_unlock_mutex(input_mutex);
								unlock = false;
								use_kitty = !use_kitty;
								playSample(bink);
								al_rest(0.5);
								break;
							}
#else
							if (POINT_IN_BOX(tx, ty, 490, 345, 172, 57)) {
								// toggle music
								al_unlock_mutex(input_mutex);
								unlock = false;
								music_on = !music_on;
								playSample(bink);
								if (!music_on) {
									stopMusic();
								}
								else {
									playMusic(true);
								}
								al_rest(0.5);
								break;
							}
							else if (POINT_IN_BOX(tx, ty, 490, 412, 172, 57)) {
								// toggle sound
								al_unlock_mutex(input_mutex);
								unlock = false;
								sound_on = !sound_on;
								playSample(bink);
								al_rest(0.5);
								break;
							}
							else if (POINT_IN_BOX(tx, ty, 662, 345, 172, 57)) {
								// toggle fullscreen
								al_unlock_mutex(input_mutex);
								unlock = false;
								is_fullscreen = !is_fullscreen;
								set_fullscreen();
								set_transform();
								playSample(bink);
								al_rest(0.5);
								break;
							}
							else if (kitty_unlocked && POINT_IN_BOX(tx, ty, 662, 412, 172, 57)) {
								// toggle sound
								al_unlock_mutex(input_mutex);
								unlock = false;

								use_kitty = !use_kitty;
								playSample(bink);
								al_rest(0.5);
								break;
							}
#endif
							else if (POINT_IN_BOX(tx, ty, 576+al_get_bitmap_width(blue_button_bmp)/2-al_get_bitmap_width(arrow_bmp)/2, 559, 60, 59)) {
								al_unlock_mutex(input_mutex);
								playSample(bink);
								al_rest(0.5);
								save_save();
								destroy_settings_bitmaps();
								return 0;
							}
							
							item = _al_list_next(touch_list, item);
						}
					}
					if (unlock)
						al_unlock_mutex(input_mutex);
				}
				else if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == draw_timer) {
					redraw = true;
				}
		}
		
		al_lock_mutex(switched_out_mutex);
		if (redraw && !switched_out) {
			al_draw_bitmap(bg_bmp, 0, 0, 0);
			al_draw_scaled_bitmap(
					      space_bmps[7],
					      0, 0, al_get_bitmap_width(space_bmps[7]), al_get_bitmap_height(space_bmps[7]),
					      st1_x, st1_y, 
					      al_get_bitmap_width(space_bmps[7])*st1_scale, al_get_bitmap_height(space_bmps[7])*st1_scale,
					      0
					      );
			al_draw_scaled_bitmap(
					      space_bmps[4],
					      0, 0, al_get_bitmap_width(space_bmps[4]), al_get_bitmap_height(space_bmps[4]),
					      st2_x, st2_y, 
					      al_get_bitmap_width(space_bmps[4])*st2_scale, al_get_bitmap_height(space_bmps[4])*st2_scale,
					      0
					      );
			al_draw_bitmap(menu_bmp, 0, 0, 0);
#ifdef ALLEGRO_IPHONE
			int ox = 0;
#else
			int ox = -86;
#endif
			if (music_on) {
				al_draw_bitmap(orange_button_bmp, 576+ox, 345, 0);
			}
			else {
				al_draw_bitmap(blue_button_bmp, 576+ox, 345, 0);
			}
			if (sound_on) {
				al_draw_bitmap(orange_button_bmp, 576+ox, 412, 0);
			}
			else {
				al_draw_bitmap(blue_button_bmp, 576+ox, 412, 0);
			}
			al_draw_bitmap(music_bmp, 576+ox+al_get_bitmap_width(blue_button_bmp)/2-al_get_bitmap_width(music_bmp)/2, 345+5, 0);
			al_draw_bitmap(sound_bmp, 576+ox+al_get_bitmap_width(blue_button_bmp)/2-al_get_bitmap_width(sound_bmp)/2, 412+5, 0);
#ifdef ALLEGRO_IPHONE
			int ox2 = 0;
			int oy = 0;
#else
			int ox2 = 86;
			int oy = -69;
#endif
			if (kitty_unlocked) {
				if (use_kitty) {
					al_draw_bitmap(orange_button_bmp, 576+ox2, 481+oy, 0);
				}
				else {
					al_draw_bitmap(blue_button_bmp, 576+ox2, 481+oy, 0);
				}
				al_draw_bitmap(kitty_bmp, 576+ox2+al_get_bitmap_width(blue_button_bmp)/2-al_get_bitmap_width(kitty_bmp)/2, 481+5+oy, 0);
			}
#ifndef ALLEGRO_IPHONE
			if (is_fullscreen) {
				al_draw_bitmap(orange_button_bmp, 576+ox2, 481+oy*2, 0);
			}
			else {
				al_draw_bitmap(blue_button_bmp, 576+ox2, 481+oy*2, 0);
			}
			al_draw_bitmap(fullscreen_bmp, 576+ox2+al_get_bitmap_width(blue_button_bmp)/2-al_get_bitmap_width(fullscreen_bmp)/2, 481+5+oy*2, 0);
#endif
			al_draw_bitmap(arrow_bmp, 576+al_get_bitmap_width(blue_button_bmp)/2-al_get_bitmap_width(arrow_bmp)/2, 569, 0);
			al_draw_bitmap(logo_bmp, 390, 60, 0);
			ALLEGRO_STATE blend_state;
			al_store_state(&blend_state, ALLEGRO_STATE_BLENDER);
			al_set_blender(ALLEGRO_ADD, ALLEGRO_ONE, ALLEGRO_ONE);
			al_draw_tinted_bitmap(logo_bmp, al_map_rgba_f(starAlpha, starAlpha, starAlpha, starAlpha), 390, 60, 0);
			al_restore_state(&blend_state);
			flip_display();
		}
		al_unlock_mutex(switched_out_mutex);
		
		al_rest(0.001);
	}
}

static void load_credits_bitmaps(void)
{
	menu_bmp = al_load_bitmap(getResource("menu.png"));
#ifdef ALLEGRO_IPHONE
	al_set_new_bitmap_format(ALLEGRO_PIXEL_FORMAT_RGB_565);
#endif
	bg_bmp = al_load_bitmap(getResource("bg1.png"));
#ifdef ALLEGRO_IPHONE
	al_set_new_bitmap_format(ALLEGRO_PIXEL_FORMAT_RGBA_4444);
#endif
	
	space_bmps[4] = al_load_bitmap(getResource("spacestuff/images2.png"));
	space_bmps[7] = al_load_bitmap(getResource("spacestuff/images5.png"));
}

static void destroy_credits_bitmaps(void)
{
	al_destroy_bitmap(menu_bmp);
	al_destroy_bitmap(bg_bmp);

	al_destroy_bitmap(space_bmps[4]);
	al_destroy_bitmap(space_bmps[7]);
}
	
static int credits(void)
{
	load_credits_bitmaps();

	al_start_timer(logic_timer);
	al_start_timer(draw_timer);
	
#if defined ALLEGRO_IPHONE || defined ALLEGRO_MACOSX
	[joypad performSelectorOnMainThread: @selector(find_devices) withObject:nil waitUntilDone:YES];	
#endif
		
	bool redraw = true;
	
	while (true) {
		ALLEGRO_EVENT event;
		
		while (!al_event_queue_is_empty(queue)) {
			al_get_next_event(queue, &event);
			
#ifdef ALLEGRO_IPHONE
			if (event.type == ALLEGRO_EVENT_DISPLAY_SWITCH_OUT) {
				switch_game_out(false);
				redraw = true;
			}
			else if (event.type == ALLEGRO_EVENT_DISPLAY_HALT_DRAWING) {
				switch_game_out(true);
				redraw = true;
				if (!isMultitaskingSupported())
					exit(0);
				continue;
			}
			else
#endif
				if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == logic_timer) {
					updateStarAlpha();
					
					if (st1_dir == 1) {
						st1_x += st1_xinc;
						st1_y += st1_yinc;
						st1_scale += st1_scaleinc;
						if (st1_xinc < 0) {
							if (st1_x < st1_x2) {
								st1_dir = -st1_dir;
							}
						}
						else {
							if (st1_x > st1_x2) {
								st1_dir = -st1_dir;
							}
						}
					}
					else {
						st1_x -= st1_xinc;
						st1_y -= st1_yinc;
						st1_scale -= st1_scaleinc;
						if (st1_xinc < 0) {
							if (st1_x > st1_x1) {
								st1_dir = -st1_dir;
							}
						}
						else {
							if (st1_x < st1_x1) {
								st1_dir = -st1_dir;
							}
						}
					}
					if (st2_dir == 1) {
						st2_x += st2_xinc;
						st2_y += st2_yinc;
						st2_scale += st2_scaleinc;
						if (st2_xinc < 0) {
							if (st2_x < st2_x2) {
								st2_dir = -st2_dir;
							}
						}
						else {
							if (st2_x > st2_x2) {
								st2_dir = -st2_dir;
							}
						}
					}
					else {
						st2_x -= st2_xinc;
						st2_y -= st2_yinc;
						st2_scale -= st2_scaleinc;
						if (st2_xinc < 0) {
							if (st2_x > st2_x1) {
								st2_dir = -st2_dir;
							}
						}
						else {
							if (st2_x < st2_x1) {
								st2_dir = -st2_dir;
							}
						}
					}
					
					al_lock_mutex(input_mutex);
					if (_al_list_size(touch_list) != 0) {
						al_unlock_mutex(input_mutex);
						playSample(bink);
						al_rest(0.5);
						destroy_credits_bitmaps();
						return 0;

					}
#ifndef ALLEGRO_IPHONE
					if (keysDown > 0) {
						al_unlock_mutex(input_mutex);
						playSample(bink);
						al_rest(0.5);
						destroy_credits_bitmaps();
						return 0;

					}
#endif
					al_unlock_mutex(input_mutex);
				}
				else if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == draw_timer) {
					redraw = true;
				}
		}
		
		al_lock_mutex(switched_out_mutex);
		if (redraw && !switched_out) {
			al_draw_bitmap(bg_bmp, 0, 0, 0);
			al_draw_scaled_bitmap(
					      space_bmps[7],
					      0, 0, al_get_bitmap_width(space_bmps[7]), al_get_bitmap_height(space_bmps[7]),
					      st1_x, st1_y, 
					      al_get_bitmap_width(space_bmps[7])*st1_scale, al_get_bitmap_height(space_bmps[7])*st1_scale,
					      0
					      );
			al_draw_scaled_bitmap(
					      space_bmps[4],
					      0, 0, al_get_bitmap_width(space_bmps[4]), al_get_bitmap_height(space_bmps[4]),
					      st2_x, st2_y, 
					      al_get_bitmap_width(space_bmps[4])*st2_scale, al_get_bitmap_height(space_bmps[4])*st2_scale,
					      0
					      );
			al_draw_bitmap(menu_bmp, 0, 0, 0);
			al_draw_bitmap(logo_bmp, 390, 60, 0);
			ALLEGRO_STATE blend_state;
			al_store_state(&blend_state, ALLEGRO_STATE_BLENDER);
			al_set_blender(ALLEGRO_ADD, ALLEGRO_ONE, ALLEGRO_ONE);
			al_draw_tinted_bitmap(logo_bmp, al_map_rgba_f(starAlpha, starAlpha, starAlpha, starAlpha), 390, 60, 0);
			al_restore_state(&blend_state);
			al_draw_filled_rectangle(0, 0, SCR_W, SCR_H, al_map_rgba_f(0, 0, 0, 0.75));
			begin_text_draw();
			al_draw_text(font, al_map_rgb(0xff, 0xd8, 0x00), 25, 345, 0, "© 2011 Nooskewl & Studio Dereka");
			al_draw_text(font, al_map_rgb(255, 255, 255), 25, 385, 0, "Special thanks to:");
			al_draw_text(font, al_map_rgb(200, 200, 200), 75, 425, 0, "Oscar Giner &");
			al_draw_text(font, al_map_rgb(200, 200, 200), 75, 465, 0, "Kris Asick for level design");
			al_draw_text(font, al_map_rgb(200, 200, 200), 75, 505, 0, "Jon Baken &");
			al_draw_text(font, al_map_rgb(200, 200, 200), 75, 545, 0, "Tony Huisman for the tunes");
			end_text_draw();
			al_draw_bitmap(arrow_bmp, SCR_W-80, SCR_H-80, ALLEGRO_FLIP_HORIZONTAL);
			flip_display();
		}
		al_unlock_mutex(switched_out_mutex);
		
		al_rest(0.001);
	}
}

static ALLEGRO_BITMAP *load_story_bitmaps()
{
	story_bmp = al_load_bitmap(getResource("story.png"));

	TEXT *text = load_text(getResource("intro"));
	
	int maxlen = 0;
	int i;
	int nlines = text->nlines;
	for (i = 0; i < text->nlines; i++) {
		int len = al_get_text_width(font, text->lines[i]);
		if (len > maxlen)
			maxlen = len;
	}
	
	int xx = (SCR_W-maxlen)/2;
	
	ALLEGRO_BITMAP *tmp = al_create_bitmap(SCR_W, SCR_H);
	al_set_target_bitmap(tmp);
	al_clear_to_color(al_map_rgba(0, 0, 0, 0));
	int yy = 0;
	for (i = 0; i < text->nlines; i++) {
		int flags = 0;
		int xpos;
		if (i == nlines-1) {
			xpos = SCR_W/2;
			flags = ALLEGRO_ALIGN_CENTRE;
		}
		else
			xpos = xx;
		al_draw_text(font, al_map_rgb(200, 200, 200), xpos, yy, flags, text->lines[i]);
		yy += al_get_font_line_height(font);
	}
	
	destroy_text(text);
	
	al_set_target_backbuffer(display);
	
	return tmp;
}

static void destroy_story_bitmaps(ALLEGRO_BITMAP *tmp)
{
	al_destroy_bitmap(story_bmp);
	al_destroy_bitmap(tmp);
}

static int story(void)
{
	al_start_timer(logic_timer);
	al_start_timer(draw_timer);
	
#if defined ALLEGRO_IPHONE || defined ALLEGRO_MACOSX
	[joypad performSelectorOnMainThread: @selector(find_devices) withObject:nil waitUntilDone:YES];
#endif
	
	bool redraw = true;
	float y = SCR_H+10;
	float dy = -20.0 / LOGIC_PER_SEC;

	TEXT *text = load_text(getResource("intro"));
	int nlines = text->nlines;
	destroy_text(text);
	
	ALLEGRO_BITMAP *tmp = load_story_bitmaps();

	while (true) {
		ALLEGRO_EVENT event;
		
		while (!al_event_queue_is_empty(queue)) {
			al_get_next_event(queue, &event);
			
#ifdef ALLEGRO_IPHONE
			if (event.type == ALLEGRO_EVENT_DISPLAY_SWITCH_OUT) {
				switch_game_out(false);
				redraw = true;
			}
			else if (event.type == ALLEGRO_EVENT_DISPLAY_HALT_DRAWING) {
				switch_game_out(true);
				redraw = true;
				if (!isMultitaskingSupported())
					exit(0);
				continue;
			}
			else
#endif
				if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == logic_timer) {
					y += dy;
					if (y < (SCR_H-(nlines*al_get_font_line_height(font))-40)) {
						y = (SCR_H-(nlines*al_get_font_line_height(font))-40);
					}
					    
					al_lock_mutex(input_mutex);
					if (_al_list_size(touch_list) != 0) {
						al_unlock_mutex(input_mutex);
						playSample(bink);
						al_rest(0.5);
						destroy_story_bitmaps(tmp);
						return 0;
					}
#ifndef ALLEGRO_IPHONE
					if (keysDown > 0) {
						al_unlock_mutex(input_mutex);
						playSample(bink);
						al_rest(0.5);
						destroy_story_bitmaps(tmp);
						return 0;
					}
#endif
					al_unlock_mutex(input_mutex);
				}
				else if (event.type == ALLEGRO_EVENT_TIMER && event.timer.source == draw_timer) {
					redraw = true;
				}
		}
		
		al_lock_mutex(switched_out_mutex);
		if (redraw && !switched_out) {
			al_clear_to_color(al_map_rgb(0, 0, 0));
			al_draw_bitmap(tmp, 0, (int)y, 0);
			ALLEGRO_VERTEX v[4];
			v[0].x = 0;
			v[0].y = 549;
			v[0].z = 0;
			v[0].color = al_map_rgba_f(0, 0, 0, 1);
			v[1].x = SCR_W;
			v[1].y = 549;
			v[1].z = 0;
			v[1].color = al_map_rgba_f(0, 0, 0, 1);
			v[2].x = SCR_W;
			v[2].y = 549+12;
			v[2].z = 0;
			v[2].color = al_map_rgba_f(0, 0, 0, 0);
			v[3].x = 0;
			v[3].y = 549+12;
			v[3].z = 0;
			v[3].color = al_map_rgba_f(0, 0, 0, 0);
			al_draw_prim(v, 0, 0, 0, 4, ALLEGRO_PRIM_TRIANGLE_FAN);
			al_draw_scaled_bitmap(story_bmp,
				0, 0,
				al_get_bitmap_width(story_bmp), al_get_bitmap_height(story_bmp),
				0, 0,
				al_get_bitmap_width(story_bmp)*2, al_get_bitmap_height(story_bmp)*2,
				0);
			flip_display();
		}
		al_unlock_mutex(switched_out_mutex);
		
		al_rest(0.001);
	}
}

//#ifdef ABCD
static int dummy_atexit(void (*crap)(void))
{
	(void)crap;
	return 0;
}
//#endif

int _al_mangled_main(int argc, char **argv);

int main(int argc, char **argv)
{
	srand(time(NULL));

	/* initialize Allegro */
//#ifdef ALLEGRO_IPHONE
#if 1
 	al_init();
#else
	al_install_system(ALLEGRO_VERSION_INT, dummy_atexit);
#endif

#ifndef ALLEGRO_IPHONE
	if (argc > 1 && !strcmp(argv[1], "-second-display"))
		default_adapter = 1;
#endif

	al_set_org_name("Nooskewl");
#ifdef LITE
	al_set_app_name("Bobby-Lite");
#else
	al_set_app_name("Bobby");
#endif
	
	// this has to be before al_create_display
	load_save();

	al_init_image_addon();
	al_init_primitives_addon();
	al_init_font_addon();
	al_init_ttf_addon();

#ifndef ALLEGRO_IPHONE
	al_install_keyboard();
	al_install_mouse();
	al_install_joystick();
	configure_joysticks();
#else
	al_install_touch_input();
#endif

	OFFSET = 32;
	BUTTON_SIZE = 160;

	logic_timer = al_create_timer(1.0/LOGIC_PER_SEC);
	//draw_timer = al_create_timer(1.0/60.0);
	draw_timer = al_create_timer(1.0/1000.0);
	
	queue = al_create_event_queue();
	al_register_event_source(queue, al_get_timer_event_source(logic_timer));
	al_register_event_source(queue, al_get_timer_event_source(draw_timer));
	
	input_queue = al_create_event_queue();
#ifdef ALLEGRO_IPHONE
	al_register_event_source(input_queue, al_get_touch_input_event_source());
#else
	al_register_event_source(input_queue, al_get_keyboard_event_source());
	al_register_event_source(input_queue, al_get_mouse_event_source());
	al_register_event_source(input_queue, al_get_joystick_event_source());
#endif
	
	touch_list = _al_list_create();
	
	input_mutex = al_create_mutex();
	switched_out_mutex = al_create_mutex();

#ifdef ALLEGRO_IPHONE
	al_set_new_bitmap_format(ALLEGRO_PIXEL_FORMAT_RGBA_4444);
#endif
	
	int flags = al_get_new_bitmap_flags();
	al_set_new_bitmap_flags(ALLEGRO_MEMORY_BITMAP);
	gradient_bmp = al_load_bitmap(getResource("gradient.png"));
	rainbow_bmp = al_load_bitmap(getResource("rainbow.png"));
	al_set_new_bitmap_flags(flags);
	
	create_gfx_stuff();
	
	#if defined ALLEGRO_WINDOWS || defined __linux__
	#ifdef LITE
	ALLEGRO_BITMAP *tmp_bmp = al_load_bitmap(getResource("icon-lite.png"));
	#else
	ALLEGRO_BITMAP *tmp_bmp = al_load_bitmap(getResource("icon-full.png"));
	#endif
	al_set_display_icon(display, tmp_bmp);
	al_destroy_bitmap(tmp_bmp);
	#endif



#if defined ALLEGRO_IPHONE || defined ALLEGRO_MACOSX
	joypad = [[joypad_handler alloc] init];
	[joypad performSelectorOnMainThread: @selector(start) withObject:nil waitUntilDone:YES];
#endif
	


#if !defined(WITHOUT_GAMECENTER) && defined(ALLEGRO_IPHONE)
	// init game center
	authenticatePlayer();
#elif !defined(ALLEGRO_IPHONE)
	loadPCAchievements();
#endif
	
	spaceThingInc = SCR_W/(LOGIC_PER_SEC*AVG_SPACE_THING_TIME);

	scrolling_strings = _al_list_create();
    
	initSound();

#ifdef ALLEGRO_IPHONE
	/** FIXME: must init 60beat GamePad here! **/
	UIApplication *thisApp = [UIApplication sharedApplication];
        thisApp.idleTimerDisabled = YES;
#endif

	start = loadSample(getResource("start.ogg"));
	boing = loadSample(getResource("boing.ogg"));
	spiral = loadSample(getResource("spiral.ogg"));
	bink = loadSample(getResource("bink.ogg"));
	boost = loadSampleLoop(getResource("boost.ogg"));
	switch_sample = loadSample(getResource("switch.ogg"));
	meow = loadSample(getResource("meow.ogg"));

	splash1 = al_load_bitmap(getResource("nooskewl_square.png"));
	splash2 = al_load_bitmap(getResource("dereka.png"));
	int splashSize = al_get_bitmap_width(splash1);

	// splash screen
	al_set_target_backbuffer(display);
	double begin = al_get_time();
	while (al_get_time() < begin+3) {
		double elapsed = al_get_time() - begin;
		int section;
		ALLEGRO_COLOR c;
		if (elapsed > 2) {
		    section = 2;
		    elapsed -= 2.0;
		    c = al_map_rgba_f(0, 0, 0, elapsed);
		    al_clear_to_color(al_map_rgb(255, 255, 255));
		}
		else {
		    if (elapsed > 1) {
			section = 1;
			elapsed -= 1.0;
		    }
		    else
			section = 0;
		    c = al_map_rgba_f(elapsed, elapsed, elapsed, elapsed);
		    al_clear_to_color(al_map_rgb(0, 0, 0));
		}
		float w = SCR_W/2;
		float x1 = -splashSize;
		float x2 = SCR_W;
		if (section == 0) {
			al_draw_tinted_bitmap(
				splash1,
				c,
				x1+(w*elapsed),
				(SCR_H-splashSize)/2,
				0
			);
			al_draw_tinted_bitmap(
				splash2,
				c,
				x2-(w*elapsed),
				(SCR_H-splashSize)/2,
				0
			);
		}
		else {
			if (section == 1) {
				al_draw_bitmap(
					splash1,
					x1+w,
					(SCR_H-splashSize)/2,
					0
				);
				al_draw_bitmap(
					splash2,
					x2-w,
					(SCR_H-splashSize)/2,
					0
				);
			}
			al_draw_filled_rectangle(0, 0, SCR_W, SCR_H, c);
		}
		flip_display();
	}
	al_destroy_bitmap(splash1);
	al_destroy_bitmap(splash2);

#ifdef ALLEGRO_IPHONE
	{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// Don't play music if iPod is already playing at game start
	MPMusicPlayerController *musicPlayer;
 	musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
	noMusic = musicPlayer.playbackState & MPMusicPlaybackStatePlaying;
	[pool drain];
	}
#endif
	
	next_smoke = al_get_time();
	int SH = (LEVEL_H*TILE_SIZE);
	int PREVIEW_H = 256 * ((float)SCR_H/SCR_W);
	float vgap = (SH-PREVIEW_H*2) / 5;
	scrolly = 0;
		
	bool quit = false;

	al_run_detached_thread(input_thread, NULL);
	
	story();

	if (!noMusic && music_on) {
		playMusic(true);
	}
	
	// more initialization crap
	st1_x = st1_x1, st1_y = st1_y1, st1_scale = st1_scale1;
	st1_dir = 1;
	st2_x = st2_x1, st2_y = st2_y1, st2_scale = st2_scale1;
	st2_dir = 1;

	while (!quit) {
		int choice = menu();
		if (choice == CONTINUE) {
			while (true) {
				level = select_level();
				if (level == -1) {
					quit = true;
					break;
				}
				else if (level == -2)
					break;
				al_rest(0.5);
				if (!start_the_game()) {
					quit = true;
					break;
				}
			}
		}
		else if (choice == CREDITS) {
			if (credits() < 0)
				quit = true;
		}
		else if (choice == SETTINGS) {
			if (settings() < 0)
				quit = true;
		}
		else if (choice < 0)
			quit = true;
	}

	return 0;
}
