use strict;
use warnings;
package Device::SMBus;

# PODNAME: Device::SMBus 
# ABSTRACT: Control and read hardware devices with i2c(SMBus)
# COPYRIGHT
# VERSION

# Dependencies
use 5.010000;

use Moose;
use Carp;

use IO::File;
use Fcntl;

require XSLoader;
XSLoader::load('Device::SMBus', $VERSION);

=constant I2C_SLAVE

=cut

use constant I2C_SLAVE => 0x0703;

=attr I2CBusDevicePath

Device path of the I2C Device. 

 * On Raspberry Pi Model A this would usually be /dev/i2c-0 if you are using the default pins.
 * On Raspberry Pi Model B this would usually be /dev/i2c-1 if you are using the default pins.

=cut

has I2CBusDevicePath   => (
    is => 'ro',
);

has I2CBusFileHandle => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_I2CBusFileHandle',
);

=attr I2CDeviceAddress

This is the Address of the device on the I2C bus, this is usually available in the device Datasheet.

 * for /dev/i2c-0 look at output of `sudo i2cdetect -y 0' 
 * for /dev/i2c-1 look at output of `sudo i2cdetect -y 1' 

=cut

has I2CDeviceAddress => (
    is => 'ro',
);

has I2CBusFilenumber => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_I2CBusFilenumber',
);

sub _build_I2CBusFileHandle {
    my ($self) = @_;
    my $fh = IO::File->new( $self->I2CBusDevicePath, O_RDWR );
    if( !$fh ){
        croak "Unable to open I2C Device File at $self->I2CBusDevicePath";
        return -1;
    }
    $fh->ioctl(I2C_SLAVE,$self->I2CDeviceAddress);
    return $fh;
}

# Implicitly Call the lazy builder for the file handle by using it and get the filenumber
sub _build_I2CBusFilenumber {
    my ($self) = @_;
    $self->I2CBusFileHandle->fileno();
}

=method fileError

returns IO::Handle->error() for the device handle since the last clearerr

=cut

sub fileError {
    my ($self) = @_;
    return $self->I2CBusFileHandle->error();
}

=method writeQuick

 $self->writeQuick($value)

This sends a single bit to the device, at the place of the Rd/Wr bit.

=cut

sub writeQuick {
    my ($self,$value) = @_;
    my $retval = Device::SMBus::_writeQuick($self->I2CBusFilenumber,$value);
}

=method readByte

 $self->readByte()

This reads a single byte from a device, without specifying a device
register. Some devices are so simple that this interface is enough; for
others, it is a shorthand if you want to read the same register as in
the previous SMBus command

=cut

sub readByte {
    my ($self) = @_;
    my $retval = Device::SMBus::_readByte($self->I2CBusFilenumber);
    return $retval;
}

=method writeByte

 $self->writeByte()

This operation is the reverse of readByte: it sends a single byte
to a device. 

=cut

sub writeByte {
    my ($self, $value) = @_;
    my $retval = Device::SMBus::_writeByte($self->I2CBusFilenumber,$value);
}

=method readByteData

 $self->readByteData($register_address)

This reads a single byte from a device, from a designated register.
The register is specified through the Comm byte.

=cut

sub readByteData {
    my ($self,$register_address) = @_;
    my $retval = Device::SMBus::_readByteData($self->I2CBusFilenumber,$register_address);
    return $retval;
}

=method writeByteData

 $self->writeByteData($register_address,$value)

This writes a single byte to a device, to a designated register. The
register is specified through the Comm byte. This is the opposite of
the Read Byte operation.

=cut

sub writeByteData {
    my ($self,$register_address,$value) = @_;
    my $retval = Device::SMBus::_writeByteData($self->I2CBusFilenumber,$register_address,$value);
}

=method readNBytes

 $self->readNBytes($lowest_byte_address, $number_of_bytes);

Read together N bytes of Data in linear register order. i.e. to read from 0x28,0x29,0x2a 

 $self->readNBytes(0x28,3);

=cut

sub readNBytes {
    my ($self,$reg,$numBytes) = @_;
    my $retval = 0;
    $retval = ($retval << 8) | $self->readByteData($reg+$numBytes - $_) for (1 .. $numBytes);
    return $retval;
}

=method readWordData

 $self->readWordData($register_address)

This operation is very like Read Byte; again, data is read from a
device, from a designated register that is specified through the Comm
byte. But this time, the data is a complete word (16 bits).

=cut

sub readWordData {
    my ($self,$register_address) = @_;
    my $retval = Device::SMBus::_readWordData($self->I2CBusFilenumber,$register_address);
    return $retval;
}

=method writeWordData

 $self->writeWordData($register_address,$value)

This is the opposite of the Read Word operation. 16 bits
of data is written to a device, to the designated register that is
specified through the Comm byte.

=cut

