#!/usr/bin/perl -w

use v5.12;
use warnings;
use lib 'lib', '../lib';

ColorToggleTester->new->MainLoop( );
exit 0;

package ColorToggleTester;
use v5.12;
use Wx;
use base qw/Wx::App/;

sub OnInit {
    my $app   = shift;
    my $frame = ColorToggleTester::Frame->new( undef, __PACKAGE__);
    $frame->Show(1);
    $frame->CenterOnScreen();
    $app->SetTopWindow($frame);
    1;
}
sub OnQuit { my( $self, $event ) = @_; $self->Close( 1 ); }
sub OnExit { my $app = shift;  1; }


package ColorToggleTester::Frame;
use base qw/Wx::Frame/;
use Wx::Custom::Widget::ColorToggle;

sub new {
    my ( $class, $parent, $title ) = @_;
    my $self = $class->SUPER::new( $parent, -1, $title );
    $self->SetIcon( Wx::GetWxPerlIcon() );

    my $state        = Wx::StaticText->new($self, -1, 1 );
    my $ct = Wx::Custom::Widget::ColorToggle->new( $self, [30, 30], [[20, 20, 200],[120, 120, 250]], 1);
    $ct->set_update_callback( sub {$state->SetLabel( $ct->get_value )} );

    my $button  = Wx::Button->new( $self, -1, 'toggle sets');
    Wx::Event::EVT_BUTTON( $button,  $button,  sub {
        $ct->max_value == 2 ? $ct->set_background_colors( [[50,10,10], [150,20,20], [250,30,30],] )
                            : $ct->set_background_colors( [[20, 20, 200],[120, 120, 250]] );
    } );

    my $item = &Wx::wxALIGN_CENTER_VERTICAL | &Wx::wxALIGN_CENTER_HORIZONTAL | &Wx::wxALL;
    my $row = &Wx::wxALIGN_CENTER_VERTICAL | &Wx::wxALIGN_LEFT | &Wx::wxLEFT;
    my $grow = &Wx::wxEXPAND|&Wx::wxGROW;
    my $toggle_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $toggle_sizer->Add( $ct,    0, $item,  10);
    $toggle_sizer->Add( $state, 0, $item,  10);
    $toggle_sizer->Add( 0,      1, $grow);
    my $button_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $button_sizer->Add( $button,  0, $item,  10);
    $button_sizer->Add( 0,             1, $grow);
    my $sizer = Wx::BoxSizer->new(&Wx::wxVERTICAL);
    $sizer->Add( $toggle_sizer, 1, $row|&Wx::wxGROW,   5);
    $sizer->Add( $button_sizer, 0, $row,   5);
    $sizer->Add( 0,             1, $grow);
    $self->SetSizer($sizer);
    $self->SetSize( [600, 300]);
    $self;
}
