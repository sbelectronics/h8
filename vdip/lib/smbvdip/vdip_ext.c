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
#define PIN_RCLR 16
#define PIN_WCLR 17
#define PIN_WRPI 18
#define PIN_RDPI 19

static int datapins[] = {PIN_D0, PIN_D1, PIN_D2, PIN_D3,
                         PIN_D4, PIN_D5, PIN_D6, PIN_D7};

void _short_delay(void)
{
    // Just do nothing for a while.
    int j;

    for (j=0; j<50; j++) {
        asm("nop");
    }
}

void _medium_delay(void)
{
    gpioDelay(4); // 4 microsecond delay
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

    // in case we just came off of a canRead(). Give H8 enough time to complete cycle.

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
}

static uint8_t _read(void) {
    uint32_t data;

    _medium_delay(); // in case we just came off of a canRead(). Give H8 enough time to complete cycle.

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

    gpioWrite(PIN_WCLR, 1);
    gpioWrite(PIN_RCLR, 1);
    gpioWrite(PIN_WRPI, 1);
    gpioWrite(PIN_RDPI, 1);

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
