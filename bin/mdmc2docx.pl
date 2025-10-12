#!/opt/homebrew/bin/perl

=head1 NAME

mdmc2docx.pl - Convertisseur MC Markdown vers DOCX

=head1 SYNOPSIS

    mdmc2docx.pl [OPTIONS] <fichier_markdown>

=head1 DESCRIPTION

Convertit des fichiers MC au format Markdown modifié vers le format DOCX
en utilisant Pandoc. Version optimisée avec gestion d'erreurs robuste.

=head1 OPTIONS

    --fid <numero>      Numéro de la première question (défaut: 1)
    --nostop <0|1>      Supprime le point final (défaut: 1)  
    --keep              Conserve le fichier Markdown temporaire
    --verbose           Mode verbeux pour le débogage
    --config <fichier>  Fichier de configuration personnalisé
    --ref <fichier>     Fichier de référence DOCX personnalisé
    --help              Affiche cette aide

=head1 EXEMPLES

    # Usage basique
    mdmc2docx.pl mon_qcm.md
    
    # Avec numérotation personnalisée et mode verbeux
    mdmc2docx.pl --fid 5 --verbose mon_qcm.md
    
    # Avec fichier de configuration personnalisé
    mdmc2docx.pl --config ../config/ma_config.json mon_qcm.md

=head1 FORMAT MARKDOWN ATTENDU

    ## [ID_Question]
    ### Énoncé de la question
    + Réponse correcte
    - Réponse incorrecte
    + Autre réponse correcte
    - Autre réponse incorrecte
    
    (ligne vide pour séparer les questions)

=head1 AUTHOR

Marc FERRE - Université d'Angers

=cut

use strict;
use warnings;
use v5.10;
use Getopt::Long qw(GetOptions);
use File::Basename;
use File::Spec;
use FindBin qw($RealBin);
use Pandoc;

# Détection des chemins relatifs au script
my $script_dir = File::Spec->catdir($RealBin, '..');
my $config_dir = File::Spec->catdir($script_dir, 'config');
my $styles_dir = File::Spec->catdir($script_dir, 'styles');

# Configuration par défaut
my %config = (
    prequestion_string   => '**Parmi les propositions suivantes, laquelle (lesquelles) est (sont) exacte(s) ?**',
    completemulti_string => 'Aucune des propositions ci-dessus n\'est exacte.',
    a_bullet            => '   A.  ',
    ref_path            => File::Spec->catfile($styles_dir, 'reference_MC_Arial10.docx'),
    min_pandoc_version  => '1.12',
    expected_answers    => 4,
    font_settings       => {},
);

# Variables de ligne de commande
my %opts = (
    q_first_id   => 1,
    no_final_dot => 1,
    keep_md4docx => 0,
    help         => 0,
    verbose      => 0,
    ref_path     => undef,
    config_file  => undef,
);

# Analyse des arguments
GetOptions(
    'fid=i'       => \$opts{q_first_id},
    'nostop=i'    => \$opts{no_final_dot},
    'keep'        => \$opts{keep_md4docx},
    'verbose'     => \$opts{verbose},
    'config=s'    => \$opts{config_file},
    'ref=s'       => \$opts{ref_path},
    'font=s'      => \$opts{font_name},
    'fontsize=i'  => \$opts{font_size},
    'help'        => \$opts{help}
) or die "Erreur dans les options de ligne de commande. Utilisez --help pour l'aide.\n";

# Affichage de l'aide
if ($opts{help} || !@ARGV) {
    print_help();
    exit 0;
}

# Chargement de la configuration (arial10.json par défaut, ou personnalisée si spécifiée)
my $config_to_load = $opts{config_file} || 'arial10.json';
load_config($config_to_load);

# Surcharge du chemin de référence si spécifié
$config{ref_path} = $opts{ref_path} if $opts{ref_path};

# Surcharge des paramètres de police si spécifiés
if ($opts{font_name} || $opts{font_size}) {
    # Traitement des options de police en ligne de commande
    $config{font_settings} ||= {};
    $config{font_settings}->{main_font} = $opts{font_name} if $opts{font_name};
    $config{font_settings}->{font_size} = $opts{font_size} if $opts{font_size};
}

# Validation des prérequis et traitement
eval {
    validate_prerequisites();
    process_qcm_file($ARGV[0]);
    log_message("Conversion terminée avec succès", 'INFO');
};
if ($@) {
    log_message("Erreur lors de la conversion: $@", 'ERROR');
    exit 1;
}

#################
### FUNCTIONS ###
#################

