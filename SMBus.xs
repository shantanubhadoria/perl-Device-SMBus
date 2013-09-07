#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include<linux/i2c-dev.h>


MODULE = Device::SMBus		PACKAGE = Device::SMBus PREFIX = SMBus_
PROTOTYPES: DISABLE

int SMBus__readByteData(file, command)
    int file;
    int command;
  CODE:
    RETVAL = i2c_smbus_read_byte_data(file, command);
  OUTPUT:
    RETVAL

int SMBus__writeByteData(file, command, value)
    int file;
    int command;
    int value;
  CODE:
    RETVAL = i2c_smbus_write_byte_data(file, command, value);
  OUTPUT:
    RETVAL
