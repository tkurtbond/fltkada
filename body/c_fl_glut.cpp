

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/Fl.H>
#include <FL/glut.H>
#include <FL/gl.h>
#include <FL/platform.H>
#include <deque>
#include <map>
#include <string>
#include <vector>
#include "c_fl_glut.h"
#include "c_fl_gl_window.h"
#include "c_fl_widget.h"




//  The callback typedefs that glut.H only spells out inline

typedef void (Glut_Void_F)();
typedef void (Glut_Int_F)(int);
typedef void (Glut_Int2_F)(int, int);
typedef void (Glut_Int3_F)(int, int, int);
typedef void (Glut_Int4_F)(int, int, int, int);
typedef void (Glut_Key_F)(unsigned char, int, int);


//  FLTK 1.4.5's glut.H declares glutExtensionSupported(char*), but
//  glut_compatibility.cxx defines and exports it as taking const char*,
//  so a call through the header's declaration cannot link. Declaring
//  the overload that libfltk_gl really exports works with either.

FL_EXPORT int glutExtensionSupported(const char * name);





//  The windows and menus GLUT has (pofltk 112)

//  GLUT follows a window or menu number without a look, deletes a window at
//  once even while it draws, and keeps every string it is given, so what is
//  needed to check them, which glut_compatibility.cxx keeps to itself, is
//  kept here.  Ported from pofltk's FlGlut.cpp.

//  MAXWINDOWS and MAXMENUS in glut_compatibility.cxx.  Every window or menu
//  past the 31st gets number 32, which the 31st has (:168, :308).
static const int max_windows = 32;
static const int max_menus = 32;

//  Every GLUT window, by number.  Fl::watch_widget_pointer zeroes a slot
//  when its window is deleted (Fl_Widget.cxx:167), however that comes.
//  Which of them are going, or hiding; which Ada made, as Glut_Windows;
//  each one's icon title, which FLTK only points at (Fl_Window.cxx:545);
//  and its display functions.
static Fl_Widget * live[max_windows + 1];
static bool destroyed[max_windows + 1];
static bool hiding[max_windows + 1];
static bool ada_made[max_windows + 1];
static std::string icon_title[max_windows + 1];
static void (*display_of[max_windows + 1])();
static void (*overlay_of[max_windows + 1])();

//  How many display functions are running.
static int displaying = 0;

static Fl_Glut_Window * live_window(int n) {
    return n >= 1 && n <= max_windows ? static_cast<Fl_Glut_Window*>(live[n]) : 0;
}

static bool alive(int n) {
    return live_window(n) != 0 && !destroyed[n];
}

void glut_window_made(Fl_Glut_Window * w, bool ada) {
    int n = w->number;
    live[n] = w;
    Fl::watch_widget_pointer(live[n]);
    destroyed[n] = false;
    hiding[n] = false;
    ada_made[n] = ada;
    icon_title[n].clear();
    display_of[n] = 0;
    overlay_of[n] = 0;
}

int fl_glut_window_alive(int n) {
    return alive(n);
}

int fl_glut_window_ada(int n) {
    return alive(n) && ada_made[n];
}

//  Window n, even while it is going, or 0.
void * fl_glut_window_pointer(int n) {
    return live_window(n);
}

int fl_glut_has_room() {
    int used = 0;
    for (int n = 1; n <= max_windows; n++) {
        used += live[n] != 0;
    }
    return used < max_windows - 1;
}

//  What FLTK calls, with the window drawn current, in place of the display
//  functions Ada gave it, so that it is known to be inside Fl::flush.  A
//  window going can be drawn before it has gone.
static void run(void (* const * of)()) {
    int n = glut_window->number;
    if (destroyed[n] || !of[n]) {
        return;
    }
    displaying++;
    of[n]();
    displaying--;
}

static void run_display() {
    run(display_of);
}

static void run_overlay() {
    run(overlay_of);
}

