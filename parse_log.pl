#!/usr/bin/perl -w
use strict;

use DBI;

my $db_user = '...'; # надо указать свой
my $db_pswd = '...'; # надо указать свой
my $dsn = "DBI:mysql:database=$db_user;host=192.168.10.240;port=3306";
my $dbh = DBI->connect( $dsn, $db_user, $db_pswd );

open FH, "out" or die $!;
while (<FH>)
{
	my ( $date, $time, $int_id, $flag, $address, @info ) = split / /;
	my $info = join ' ', @info;
	$info =~ s/\n//;

	my $str;
	# Строка лога без временной метки (в случаях, когда в лог пишется общая информация, флаг и адрес получателя не указываются)
	if ($flag && $address && $address =~ /\@/)
	{
		$str = $int_id . ' ' . $flag . ' ' . $address . ' ' . $info;
	}
	else
	{
		next;
	}

	my $sql;
	my @sql_binds;
	# timestamp строки лога
	push @sql_binds, $date . ' ' . $time;

	# Строки прибытия сообщения (с флагом <=)
	if ( $flag eq '<=' )
	{
		$sql = qq{
			INSERT INTO
				message
			SET
				created = ?
		};
		# Находим значение поля id=xxxx из строки лога
		my $id;
		if ( $info =~ /id=(\d+)/ )
		{
			$id = $1;
		}

		$sql .= ', id = ?, int_id = ?, str = ?';
		push @sql_binds, $id, $int_id, $str;
	}
	else
	{
		$sql = qq{
			INSERT INTO
				log
			SET
				created = ?
		};

		$sql .= ', int_id = ?, str = ?, address = ?';
		push @sql_binds, $int_id, $str, $address;
	}

	$dbh->do( $sql, undef, @sql_binds );

}
close FH;

1;