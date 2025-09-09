#!/usr/bin/perl -w

use v5.12;
use warnings;
use lib 'lib', '../lib';

ProgressbarTester->new->MainLoop( );
exit 0;


package ProgressbarTester;
use v5.12;
use Wx;
use base qw/Wx::App/;

sub OnInit {
    my $app   = shift;
    my $frame = ProgressbarTester::Frame->new( undef, __PACKAGE__);
    $frame->Show(1);
    $frame->CenterOnScreen();
    $app->SetTopWindow($frame);
    1;
}
sub OnQuit { my( $self, $event ) = @_; $self->Close( 1 ); }
sub OnExit { my $app = shift;  1; }


package ProgressbarTester::Frame;
use base qw/Wx::Frame/;
use Wx::Custom::Widget::ProgressBar;

sub new {
    my ( $class, $parent, $title ) = @_;
    my $self = $class->SUPER::new( $parent, -1, $title );
    $self->SetIcon( Wx::GetWxPerlIcon() );

    my $monochrome = Wx::Custom::Widget::ProgressBar->new( $self, [250,20], [200, 200, 200]);
    my $rainbow    = Wx::Custom::Widget::ProgressBar->new( $self );

    $monochrome->set_foreground_colors([20,10, 255]);
    $rainbow->set_foreground_colors([20,10, 255], [20,255, 15], [255, 20, 15]);

    my $button_rm = Wx::Button->new( $self, -1, 'reset mono');
    my $button_am = Wx::Button->new( $self, -1, 'add mono');
    my $button_rr = Wx::Button->new( $self, -1, 'reset rainb.');
    my $button_ar = Wx::Button->new( $self, -1, 'add rainb.');

    Wx::Event::EVT_BUTTON( $button_rm, $button_rm, sub { $monochrome->reset } );
    Wx::Event::EVT_BUTTON( $button_am, $button_am, sub { $monochrome->set_progress( $monochrome->get_progress + 10 ); } );
    Wx::Event::EVT_BUTTON( $button_rr, $button_rr, sub { $rainbow->reset    } );
    Wx::Event::EVT_BUTTON( $button_ar, $button_ar, sub { $rainbow->set_progress( $rainbow->get_progress + 10 )  } );

    my $item = &Wx::wxALIGN_CENTER_VERTICAL | &Wx::wxALIGN_CENTER_HORIZONTAL | &Wx::wxALL;
    my $row = &Wx::wxALIGN_CENTER_VERTICAL | &Wx::wxALIGN_LEFT | &Wx::wxLEFT;
    my $grow = &Wx::wxEXPAND|&Wx::wxGROW;
    my $mono_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $mono_sizer->Add( $button_rm,  0, $item,  10);
    $mono_sizer->Add( $button_am,  0, $item,  10);
    $mono_sizer->Add( $monochrome, 0, $item,  10);
    $mono_sizer->Add( 0,           1, $grow);
    my $rain_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $rain_sizer->Add( $button_rr,  0, $item,  10);
    $rain_sizer->Add( $button_ar,  0, $item,  10);
    $rain_sizer->Add( $rainbow,    0, $item,  10);
    $rain_sizer->Add( 0,           1, $grow);
    my $sizer = Wx::BoxSizer->new(&Wx::wxVERTICAL);
    $sizer->Add( $mono_sizer,    0, $row,   5);
    $sizer->Add( $rain_sizer,    0, $row,   5);
    $sizer->Add( 0,              1, $grow);
    $self->SetSizer($sizer);
    $self->SetSize( [500,200]);
    $self;
}
