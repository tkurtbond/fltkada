

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/Fl.H>
#include <FL/glut.H>
#include "c_fl_glut.h"




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
    return n;
}

int fl_glut_create_sub_window(int win, int x, int y, int w, int h) {
    return glutCreateSubWindow(win, x, y, w, h);
}

void fl_glut_destroy_window(int win) {
    glutDestroyWindow(win);
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
    glutSetIconTitle(const_cast<char*>(t));
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
    glutShowWindow();
}

void fl_glut_hide_window() {
    glutHideWindow();
}

void fl_glut_full_screen() {
    glutFullScreen();
}

void fl_glut_set_cursor(int c) {
    glutSetCursor(static_cast<Fl_Cursor>(c));
}

void fl_glut_warp_pointer(int x, int y) {
    glutWarpPointer(x, y);
}




//  Overlays

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
    return glutCreateMenu(reinterpret_cast<Glut_Int_F*>(f));
}

void fl_glut_destroy_menu(int m) {
    glutDestroyMenu(m);
}

int fl_glut_get_menu() {
    return glutGetMenu();
}

void fl_glut_set_menu(int m) {
    glutSetMenu(m);
}

void fl_glut_add_menu_entry(const char * t, int v) {
    glutAddMenuEntry(t, v);
}

void fl_glut_add_sub_menu(const char * t, int s) {
    glutAddSubMenu(const_cast<char*>(t), s);
}

void fl_glut_change_to_menu_entry(int i, const char * t, int v) {
    glutChangeToMenuEntry(i, const_cast<char*>(t), v);
}

void fl_glut_change_to_sub_menu(int i, const char * t, int s) {
    glutChangeToSubMenu(i, const_cast<char*>(t), s);
}

void fl_glut_remove_menu_item(int i) {
    glutRemoveMenuItem(i);
}

void fl_glut_attach_menu(int b) {
    glutAttachMenu(b);
}

void fl_glut_detach_menu(int b) {
    glutDetachMenu(b);
}




//  Callbacks

void fl_glut_display_func(void * f) {
    glutDisplayFunc(reinterpret_cast<Glut_Void_F*>(f));
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
    glutOverlayDisplayFunc(reinterpret_cast<Glut_Void_F*>(f));
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

int fl_glut_get(unsigned int t) {
    return glutGet(t);
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


