import os
import sys

from setuptools import setup, Extension

from smbvdip.version import __version__

vdip_ext = Extension('smbvdip.vdip_ext',
                     sources = ['smbvdip/vdip_ext.c'],
                     library_dirs = ['/usr/local/lib'],
                     libraries = ['pigpio'])


# python 3.x
# wiringpi is not supported
setup_result = setup(name='smbvdip',
      version=__version__,
      description="Scott Baker's Raspberry Pi VDIP Library",
      packages=['smbvdip'],
      zip_safe=False,
      ext_modules=[vdip_ext]
)
