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
use Wx::Custom::Widget::ColorDisplay;

sub new {
    my ( $class, $parent, $title ) = @_;
    my $self = $class->SUPER::new( $parent, -1, $title );
    $self->SetIcon( Wx::GetWxPerlIcon() );

    my $blue = Wx::Custom::Widget::ColorDisplay->new( $self, [20,20], [0, 10,250], 24);
    my $black = Wx::Custom::Widget::ColorDisplay->new( $self);

    $blue->set_left_click_callback( sub { Wx::MessageBox( 'my data is '.$blue->get_data, 'Info',
                                          &Wx::wxOK | &Wx::wxICON_INFORMATION | &Wx::wxSTAY_ON_TOP ) });
    $black->set_left_click_callback( sub { Wx::MessageBox( 'no data', 'Info',
                                           &Wx::wxOK | &Wx::wxICON_INFORMATION | &Wx::wxSTAY_ON_TOP )
                                                                     unless defined $black->get_data });
    my $button = Wx::Button->new( $self, -1, 'dimm blue');
    Wx::Event::EVT_BUTTON( $button, $button, sub {
        my $color = $blue->get_color();
        $color->[2] -= 10;
        $color->[2] += 250 if $color->[2] < 0;
        $blue->set_color( $color );
    } );

    my $attr = &Wx::wxALIGN_LEFT | &Wx::wxALIGN_CENTER_VERTICAL | &Wx::wxLEFT | &Wx::wxRIGHT;
    my $sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $sizer->Add( $blue,    0, $attr,  15);
    $sizer->Add( $button,  0, $attr, 15);
    $sizer->Add( $black,   0, $attr,   5);
    $sizer->Add( 0,     1, &Wx::wxEXPAND|&Wx::wxGROW);
    $self->SetSizer($sizer);
    $self;
}