sub writeWordData {
    my ($self,$register_address,$value) = @_;
    my $retval = Device::SMBus::_writeWordData($self->I2CBusFilenumber,$register_address,$value);
}

=method processCall

 $self->processCall($register_address,$value)

This command selects a device register (through the Comm byte), sends
16 bits of data to it, and reads 16 bits of data in return.

=cut

sub processCall {
    my ($self,$register_address,$value) = @_;
    my $retval = Device::SMBus::_processCall($self->I2CBusFilenumber,$register_address,$value);
}

=method writeBlockData

 $self->writeBlockData($register_address, $values)

Writes a maximum of 32 bytes in a single block to the i2c device.  The supplied $values should be
an array ref containing the bytes to be written.

The register address should be one that is at the beginning of a contiguous block of registers of equal length
to the array of values passed.  Not adhering to this will almost certainly result in unexpected behaviour in
the device.

=cut

sub writeBlockData {
    my ( $self, $register_address, $values ) = @_;
    
    my $value  = pack "C*", @{$values};

    my $retval = Device::SMBus::_writeI2CBlockData($self->I2CBusFilenumber,$register_address, $value);
    return $retval;
}


=method readBlockData

 $self->readBlockData($register_address, $numBytes)


Read $numBytes form the given register address,
data is returned as array

The register address is often 0x00 or the value your device expects

common usage with micro controllers that receive and send large amounts of data:
they almost always needs a 'command' to be written to them then they send a response:
e.g:
1) send 'command' with writeBlockData, or writeByteData, for example 'get last telegram'
2) read 'response' with readBlockData of size $numBytes, controller is sending the last telegram


=cut


sub readBlockData {
    my ( $self, $register_address, $numBytes) = @_;

    my $read_val = '0' x ($numBytes);

    my $retval = Device::SMBus::_readI2CBlockData( $self->I2CBusFilenumber,
        $register_address, $read_val );

    my @result = unpack("C*", $read_val);
    return @result;
}



# Preloaded methods go here.
=method DEMOLISH

Destructor

=cut

sub DEMOLISH {
    my ($self) = @_;
    $self->I2CBusFileHandle->close();
}

1;

__END__

=begin wikidoc

= SYNOPSIS

  use Device::SMBus;
  $dev = Device::SMBus->new(
    I2CBusDevicePath => '/dev/i2c-1',
    I2CDeviceAddress => 0x1e,
  );
  print $dev->readByteData(0x20);

= DESCRIPTION

This is a perl interface to smbus interface using libi2c-dev library. 

Prerequisites:

For Debian and derivative distros(including raspbian) use the following to install dependencies:

 sudo apt-get install libi2c-dev i2c-tools build-essential

If you are using Angstrom Linux use the following:

 opkg install i2c-tools
 opkg install i2c-tools-dev

For ArchLINUX use the following steps:

 pacman -S base-devel
 pacman -S i2c-tools

Special Instructions for enabling the I2C driver on a Raspberry Pi:

You will need to comment out the driver from the blacklist. currently the
I2C driver isn't being loaded.

    sudo vim /etc/modprobe.d/raspi-blacklist.conf

Replace this line 

    blacklist i2c-bcm2708

with this

    #blacklist i2c-bcm2708

You now need to edit the modules conf file.

    sudo vim /etc/modules

Add these two lines;

    i2c-dev
    i2c-bcm2708

Now run this command(replace 1 with 0 for older model Pi)

    sudo i2cdetect -y 1

If that doesnt work on your system you may alternatively use this:

    sudo i2cdetect -r 1

you should now see the addresses of the i2c devices connected to your i2c bus

= CREATING YOUR OWN CHIPSET DRIVERS

Writing your own chipset driver for your own i2c devices is quiet simple. You just need to know the i2c address of your device and the registers that you need to read or write. Follow the manual at [Device::SMBus::Manual].

= NOTES

I wrote this library for my Quadrotor project for controlling PWM Wave Generators ( ESC or DC motor controller ), Accelerometer, Gyroscope, Magnetometer, Altimeter, Temperature Sensor etc. However this module can also be used by anyone who wishes to read or control motherboard devices on I2C like laptop battery system, temperature or voltage sensors, fan controllers, lid switches, clock chips. Some PCI add in cards may connect to a SMBus segment.

The SMBus was defined by Intel in 1995. It carries clock, data, and instructions and is based on Philips' I2C serial bus protocol. Its clock frequency range is 10 kHz to 100 kHz. (PMBus extends this to 400 kHz.) Its voltage levels and timings are more strictly defined than those of I2C, but devices belonging to the two systems are often successfully mixed on the same bus. SMBus is used as an interconnect in several platform management standards including: ASF, DASH, IPMI. 

-wiki

= USAGE

* This module provides a simplified object oriented interface to the libi2c-dev library for accessing electronic peripherals connected on the I2C bus. It uses Moose.

= SEE ALSO

* [Moose]
* [IO::File]
* [Fcntl]

=end wikidoc

=cut
