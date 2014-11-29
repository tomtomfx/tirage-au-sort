#!/usr/bin/perl
use strict;
use warnings;
use Email::Send;
use Email::Send::Gmail;
use Email::Simple::Creator;

package mail;

use vars qw(@EXPORT);
@EXPORT = qw(envoiMail);

sub envoiMail 
{
	my $adresse = $_[1];
	my $mailContent = $_[0];
	my $email = Email::Simple->create(
	header => [
	  From    => 'repasdenoel2012@gmail.com',
	  To      => $adresse,
	  Subject => 'Repas de noël 2012',
	],
	body => $mailContent,
	);

	my $sender = Email::Send->new(
		{   mailer      => 'Gmail',
			mailer_args => [
			username => 'repasdenoel2012@gmail.com',
			password => 'noel2012',
			]	
		}
	);
	eval { $sender->send($email) };
	die "Error sending email: $@" if $@;

    print "Mail sent to $adresse !\n";
}

1; 