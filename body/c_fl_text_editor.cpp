

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Text_Editor.H>
#include "c_fl_text_editor.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Non-friend protected access

class Friend_Text_Editor : Fl_Text_Editor {
public:
    using Fl_Text_Editor::handle_key;
    using Fl_Text_Editor::maybe_do_callback;
};




//  Attaching all relevant hooks and friends

class My_Text_Editor : public Fl_Text_Editor {
public:
    using Fl_Text_Editor::Fl_Text_Editor;

    friend void fl_text_editor_draw(TEXTEDITOR te);
    friend int fl_text_editor_handle(TEXTEDITOR te, int e);

    void draw();
    int handle(int e);
};

void My_Text_Editor::draw() {
    widget_draw_hook(this->user_data());
}

int My_Text_Editor::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

TEXTEDITOR new_fl_text_editor(int x, int y, int w, int h, char* label) {
    My_Text_Editor *te = new My_Text_Editor(x, y, w, h, label);
    return te;
}

void free_fl_text_editor(TEXTEDITOR te) {
    if (fl_inside_callback) {
        fl_delete_widget(te);
    } else {
        delete static_cast<My_Text_Editor*>(te);
    }
}




void fl_text_editor_default(TEXTEDITOR te, int k) {
    Fl_Text_Editor::kf_default(k, static_cast<Fl_Text_Editor*>(te));
}




