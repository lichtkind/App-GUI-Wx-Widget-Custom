#!/usr/bin/perl -w

use v5.12;
use warnings;
use lib 'lib', '../lib';

ColorDisplayTester->new->MainLoop( );
exit 0;


package ColorDisplayTester;
use v5.12;
use Wx;
use base qw/Wx::App/;

sub OnInit {
    my $app   = shift;
    my $frame = ColorDisplayTester::Frame->new( undef, __PACKAGE__);
    $frame->Show(1);
    $frame->CenterOnScreen();
    $app->SetTopWindow($frame);
    1;
}
sub OnQuit { my( $self, $event ) = @_; $self->Close( 1 ); }
sub OnExit { my $app = shift;  1; }


package ColorDisplayTester::Frame;
use base qw/Wx::Frame/;

sub new {
    my ( $class, $parent, $title ) = @_;
    my $self = $class->SUPER::new( $parent, -1, $title );
    $self->SetIcon( Wx::GetWxPerlIcon() );

    $self;
}
