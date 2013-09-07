use strict;
use warnings;
package Device::SMBus;

# PODNAME: Device::SMBus 
# ABSTRACT: Perl interface for smbus using libi2c-dev library.  
# COPYRIGHT
# VERSION

use 5.010000;

# Dependencies
use Mo;
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
    is         => 'ro',
    lazy_build => 1,
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
    is => 'ro',
);

sub _build_I2CBusFileHandle {
    my ($self) = @_;
    my $fh = IO::File->new( $self->I2CBusDevicePath, O_RDWR );
    if( !$fh ){
        croak "Unable to open I2C Device File at $self->I2CBusDevicePath";
<<<<<<< HEAD
        return -1;
=======
        return undef;
>>>>>>> 840c7e4b7087083b7f9a951c2cee4d3e498deb3d
    }
    $self->I2CBusFilenumber($fh->fileno());
    $fh->ioctl(I2C_SLAVE,$self->I2CDeviceAddress);
    return $fh;
}

<<<<<<< HEAD
=method readByteData

$self->readByteData($register_address)

=cut

=======
>>>>>>> 840c7e4b7087083b7f9a951c2cee4d3e498deb3d
sub readByteData {
    my ($self,$register_address) = @_;
    my $retval = Device::SMBus::_readByteData($self->I2CBusFilenumber,$register_address);
}

<<<<<<< HEAD
=method writeByteData

$self->writeByteData($register_address,$value)

=cut

=======
>>>>>>> 840c7e4b7087083b7f9a951c2cee4d3e498deb3d
sub writeByteData {
    my ($self,$register_address,$value) = @_;
    my $retval = Device::SMBus::_readByteData($self->I2CBusFilenumber,$register_address,$value);
}

<<<<<<< HEAD
=======
# Preloaded methods go here.

>>>>>>> 840c7e4b7087083b7f9a951c2cee4d3e498deb3d
sub DEMOLISH {
    my ($self) = @_;
    $self->I2CBusFileHandle->close();
}

1;
<<<<<<< HEAD

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

* This module provides a simplified object oriented interface to the libi2c-dev library for accessing electronic peripherals connected on the I2C bus. It uses Mo, a scaled down version of Moose without any data checks to improve speed.

= see ALSO

* [Mo]
* [IO::File]
* [Fcntl]

=end wikidoc
=======
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Device::SMBus - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Device::SMBus;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Device::SMBus, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Shantanu Bhadoria, E<lt>shantanu@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Shantanu Bhadoria

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.

>>>>>>> 840c7e4b7087083b7f9a951c2cee4d3e498deb3d

=cut