sub print_help {
    print <<'EOF';
MC Markdown vers DOCX - Convertisseur optimisé
================================================

USAGE:
    mdmc2docx.pl [OPTIONS] <fichier_markdown>

DESCRIPTION:
    Convertit un fichier MC Markdown vers DOCX avec Pandoc

OPTIONS:
    --fid <numero>      Numéro de la première question (défaut: 1)
    --nostop <0|1>      Supprime le point final (défaut: 1)  
    --keep              Conserve le fichier Markdown temporaire
    --verbose           Mode verbeux pour le débogage
    --config <fichier>  Fichier de configuration JSON (défaut: arial10.json)
    --ref <fichier>     Fichier de référence DOCX personnalisé
    --font <police>     Police principale (ex: Arial, Times, Calibri)
    --fontsize <taille> Taille de police en points (ex: 10, 11, 12)
    --help              Affiche cette aide

EXEMPLES:
    mdmc2docx.pl examen.md                                    (Arial 10pt par défaut)
    mdmc2docx.pl --fid 10 --verbose --keep examen.md
    mdmc2docx.pl --config ma_config.json examen.md           (config personnalisée)
    mdmc2docx.pl --font Times --fontsize 12 examen.md        (police en ligne de commande)
    mdmc2docx.pl --ref styles/ma_reference.docx examen.md

FORMAT ATTENDU:
    ## [ID_Question]
    ### Texte de la question
    + Réponse correcte
    - Réponse incorrecte
    + Autre réponse correcte
    - Autre réponse incorrecte
    
    (ligne vide entre les questions)

FICHIERS DE SORTIE:
    - fichier.docx     : Document Word final
    - fichier.md4docx  : Markdown temporaire (si --keep)

Pour plus d'informations, consultez le README.md
EOF
}

sub log_message {
    my ($message, $level) = @_;
    $level ||= 'INFO';
    
    return unless $opts{verbose} || $level eq 'ERROR';
    
    my $timestamp = localtime();
    printf "[%s] %s: %s\n", $timestamp, $level, $message;
}

sub load_config {
    my ($config_file) = @_;
    
    # Tentative de chargement du module JSON
    eval { require JSON::PP; JSON::PP->import; };
    if ($@) {
        log_message("Module JSON::PP non disponible, configuration par défaut utilisée", 'WARN');
        return;
    }
    
    # Résolution du chemin relatif si nécessaire
    unless (File::Spec->file_name_is_absolute($config_file)) {
        $config_file = File::Spec->catfile($config_dir, $config_file);
    }
    
    # Vérification de l'existence du fichier
    unless (-f $config_file) {
        # Si c'est le fichier par défaut (arial10.json) et qu'il n'existe pas, continuer avec config par défaut
        if ($config_file =~ /arial10\.json$/) {
            log_message("Configuration par défaut arial10.json introuvable, utilisation de la configuration intégrée", 'WARN');
            return;
        } else {
            die "Fichier de configuration introuvable: $config_file\n";
        }
    }
    
    local $/;
    open my $fh, '<:utf8', $config_file or die "Impossible d'ouvrir $config_file: $!\n";
    my $json_text = <$fh>;
    close $fh;
    
    my $custom_config = eval { JSON::PP->new->decode($json_text) };
    if ($@) {
        die "Erreur dans le fichier de configuration JSON: $@\n";
    }
    
    # Fusion de la configuration
    for my $key (keys %$custom_config) {
        if (exists $config{$key}) {
            $config{$key} = $custom_config->{$key};
            log_message("Configuration mise à jour: $key", 'DEBUG');
        } else {
            log_message("Clé de configuration inconnue ignorée: $key", 'WARN');
        }
    }
    
    log_message("Configuration chargée depuis: $config_file", 'INFO');
}

sub validate_prerequisites {
    log_message("Validation des prérequis...", 'INFO');
    
    # Vérification de Pandoc
    eval {
        pandoc or die "Exécutable pandoc introuvable dans le PATH";
        my $version = pandoc->version;
        unless ($version && $version > $config{min_pandoc_version}) {
            die sprintf "Pandoc >= %s requis (version actuelle: %s)", 
                $config{min_pandoc_version}, $version || 'inconnue';
        }
        log_message("Pandoc version $version détecté", 'INFO');
    };
    if ($@) {
        die "Erreur avec Pandoc: $@\n";
    }
    
    # Vérification du fichier de référence
    unless (-f $config{ref_path}) {
        log_message("Fichier de référence introuvable: $config{ref_path}", 'WARN');
        log_message("Le style par défaut de Pandoc sera utilisé", 'INFO');
        $config{ref_path} = undef;
    } else {
        log_message("Fichier de référence trouvé: $config{ref_path}", 'INFO');
    }
}

