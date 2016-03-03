package ShiftPlaner::planVal;

use strict;
use warnings;
use Time::Piece;
use Time::Seconds;
use ShiftPlaner::planDB qw(setAssignedLeaves getAssignedLeaves empLeaves empCompoff);
use ShiftPlaner::planGen qw(getCal);

use Exporter qw(import);
our @EXPORT_OK = qw(assign dateToIndex putLeaves);

	#<--leaves input ds goes here
#----------------------------------Data Strucures Used In Program---------------------
#Data Strucure to Store Emplyee's Shift Plan
#	$emp_ref->{$emp_number}->[$day1_shift,$day2_shift,$day3_shift...$day21_shift]
#Data Structure to Store leaves granted and person assigned on particular date
#	$leaves->{$date}->[$person_on_leave1,$person_on_leave2,$person_on_leave3]
#			->[$person_assigend1 , $person_assigned2, $person_assigned3]
#-------------------------------------------------------------------------------------


#####	Sub-Routine to assign leaves and store to db	##### 
#Variable Set By User Through Getopts
sub assign {
	my %hash = %{$_[0]};
	my $num = 10;
	my @status;
	my $i = 0;
	foreach my $date_str (keys %hash){
		my $chutti;
		my $date = Time::Piece->strptime($date_str,"%d %b %Y");
		my $index = dateToIndex($date);
		my $dateIndex = ($index%7) + 7;
		print "Date = $date_str\tI = $index\tDI = $dateIndex\n";
		my $emp_ref = putLeaves($num,$date_str);
		#Set Staus of Employee Who are asking for leaves = UNAVAILBLE U
                foreach my $emp (@{$hash{$date_str}}){
                        $status[$emp] = 'U';
                }
		EMP: foreach my $emp (@{$hash{$date_str}}){
			$i = 0;
			unless($emp_ref->{$emp}->[$dateIndex] eq 'O' || $emp_ref->{$emp}->[$dateIndex] eq 'L'){
				while($i < $num){
					if(($emp_ref->{$i}->[$dateIndex] eq 'G' || $emp_ref->{$i}->[$dateIndex] eq 'O') && (!defined $status[$i])){
						my $temp = $emp_ref->{$i}->[$dateIndex];
						$emp_ref->{$i}->[$dateIndex] = $emp_ref->{$emp}->[$dateIndex];
						$emp_ref->{$emp}->[$dateIndex] = 'L';
						my $stat = validate($emp_ref,$dateIndex);
						if($stat eq "OK"){
							print "Leave assigned to $emp on $date_str against $i\n";
							push @{$chutti->{$date_str}->[0]}, $emp;
							push @{$chutti->{$date_str}->[1]}, $i;
							next EMP;
						}
						else{
							print "$stat\n";
							$emp_ref->{$emp}->[$dateIndex] = $emp_ref->{$i}->[$dateIndex];
							$emp_ref->{$i}->[$dateIndex] = $temp;
						}
					}
					$i++;
				}
				print "Cannot assign leave to $emp on $date_str\n";
				
			}
		}
		#----------------Discuss with HR.--------------------
		setAssignedLeaves($chutti,$num);
		#----------------------------------------------------
	}
#	empLeaves();
#	print"------------------------\n";
#	print "Employee 4 has taken ".empLeaves(4)." Leaves\n";
#	empCompoff();
#	print"------------------------\n";
#	print "Employee 6 has ".empCompoff(6)." CompOff\n";
}

#####	Misc Sub-routine to get index from date	#####
#dateToIndex(Time::Piece->strptime($dateVal,$dateFormat))
sub dateToIndex{
	my $epoch = Time::Piece->strptime("1 Jan 1970","%d %b %Y");
	my $date = $_[0];	#Time::Piece->strptime($dateVal,$dateFormat);
	my $index = (($date - $epoch)->days - 4) % 21;
	return $index;
}

#####	Sub-routine to validate the leaves (add conditions here)	#####
#validate(emp_ref)
sub validate{
	my $emp_ref = $_[0];
	my $status = "OK";
	my $index=$_[1];
	my $dayRoutine="";
	foreach(0..(scalar keys %{$emp_ref})-1){
		my $str = join("",@{$emp_ref->{$_}});
#		print "$str\n";
		if($str =~ /NM/){$status = "Shifts prob in $_";};
		if($str =~ /([^OL]{7,})/){$status = "Excessive work for $_";};
		$dayRoutine=$dayRoutine.$emp_ref->{$_}->[$index];
	}
	#There Should be Atleast One Person In Every Shift
	#To Make it Two person Minimium Regex : (.*M.*M)
	unless($dayRoutine=~/(.*M.*)/){$status = "Less People in Morning at $index";}
	unless($dayRoutine=~/(.*N.*)/){$status = "Less People in Night at $index";}
	unless($dayRoutine=~/(.*A.*)/){$status = "Less People in AfterNoon at $index";}
	#print $status."\n";
	return $status;
}

#####	Sub-Routine to put the assigned leaves to the calendar	#####
#putLeaves($num ."22 Sept 1970")
sub putLeaves{
	my $num = $_[0];
	my $date = Time::Piece->strptime($_[1],"%d %b %Y");
	my $index = dateToIndex($date);
	my $dateIndex = ($index%7) + 7;
	my $emp_ref = getCal($num,$index/7);
	my $startDate = $date - ($dateIndex*60*60*24);
	my $endDate = $startDate + (21*60*60*24);
	my $leaves = getAssignedLeaves($startDate,$endDate,(scalar keys %{$emp_ref}));
	foreach my $day (keys %{$leaves}){
		my $dateIndexLeave = (Time::Piece->strptime($day,"%d %b %Y") - $startDate)->days;
		foreach my $i (0..(scalar @{$leaves->{$day}->[0]})-1){
			$emp_ref->{$leaves->{$day}->[1]->[$i]}->[$dateIndexLeave] = $emp_ref->{$leaves->{$day}->[0]->[$i]}->[$dateIndexLeave];
			$emp_ref->{$leaves->{$day}->[0]->[$i]}->[$dateIndexLeave] = 'L';
		}
	}
	return $emp_ref;
}
