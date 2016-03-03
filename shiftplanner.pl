#!/usr/bin/perl

use strict;
use warnings;

#use File::Basename qw(ShiftPlaner);
#use Cwd  qw(lib/ShiftPlaner);
#use lib dirname("ShiftPlaner" "lib/ShiftPlaner" $0) . '/lib';

use ShiftPlaner::planVal qw(assign);

assign({"22 Sep 2015"=>['1','2','3','4'],"23 Sep 2015"=>['1','2','3','4'],"24 Sep 2015"=>['1','2','3','4'],"25 Sep 2015"=>['1','2','3','4'],"26 Sep 2015"=>['1','2','3','4'],"27 Sep 2015"=>['1','2','3','4']});
