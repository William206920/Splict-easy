#include "moonbit.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <io.h>
static WCHAR *io_path(moonbit_bytes_t path) {
 int len=Moonbit_array_length(path);
 int n=MultiByteToWideChar(CP_UTF8,MB_ERR_INVALID_CHARS,(char*)path,len,NULL,0);
 if(!n) return NULL;
 WCHAR *w=calloc((size_t)n+1,sizeof(WCHAR));
 if(w) MultiByteToWideChar(CP_UTF8,MB_ERR_INVALID_CHARS,(char*)path,len,w,n);
 return w;
}
#else
#include <unistd.h>
static char *io_path(moonbit_bytes_t path) {
 size_t n=Moonbit_array_length(path);char *s=malloc(n+1);
 if(s){memcpy(s,path,n);s[n]=0;}return s;
}
#endif
static int32_t io_failed;
int32_t se_io_failed(void){return io_failed;}
moonbit_bytes_t se_io_read(moonbit_bytes_t path) {
 io_failed=0;
#ifdef _WIN32
 WCHAR *name=io_path(path);FILE *f=name?_wfopen(name,L"rb"):NULL;
#else
 char *name=io_path(path);FILE *f=name?fopen(name,"rb"):NULL;
#endif
 free(name);
 if(!f){io_failed=1;return moonbit_make_bytes(0,0);}
 if(fseek(f,0,SEEK_END)){fclose(f);io_failed=1;return moonbit_make_bytes(0,0);}
 long size=ftell(f);
 if(size<0 || size>8000000 || fseek(f,0,SEEK_SET)){fclose(f);io_failed=1;return moonbit_make_bytes(0,0);}
 moonbit_bytes_t data=moonbit_make_bytes((int32_t)size,0);
 if(fread(data,1,(size_t)size,f)!=(size_t)size)io_failed=1;
 fclose(f);return data;
}
int32_t se_io_write_atomic(moonbit_bytes_t path,moonbit_bytes_t data) {
 io_failed=1;
#ifdef _WIN32
 WCHAR *name=io_path(path);if(!name)return 0;
 size_t n=wcslen(name);WCHAR *temp=calloc(n+40,sizeof(WCHAR));if(!temp){free(name);return 0;}
 swprintf(temp,n+40,L"%ls.tmp.%lu",name,(unsigned long)GetCurrentProcessId());
 FILE *f=_wfopen(temp,L"wb");
#else
 char *name=io_path(path);if(!name)return 0;
 size_t n=strlen(name);char *temp=malloc(n+40);if(!temp){free(name);return 0;}
 snprintf(temp,n+40,"%s.tmp.%ld",name,(long)getpid());FILE *f=fopen(temp,"wb");
#endif
 int ok=0;
 if(f){size_t len=Moonbit_array_length(data);ok=fwrite(data,1,len,f)==len;
  if(fflush(f)!=0)ok=0;
#ifdef _WIN32
  if(_commit(_fileno(f))!=0)ok=0;
#else
  if(fsync(fileno(f))!=0)ok=0;
#endif
  if(fclose(f)!=0)ok=0;
 }
#ifdef _WIN32
 if(ok)ok=MoveFileExW(temp,name,MOVEFILE_REPLACE_EXISTING|MOVEFILE_WRITE_THROUGH)!=0;
 if(!ok)DeleteFileW(temp);
#else
 if(ok)ok=rename(temp,name)==0;
 if(!ok)remove(temp);
#endif
 free(temp);free(name);io_failed=!ok;return ok;
}
int32_t se_io_remove(moonbit_bytes_t path){
#ifdef _WIN32
 WCHAR *name=io_path(path);int ok=name&&DeleteFileW(name);
#else
 char *name=io_path(path);int ok=name&&remove(name)==0;
#endif
 free(name);return ok;
}

int32_t se_io_pid(void){
#ifdef _WIN32
return (int32_t)GetCurrentProcessId();
#else
return (int32_t)getpid();
#endif
}

int32_t se_io_exists(moonbit_bytes_t path){
#ifdef _WIN32
 WCHAR *name=io_path(path);int exists=name&&GetFileAttributesW(name)!=INVALID_FILE_ATTRIBUTES;
#else
 char *name=io_path(path);int exists=name&&access(name,F_OK)==0;
#endif
 free(name);return exists;
}
