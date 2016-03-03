#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long qw(GetOptions);
use Time::Piece;
use Time::Seconds;
use Term::ANSIColor;
my %days = qw( Sun 7 Mon 1 Tue 2 Wed 3 Thu 4 Fri 5 Sat 6 );
my ($start_date,$end_date,$leave,$diff,$names,$file,$no_emp,$start,$end,$help,@emp_names)=(0,0,0,0,0,0,0,0,0,0);
my $t = localtime;
GetOptions(
"names|o=s"=>\$names,
"filename|f=s"=>\$file,
"number|n=i"=>\$no_emp,
"start|s=s"=>\$start,
"end|e=s"=>\$end,
"leave|L"=>\$leave,
"help|h"=>\$help
);
eval{
	if (  $start  eq 0  ){        ### if user does not enters start date then localtime is taken####
		$start = $t;
	}
	else{
		$start = Time::Piece->strptime($start,"%d %b %Y");  ## if user enter the date in correct format##
	}
	if ( $end eq 0  ){
		$end += $start + ONE_DAY * ( 7 - $days{$start->wdayname});  # if user does not enters the end date##
	}
	else{
		$end = Time::Piece->strptime($end,"%d %b %Y");   ## if user enters the end date in correct format##
	}
};
if ($@){
print "Usage: Enter correct date format \n \n";
}
$diff =  $end - $start;                                            ## calc diff btw end and start date####

if ( $file ne 0 && $no_emp == 0 && $names eq 0 && $help == 0 && $leave == 0 ){
		open(my $mread,'<',$file) or die "$file : $!";
		while(<$mread>){
			chomp;
			push (@emp_names,$_);    ## if user enter the name through file option####
		}
			$no_emp = @emp_names;
			answer();
	}

elsif ( $no_emp != 0 && $file eq 0 && $names eq 0 && $help == 0 && $leave == 0 ){
		for (my $i=1;$i<=$no_emp;$i++){
			push (@emp_names,"Emp$i");   ## if user enters the number of file option#####
			}
			answer();
	}

elsif ( $names ne 0 && $no_emp == 0 && $file eq 0 && $help == 0 && $leave == 0 ){
		push (@emp_names,$names);
		for (my $j=0;$j<=$#ARGV;$j++) {
                       

			push (@emp_names,$ARGV[$j]);  ### if user enters the name option#
}

			$no_emp = @emp_names;
			answer();
}	
#elsif ( $help == 1 && $no_emp == 0 && $file eq 0 && $names eq 0 && $leave == 0 ){
#	help();
#}
elsif ( $leave == 1 && $no_emp == 0 && $file eq 0 && $names eq 0 && $help == 0 && not defined $ARGV[0] ){
	leave();	  ## user enters the leave options##
}

else{
	help();            #### help option####
}
############# Calculate start and end date ##############

sub answer{
	if ( int($diff->days ) >= 0 ){				

		$start_date=$start->strftime("%d %b %Y");
   
		$end_date=$end->strftime("%d %b %Y"); 

	}
	else{
		print "End date must be greater then start date \n";
	}	
}
print "@emp_names \n $no_emp \n $start_date \n $end_date \n";

############# Leave subroutine ###########

sub leave{
	my ($which_day,@id,$id,%leave_date);
	print "On which date employee want leave (dd mmm yyyy):- ";
	$which_day = <>;
	chomp $which_day;
	print "Enter employee id's with space between them:- ";
	$id = <>;
	chomp $id;	
	@id = split / /, $id;
	if ( checks($which_day,@id) == 0 ){
		push (@{$leave_date{$which_day}}, @id);
		print "Assign more leaves:- y/n ";
		my $ans = <>;
		chomp $ans;
			if ( "$ans" eq "y" ){
				leave();
			}	
	}
}
sub checks{
	my $flag=0;
	my($wd,@id2)=@_;
	if ( $wd =~ /\d\d\s\w{3}\s\w{4}/ ){
		foreach my $r (@id2){
			unless ( $r =~ /\d+/ ){
				$flag = 1;
				print "Enter correct employee id \n";
			}
		}
		$wd = Time::Piece->strptime($wd,"%d %b %Y");
		my $diffl = $wd - $t;
				unless( int($diffl->days) >= 0 ){
					print "Enter date after today's date \n";
					$flag=1;
				}		
	}
	else{
		print "Enter correct date format \n";
		$flag=1;
	}
	return $flag;
}
sub help{
	print "Planner 1.0 for amd64 compiled on Oct 15 2015 13:09:05
Usage: planner [options] arguments
planner -o | -f | -n | -L | -h [-s mmm dd yyy] [-e mmm dd yyy]

CLI for planner.
Basic commands:
 -o|--names -> names of employees
 -f|--filename -> filename
 -n|--number -> number of employees		
 -L|--leave -> assign leaves
 -h|--help -> help\n";
}