//  Deletes or hides window n, as GLUT would have, when the program next
//  waits: hiding a window in its display function frees what Fl::flush is
//  walking, and a window can go while GLUT's calls are on the stack.
static void settle(void * data) {
    int n = static_cast<int>(reinterpret_cast<intptr_t>(data));
    Fl_Glut_Window * w = live_window(n);
    if (!w) {
        return;
    }
    Fl_Glut_Window * was = glut_window;
    if (destroyed[n]) {
        for (int i = 1; i <= max_windows; i++) {
            if (live[i] && w->contains(live[i])) {
                live_window(i)->visibility = 0;
            }
        }
        //  Window_Of may have given them Ada objects, which outlive them, so
        //  the table of Ada objects is not to keep them
        widget_forget_ada_objects(w);
        Fl::delete_widget(w);
        if (was && w->contains(was)) {
            was = 0;
        }
    } else if (hiding[n]) {
        hiding[n] = false;
        w->hide();
    }
    glut_window = was;
    if (was) {
        glutSetWindow(was->number);
    }
}

static void * settle_data(int n) {
    return reinterpret_cast<void*>(static_cast<intptr_t>(n));
}

static void settle_later(int n) {
    Fl::remove_timeout(settle, settle_data(n));
    Fl::add_timeout(0.0, settle, settle_data(n));
}


//  What FLTK's menu has that it won't tell: the labels it points at, each
//  item's submenu or 0, and the size of its array, mirroring additem
//  (glut_compatibility.cxx:331-346).
struct Glut_Menu {
    Glut_Menu() : alloc(0) {}
    std::deque<std::string> labels;
    std::vector<int> subs;
    int alloc;
};

static std::map<int, Glut_Menu> menus;

static Glut_Menu * find_menu(int m) {
    std::map<int, Glut_Menu>::iterator i = menus.find(m);
    return i == menus.end() ? 0 : &i->second;
}

static Glut_Menu * current_menu() {
    return find_menu(glut_menu);
}

//  A deque's elements stay where they are as it grows.
static char * keep(Glut_Menu * m, const char * label) {
    m->labels.push_back(label);
    return &m->labels.back()[0];
}

static void will_add(Glut_Menu * m) {
    int size = static_cast<int>(m->subs.size());
    if (size + 1 >= m->alloc) {
        m->alloc = size * 2 + 10;
    }
}

//  additem sets only the text of the menu's terminator (:342), and a pop-up
//  reads its flags.  glutChangeToMenuEntry takes its item unchecked, so it
//  can set them.
static void seal(Glut_Menu * m) {
    glutChangeToMenuEntry(static_cast<int>(m->subs.size()) + 1, 0, 0);
}

int fl_glut_menu_exists(int m) {
    return find_menu(m) != 0;
}

int fl_glut_menu_room() {
    return static_cast<int>(menus.size()) < max_menus - 1;
}

int fl_glut_menu_items(int m) {
    Glut_Menu * g = find_menu(m);
    return g ? static_cast<int>(g->subs.size()) : 0;
}

//  Whether m is another menu's submenu, which points at m's array of items,
//  which adding to m, removing from it or destroying it would free.
int fl_glut_menu_used(int m) {
    for (std::map<int, Glut_Menu>::iterator i = menus.begin(); i != menus.end(); ++i) {
        std::vector<int> & s = i->second.subs;
        for (size_t k = 0; k < s.size(); k++) {
            if (s[k] == m) {
                return 1;
            }
        }
    }
    return 0;
}


//  glGetIntegerv leaves p alone for a query GL doesn't take.
static int gl_int(GLenum type) {
    GLint p = 0;
    glGetIntegerv(type, &p);
    return p;
}




//  Initialisation

void fl_glut_init(int * argc, void * argv) {
    glutInit(argc, static_cast<char**>(argv));
}

void fl_glut_init_display_mode(unsigned int m) {
    glutInitDisplayMode(m);
}

void fl_glut_init_window_position(int x, int y) {
    glutInitWindowPosition(x, y);
}

void fl_glut_init_window_size(int w, int h) {
    glutInitWindowSize(w, h);
}

void fl_glut_main_loop() {
    glutMainLoop();
}




//  Windows

int fl_glut_create_window(const char * t) {
    int n = glutCreateWindow(t);
    //  Fl_Widget::label does not copy, so take a copy before Ada frees t
    if (glut_window) {
        glut_window->copy_label(t);
    }
    glut_window_made(glut_window, false);
    return n;
}

