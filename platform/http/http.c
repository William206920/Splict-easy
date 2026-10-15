#include "moonbit.h"
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
static char *se_result;
static int32_t se_length;

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <winhttp.h>
#include <wchar.h>
#pragma comment(lib,"winhttp.lib")
static volatile LONG se_state,se_cancelled;
static ULONGLONG se_started;
typedef struct {char *url,*key,*body;} Request;
static char *copy_bytes(moonbit_bytes_t b){size_t n=Moonbit_array_length(b);char *s=malloc(n+1);if(s){memcpy(s,b,n);s[n]=0;}return s;}
static WCHAR *wide(const char *s){int n=MultiByteToWideChar(CP_UTF8,MB_ERR_INVALID_CHARS,s,-1,NULL,0);if(!n)return NULL;WCHAR *w=malloc((size_t)n*sizeof(WCHAR));if(w)MultiByteToWideChar(CP_UTF8,MB_ERR_INVALID_CHARS,s,-1,w,n);return w;}
static void outcome(const char *text,int32_t state){free(se_result);se_length=(int32_t)strlen(text);se_result=malloc((size_t)se_length+1);if(se_result)memcpy(se_result,text,(size_t)se_length+1);else se_length=0;InterlockedExchange(&se_state,state);}
static DWORD WINAPI worker(LPVOID data){
 Request *input=(Request*)data;
 WCHAR *url=wide(input->url),*headers=NULL;
 HINTERNET session=NULL,connection=NULL,request=NULL;
 char *result=NULL;size_t length=0;int success=0;char error[160]="Network request failed";
 ULONGLONG started=se_started;
 if(InterlockedCompareExchange(&se_cancelled,0,0)){strcpy_s(error,sizeof(error),"Cancelled");goto done;}
 if(!url){strcpy_s(error,sizeof(error),"Invalid service URL");goto done;}
 URL_COMPONENTS parts={0};parts.dwStructSize=sizeof(parts);parts.dwHostNameLength=(DWORD)-1;parts.dwUrlPathLength=(DWORD)-1;parts.dwExtraInfoLength=(DWORD)-1;
 if(!WinHttpCrackUrl(url,0,0,&parts)||parts.dwHostNameLength>=512){strcpy_s(error,sizeof(error),"Invalid service URL");goto done;}
 WCHAR host[512];wcsncpy_s(host,512,parts.lpszHostName,parts.dwHostNameLength);
 if(parts.nScheme!=INTERNET_SCHEME_HTTPS && !(parts.nScheme==INTERNET_SCHEME_HTTP&&(_wcsicmp(host,L"127.0.0.1")==0||_wcsicmp(host,L"localhost")==0))){strcpy_s(error,sizeof(error),"HTTPS required");goto done;}
 WCHAR path[8192];if(parts.dwUrlPathLength+parts.dwExtraInfoLength>=8190){strcpy_s(error,sizeof(error),"URL too long");goto done;}
 wcsncpy_s(path,8192,parts.lpszUrlPath,parts.dwUrlPathLength);
 if(parts.dwExtraInfoLength)wcsncat_s(path,8192,parts.lpszExtraInfo,parts.dwExtraInfoLength);
 if(!path[0])wcscpy_s(path,8192,L"/");
 session=WinHttpOpen(L"SplitEasy/0.8.0",WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,WINHTTP_NO_PROXY_NAME,WINHTTP_NO_PROXY_BYPASS,0);
 if(!session)goto done;
 WinHttpSetTimeouts(session,30000,30000,30000,30000);
 connection=WinHttpConnect(session,host,parts.nPort,0);if(!connection)goto done;
 request=WinHttpOpenRequest(connection,L"POST",path,NULL,WINHTTP_NO_REFERER,WINHTTP_DEFAULT_ACCEPT_TYPES,parts.nScheme==INTERNET_SCHEME_HTTPS?WINHTTP_FLAG_SECURE:0);if(!request)goto done;
 DWORD policy=WINHTTP_OPTION_REDIRECT_POLICY_NEVER;WinHttpSetOption(request,WINHTTP_OPTION_REDIRECT_POLICY,&policy,sizeof(policy));
 size_t header_size=strlen(input->key)+96;char *header=malloc(header_size);if(!header)goto done;
 snprintf(header,header_size,"Content-Type: application/json\r\nAuthorization: Bearer %s\r\n",input->key);headers=wide(header);SecureZeroMemory(header,header_size);free(header);if(!headers)goto done;
 if(!WinHttpSendRequest(request,headers,(DWORD)-1,input->body,(DWORD)strlen(input->body),(DWORD)strlen(input->body),0)||!WinHttpReceiveResponse(request,NULL))goto done;
 DWORD code=0,size=sizeof(code);if(!WinHttpQueryHeaders(request,WINHTTP_QUERY_STATUS_CODE|WINHTTP_QUERY_FLAG_NUMBER,WINHTTP_HEADER_NAME_BY_INDEX,&code,&size,WINHTTP_NO_HEADER_INDEX))goto done;
 if(code<200||code>=300){snprintf(error,sizeof(error),"HTTP %lu",(unsigned long)code);goto done;}
 while(1){
  if(InterlockedCompareExchange(&se_cancelled,0,0)){strcpy_s(error,sizeof(error),"Cancelled");goto done;}
  if(GetTickCount64()-started>=30000){strcpy_s(error,sizeof(error),"Request timeout");goto done;}
  char chunk[8192];DWORD received=0;
  if(!WinHttpReadData(request,chunk,sizeof(chunk),&received))goto done;
  if(!received)break;
  if(length+received>4000000){strcpy_s(error,sizeof(error),"Response too large");goto done;}
  char *grown=realloc(result,length+received+1);if(!grown){strcpy_s(error,sizeof(error),"Out of memory");goto done;}
  result=grown;memcpy(result+length,chunk,received);length+=received;result[length]=0;
 }
 success=1;
done:
 {DWORD last=GetLastError();if(!success && last==ERROR_WINHTTP_TIMEOUT && strcmp(error,"Network request failed")==0)strcpy_s(error,sizeof(error),"Request timeout");}
 if(request)WinHttpCloseHandle(request);if(connection)WinHttpCloseHandle(connection);if(session)WinHttpCloseHandle(session);
 free(url);if(headers){SecureZeroMemory(headers,wcslen(headers)*sizeof(WCHAR));free(headers);}
 if(input->key){SecureZeroMemory(input->key,strlen(input->key));free(input->key);}free(input->url);free(input->body);free(input);
 LONG cancelled=InterlockedCompareExchange(&se_cancelled,0,0);
 if(GetTickCount64()-started>=30000 && cancelled==0)cancelled=2;
 if(cancelled){free(result);outcome(cancelled==2?"Request timeout":"Cancelled",cancelled==2?3:4);}
 else if(success){free(se_result);se_result=result;se_length=(int32_t)length;InterlockedExchange(&se_state,2);}
 else {free(result);outcome(error,3);}
 return 0;
}
int32_t se_http_start(moonbit_bytes_t url,moonbit_bytes_t key,moonbit_bytes_t body){
 if(InterlockedCompareExchange(&se_state,1,1)==1)return 0;
 Request *input=calloc(1,sizeof(Request));if(!input)return 0;
 input->url=copy_bytes(url);input->key=copy_bytes(key);input->body=copy_bytes(body);
 if(!input->url||!input->key||!input->body){free(input->url);free(input->key);free(input->body);free(input);return 0;}
 se_started=GetTickCount64();InterlockedExchange(&se_cancelled,0);InterlockedExchange(&se_state,1);
 HANDLE thread=CreateThread(NULL,0,worker,input,0,NULL);
 if(!thread){free(input->url);free(input->key);free(input->body);free(input);InterlockedExchange(&se_state,3);return 0;}
 CloseHandle(thread);return 1;
}
int32_t se_http_state(void){
 LONG state=InterlockedCompareExchange(&se_state,0,0);
 if(state==1 && GetTickCount64()-se_started>=30000){InterlockedCompareExchange(&se_cancelled,2,0);return 3;}
 return (int32_t)state;
}
void se_http_cancel(void){InterlockedCompareExchange(&se_cancelled,1,0);}
void se_http_pause(int32_t milliseconds){Sleep((DWORD)milliseconds);}
#else
#include <unistd.h>
int32_t se_http_start(moonbit_bytes_t u,moonbit_bytes_t k,moonbit_bytes_t b){(void)u;(void)k;(void)b;return 0;}
int32_t se_http_state(void){return 3;}
void se_http_cancel(void){}
void se_http_pause(int32_t ms){usleep((unsigned int)ms*1000);}
#endif
moonbit_bytes_t se_http_result(void){
#ifdef _WIN32
 if(InterlockedCompareExchange(&se_cancelled,0,0)==2){const char *message="Request timeout";int len=(int)strlen(message);moonbit_bytes_t bytes=moonbit_make_bytes(len,0);memcpy(bytes,message,(size_t)len);return bytes;}
#endif
 moonbit_bytes_t bytes=moonbit_make_bytes(se_length,0);if(se_length&&se_result)memcpy(bytes,se_result,(size_t)se_length);return bytes;}
