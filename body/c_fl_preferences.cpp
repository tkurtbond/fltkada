

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Preferences.H>
#include <FL/filename.H>
#include <cstdlib>
#include <string>
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


//  A group keeps no Fl_Preferences of its own.  One made for a group keeps
//  a plain pointer to the group's node, which deleteGroup, deleteAllGroups
//  and clear of a group above it free (pofltk 51).  So a group is the
//  database or memory group it is in, its base, and its path from there,
//  and each call opens it for as long as the call takes.  A group holds a
//  reference to its base, so the base goes with the last of them.
struct Pref_Group {
    My_Preferences *base;
    std::string path;
};

//  The group e, opened.  Fl_Preferences(parent, path) makes the group if
//  it is missing, so the Ada side checks fl_pref_group_exists first.
class Opened {
    public:
        explicit Opened(PREFS e) : group(static_cast<Pref_Group*>(e)), temp(0) {
            if (!group->path.empty()) {
                temp = new Fl_Preferences(group->base, group->path.c_str());
            }
        }
        ~Opened() {
            delete temp;
        }
        Fl_Preferences * operator->() {
            return get();
        }
        Fl_Preferences * get() {
            return temp ? temp : group->base;
        }
    private:
        Opened(const Opened &) = delete;
        Opened & operator=(const Opened &) = delete;
        Pref_Group *group;
        Fl_Preferences *temp;
};

static PREFS new_group(My_Preferences *base, const std::string &path) {
    Pref_Group *g = new Pref_Group;
    g->base = base;
    g->path = path;
    upref_fl_pref_database(base);
    return g;
}

//  The group child of the group e, which is in e's base.
static PREFS new_group(PREFS e, Fl_Preferences &child) {
    My_Preferences *base = static_cast<Pref_Group*>(e)->base;
    std::string from = std::string(base->path()) + "/";
    std::string path = child.path();
    if (path.compare(0, from.size(), from) == 0) {
        path.erase(0, from.size());
    }
    return new_group(base, path);
}

PREFS new_fl_pref_group_copy(PREFS e) {
    return new_group(static_cast<My_Preferences*>(e), "");
}

PREFS new_fl_pref_group_memory(char * n) {
    //  The group's reference, which new_group takes, is its only one.
    My_Preferences *m = new My_Preferences(static_cast<Fl_Preferences*>(0), n);
    m->reference_count = -1;
    return new_group(m, "");
}

PREFS new_fl_pref_group_name(PREFS e, char * n) {
    Opened from(e);
    Fl_Preferences child(from.get(), n);
    return new_group(e, child);
}

PREFS new_fl_pref_group_index(PREFS e, int i) {
    Opened from(e);
    Fl_Preferences child(from.get(), i);
    return new_group(e, child);
}

void free_fl_pref_group(PREFS e) {
    Pref_Group *g = static_cast<Pref_Group*>(e);
    free_fl_pref_database(g->base);
    delete g;
}

int fl_pref_group_exists(PREFS e) {
    Pref_Group *g = static_cast<Pref_Group*>(e);
    return g->path.empty() || g->base->groupExists(g->path.c_str());
}




int fl_preferences_flush(PREFS e) {
    return static_cast<Fl_Preferences*>(e)->flush();
}

int fl_preferences_getuserdatapath(PREFS e, char * p, int len) {
    return (int)static_cast<Fl_Preferences*>(e)->getUserdataPath(p, len);
}




int fl_preferences_deleteentry(PREFS e, const char * k) {
    return (int)Opened(e)->deleteEntry(k);
}

int fl_preferences_deleteallentries(PREFS e) {
    return (int)Opened(e)->deleteAllEntries();
}

int fl_preferences_deletegroup(PREFS e, const char * g) {
    return (int)Opened(e)->deleteGroup(g);
}

int fl_preferences_deleteallgroups(PREFS e) {
    return (int)Opened(e)->deleteAllGroups();
}

int fl_preferences_clear(PREFS e) {
    return (int)Opened(e)->clear();
}




int fl_preferences_entries(PREFS e) {
    return Opened(e)->entries();
}

const char * fl_preferences_entry(PREFS e, int i) {
    return Opened(e)->entry(i);
}

int fl_preferences_entryexists(PREFS e, const char * k) {
    return (int)Opened(e)->entryExists(k);
}

int fl_preferences_size(PREFS e, const char * k) {
    return Opened(e)->size(k);
}




int fl_preferences_groups(PREFS e) {
    return Opened(e)->groups();
}

const char * fl_preferences_group(PREFS e, int i) {
    return Opened(e)->group(i);
}

int fl_preferences_groupexists(PREFS e, const char * g) {
    return (int)Opened(e)->groupExists(g);
}




const char * fl_preferences_name(PREFS e) {
    return Opened(e)->name();
}

const char * fl_preferences_path(PREFS e) {
    return Opened(e)->path();
}




int fl_preferences_get_int(PREFS e, const char * k, int& v, int d) {
    return (int)Opened(e)->get(k,v,d);
}

int fl_preferences_get_float(PREFS e, const char * k, float& v, float d) {
    return (int)Opened(e)->get(k,v,d);
}

int fl_preferences_get_double(PREFS e, const char * k, double& v, double d) {
    return (int)Opened(e)->get(k,v,d);
}

//  must deallocate result afterwards
int fl_preferences_get_str(PREFS e, const char * k, char *& v, const char * d) {
    return (int)Opened(e)->get(k,v,d);
}

int fl_preferences_get_str_limit (PREFS e, const char * k, char * v, const char * d, int m) {
    return (int)Opened(e)->get(k, v, d, m);
}

//  must deallocate result afterwards
int fl_preferences_get_void (PREFS e, const char * k, void *& v, const void * d, int ds) {
    return (int)Opened(e)->get(k, v, d, ds);
}

int fl_preferences_get_void_limit (PREFS e, const char * k, void * v, const void * d, int ds, int ms) {
    return (int)Opened(e)->get(k, v, d, ds, ms);
}

void free_fl_preferences_void_data(void * v) {
    free(v);
}




int fl_preferences_set_int(PREFS e, const char * k, int v) {
    return (int)Opened(e)->set(k,v);
}

int fl_preferences_set_float(PREFS e, const char * k, float v) {
    return (int)Opened(e)->set(k,v);
}

int fl_preferences_set_float_prec(PREFS e, const char * k, float v, int p) {
    return (int)Opened(e)->set(k,v,p);
}

int fl_preferences_set_double(PREFS e, const char * k, double v) {
    return (int)Opened(e)->set(k,v);
}

int fl_preferences_set_double_prec(PREFS e, const char * k, double v, int p) {
    return (int)Opened(e)->set(k,v,p);
}

int fl_preferences_set_str(PREFS e, const char * k, const char * v) {
    return (int)Opened(e)->set(k,v);
}

int fl_preferences_set_void(PREFS e, const char * k, const void * d, int ds) {
    return (int)Opened(e)->set(k, d, ds);
}