sub validate_input_file {
    my ($file_path) = @_;
    
    unless (-f $file_path) {
        die "Fichier d'entrée introuvable: $file_path\n";
    }
    
    unless (-r $file_path) {
        die "Fichier d'entrée non lisible: $file_path\n";
    }
    
    log_message("Fichier d'entrée validé: $file_path", 'INFO');
}

sub setup_output_paths {
    my ($input_path) = @_;
    
    my ($base, $dir, $ext) = fileparse($input_path, qr/\.md$/i);
    
    unless ($ext) {
        log_message("Extension .md non détectée, traitement comme Markdown", 'WARN');
    }
    
    my $temp_path = File::Spec->catfile($dir, $base . '.md4docx');
    my $output_path = File::Spec->catfile($dir, $base . '.docx');
    
    # Vérification des permissions d'écriture
    unless (-w $dir) {
        die "Répertoire de sortie non accessible en écriture: $dir\n";
    }
    
    return ($temp_path, $output_path);
}

sub process_qcm_file {
    my ($input_path) = @_;
    
    log_message("Début du traitement: $input_path", 'INFO');
    
    validate_input_file($input_path);
    my ($temp_path, $output_path) = setup_output_paths($input_path);
    
    # Parsing du contenu
    my ($questions_count, $answers_count, $warnings_count) = parse_and_convert($input_path, $temp_path);
    
    # Conversion avec Pandoc
    convert_to_docx($temp_path, $output_path);
    
    # Nettoyage
    cleanup_temp_file($temp_path) unless $opts{keep_md4docx};
    
    log_message("Fichier DOCX créé: $output_path", 'INFO');
    
    # Message de succès moderne avec statistiques
    print "\n";
    print "✅ Conversion terminée avec succès !\n";
    print "📄 Fichier généré: $output_path\n";
    print "📊 Statistiques: $questions_count questions, $answers_count réponses";
    print $warnings_count > 0 ? ", $warnings_count avertissements\n" : "\n";
    print "\n";
}

sub parse_and_convert {
    my ($input_path, $output_path) = @_;
    
    # Tentative d'ouverture avec différents encodages
    my $in_fh;
    if (!open $in_fh, '<:encoding(UTF-8)', $input_path) {
        # Tentative avec latin1 puis conversion
        if (!open $in_fh, '<:encoding(latin1)', $input_path) {
            die "Impossible d'ouvrir $input_path avec aucun encodage: $!\n";
        } else {
            log_message("Fichier ouvert avec encodage latin1", 'WARN');
        }
    } else {
        log_message("Fichier ouvert avec encodage UTF-8", 'INFO');
    }
    
    open my $out_fh, '>:utf8', $output_path
        or die "Impossible de créer $output_path: $!\n";
    
    # En-tête du fichier généré
    write_header($out_fh, $input_path);
    
    # État du parsing
    my ($q_into, $a_into) = (0, 0);
    my ($q_id, $a_id) = ($opts{q_first_id}, 0);
    my $questions_string = '';
    my @answers_string = ();
    my @answers_eval = ();
    
    # Statistiques
    my ($questions_count, $answers_count, $warnings_count) = (0, 0, 0);
    
    # Préparation des chaînes
    my $completemulti_string = $config{completemulti_string};
    if ($opts{no_final_dot}) {
        $completemulti_string =~ s/\.$//g;
    }
    
    my $line_number = 0;
    while (my $line = <$in_fh>) {
        $line_number++;
        
        # Gestion robuste de l'encodage
        eval {
            chomp $line;
            # Nettoyer les caractères de contrôle problématiques
            $line =~ s/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]//g;
            $line =~ s/^\s+|\s+$//g;    # Trim
            
            if ($opts{no_final_dot}) {
                $line =~ s/\.$//g;
            }
        };
        if ($@) {
            log_message("Ligne $line_number: Caractère invalide détecté et ignoré", 'WARN');
            $warnings_count++;
            next;
        }
        
        eval {
            # Traitement selon le type de ligne
            if ($line =~ m/^## \[(.+)\]/) {
                process_question_id(\$q_into, \$a_into, \$questions_string, \$q_id, $1, $line_number);
            }
            elsif ($line =~ m/^### (.+)$/) {
                process_question_text(\$q_into, \$questions_string, $1, $line_number);
            }
            elsif ($line =~ m/^([\+-]) (.+)$/) {
                process_answer(\$q_into, \$a_into, \@answers_eval, \@answers_string, \$a_id, \$answers_count, $1, $2);
            }
            elsif ($line =~ m/^[_\s]*$/) {
                if ($a_into) {
                    process_end_answers($out_fh, \$a_into, \$a_id, \$questions_string, \@answers_string, \@answers_eval, \$questions_count, $completemulti_string, $line_number);
                }
            }
            elsif ($q_into && !$a_into) {
                $questions_string .= "$line\n";
            }
            elsif (!$q_into && !$a_into) {
                print $out_fh "$line\n";
            }
            else {
                die "État inattendu lors du traitement";
            }
        };
        if ($@) {
            close $in_fh;
            close $out_fh;
            die "Erreur ligne $line_number: $@\n";
        }
    }
    
    # Vérification de l'état final
    if ($a_into) {
        die "Fichier terminé de manière inattendue dans le contexte des réponses\n";
    }
    
    if ($q_into) {
        $warnings_count++;
        log_message("Question ouverte en fin de fichier", 'WARN');
    }
    
    close $in_fh;
    close $out_fh;
    
    log_message(sprintf("Statistiques: %d questions, %d réponses, %d avertissements", 
        $questions_count, $answers_count, $warnings_count), 'INFO');
    
    return ($questions_count, $answers_count, $warnings_count);
}

