

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Preferences.H>
#include <FL/filename.H>
#include <cstdlib>
#include "c_fl_preferences.h"




const int root_fl_prefs_system = Fl_Preferences::SYSTEM;
const int root_fl_prefs_user = Fl_Preferences::USER;

const int const_fl_path_max = FL_PATH_MAX;




const char * fl_preferences_new_uuid() {
    return Fl_Preferences::newUUID();
}




class My_Preferences : public Fl_Preferences {
    public:
        using Fl_Preferences::Fl_Preferences;
        int reference_count = 0;
};




PREFS new_fl_pref_database_path(char * p, char * v, char * a) {
    My_Preferences *e = new My_Preferences(p, v, a, (Fl_Preferences::Root)0);
    return e;
}

PREFS new_fl_pref_database_scope(int s, char * v, char * a) {
    My_Preferences *e = new My_Preferences((Fl_Preferences::Root)s, v, a);
    return e;
}

void upref_fl_pref_database(PREFS e) {
    static_cast<My_Preferences*>(e)->reference_count += 1;
}

void free_fl_pref_database(PREFS e) {
    if (static_cast<My_Preferences*>(e)->reference_count <= 0) {
        delete static_cast<My_Preferences*>(e);
    } else {
        static_cast<My_Preferences*>(e)->reference_count -= 1;
    }
}


//  A database's root group: a copy, sharing the database's nodes.
//  ~Fl_Preferences deletes the root node when its node has no parent,
//  as a copy of the root's hasn't, but the database owns the root node,
//  so this group forgets its node first.
class My_Root_Group : public Fl_Preferences {
    public:
        My_Root_Group(const Fl_Preferences &from) : Fl_Preferences(from) { }
        ~My_Root_Group() { node = 0; }
};

PREFS new_fl_pref_group_copy(PREFS e) {
    //  Not new Fl_Preferences(e): with one pointer that is Fl_Preferences(ID),
    //  which takes the database for a group's ID.
    Fl_Preferences *g = new My_Root_Group(*static_cast<Fl_Preferences*>(e));
    return g;
}

PREFS new_fl_pref_group_memory(char * n) {
    Fl_Preferences *g = new Fl_Preferences(NULL, n);
    return g;
}

PREFS new_fl_pref_group_name(PREFS e, char * n) {
    Fl_Preferences *g = new Fl_Preferences(static_cast<Fl_Preferences*>(e), n);
    return g;
}

PREFS new_fl_pref_group_index(PREFS e, int i) {
    Fl_Preferences *g = new Fl_Preferences(static_cast<Fl_Preferences*>(e), i);
    return g;
}

void free_fl_pref_group(PREFS e) {
    delete static_cast<Fl_Preferences*>(e);
}




int fl_preferences_flush(PREFS e) {
    return static_cast<Fl_Preferences*>(e)->flush();
}

int fl_preferences_getuserdatapath(PREFS e, char * p, int len) {
    return (int)static_cast<Fl_Preferences*>(e)->getUserdataPath(p, len);
}




int fl_preferences_deleteentry(PREFS e, const char * k) {
    return (int)static_cast<Fl_Preferences*>(e)->deleteEntry(k);
}

int fl_preferences_deleteallentries(PREFS e) {
    return (int)static_cast<Fl_Preferences*>(e)->deleteAllEntries();
}

int fl_preferences_deletegroup(PREFS e, const char * g) {
    return (int)static_cast<Fl_Preferences*>(e)->deleteGroup(g);
}

int fl_preferences_deleteallgroups(PREFS e) {
    return (int)static_cast<Fl_Preferences*>(e)->deleteAllGroups();
}

int fl_preferences_clear(PREFS e) {
    return (int)static_cast<Fl_Preferences*>(e)->clear();
}




int fl_preferences_entries(PREFS e) {
    return static_cast<Fl_Preferences*>(e)->entries();
}

const char * fl_preferences_entry(PREFS e, int i) {
    return static_cast<Fl_Preferences*>(e)->entry(i);
}

int fl_preferences_entryexists(PREFS e, const char * k) {
    return (int)static_cast<Fl_Preferences*>(e)->entryExists(k);
}

int fl_preferences_size(PREFS e, const char * k) {
    return static_cast<Fl_Preferences*>(e)->size(k);
}




int fl_preferences_groups(PREFS e) {
    return static_cast<Fl_Preferences*>(e)->groups();
}

const char * fl_preferences_group(PREFS e, int i) {
    return static_cast<Fl_Preferences*>(e)->group(i);
}

int fl_preferences_groupexists(PREFS e, const char * g) {
    return (int)static_cast<Fl_Preferences*>(e)->groupExists(g);
}




const char * fl_preferences_name(PREFS e) {
    return static_cast<Fl_Preferences*>(e)->name();
}

const char * fl_preferences_path(PREFS e) {
    return static_cast<Fl_Preferences*>(e)->path();
}




int fl_preferences_get_int(PREFS e, const char * k, int& v, int d) {
    return (int)static_cast<Fl_Preferences*>(e)->get(k,v,d);
}

int fl_preferences_get_float(PREFS e, const char * k, float& v, float d) {
    return (int)static_cast<Fl_Preferences*>(e)->get(k,v,d);
}

int fl_preferences_get_double(PREFS e, const char * k, double& v, double d) {
    return (int)static_cast<Fl_Preferences*>(e)->get(k,v,d);
}

//  must deallocate result afterwards
int fl_preferences_get_str(PREFS e, const char * k, char *& v, const char * d) {
    return (int)static_cast<Fl_Preferences*>(e)->get(k,v,d);
}

int fl_preferences_get_str_limit (PREFS e, const char * k, char * v, const char * d, int m) {
    return (int)static_cast<Fl_Preferences*>(e)->get(k, v, d, m);
}

//  must deallocate result afterwards
int fl_preferences_get_void (PREFS e, const char * k, void *& v, const void * d, int ds) {
    return (int)static_cast<Fl_Preferences*>(e)->get(k, v, d, ds);
}

int fl_preferences_get_void_limit (PREFS e, const char * k, void * v, const void * d, int ds, int ms) {
    return (int)static_cast<Fl_Preferences*>(e)->get(k, v, d, ds, ms);
}

void free_fl_preferences_void_data(void * v) {
    free(v);
}




int fl_preferences_set_int(PREFS e, const char * k, int v) {
    return (int)static_cast<Fl_Preferences*>(e)->set(k,v);
}

int fl_preferences_set_float(PREFS e, const char * k, float v) {
    return (int)static_cast<Fl_Preferences*>(e)->set(k,v);
}

int fl_preferences_set_float_prec(PREFS e, const char * k, float v, int p) {
    return (int)static_cast<Fl_Preferences*>(e)->set(k,v,p);
}

int fl_preferences_set_double(PREFS e, const char * k, double v) {
    return (int)static_cast<Fl_Preferences*>(e)->set(k,v);
}

int fl_preferences_set_double_prec(PREFS e, const char * k, double v, int p) {
    return (int)static_cast<Fl_Preferences*>(e)->set(k,v,p);
}

int fl_preferences_set_str(PREFS e, const char * k, const char * v) {
    return (int)static_cast<Fl_Preferences*>(e)->set(k,v);
}

int fl_preferences_set_void(PREFS e, const char * k, const void * d, int ds) {
    return (int)static_cast<Fl_Preferences*>(e)->set(k, d, ds);
}