int fl_glut_create_sub_window(int win, int x, int y, int w, int h) {
    int n = glutCreateSubWindow(win, x, y, w, h);
    glut_window_made(glut_window, false);
    return n;
}

//  Later, not at once as glutDestroyWindow does (:279): a window can go in
//  its own display function, or with GLUT's calls on the stack.  Returns 0,
//  and does nothing, if a window Ada made would go too.
int fl_glut_destroy_window(int win) {
    Fl_Glut_Window * w = live_window(win);
    for (int n = 1; n <= max_windows; n++) {
        if (alive(n) && ada_made[n] && w->contains(live[n])) {
            return 0;
        }
    }
    for (int n = 1; n <= max_windows; n++) {
        if (live[n] && w->contains(live[n])) {
            destroyed[n] = true;
            Fl::remove_timeout(settle, settle_data(n));
        }
    }
    if (glut_window && w->contains(glut_window)) {
        glut_window = 0;
    }
    settle_later(win);
    return 1;
}

void fl_glut_post_redisplay() {
    glutPostRedisplay();
}

void fl_glut_post_window_redisplay(int win) {
    glutPostWindowRedisplay(win);
}

void fl_glut_swap_buffers() {
    glutSwapBuffers();
}

int fl_glut_get_window() {
    return glutGetWindow();
}

void fl_glut_set_window(int win) {
    glutSetWindow(win);
}




void fl_glut_set_window_title(const char * t) {
    //  glutSetWindowTitle does not copy the string, so copy it here
    if (glut_window) {
        glut_window->copy_label(t);
    }
}

void fl_glut_set_icon_title(const char * t) {
    if (glut_window) {
        int n = glut_window->number;
        icon_title[n] = t;
        glut_window->iconlabel(icon_title[n].c_str());
    }
}

void fl_glut_position_window(int x, int y) {
    glutPositionWindow(x, y);
}

void fl_glut_reshape_window(int w, int h) {
    glutReshapeWindow(w, h);
}

void fl_glut_pop_window() {
    glutPopWindow();
}

void fl_glut_push_window() {
    glutPushWindow();
}

void fl_glut_iconify_window() {
    glutIconifyWindow();
}

void fl_glut_show_window() {
    if (glut_window) {
        hiding[glut_window->number] = false;
    }
    glutShowWindow();
}

//  Later, while a window draws: hiding it frees what Fl::flush is walking.
void fl_glut_hide_window() {
    if (!glut_window) {
        return;
    }
    if (displaying || gl_window_drawing) {
        hiding[glut_window->number] = true;
        settle_later(glut_window->number);
    } else {
        glutHideWindow();
    }
}

//  Not on a window hiding later, which under Wayland would wait for an
//  expose that the hiding ends.
void fl_glut_full_screen() {
    if (glut_window && !hiding[glut_window->number]) {
        glutFullScreen();
    }
}

void fl_glut_set_cursor(int c) {
    glutSetCursor(static_cast<Fl_Cursor>(c));
}

void fl_glut_warp_pointer(int x, int y) {
    glutWarpPointer(x, y);
}




//  Overlays

//  make_overlay_current works on a window not shown: on X11 and Wayland
//  it is glDrawBuffer(GL_FRONT) (FLTKAda-BUGS.md 91).

void fl_glut_establish_overlay() {
    glutEstablishOverlay();
}

void fl_glut_remove_overlay() {
    glutRemoveOverlay();
}

void fl_glut_use_layer(unsigned int l) {
    glutUseLayer(l);
}

void fl_glut_post_overlay_redisplay() {
    glutPostOverlayRedisplay();
}

void fl_glut_show_overlay() {
    glutShowOverlay();
}

void fl_glut_hide_overlay() {
    glutHideOverlay();
}




//  Menus

int fl_glut_create_menu(void * f) {
    int n = glutCreateMenu(reinterpret_cast<Glut_Int_F*>(f));
    menus[n];
    return n;
}

