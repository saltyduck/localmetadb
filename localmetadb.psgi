use strict;
use warnings;
use LocalMetaDB;
use YAML qw//;

our $metadb = LocalMetaDB->new('sample.lmdb');

my $app = sub {
   my $env = shift;

   my (undef, $module_name) = split('/', $env->{PATH_INFO});
   $module_name or return [404,
           ['Content-Type', 'text/plain; charset=us-ascii'],
           ['Module name required.'],
       ];
   my $meta = $metadb->resolve($module_name);
   $meta or return [404,
           ['Content-Type', 'text/plain; charset=us-ascii'],
           ['Requested module ', $module_name, ' is not found on this server'],
       ];

   return [200,
   	   ['Content-Type', 'text/plain; charset=us-ascii'],
           [YAML::Dump($meta)],
          ];
};

