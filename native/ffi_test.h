DLLEXPORT void ffi_test_0(void);
DLLEXPORT int ffi_test_1(void);
DLLEXPORT int ffi_test_2(int x, int y);
DLLEXPORT int ffi_test_3(int x, int y, int z, int t);
DLLEXPORT float ffi_test_4(void);
DLLEXPORT double ffi_test_5(void);
DLLEXPORT double ffi_test_6(float x, float y);
DLLEXPORT double ffi_test_7(double x, double y);
DLLEXPORT double ffi_test_8(double x, float y, double z, float t, int w);
DLLEXPORT int ffi_test_9(int a, int b, int c, int d, int e, int f, int g);
DLLEXPORT int ffi_test_10(int a, int b, double c, int d, float e, int f, int g, int h);
struct foo { int x, y; };
DLLEXPORT int ffi_test_11(int a, struct foo b, int c);
struct rect { float x, y, w, h; };
DLLEXPORT int ffi_test_12(int a, int b, struct rect c, int d, int e, int f);
DLLEXPORT int ffi_test_13(int a, int b, int c, int d, int e, int f, int g, int h, int i, int j, int k);
DLLEXPORT void callback_test_1(void (*callback)(void));
DLLEXPORT void callback_test_2(void (*callback)(int x, int y), int x, int y);
DLLEXPORT void callback_test_3(void (*callback)(int x, double y, int z), int x, double y, int z);
DLLEXPORT void callback_test_4(void (*callback)(int a1, int a2, int a3, int a4, int a5, int a6, int a7, int a8, int a9, int a10), int a1, int a2, int a3, int a4, int a5, int a6, int a7, int a8, int a9, int a10);
DLLEXPORT int callback_test_5(int (*callback)(void));
DLLEXPORT float callback_test_6(float (*callback)(void));
DLLEXPORT double callback_test_7(double (*callback)(void));
DLLEXPORT int callback_test_8(int (*callback)(struct foo x), struct foo x);