//  A window's button on a destroyed menu would pop up a null pointer
//  (domenu, :298), and glutDestroyMenu leaves glut_menu set.
void fl_glut_destroy_menu(int m) {
    for (int n = 1; n <= max_windows; n++) {
        Fl_Glut_Window * w = live_window(n);
        if (w) {
            for (int b = 0; b < 3; b++) {
                if (w->menu[b] == m) {
                    w->menu[b] = 0;
                }
            }
        }
    }
    glutDestroyMenu(m);
    menus.erase(m);
    if (glut_menu == m) {
        glut_menu = 0;
    }
}

int fl_glut_get_menu() {
    return glutGetMenu();
}

void fl_glut_set_menu(int m) {
    glutSetMenu(m);
}

void fl_glut_add_menu_entry(const char * t, int v) {
    Glut_Menu * m = current_menu();
    will_add(m);
    m->subs.push_back(0);
    glutAddMenuEntry(keep(m, t), v);
    seal(m);
}

void fl_glut_add_sub_menu(const char * t, int s) {
    Glut_Menu * m = current_menu();
    will_add(m);
    m->subs.push_back(s);
    glutAddSubMenu(keep(m, t), s);
    seal(m);
}

void fl_glut_change_to_menu_entry(int i, const char * t, int v) {
    Glut_Menu * m = current_menu();
    m->subs[i - 1] = 0;
    glutChangeToMenuEntry(i, keep(m, t), v);
}

void fl_glut_change_to_sub_menu(int i, const char * t, int s) {
    Glut_Menu * m = current_menu();
    m->subs[i - 1] = s;
    glutChangeToSubMenu(i, keep(m, t), s);
}

//  glutRemoveMenuItem copies down the item past the terminator (:384),
//  which is past the array when that is full, so an item more makes it
//  larger first.
void fl_glut_remove_menu_item(int i) {
    Glut_Menu * m = current_menu();
    bool full = static_cast<int>(m->subs.size()) + 1 == m->alloc;
    if (full) {
        will_add(m);
        glutAddMenuEntry(keep(m, ""), 0);
    }
    glutRemoveMenuItem(i);
    m->subs.erase(m->subs.begin() + (i - 1));
    if (full) {
        glutRemoveMenuItem(static_cast<int>(m->subs.size()) + 1);
    }
    seal(m);
}

void fl_glut_attach_menu(int b) {
    glutAttachMenu(b);
}

void fl_glut_detach_menu(int b) {
    glutDetachMenu(b);
}




//  Callbacks

void fl_glut_display_func(void * f) {
    if (glut_window) {
        display_of[glut_window->number] = reinterpret_cast<Glut_Void_F*>(f);
        glutDisplayFunc(run_display);
    }
}

void fl_glut_reshape_func(void * f) {
    glutReshapeFunc(reinterpret_cast<Glut_Int2_F*>(f));
}

void fl_glut_keyboard_func(void * f) {
    glutKeyboardFunc(reinterpret_cast<Glut_Key_F*>(f));
}

void fl_glut_mouse_func(void * f) {
    glutMouseFunc(reinterpret_cast<Glut_Int4_F*>(f));
}

void fl_glut_motion_func(void * f) {
    glutMotionFunc(reinterpret_cast<Glut_Int2_F*>(f));
}

void fl_glut_passive_motion_func(void * f) {
    glutPassiveMotionFunc(reinterpret_cast<Glut_Int2_F*>(f));
}

void fl_glut_entry_func(void * f) {
    glutEntryFunc(reinterpret_cast<Glut_Int_F*>(f));
}

void fl_glut_visibility_func(void * f) {
    glutVisibilityFunc(reinterpret_cast<Glut_Int_F*>(f));
}

void fl_glut_special_func(void * f) {
    glutSpecialFunc(reinterpret_cast<Glut_Int3_F*>(f));
}

void fl_glut_overlay_display_func(void * f) {
    if (glut_window) {
        overlay_of[glut_window->number] = reinterpret_cast<Glut_Void_F*>(f);
        glutOverlayDisplayFunc(run_overlay);
    }
}

void fl_glut_idle_func(void * f) {
    glutIdleFunc(reinterpret_cast<Glut_Void_F*>(f));
}