void fl_text_editor_undo(TEXTEDITOR te) {
    Fl_Text_Editor::kf_undo(0, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_cut(TEXTEDITOR te) {
    Fl_Text_Editor::kf_cut(0, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_copy(TEXTEDITOR te) {
    Fl_Text_Editor::kf_copy(0, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_paste(TEXTEDITOR te) {
    Fl_Text_Editor::kf_paste(0, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_delete(TEXTEDITOR te) {
    Fl_Text_Editor::kf_delete(0, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_select_all(TEXTEDITOR te) {
    Fl_Text_Editor::kf_select_all(0, static_cast<Fl_Text_Editor*>(te));
}




void fl_text_editor_backspace(TEXTEDITOR te) {
    Fl_Text_Editor::kf_backspace(0, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_insert(TEXTEDITOR te) {
    Fl_Text_Editor::kf_insert(0, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_enter(TEXTEDITOR te) {
    Fl_Text_Editor::kf_enter(0, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_ignore(TEXTEDITOR te) {
    Fl_Text_Editor::kf_ignore(0, static_cast<Fl_Text_Editor*>(te));
}




void fl_text_editor_home(TEXTEDITOR te) {
    Fl_Text_Editor::kf_home(0, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_end(TEXTEDITOR te) {
    Fl_Text_Editor::kf_end(0, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_page_down(TEXTEDITOR te) {
    Fl_Text_Editor::kf_page_down(0, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_page_up(TEXTEDITOR te) {
    Fl_Text_Editor::kf_page_up(0, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_down(TEXTEDITOR te) {
    Fl_Text_Editor::kf_down(0, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_left(TEXTEDITOR te) {
    Fl_Text_Editor::kf_left(0, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_right(TEXTEDITOR te) {
    Fl_Text_Editor::kf_right(0, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_up(TEXTEDITOR te) {
    Fl_Text_Editor::kf_up(0, static_cast<Fl_Text_Editor*>(te));
}




void fl_text_editor_shift_home(TEXTEDITOR te) {
    Fl_Text_Editor::kf_shift_move(FL_Home, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_shift_end(TEXTEDITOR te) {
    Fl_Text_Editor::kf_shift_move(FL_End, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_shift_page_down(TEXTEDITOR te) {
    Fl_Text_Editor::kf_shift_move(FL_Page_Down, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_shift_page_up(TEXTEDITOR te) {
    Fl_Text_Editor::kf_shift_move(FL_Page_Up, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_shift_down(TEXTEDITOR te) {
    Fl_Text_Editor::kf_shift_move(FL_Down, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_shift_left(TEXTEDITOR te) {
    Fl_Text_Editor::kf_shift_move(FL_Left, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_shift_right(TEXTEDITOR te) {
    Fl_Text_Editor::kf_shift_move(FL_Right, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_shift_up(TEXTEDITOR te) {
    Fl_Text_Editor::kf_shift_move(FL_Up, static_cast<Fl_Text_Editor*>(te));
}




void fl_text_editor_ctrl_home(TEXTEDITOR te) {
    Fl_Text_Editor::kf_ctrl_move(FL_Home, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_ctrl_end(TEXTEDITOR te) {
    Fl_Text_Editor::kf_ctrl_move(FL_End, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_ctrl_page_down(TEXTEDITOR te) {
    Fl_Text_Editor::kf_ctrl_move(FL_Page_Down, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_ctrl_page_up(TEXTEDITOR te) {
    Fl_Text_Editor::kf_ctrl_move(FL_Page_Up, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_ctrl_down(TEXTEDITOR te) {
    Fl_Text_Editor::kf_ctrl_move(FL_Down, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_ctrl_left(TEXTEDITOR te) {
    Fl_Text_Editor::kf_ctrl_move(FL_Left, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_ctrl_right(TEXTEDITOR te) {
    Fl_Text_Editor::kf_ctrl_move(FL_Right, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_ctrl_up(TEXTEDITOR te) {
    Fl_Text_Editor::kf_ctrl_move(FL_Up, static_cast<Fl_Text_Editor*>(te));
}




void fl_text_editor_ctrl_shift_home(TEXTEDITOR te) {
    Fl_Text_Editor::kf_c_s_move(FL_Home, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_ctrl_shift_end(TEXTEDITOR te) {
    Fl_Text_Editor::kf_c_s_move(FL_End, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_ctrl_shift_page_down(TEXTEDITOR te) {
    Fl_Text_Editor::kf_c_s_move(FL_Page_Down, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_ctrl_shift_page_up(TEXTEDITOR te) {
    Fl_Text_Editor::kf_c_s_move(FL_Page_Up, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_ctrl_shift_down(TEXTEDITOR te) {
    Fl_Text_Editor::kf_c_s_move(FL_Down, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_ctrl_shift_left(TEXTEDITOR te) {
    Fl_Text_Editor::kf_c_s_move(FL_Left, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_ctrl_shift_right(TEXTEDITOR te) {
    Fl_Text_Editor::kf_c_s_move(FL_Right, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_ctrl_shift_up(TEXTEDITOR te) {
    Fl_Text_Editor::kf_c_s_move(FL_Up, static_cast<Fl_Text_Editor*>(te));
}




void fl_text_editor_meta_home(TEXTEDITOR te) {
    Fl_Text_Editor::kf_meta_move(FL_Home, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_meta_end(TEXTEDITOR te) {
    Fl_Text_Editor::kf_meta_move(FL_End, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_meta_page_down(TEXTEDITOR te) {
    Fl_Text_Editor::kf_meta_move(FL_Page_Down, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_meta_page_up(TEXTEDITOR te) {
    Fl_Text_Editor::kf_meta_move(FL_Page_Up, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_meta_down(TEXTEDITOR te) {
    Fl_Text_Editor::kf_meta_move(FL_Down, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_meta_left(TEXTEDITOR te) {
    Fl_Text_Editor::kf_meta_move(FL_Left, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_meta_right(TEXTEDITOR te) {
    Fl_Text_Editor::kf_meta_move(FL_Right, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_meta_up(TEXTEDITOR te) {
    Fl_Text_Editor::kf_meta_move(FL_Up, static_cast<Fl_Text_Editor*>(te));
}




void fl_text_editor_meta_shift_home(TEXTEDITOR te) {
    Fl_Text_Editor::kf_m_s_move(FL_Home, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_meta_shift_end(TEXTEDITOR te) {
    Fl_Text_Editor::kf_m_s_move(FL_End, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_meta_shift_page_down(TEXTEDITOR te) {
    Fl_Text_Editor::kf_m_s_move(FL_Page_Down, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_meta_shift_page_up(TEXTEDITOR te) {
    Fl_Text_Editor::kf_m_s_move(FL_Page_Up, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_meta_shift_down(TEXTEDITOR te) {
    Fl_Text_Editor::kf_m_s_move(FL_Down, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_meta_shift_left(TEXTEDITOR te) {
    Fl_Text_Editor::kf_m_s_move(FL_Left, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_meta_shift_right(TEXTEDITOR te) {
    Fl_Text_Editor::kf_m_s_move(FL_Right, static_cast<Fl_Text_Editor*>(te));
}

void fl_text_editor_meta_shift_up(TEXTEDITOR te) {
    Fl_Text_Editor::kf_m_s_move(FL_Up, static_cast<Fl_Text_Editor*>(te));
}




void fl_text_editor_add_key_binding(TEXTEDITOR te, int k, int s, void * f) {
    static_cast<Fl_Text_Editor*>(te)->add_key_binding
        (k, s, reinterpret_cast<Fl_Text_Editor::Key_Func>(f));
}

void fl_text_editor_remove_all_key_bindings(TEXTEDITOR te) {
    static_cast<Fl_Text_Editor*>(te)->remove_all_key_bindings();
}

void fl_text_editor_set_default_key_function(TEXTEDITOR te, void * f) {
    static_cast<Fl_Text_Editor*>(te)->default_key_function
        (reinterpret_cast<Fl_Text_Editor::Key_Func>(f));
}




int fl_text_editor_get_insert_mode(TEXTEDITOR te) {
    return static_cast<Fl_Text_Editor*>(te)->insert_mode();
}

void fl_text_editor_set_insert_mode(TEXTEDITOR te, int i) {
    static_cast<Fl_Text_Editor*>(te)->insert_mode(i);
}

int fl_text_editor_get_tab_nav(TEXTEDITOR te) {
#if FLTK_ABI_VERSION >= 10304
    return static_cast<Fl_Text_Editor*>(te)->tab_nav();
#else
    (void)(te);
    return 0;
#endif
}

void fl_text_editor_set_tab_nav(TEXTEDITOR te, int t) {
#if FLTK_ABI_VERSION >= 10304
    static_cast<Fl_Text_Editor*>(te)->tab_nav(t);
#else
    (void)(te);
    (void)(t);
#endif
}




void fl_text_editor_draw(TEXTEDITOR te) {
    static_cast<My_Text_Editor*>(te)->Fl_Text_Editor::draw();
}

int fl_text_editor_handle(TEXTEDITOR te, int e) {
    return static_cast<My_Text_Editor*>(te)->Fl_Text_Editor::handle(e);
}

int fl_text_editor_handle_key(TEXTEDITOR te) {
    return (static_cast<Fl_Text_Editor*>(te)->*(&Friend_Text_Editor::handle_key))();
}

void fl_text_editor_maybe_do_callback(TEXTEDITOR te) {
    (static_cast<Fl_Text_Editor*>(te)->*(&Friend_Text_Editor::maybe_do_callback))(FL_REASON_CHANGED);
}


