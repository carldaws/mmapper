#include "ruby.h"
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

typedef struct {
  int fd;
  size_t size;
  void *map;
} mmap_file;

static VALUE cMmapFile;

static void mmap_file_free(void *ptr) {
  mmap_file *m = (mmap_file *)ptr;
  if (m->map)
    munmap(m->map, m->size);
  if (m->fd >= 0)
    close(m->fd);
  free(m);
}

static VALUE mmap_file_alloc(VALUE klass) {
  mmap_file *m = ALLOC(mmap_file);
  m->fd = -1;
  m->map = NULL;
  m->size = 0;
  return Data_Wrap_Struct(klass, NULL, mmap_file_free, m);
}

static VALUE mmap_file_initialize(VALUE self, VALUE path) {
  mmap_file *m;
  const char *c_path = StringValueCStr(path);
  Data_Get_Struct(self, mmap_file, m);

  m->fd = open(c_path, O_RDWR);
  if (m->fd < 0)
    rb_sys_fail("open");

  m->size = lseek(m->fd, 0, SEEK_END);
  lseek(m->fd, 0, SEEK_SET);

  m->map = mmap(NULL, m->size, PROT_READ | PROT_WRITE, MAP_SHARED, m->fd, 0);
  if (m->map == MAP_FAILED)
    rb_sys_fail("mmap");

  return self;
}

static VALUE mmap_file_read(VALUE self, VALUE offset_val, VALUE length_val) {
  mmap_file *m;
  Data_Get_Struct(self, mmap_file, m);

  long offset = NUM2LONG(offset_val);
  long length = NUM2LONG(length_val);

  if (offset < 0 || offset + length > (long)m->size)
    rb_raise(rb_eArgError, "read out of bounds");

  return rb_str_new((char *)m->map + offset, length);
}

static VALUE mmap_file_write(VALUE self, VALUE offset_val, VALUE str_val) {
  mmap_file *m;
  Data_Get_Struct(self, mmap_file, m);

  long offset = NUM2LONG(offset_val);
  StringValue(str_val);
  long len = RSTRING_LEN(str_val);

  if (offset < 0 || offset + len > (long)m->size)
    rb_raise(rb_eArgError, "write out of bounds");

  memcpy((char *)m->map + offset, RSTRING_PTR(str_val), len);
  msync(m->map, m->size, MS_SYNC);

  return Qtrue;
}

static VALUE mmap_file_size(VALUE self) {
  mmap_file *m;
  Data_Get_Struct(self, mmap_file, m);
  return LONG2NUM(m->size);
}

void Init_mmapper(void) {
  VALUE mMmapper = rb_define_module("Mmapper");
  cMmapFile = rb_define_class_under(mMmapper, "File", rb_cObject);

  rb_define_alloc_func(cMmapFile, mmap_file_alloc);
  rb_define_method(cMmapFile, "initialize", mmap_file_initialize, 1);
  rb_define_method(cMmapFile, "read", mmap_file_read, 2);
  rb_define_method(cMmapFile, "write", mmap_file_write, 2);
  rb_define_method(cMmapFile, "size", mmap_file_size, 0);
}