void fl_glut_timer_func(unsigned int msec, void * f, void * d) {
    //  Same as the inline glutTimerFunc, but with a pointer for data instead
    //  of an int, so that Ada can pass its own closure record through
    Fl::add_timeout(msec * .001, reinterpret_cast<Fl_Timeout_Handler>(f), d);
}

void fl_glut_menu_state_func(void * f) {
    glutMenuStateFunc(reinterpret_cast<Glut_Int_F*>(f));
}

void fl_glut_menu_status_func(void * f) {
    glutMenuStatusFunc(reinterpret_cast<Glut_Int3_F*>(f));
}




//  Queries

//  GLUT_DISPLAY_MODE_POSSIBLE is Fl_Gl_Window::can_do (glut_compatibility.cxx:410),
//  which needs the display open (pofltk 110).
//  GLUT_WINDOW_PARENT casts the parent, whatever it is (:398).
//  GLUT_WINDOW_BUFFER_SIZE asks glutGet(GLUT_WINDOW_RGBA), which is GL_RGBA,
//  not a glGetIntegerv query (:421).  And the default leaves p unset for a
//  query GL doesn't take (:430).
int fl_glut_get(unsigned int t) {
    switch (t) {
    case GLUT_WINDOW_PARENT: {
        Fl_Group * p = glut_window ? glut_window->parent() : 0;
        Fl_Glut_Window * g = dynamic_cast<Fl_Glut_Window*>(p);
        return g ? g->number : 0;
    }
    case GLUT_DISPLAY_MODE_POSSIBLE:
        fl_open_display();
        return glutGet(t);
    case GLUT_WINDOW_BUFFER_SIZE:
        return gl_int(GL_RED_BITS) + gl_int(GL_GREEN_BITS)
            + gl_int(GL_BLUE_BITS) + gl_int(GL_ALPHA_BITS);
    default:
        return t >= 100 ? gl_int(t) : glutGet(t);
    }
}

int fl_glut_device_get(unsigned int t) {
    return glutDeviceGet(t);
}

int fl_glut_layer_get(unsigned int t) {
    return glutLayerGet(t);
}

int fl_glut_get_modifiers() {
    return glutGetModifiers();
}

int fl_glut_extension_supported(const char * n) {
    return glutExtensionSupported(n);
}

void * fl_glut_get_proc_address(const char * n) {
    return reinterpret_cast<void*>(glutGetProcAddress(n));
}





//  The fonts (Phase 13)

//  Bitmap_Font'Pos and Stroke_Font'Pos.
static Fl_Glut_Bitmap_Font * bitmap_font(int f) {
    static Fl_Glut_Bitmap_Font * const fonts[] = {
        GLUT_BITMAP_9_BY_15, GLUT_BITMAP_8_BY_13, GLUT_BITMAP_TIMES_ROMAN_10,
        GLUT_BITMAP_TIMES_ROMAN_24, GLUT_BITMAP_HELVETICA_10, GLUT_BITMAP_HELVETICA_12,
        GLUT_BITMAP_HELVETICA_18};
    return fonts[f];
}

static Fl_Glut_StrokeFont * stroke_font(int f) {
    return f == 0 ? GLUT_STROKE_ROMAN : GLUT_STROKE_MONO_ROMAN;
}

//  How many pixels a unit of gl_width is: the GL window's, or with
//  gl_start the screen's scale, by which gl_font scales the font
//  (gl_draw.cxx:579).
static float text_scale() {
    Fl_Window * c = Fl_Window::current();
    Fl_Gl_Window * g = c->as_gl_window();
    if (g != 0) {
        return g->pixels_per_unit();
    }
    return Fl::screen_scale(c->screen_num());
}

