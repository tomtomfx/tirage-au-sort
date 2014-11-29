#!/usr/bin/perl
use strict;
use warnings;

use mail;

my $state = "none";
my %participants;
my @recevants;
my $mail = "";

# Récupération des infos de chaque participant
open(my $FILE, "<", "participant.txt") or die ("Can't open file.");
foreach my $line (<$FILE>)
{
	if ($line =~ /\[\/adresses\]/ || $line =~ /\[\/couples\]/ || $line =~ /\[\/mail\]/){$state="none"; next;}
	if ($line =~ /\[adresses\]/){$state="adresses"; next;}
	if ($line =~ /\[couples\]/){$state="couples"; next;}
	if ($line =~ /\[mail\]/){$state="mail"; next;}

	if ($state eq "adresses")
	{
		next unless $line =~/(.+) (.+)/;
		$participants{$1}{'mail'} = $2;
		push (@recevants, $1);
		#print ("Prenom = $1\nMail = $participants{$1}{'mail'}\n");
	}
	elsif ($state eq "couples")
	{
		next unless $line =~/(.+) (.+)/;
		if (exists($participants{$1}) && exists($participants{$2}))
		{
			$participants{$1}{'conjoint'} = $2;
			$participants{$2}{'conjoint'} = $1;
		}
		else 
		{
			if (exists($participants{$1})){die ("$2 ne participe pas");}
			else {die ("$1 ne participe pas");}
		}
	}
	elsif ($state eq "mail")
	{
		$mail = "$mail$line";
	}
}
close ($FILE);

my @joueurs = keys(%participants);

# Compléter les conjoints et init cadeau
foreach my $joueur (@joueurs)
{
	$participants{$joueur}{'cadeau'} = "None";
	if (exists ($participants{$joueur}{'conjoint'})){next;}
	else {$participants{$joueur}{'conjoint'} = "None";}
}

my $Psize = @joueurs;
my $Rsize = @recevants;
if ($Psize != $Rsize) {die ("Les deux listes ne font pas la même taille... Quelqu'un n'aura pas de cadeau...");}

# Associations des participants pour les cadeaux
foreach my $joueur (@joueurs)
{
	my $found = 0;
	my $recevant;
	while ($found == 0)
	{
		my $size = @recevants;
		my $random = int(rand($size));
		$recevant = $recevants[$random];
		if (($recevant ne $joueur) && ($recevant ne $participants{$joueur}{'conjoint'}) && ($joueur ne $participants{$recevant}{'cadeau'}))
		{
			$participants{$joueur}{'cadeau'} = $recevant;
			$found = 1;
		}
	}
	# Supprimer l'élément trouvé
	$found = 0;
	my @recevantsTemp;
	foreach my $personne (@recevants)
	{
		if (($personne eq $recevant) && $found == 0) {$found = 1; next;}
		push (@recevantsTemp, $personne);
	}
	@recevants = @recevantsTemp;
}

# Print results
# foreach my $joueur (@joueurs)
# {
	# print ("$joueur:\n\tMail: $participants{$joueur}{'mail'}");
	# if (exists($participants{$joueur}{'conjoint'})){print ("\n\tConjoint: $participants{$joueur}{'conjoint'}");}
	# if (exists($participants{$joueur}{'cadeau'})){print ("\n\tCadeau: $participants{$joueur}{'cadeau'}");}
	# print ("\n\n");
# }

print ("Tous les cadeaux sont distribues\n\n");

# Envoi des mails
foreach my $joueur (@joueurs)
{
	my $mailPerso = $mail;
	$mailPerso =~ s/participant/$joueur/;
	$mailPerso =~ s/destinataire/$participants{$joueur}{'cadeau'}/;
	&mail::envoiMail($mailPerso, $participants{$joueur}{'mail'});
}
