package LocalMetaDB;
use strict;
use warnings;

sub new {
    my ($class, $dbfile) = @_;

    my $self = bless { db => {}, file => $dbfile }, $class;
    $self->read_data();
    return $self;
}

sub read_data {
    my $self = shift;
    open my $d, $self->{file} or die $self->{file}, ": $!";
    while (<$d>) {
        next if /^#/ || /^\s+$/; # skip comment or empty line
        my ($module_name, $url, $version) = split;
        defined $version or $version = "0";
        unless ($url) {
            # we assume standard module tar.gz filename
            $url = $module_name;
            $url =~ m!/([^/]+)-([\d.]+)\.tar\.gz$!
                or die "can't guess module name";
            ($module_name, $version) = ($1, $2);
            $module_name =~ s!-!::!sg;
        }
        $self->{db}{$module_name} = [$url, $version];
    }
    close $d;
    return $self;
}

sub resolve {
    my ($self, $module_name) = @_;

    my $meta = $self->{db}{$module_name};
    return unless $meta;
    return { url => $meta->[0], version => $meta->[1] };
}

1;
