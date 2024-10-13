

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_GUARD
#define FL_GUARD




size_t c_pointer_size();


extern "C" int fl_abi_check(int v);
extern "C" int fl_abi_version();
extern "C" int fl_api_version();
extern "C" double fl_version();


extern "C" void fl_awake();
extern "C" void fl_lock();
extern "C" void fl_unlock();


extern "C" int fl_get_damage();
extern "C" void fl_set_damage(int v);
extern "C" void fl_flush();
extern "C" void fl_redraw();


extern "C" int fl_check();
extern "C" int fl_ready();
extern "C" int fl_wait();
extern "C" int fl_wait2(double s);
extern "C" int fl_run();


#endif

