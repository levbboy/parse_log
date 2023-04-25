#!/usr/bin/perl
use strict;

use CGI::Carp qw(fatalsToBrowser);
use CGI qw(:standard);
use Data::Dumper;
use DBI;

my $db_user = '...'; # надо указать свой
my $db_pswd = '...'; # надо указать свой
my $dsn = "DBI:mysql:database=$db_user;host=192.168.10.240;port=3306";
my $dbh = DBI->connect( $dsn, $db_user, $db_pswd );

my @email = param('email');
@email = map { split /\s+/ } @email;

print "Content-type: text/html; charset=windows-1251\n\n";
print q{<html>
<head>
	<title>ѕоиск записей по адресам</title>
	<style>
		body
		{
			width: 80%;
			font-family: Arial, Tahoma, Verdana, Helvetica;
		}
		h1, h2, h3, h4, h5
		{
			font-weight: normal;
			margin: 5px 0;
		}
	</style>
</head>
<body>};

if ( @email )
{
	print q{<a href="/cgi-bin/tools/find_messages_by_email.pl">¬ернутьс€</a><p></p>};

	my @res;

	for my $email ( @email )
	{
		my $logs = $dbh->selectall_arrayref( '
			SELECT
				created, str
			FROM
				log
			WHERE
				address = ?
			ORDER BY
				int_id, created
			', undef, $email );

		foreach my $row (@$logs)
		{
			push @res, $row;
		}
	}

	if (scalar @res > 100)
	{
		print qq{<h3>ѕревышен лимит в 100 сообщений</h3>};
	}
	else
	{
		foreach my $row (@res)
		{
			my ($created, $str) = @$row;
			print qq{<h3>$created $str</h3>};
		}
	}
}
else
{
	print q{<h1 style="font-weight: normal;">ѕоиск записей по адресам</h1>
	<form>
		<textarea name="email" placeholder="¬ведите адреса получателей через пробел или каждый с новой строки" style="width: 80%; height: 50%;"></textarea>
		<div style="margin-top: 20px;"><button type="submit" style="font-size: 200%;">найти</button></div>
	</form>};
}

print q{</body></html>};

exit;
