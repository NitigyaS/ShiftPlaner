package ShiftPlaner::planGen;

use strict;
use warnings;
use Time::Piece;
use Time::Seconds;
use Exporter qw(import);
our @EXPORT_OK = qw(getCal);
#----------------------------------Data Strucures Used In Program---------------------
#Data Strucure to Store Emplyee's Shift Plan
#	$emp_ref->{$emp_number}->[$day1_shift,$day2_shift,$day3_shift...$day21_shift]
#Data Structure to Store leaves granted and person assigned on particular date
#	$leaves->{$date}->[$person_on_leave1,$person_on_leave2,$person_on_leave3]
#			->[$person_assigend1 , $person_assigned2, $person_assigned3]
#-------------------------------------------------------------------------------------



#####	Sub-Routine to generate One Week (Pass week no. and No of employees)	#####
#For Internal Usage
sub getWeek{
	my ($watch ,$num)  = @_;
	my $day = 0;
	my @watches = ("M","A","N");
	my $cal;
	my $counter = 0;
	my $gen = sprintf("%d",log($num)/log(2));
	for(my $i = 0; $i < $num-$gen; $i++){
		$cal->{$i}->[$day] = 'O';
		$day = ($day+1)%7;
		$cal->{$i}->[$day] = 'O';
		$day = ($day+1)%7;
		for(my $j=0;$j<7;$j++){
			if($counter>=7){
				$watch = ($watch+1)%3;
				$counter = 0;
			}
			unless(defined $cal->{$i}->[$j]){
				$cal->{$i}->[$j] = $watches[$watch%3];
				$counter++;
			}
		}
	}
	for(my $i=$num-$gen; $i<$num; $i++){
		for(my $j=0;$j<5;$j++){
			$cal->{$i}->[$j] = 'G';
		}
		$cal->{$i}->[5] = 'O';
		$cal->{$i}->[6] = 'O';
	}
	return $cal;
}

#####	Sub-Routine to get Complete Calendar of 3 Weeks	(Pass no of Employees)	#####
#For Internal Usage
sub getCal{
	my ($num,$order) = @_;
	my $emp_ref ;
	foreach my $i (0..2){
		my $temp = getWeek($i+$order,$num);
		foreach my $j (0..$num-1){
			push @{$emp_ref->{$j}}  ,@{$temp->{$j}};
		}
	}
	return $emp_ref;
}