sub write_header {
    my ($fh, $input_path) = @_;
    
    my $date = localtime();
    my $comment = sprintf("Converti depuis: %s le %s --- Marc FERRE. TOUS DROITS RÉSERVÉS.", 
        $input_path, $date);
    
    printf $fh "<!--%s-->\n\n", $comment;
}

sub process_question_id {
    my ($q_into_ref, $a_into_ref, $questions_ref, $q_id_ref, $id, $line_number) = @_;
    
    if ($$a_into_ref) {
        die "ID de question trouvé alors que des réponses étaient attendues";
    }
    
    $$q_into_ref = 1;
    $$questions_ref .= sprintf "\n**%d\.** %s\n", $$q_id_ref, $config{prequestion_string};
    $$q_id_ref++;
    
    log_message("Question $id traitée (numéro $$q_id_ref)", 'DEBUG');
}

sub process_question_text {
    my ($q_into_ref, $questions_ref, $text, $line_number) = @_;
    
    unless ($$q_into_ref) {
        die "Texte de question trouvé hors contexte de question";
    }
    
    $$questions_ref .= "**$text**\n";
}

sub process_answer {
    my ($q_into_ref, $a_into_ref, $answers_eval_ref, $answers_string_ref, $a_id_ref, $answers_count_ref, $eval, $text) = @_;
    
    $$q_into_ref = 0;
    $$a_into_ref = 1;
    
    push @$answers_eval_ref, $eval;
    push @$answers_string_ref, $text;
    
    $$a_id_ref++;
    $$answers_count_ref++;
}

sub process_end_answers {
    my ($fh, $a_into_ref, $a_id_ref, $questions_ref, $answers_string_ref, $answers_eval_ref, $questions_count_ref, $completemulti_string, $line_number) = @_;
    
    $$a_into_ref = 0;
    $$a_id_ref = 0;
    
    my $answers_count = @$answers_string_ref;
    
    # Validation du nombre de propositions selon les nouvelles règles
    if ($answers_count < 4 || $answers_count > 5) {
        die sprintf "Ligne %d: Nombre de propositions invalide: %d trouvées. Attendu: 4 ou 5 propositions", 
            $line_number, $answers_count;
    }
    
    # Validation des évaluations
    my ($true_count, $false_count) = (0, 0);
    for my $eval (@$answers_eval_ref) {
        $true_count++ if $eval eq '+';
        $false_count++ if $eval eq '-';
    }
    
    unless ($true_count + $false_count == $answers_count) {
        die "Toutes les réponses doivent avoir une évaluation (+ ou -)";
    }
    
    # Génération de la sortie selon le nombre de propositions
    if ($answers_count == 4) {
        # 4 propositions: ajouter completemulti_string
        output_question_and_answers($fh, $$questions_ref, $answers_string_ref, $answers_eval_ref, $completemulti_string, $true_count == 0);
    } elsif ($answers_count == 5) {
        # 5 propositions: ne pas ajouter completemulti_string
        output_question_and_answers_no_completemulti($fh, $$questions_ref, $answers_string_ref, $answers_eval_ref);
    }
    
    # Réinitialisation
    $$questions_ref = '';
    @$answers_string_ref = ();
    @$answers_eval_ref = ();
    $$questions_count_ref++;
}