//  glutBitmapString and glutBitmapCharacter are gl_draw, which crashes
//  on text with no width (pofltk 134), and moves the raster position on
//  by the width of the texture it drew, a multiple of 4 pixels, not by
//  the text's (gl_draw.cxx:396, pofltk 135).  So the text is drawn only
//  if it has a width, and the position is moved on by it.  Ada checks
//  that there is a GL context.
void fl_glut_bitmap_draw(int f, const char * s, int n) {
    Fl_Glut_Bitmap_Font * font = bitmap_font(f);
    gl_font(font->font, font->size);
    double w = gl_width(s, n);
    if (!(w > 0)) {
        return;
    }
    GLint valid;
    glGetIntegerv(GL_CURRENT_RASTER_POSITION_VALID, &valid);
    GLfloat before[4];
    glGetFloatv(GL_CURRENT_RASTER_POSITION, before);
    gl_draw(s, n);
    if (!valid) {
        return;
    }
    GLfloat after[4];
    glGetFloatv(GL_CURRENT_RASTER_POSITION, after);
    GLfloat target = before[0] + static_cast<GLfloat>(w) * text_scale();
    glBitmap(0, 0, 0, 0, target - after[0], before[1] - after[1], 0);
}

int fl_glut_bitmap_width(int f, int c) {
    return glutBitmapWidth(bitmap_font(f), c);
}

//  glutBitmapLength stops at a NUL.
int fl_glut_bitmap_length(int f, const char * s, int n) {
    Fl_Glut_Bitmap_Font * font = bitmap_font(f);
    gl_font(font->font, font->size);
    return int(gl_width(s, n) + .5);
}

int fl_glut_bitmap_height(int f) {
    return glutBitmapHeight(bitmap_font(f));
}

void fl_glut_stroke_character(int f, int c) {
    glutStrokeCharacter(stroke_font(f), c);
}

//  glutStrokeString and glutStrokeLength stop at a NUL, which no stroke
//  font has, so the NULs are left out.
static std::string without_nuls(const char * s, int n) {
    std::string t;
    for (int i = 0; i < n; i++) {
        if (s[i] != 0) {
            t += s[i];
        }
    }
    return t;
}

void fl_glut_stroke_string(int f, const char * s, int n) {
    try {
        std::string t = without_nuls(s, n);
        glutStrokeString(stroke_font(f), reinterpret_cast<const unsigned char *>(t.c_str()));
    } catch (...) {
    }
}

int fl_glut_stroke_width(int f, int c) {
    return glutStrokeWidth(stroke_font(f), c);
}

int fl_glut_stroke_length(int f, const char * s, int n) {
    try {
        std::string t = without_nuls(s, n);
        return glutStrokeLength(stroke_font(f), reinterpret_cast<const unsigned char *>(t.c_str()));
    } catch (...) {
        return 0;
    }
}

float fl_glut_stroke_height(int f) {
    return glutStrokeHeight(stroke_font(f));
}






//  GLUT's shapes, each drawn solid or as a wire frame.  Ada checks the
//  counts and that there is a GL context.

void fl_glut_sphere(int solid, double r, int slices, int stacks) {
    if (solid) {
        glutSolidSphere(r, slices, stacks);
    } else {
        glutWireSphere(r, slices, stacks);
    }
}

void fl_glut_cone(int solid, double base, double height, int slices, int stacks) {
    if (solid) {
        glutSolidCone(base, height, slices, stacks);
    } else {
        glutWireCone(base, height, slices, stacks);
    }
}

void fl_glut_torus(int solid, double inner, double outer, int sides, int rings) {
    if (solid) {
        glutSolidTorus(inner, outer, sides, rings);
    } else {
        glutWireTorus(inner, outer, sides, rings);
    }
}

void fl_glut_cube(int solid, double size) {
    if (solid) {
        glutSolidCube(size);
    } else {
        glutWireCube(size);
    }
}

void fl_glut_teapot(int solid, double size) {
    if (solid) {
        glutSolidTeapot(size);
    } else {
        glutWireTeapot(size);
    }
}

//  0 a tetrahedron, 1 an octahedron, 2 a dodecahedron, 3 an icosahedron
void fl_glut_polyhedron(int solid, int shape) {
    switch (shape) {
    case 0:
        if (solid) {
            glutSolidTetrahedron();
        } else {
            glutWireTetrahedron();
        }
        break;
    case 1:
        if (solid) {
            glutSolidOctahedron();
        } else {
            glutWireOctahedron();
        }
        break;
    case 2:
        if (solid) {
            glutSolidDodecahedron();
        } else {
            glutWireDodecahedron();
        }
        break;
    default:
        if (solid) {
            glutSolidIcosahedron();
        } else {
            glutWireIcosahedron();
        }
        break;
    }
}

