

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_FILE_INPUT_GUARD
#define FL_FILE_INPUT_GUARD


typedef void* FILEINPUT;


extern "C" FILEINPUT new_fl_file_input(int x, int y, int w, int h, char* label);
extern "C" void free_fl_file_input(FILEINPUT i);


extern "C" int fl_file_input_get_down_box(FILEINPUT i);
extern "C" void fl_file_input_set_down_box(FILEINPUT i, int t);
extern "C" unsigned int fl_file_input_get_errorcolor(FILEINPUT i);
extern "C" void fl_file_input_set_errorcolor(FILEINPUT i, unsigned int t);


extern "C" const char * fl_file_input_get_value(FILEINPUT i);
extern "C" int fl_file_input_set_value(FILEINPUT i, const char * s, int len);


extern "C" void fl_file_input_draw(FILEINPUT i);
extern "C" int fl_file_input_handle(FILEINPUT i, int e);


#endif


