#!/usr/bin/env perl
# Utilitaire de diagnostic d'encodage pour mdmc2docx

use strict;
use warnings;
use utf8;
use Encode qw(decode encode find_encoding);

sub check_file_encoding {
    my ($file_path) = @_;
    
    print "🔍 Diagnostic d'encodage pour: $file_path\n\n";
    
    unless (-f $file_path) {
        print "❌ Fichier introuvable: $file_path\n";
        return;
    }
    
    # Lire le fichier en mode binaire
    open my $fh, '<:raw', $file_path or die "Impossible d'ouvrir $file_path: $!\n";
    my $content = do { local $/; <$fh> };
    close $fh;
    
    my @encodings_to_test = qw(UTF-8 latin1 cp1252 iso-8859-1);
    my $detected_encoding;
    
    print "📋 Tests d'encodage:\n";
    foreach my $encoding (@encodings_to_test) {
        my $encoder = find_encoding($encoding);
        next unless $encoder;
        
        eval {
            my $decoded = $encoder->decode($content, Encode::FB_CROAK);
            print "  ✅ $encoding: OK\n";
            $detected_encoding ||= $encoding;
        };
        if ($@) {
            print "  ❌ $encoding: Échec\n";
        }
    }
    
    print "\n";
    
    if ($detected_encoding) {
        print "🎯 Encodage recommandé: $detected_encoding\n";
        
        # Afficher les premières lignes pour vérification
        my $encoder = find_encoding($detected_encoding);
        my $decoded = $encoder->decode($content);
        my @lines = split /\n/, $decoded;
        
        print "\n📄 Aperçu du contenu (5 premières lignes):\n";
        for my $i (0..4) {
            last if $i >= @lines;
            my $line = $lines[$i];
            $line = substr($line, 0, 80) . "..." if length($line) > 80;
            printf "  %d: %s\n", $i+1, $line;
        }
        
        # Rechercher des caractères problématiques
        print "\n🔍 Analyse des caractères:\n";
        my @problematic_chars;
        for my $i (0..$#lines) {
            my $line = $lines[$i];
            if ($line =~ /[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]/) {
                push @problematic_chars, "Ligne " . ($i+1) . ": caractères de contrôle";
            }
            if ($line =~ /[^\x00-\x7F]/ && $detected_encoding eq 'UTF-8') {
                # C'est normal pour UTF-8
            } elsif ($line =~ /[^\x00-\x7F]/) {
                push @problematic_chars, "Ligne " . ($i+1) . ": caractères non-ASCII";
            }
        }
        
        if (@problematic_chars) {
            print "  ⚠️ Caractères potentiellement problématiques:\n";
            print "    $_\n" for @problematic_chars;
        } else {
            print "  ✅ Aucun caractère problématique détecté\n";
        }
        
    } else {
        print "❌ Aucun encodage valide détecté\n";
    }
    
    return $detected_encoding;
}

sub convert_encoding {
    my ($input_file, $output_file, $target_encoding) = @_;
    $target_encoding ||= 'UTF-8';
    
    print "\n🔄 Conversion vers $target_encoding...\n";
    
    # Auto-détection de l'encodage source
    open my $in_fh, '<:raw', $input_file or die "Impossible d'ouvrir $input_file: $!\n";
    my $content = do { local $/; <$in_fh> };
    close $in_fh;
    
    my @encodings_to_test = qw(UTF-8 latin1 cp1252 iso-8859-1);
    my $source_encoding;
    
    foreach my $encoding (@encodings_to_test) {
        my $encoder = find_encoding($encoding);
        next unless $encoder;
        
        eval {
            $encoder->decode($content, Encode::FB_CROAK);
            $source_encoding = $encoding;
            last;
        };
    }
    
    unless ($source_encoding) {
        print "❌ Impossible de détecter l'encodage source\n";
        return;
    }
    
    print "  📥 Encodage source détecté: $source_encoding\n";
    
    # Conversion
    my $source_encoder = find_encoding($source_encoding);
    my $target_encoder = find_encoding($target_encoding);
    
    my $decoded = $source_encoder->decode($content);
    my $encoded = $target_encoder->encode($decoded);
    
    # Écriture du fichier converti
    open my $out_fh, '>:raw', $output_file or die "Impossible de créer $output_file: $!\n";
    print $out_fh $encoded;
    close $out_fh;
    
    print "  ✅ Fichier converti: $output_file\n";
}

# Script principal
if (@ARGV == 0) {
    print "Usage:\n";
    print "  $0 <fichier>                     # Diagnostic uniquement\n";
    print "  $0 <fichier> <sortie> [encodage] # Conversion (défaut: UTF-8)\n";
    exit 1;
}

my ($input_file, $output_file, $target_encoding) = @ARGV;

my $detected = check_file_encoding($input_file);

if ($output_file) {
    convert_encoding($input_file, $output_file, $target_encoding);
    print "\n💡 Conseil: Testez maintenant avec mdmc2docx:\n";
    print "  ./bin/mdmc2docx.pl --verbose '$output_file'\n";
}