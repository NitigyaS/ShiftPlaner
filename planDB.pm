package ShiftPlaner::planDB;
use strict;
use warnings;
use Time::Piece;
use Time::Seconds;
use DBI;

use Exporter qw(import);
our @EXPORT_OK = qw(getAssignedLeaves setAssignedLeaves empLeaves empCompoff);



#----------------------------------Data Strucures Used In Program---------------------
#Data Strucure to Store Emplyee's Shift Plan
#	$emp_ref->{$emp_number}->[$day1_shift,$day2_shift,$day3_shift...$day21_shift]
#Data Structure to Store leaves granted and person assigned on particular date
#	$leaves->{$date}->[$person_on_leave1,$person_on_leave2,$person_on_leave3]
#			->[$person_assigend1 , $person_assigned2, $person_assigned3]
#-------------------------------------------------------------------------------------

#####	Sub-Routine to fetch the assigned leaves from DB	#####
#getAssignedLeaves($starttDateOb, $endDateOb, $num_of_Employee)
sub getAssignedLeaves{
	my $dbh = connectToDB("shifts","localhost","3306","root","root");
	my $arambh = $_[0]->ymd;
	my $samapti = $_[1]->ymd;
	my $emp_num = $_[2];
	my $sth = $dbh->prepare("SELECT DATE_FORMAT(tarik,'%d %b %Y') as tarik,chutti,badli FROM karyakarini WHERE  tarik BETWEEN \'$arambh\' AND \'$samapti\' AND ginti = $emp_num");
	my $leaves;
	$sth->execute();
	while(my $ref = $sth->fetchrow_hashref()){
		push @{$leaves->{$ref->{'tarik'}}->[1]} , $ref->{'badli'};
		push @{$leaves->{$ref->{'tarik'}}->[0]} , $ref->{'chutti'};
	}
	return $leaves;
}

#####	Sub-routine to connect to database	#####

sub connectToDB{
	my $dsn ="DBI:mysql:database=$_[0]; host=$_[1]; port=$_[2]";
	my $dbh =DBI->connect($dsn,$_[3],$_[4]);
	return $dbh;
}

#####	Sub-routine to put assigned leaves to DB	#####
#seatAssignedLeaves($leave, num_of_employee)
sub setAssignedLeaves{
	my $dbh = connectToDB("shifts","localhost","3306","root","root");
	my $leaves = $_[0];        #assume Data Structure as defined above
	my $emp_num = $_[1];		#Count of Employees
	foreach my $date (keys %{$leaves}){
		print "$date\n";
		foreach (0..$#{$leaves->{$date}->[0]}){
			$dbh->do("insert into karyakarini(tarik , chutti , badli , ginti) values (STR_TO_DATE(\'$date\','%d %b %Y') , ? , ? , ? )",undef , $leaves->{$date}->[0]->[$_] , $leaves->{$date}->[1]->[$_] , $emp_num);
		}
	}
}

#####   Leaves
#empLeave(); Output Leave details of Every Employee
#empLeave($emp_number); Output Number of Leave given Employee -----RETURN VALUE-----
sub empLeaves{
	my $dbh = connectToDB("shifts","localhost","3306","root","root");
	my $sth;
	if (defined $_[0]){
		$sth = $dbh->prepare("select chutti as \"Employees\", count(chutti) as \"Leaves\" from karyakarini group by chutti having chutti = $_[0]");
		$sth->execute();
		while(my $ref = $sth->fetchrow_hashref()){
			return $ref->{'Leaves'};
		}
	return 0;
	}

	else {
		$sth = $dbh->prepare('select chutti as "Employees", count(chutti) as "Leaves" from karyakarini group by chutti');
		$sth->execute();
		while(my $ref = $sth->fetchrow_hashref()){
			print "Employee ".$ref->{'Employees'}." has ".$ref->{'Leaves'}." Leaves\'s\n";
		}

	}
}

###### empCompoff
#empCompoff(); Output Comp-off Details of Every Employee
#empCompff($emp_number) : Output Number of Compoff of given Employee -----RETURN VALUE-----
sub empCompoff{
	my $dbh = connectToDB("shifts","localhost","3306","root","root");
	my $sth;
	if (defined $_[0]){
		$sth = $dbh->prepare("select badli as \"Employees\" , count(badli) as \"Compoff\" from karyakarini where badli < (ginti - log2(ginti)) group by badli having badli = $_[0]");
		$sth->execute();
		while(my $ref = $sth->fetchrow_hashref()){
			return $ref->{'Compoff'};
		}
	return 0;
	}

	else {
		$sth = $dbh->prepare('select badli as "Employees" , count(badli) as "Compoff" from karyakarini where badli < (ginti - log2(ginti)) group by badli');
		$sth->execute();
		while(my $ref = $sth->fetchrow_hashref()){
			print "Employee ".$ref->{'Employees'}." has ".$ref->{'Compoff'}." Comp-off\'s\n";
		}

	}



}














