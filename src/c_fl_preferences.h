

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_PREFERENCES_GUARD
#define FL_PREFERENCES_GUARD




typedef void* PREFS;




extern const int root_fl_prefs_system;
extern const int root_fl_prefs_user;

extern const int const_fl_path_max;




extern "C" const char * fl_preferences_new_uuid();




extern "C" PREFS new_fl_pref_database_path(char * p, char * v, char * a);
extern "C" PREFS new_fl_pref_database_scope(int s, char * v, char * a);
extern "C" void upref_fl_pref_database(PREFS e);
extern "C" void free_fl_pref_database(PREFS e);

extern "C" PREFS new_fl_pref_group_copy(PREFS e);
extern "C" PREFS new_fl_pref_group_memory(char * n);
extern "C" PREFS new_fl_pref_group_name(PREFS e, char * n);
extern "C" PREFS new_fl_pref_group_index(PREFS e, int i);
extern "C" void free_fl_pref_group(PREFS e);




extern "C" void fl_preferences_flush(PREFS e);
extern "C" int fl_preferences_getuserdatapath(PREFS e, char * p, int len);


extern "C" int fl_preferences_deleteentry(PREFS e, const char * k);
extern "C" int fl_preferences_deleteallentries(PREFS e);
extern "C" int fl_preferences_deletegroup(PREFS e, const char * g);
extern "C" int fl_preferences_deleteallgroups(PREFS e);
extern "C" int fl_preferences_clear(PREFS e);


extern "C" int fl_preferences_entries(PREFS e);
extern "C" const char * fl_preferences_entry(PREFS e, int i);
extern "C" int fl_preferences_entryexists(PREFS e, const char * k);
extern "C" int fl_preferences_size(PREFS e, const char * k);


extern "C" int fl_preferences_groups(PREFS e);
extern "C" const char * fl_preferences_group(PREFS e, int i);
extern "C" int fl_preferences_groupexists(PREFS e, const char * g);


extern "C" const char * fl_preferences_name(PREFS e);
extern "C" const char * fl_preferences_path(PREFS e);


extern "C" int fl_preferences_get_int(PREFS e, const char * k, int& v, int d);
extern "C" int fl_preferences_get_float(PREFS e, const char * k, float& v, float d);
extern "C" int fl_preferences_get_double(PREFS e, const char * k, double& v, double d);
extern "C" int fl_preferences_get_str
    (PREFS e, const char * k, char *& v, const char * d);
extern "C" int fl_preferences_get_str_limit
    (PREFS e, const char * k, char * v, const char * d, int m);
extern "C" int fl_preferences_get_void
    (PREFS e, const char * k, void *& v, const void * d, int ds);
extern "C" int fl_preferences_get_void_limit
    (PREFS e, const char * k, void * v, const void * d, int ds, int ms);
extern "C" void free_fl_preferences_void_data(void * v);


extern "C" int fl_preferences_set_int(PREFS e, const char * k, int v);
extern "C" int fl_preferences_set_float(PREFS e, const char * k, float v);
extern "C" int fl_preferences_set_float_prec(PREFS e, const char * k, float v, int p);
extern "C" int fl_preferences_set_double(PREFS e, const char * k, double v);
extern "C" int fl_preferences_set_double_prec(PREFS e, const char * k, double v, int p);
extern "C" int fl_preferences_set_str(PREFS e, const char * k, const char * v);
extern "C" int fl_preferences_set_void(PREFS e, const char * k, const void * d, int ds);


#endif

