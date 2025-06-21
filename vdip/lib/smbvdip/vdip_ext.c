#include <Python.h>
#include <unistd.h>
#include <fcntl.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <pigpio.h>

#define PIN_D0 4
#define PIN_D1 5
#define PIN_D2 6
#define PIN_D3 7
#define PIN_D4 8
#define PIN_D5 9
#define PIN_D6 10
#define PIN_D7 11
#define PIN_RXF 12
#define PIN_TXE 13
#define PIN_RCLR 24
#define PIN_WCLR 25
#define PIN_WRPI 18
#define PIN_RDPI 19
#define PIN_RXFD 20
#define PIN_TXED 21

static int datapins[] = {PIN_D0, PIN_D1, PIN_D2, PIN_D3,
                         PIN_D4, PIN_D5, PIN_D6, PIN_D7};

void _short_delay(void)
{
    // Just do nothing for a while.
    int j;

    // by experimentation on a pi zero w, 50 NOPs produced intermittent errors.
    // 20 NOPs produced frequent errors
    // 100 NOPs seemed safe.
    // Could go 200 NOPs, which is twice the safe value.

    // on pi zero w
    //     0 nops = 15ns
    //    50 nops = 170ns
    //   100 nops = 320ns
    //   200 nops = 620ns
    //   400 nops = 1332ns
    //   gpioDelay(1) == 2189ns

    // on pi zero 2 w
    //    50 nops = 120ns
    //   100 nops = 220ns
    //   200 nops = 420ns
    //   400 nops = 820ns

    // Intermittent errors seen on pi zero 2 w with 100 nops.


    for (j=0; j<200; j++) { 
        asm("nop");
    }
}

/*
void bench(void)
{
    struct timeval tv;
    gettimeofday(&tv,NULL);

    unsigned long t1 = 1000000 * tv.tv_sec + tv.tv_usec;

    for (int i=0; i<1000000; i++) {
        _short_delay();
    }

    gettimeofday(&tv,NULL);
    unsigned long t2 = 1000000 * tv.tv_sec + tv.tv_usec;

    printf("microseconds for 1000000 ops: %lu\n", t2-t1);
}
*/

void _medium_delay(void)
{
    gpioDelay(1); // 1 microsecond delay
}

/* unused
static void _clearWrite(void) {
    gpioWrite(PIN_WCLR, 0);
    _short_delay();
    gpioWrite(PIN_WCLR, 1);
}

static void _clearRead(void) {
    gpioWrite(PIN_RCLR, 0);
    _short_delay();
    gpioWrite(PIN_RCLR, 1);  
}
*/

static int _canWrite(void) {
    return gpioRead(PIN_RXF);
}

static int _canRead(void) {
    return gpioRead(PIN_TXE);
}

static void _databus_config_read(void)
{
    for (int i=0; i<8; i++) {
      gpioSetMode(datapins[i], PI_INPUT);
    }
}

static void _databus_config_write(void)
{
    for (int i=0; i<8; i++) {
      gpioSetMode(datapins[i], PI_OUTPUT);
    }
}

static void _write(uint8_t b) {
    uint32_t data = b;

    _short_delay(); // in case we just came off of a canWrite(). Give H8 enough time to complete cycle.

    _databus_config_write();
    gpioWrite_Bits_0_31_Clear(0x00000FF0);   // bits 4-11
    gpioWrite_Bits_0_31_Set(data<<4);

    gpioWrite(PIN_WRPI,0);
    _short_delay();
    gpioWrite(PIN_WRPI,1);
    _short_delay();

    gpioWrite(PIN_RCLR, 0);
    _short_delay();
    gpioWrite(PIN_RCLR, 1);
    _short_delay();

    _medium_delay(); // this seems to be necessary for correctness. Otherwise we get occasional glitches.
}

static uint8_t _read(void) {
    uint32_t data;

    _short_delay(); // in case we just came off of a canRead(). Give H8 enough time to complete cycle.

    _databus_config_read();

    gpioWrite(PIN_RDPI,0);
    _short_delay();

    data = gpioRead_Bits_0_31();

    gpioWrite(PIN_RDPI,1);

    gpioWrite(PIN_WCLR, 0);
    _short_delay();
    gpioWrite(PIN_WCLR, 1);
    _short_delay();

    return (data>>4) & 0xFF;
}

static void _waitWrite(uint8_t b) {
    while (!_canWrite()) {
      // do nothing
    }
    _write(b);
}

static void _waitWriteString(char *s) {
    while (*s) {
        _waitWrite(*s);
        s++;
    }
}

// set the transmit empty signal.
static void _set_txe() {
    gpioWrite(PIN_WCLR, 0);
    _short_delay();
    gpioWrite(PIN_WCLR, 1);
    _short_delay();
}

static void _clear_rxf() {
    // clock a 1 into RXF
    gpioWrite(PIN_RXFD, 1);
    gpioWrite(PIN_RCLR, 0);
    _short_delay();
    gpioWrite(PIN_RCLR, 1);
    _short_delay();

    // from now on we always want to clock 0s into RXF
    gpioWrite(PIN_RXFD, 0);
}

