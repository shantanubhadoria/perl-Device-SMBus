use strict;
use warnings;
package Device::SMBus;

# PODNAME: Device::SMBus 
# ABSTRACT: Perl interface for smbus using libi2c-dev library.  
# COPYRIGHT
# VERSION

use 5.010000;

# Dependencies
use Moose;
use Carp;

use IO::File;
use Fcntl;

require XSLoader;
XSLoader::load('Device::SMBus', $VERSION);

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

# Implicitly Call the lazy builder for the file handle by using it and get the fileno
sub _build_I2CBusFilenumber {
    my ($self) = @_;
    $self->I2CBusFileHandle->fileno();
}

=method writeQuick

$self->writeQuick($value)

=cut

sub writeQuick {
    my ($self,$value) = @_;
    my $retval = Device::SMBus::_writeQuick($self->I2CBusFilenumber,$value);
}

=method readByte

$self->readByte()

=cut

sub readByte {
    my ($self) = @_;
    my $retval = Device::SMBus::_readByte($self->I2CBusFilenumber);
}

=method writeByte

$self->writeByte()

=cut

sub writeByte {
    my ($self, $value) = @_;
    my $retval = Device::SMBus::_writeByte($self->I2CBusFilenumber,$value);
}

=method readByteData

$self->readByteData($register_address)

=cut

sub readByteData {
    my ($self,$register_address) = @_;
    my $retval = Device::SMBus::_readByteData($self->I2CBusFilenumber,$register_address);
}

=method writeByteData

$self->writeByteData($register_address,$value)

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

=cut

sub readWordData {
    my ($self,$register_address) = @_;
    my $retval = Device::SMBus::_readWordData($self->I2CBusFilenumber,$register_address);
}

=method writeWordData

$self->writeWordData($register_address,$value)

=cut

sub writeWordData {
    my ($self,$register_address,$value) = @_;
    my $retval = Device::SMBus::_writeWordData($self->I2CBusFilenumber,$register_address,$value);
}

=method processCall

$self->processCall($register_address,$value)

=cut

sub processCall {
    my ($self,$register_address,$value) = @_;
    my $retval = Device::SMBus::_processCall($self->I2CBusFilenumber,$register_address,$value);
}

# Preloaded methods go here.

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

= USAGE

* This module provides a simplified object oriented interface to the libi2c-dev library for accessing electronic peripherals connected on the I2C bus. It uses Moose.

= see ALSO

* [Moose]
* [IO::File]
* [Fcntl]

=end wikidoc

=cut