sub output_question_and_answers {
    my ($fh, $questions_string, $answers_string_ref, $answers_eval_ref, $completemulti_string, $completemulti_true) = @_;
    
    # Question
    print $fh "$questions_string\n";
    
    # Réponses
    my $bullet = $config{a_bullet};
    for my $i (0 .. $#{$answers_string_ref}) {
        print $fh $bullet;
        
        if ($answers_eval_ref->[$i] eq '+') {
            print $fh format_true($answers_string_ref->[$i]);
        } else {
            print $fh format_false($answers_string_ref->[$i]);
        }
        print $fh "\n";
    }
    
    # Option "Aucune des propositions" (pour 4 propositions)
    print $fh $bullet;
    if ($completemulti_true) {
        print $fh format_true($completemulti_string);
    } else {
        print $fh format_false($completemulti_string);
    }
    print $fh "\n";
    # Une seule ligne vide avec espace insécable pour forcer l'espacement dans DOCX
    print $fh "\n&nbsp;\n\n";
}

sub output_question_and_answers_no_completemulti {
    my ($fh, $questions_string, $answers_string_ref, $answers_eval_ref) = @_;
    
    # Question
    print $fh "$questions_string\n";
    
    # Réponses uniquement (pas de completemulti_string pour 5 propositions)
    my $bullet = $config{a_bullet};
    for my $i (0 .. $#{$answers_string_ref}) {
        print $fh $bullet;
        
        if ($answers_eval_ref->[$i] eq '+') {
            print $fh format_true($answers_string_ref->[$i]);
        } else {
            print $fh format_false($answers_string_ref->[$i]);
        }
        print $fh "\n";
    }
    # Séparation avec espaces insécables pour forcer l'espacement dans DOCX
    print $fh "\n&nbsp;\n\n&nbsp;\n\n";
}

sub convert_to_docx {
    my ($temp_path, $output_path) = @_;
    
    log_message("Conversion Pandoc: $temp_path -> $output_path", 'INFO');
    
    my @pandoc_args = (
        $temp_path,
        -f => 'markdown',
        -t => 'docx+styles',
        -o => $output_path
    );
    
    # Gestion des polices - approche simplifiée et robuste
    my $use_reference_file = 0;
    
    # Priorité 1: Variables de police Pandoc (toujours appliquées si configurées)
    if ($config{font_settings}) {
        if ($config{font_settings}->{main_font}) {
            push @pandoc_args, '-V', "mainfont=" . $config{font_settings}->{main_font};
            log_message("Police principale forcée: " . $config{font_settings}->{main_font}, 'INFO');
        }
        if ($config{font_settings}->{font_size}) {
            push @pandoc_args, '-V', "fontsize=" . $config{font_settings}->{font_size} . "pt";
            log_message("Taille de police forcée: " . $config{font_settings}->{font_size} . "pt", 'INFO');
        }
    }
    
    # Priorité 2: Fichier de référence (seulement si pas de variables ou si explicitement demandé)
    if ($config{ref_path} && -f $config{ref_path}) {
        push @pandoc_args, '--reference-doc', $config{ref_path};
        log_message("Fichier de référence utilisé: $config{ref_path}", 'INFO');
        $use_reference_file = 1;
    } elsif ($config{ref_path}) {
        log_message("Fichier de référence introuvable: $config{ref_path}", 'WARN');
    }
    
    # Information sur la stratégie utilisée
    if ($config{font_settings} && ($config{font_settings}->{main_font} || $config{font_settings}->{font_size})) {
        if ($use_reference_file) {
            log_message("Stratégie: Variables de police + fichier de référence (variables prioritaires)", 'INFO');
        } else {
            log_message("Stratégie: Variables de police uniquement", 'INFO');
        }
    } elsif ($use_reference_file) {
        log_message("Stratégie: Fichier de référence uniquement", 'INFO');
    } else {
        log_message("Stratégie: Styles par défaut Pandoc", 'INFO');
    }
    

    eval {
        pandoc @pandoc_args;
    };
    if ($@) {
        die "Erreur lors de la conversion Pandoc: $@";
    }
}

sub cleanup_temp_file {
    my ($temp_path) = @_;
    
    if (-f $temp_path) {
        unlink($temp_path) or log_message("Impossible de supprimer $temp_path: $!", 'WARN');
        log_message("Fichier temporaire supprimé", 'INFO');
    }
}

sub format_true {
    my ($string) = @_;
    return "**$string**";  # Gras - plus visible et universellement supporté
}

sub format_false {
    my ($string) = @_;
    return $string;
}

__END__