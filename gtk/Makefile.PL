use ExtUtils::MakeMaker;

WriteMakefile(
    NAME		    => 'pmp3_gtk',
    VERSION_FROM	=> 'pmp3_gtk',
    AUTHOR          => 'Matt Cashner <matt@cre8tivegroup.com>',
    ABSTRACT        => 'A Perl MP3 Player',
    PREFIX          => '/usr/local',
    PM              => {'pmp3_gtk' => '${INST_BIN}/pmp3_gtk',
                        'pmp3_mini' => '${INST_BIN}/pmp3_mini',
                        'upload_status' => '${INST_BIN}/upload_status',
                       },
    MAN3PODS        => {'pmp3_gtk' => '${INST_MAN3DIR}/pmp3_gtk.3'},
    PREREQ_PM		=> { 'MPEG::MP3Info' => 0,
                         'MPEG::MP3Play' => 0,
            			 'Gtk' => 0,
                       },
	
);

sub MY::install {
    my $self = shift;
    return q{
install :: all pure_site_install

pure_site_install ::
	} . $self->{NOECHO} . q{$(MOD_INSTALL) \
		$(INST_BIN) $(INSTALLBIN) \
		$(INST_MAN3DIR) $(INSTALLMAN3DIR)

uninstall : 
	}.$self->{NOECHO}.q{echo Deleting $(INSTALLBIN)/pmp3_gtk
	}.$self->{NOECHO}.q{echo Deleting $(INSTALLMAN3DIR)/pmp3_gtk.3
	}.$self->{NOECHO}.q{echo Deleting $(INSTALLBIN)/upload_status
	}.$self->{NOECHO}.q{rm $(INSTALLBIN)/playmp3 $(INSTALLMAN3DIR)/playmp3.3 $(INSTALLBIN)/upload_status
};


}

sub MY::tools_other { 
    my($self) = shift;
    my @m;
    my $bin_sh = $Config{sh} || '/bin/sh';
    push @m, qq{
SHELL = $bin_sh
};

    for (qw/ CHMOD CP LD MV NOOP RM_F RM_RF TEST_F TOUCH UMASK_NULL DEV_NULL/ ) {
    push @m, "$_ = $self->{$_}\n";
    }

    push @m, q{
# The following is a portable way to say mkdir -p
# To see which directories are created, change the if 0 to if 1
MKPATH = $(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) -MExtUtils::Command -e mkpath

# This helps us to minimize the effect of the .exists files A yet
# better solution would be to have a stable file in the perl
# distribution with a timestamp of zero. But this solution doesn't
# need any changes to the core distribution and works with older perls
EQUALIZE_TIMESTAMP = $(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) -MExtUtils::Command -e eqtime
};


    return join "", @m if $self->{PARENT};

    push @m, q!
UNINST=0
VERBINST=1

MOD_INSTALL = $(PERL) -I$(INST_LIB) -I$(PERL_LIB) -MExtUtils::Install -e "install({@ARGV},'$(VERBINST)',0,'$(UNINST)');"

DOC_INSTALL = $(PERL) -e '$$\="\n\n";' \
-e 'print "=head2 ", scalar(localtime), ": C<", shift, ">", " L<", shift, ">";' \
-e 'print "=over 4";' \
-e 'while (defined($$key = shift) and defined($$val = shift)){print "=item *";print "C<$$key: $$val>";}' \
-e 'print "=back";'

UNINSTALL =   $(PERL) -MExtUtils::Install -e 'uninstall($$ARGV[0],1,1);'
!;

    return join "", @m;
}
    