void timetest(void) {
    struct timeval tv;
    gettimeofday(&tv,NULL);

    unsigned long t1 = 1000000 * tv.tv_sec + tv.tv_usec;

    for (int i=0; i<1000; i++) {
        _short_delay();
    }

    gettimeofday(&tv,NULL);
    unsigned long t2 = 1000000 * tv.tv_sec + tv.tv_usec;

    printf("%lu\n", t2-t1);
}


static PyObject *vdip_init(PyObject *self, PyObject *args)
{
    if (gpioInitialise() < 0) {
      Py_RETURN_FALSE;
    }

    _databus_config_read();
    gpioSetMode(PIN_RXF, PI_INPUT);
    gpioSetMode(PIN_TXE, PI_INPUT);
    gpioSetMode(PIN_WCLR, PI_OUTPUT);
    gpioSetMode(PIN_RCLR, PI_OUTPUT);
    gpioSetMode(PIN_WRPI, PI_OUTPUT);
    gpioSetMode(PIN_RDPI, PI_OUTPUT);
    gpioSetMode(PIN_RXFD, PI_OUTPUT);    
    gpioSetMode(PIN_TXED, PI_OUTPUT);

    gpioWrite(PIN_RXFD, 0);
    gpioWrite(PIN_TXED, 0);
    gpioWrite(PIN_WCLR, 1);
    gpioWrite(PIN_RCLR, 1);
    gpioWrite(PIN_WRPI, 1);
    gpioWrite(PIN_RDPI, 1);

    _set_txe();

    _clear_rxf();

    Py_RETURN_TRUE;
}

static PyObject *vdip_canWrite(PyObject *self, PyObject *args)
{
    if (_canWrite()) {
        Py_RETURN_TRUE;
    } else {
        Py_RETURN_FALSE;
    }
}

static PyObject *vdip_canRead(PyObject *self, PyObject *args)
{
    if (_canRead()) {
        Py_RETURN_TRUE;
    } else {
        Py_RETURN_FALSE;
    }
}

static PyObject *vdip_write(PyObject *self, PyObject *args)
{
    uint8_t val;

    if (!PyArg_ParseTuple(args, "B", &val)) {
      return NULL;
    }

    _write(val);

    return Py_BuildValue("");
}

static PyObject *vdip_waitWrite(PyObject *self, PyObject *args)
{
    uint8_t val;

    if (!PyArg_ParseTuple(args, "B", &val)) {
      return NULL;
    }

    _waitWrite(val);

    return Py_BuildValue("");
}

static PyObject *vdip_waitWriteStr(PyObject *self, PyObject *args)
{
    char *val;

    if (!PyArg_ParseTuple(args, "s", &val)) {
      return NULL;
    }

    _waitWriteString(val);

    return Py_BuildValue("");
}

static PyObject *vdip_read(PyObject *self, PyObject *args)
{
    uint8_t val;

    val = _read();

    return Py_BuildValue("B", val);
}


static PyObject *vdip_waitWriteBuffer(PyObject *self, PyObject *args)
{
    Py_buffer pybuf;
    unsigned char bytes[1024];
    int res;

    if (!PyArg_ParseTuple(args, "y*", &pybuf)) {
        return NULL;
    }

    if (pybuf.len > 1024) {
        PyErr_SetString(PyExc_RuntimeError, "passed buffer is too big!");
        return (PyObject *) NULL;
    }

    res = PyBuffer_ToContiguous(bytes, &pybuf, pybuf.len, 'C');
    if (res!=0) {
        PyErr_SetString(PyExc_RuntimeError, "failed toContiguous!");
        return (PyObject *) NULL;
    }

    for (int i=0; i<pybuf.len; i++) {
        _waitWrite(bytes[i]);
    }

    PyBuffer_Release(&pybuf);

    return Py_BuildValue("");
}

static PyMethodDef vdip_methods[] = {
  {"init", vdip_init, METH_VARARGS, "Initialize"},
  {"canWrite", vdip_canWrite, METH_VARARGS, "Return true if write is possible"},
  {"canRead", vdip_canRead, METH_VARARGS, "Return true if read is possible"},
  {"write", vdip_write, METH_VARARGS, "Write a byte"},
  {"waitWrite", vdip_waitWrite, METH_VARARGS, "Write a byte, waiting until able"},
  {"waitWriteStr", vdip_waitWriteStr, METH_VARARGS, "Write a string, waiting until able"},
  {"waitWriteBuffer", vdip_waitWriteBuffer, METH_VARARGS, "Write a buffer, waiting until able"},
  {"read", vdip_read, METH_VARARGS, "Read a byte"},
  {NULL, NULL, 0, NULL}
};

static struct PyModuleDef vdip_module =
{
    PyModuleDef_HEAD_INIT,
    "vdip_ext", /* name of module */
    "",          /* module documentation, may be NULL */
    -1,          /* size of per-interpreter state of the module, or -1 if the module keeps state in global variables. */
   vdip_methods
};

PyMODINIT_FUNC PyInit_vdip_ext(void)
{
  return PyModule_Create(&vdip_module);
}
