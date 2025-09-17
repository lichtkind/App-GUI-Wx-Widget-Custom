
# square widget that displays a color, stores data and can react to clicks

package Wx::Custom::Widget::ColorDisplay;
use base qw/Wx::Panel/;
use v5.12;
use warnings;
use Wx;

sub new {
    my ($class, $parent, $size, $init_color ) = @_;
    $size //= [15, 15];
    $init_color //= [0,0,0];
    return if ref $size ne 'ARRAY' or @$size != 2;
    return if ref $init_color ne 'ARRAY' or @$init_color != 3;

    my $self = $class->SUPER::new( $parent, -1, [-1,-1], $size );
    $self->set_border_color( [0, 0, 0] );
    $self->{'init_color'} = $init_color;
    $self->reset_background_color( );

    Wx::Event::EVT_PAINT( $self, sub {
        my( $panel, $event ) = @_;
        my $dc = Wx::PaintDC->new( $self );
        $dc->SetBackground(
            Wx::Brush->new( Wx::Colour->new( @{$self->get_background_color} ),
                            &Wx::wxBRUSHSTYLE_SOLID ),                           );
        $dc->Clear();
        $dc->SetPen( Wx::Pen->new( Wx::Colour->new( @{$self->get_border_color} ),
                                   1, &Wx::wxPENSTYLE_SOLID )                    );

        my ($x, $y) = ( $self->GetSize->GetWidth, $self->GetSize->GetHeight );
        $dc->DrawLine(    0,    0, $x-1,    0 );
        $dc->DrawLine(    0, $y-1, $x-1, $y-1 );
        $dc->DrawLine(    0,    0,    0, $y-1 );
        $dc->DrawLine( $x-1,    0, $x-1, $y-1 );
        $self->{'paint'}->( $dc, $x, $y ) if ref $self->{'paint'};
        $event->Skip;
    } );

    Wx::Event::EVT_LEFT_DOWN( $self, sub {
        my( $self, $event ) = @_;
        next unless ref $self->{'left_click'};
        $self->{'left_click'}->( $event );
        $event->Skip;
    });

    Wx::Event::EVT_RIGHT_DOWN( $self, sub {
        my( $self, $event ) = @_;
        next unless ref $self->{'right_click'};
        $self->{'right_click'}->( $event );
        $event->Skip;
    });
    $self;
}

sub set_paint_callback {
    my ($self, $code) = @_;
    return unless ref $code eq 'CODE';
    $self->{'paint'} = $code;
}
sub set_left_click_callback {
    my ($self, $code) = @_;
    return unless ref $code eq 'CODE';
    $self->{'left_click'} = $code;
}
sub set_right_click_callback {
    my ($self, $code) = @_;
    return unless ref $code eq 'CODE';
    $self->{'right_click'} = $code;
}

sub get_background_color { $_[0]->{'background_color'} }
sub set_background_color {
    my ( $self, $background_color, $passive) = @_;
    return if ref $background_color ne 'ARRAY' or @$background_color != 3;
    $self->{'background_color'} = $self->_put_color_in_range( $background_color );
    $self->Refresh unless defined $passive and $passive;
    return $background_color;
}
sub reset_background_color {
    my ($self) = @_;
    $self->set_background_color( $self->{'init_color'} );
}

sub get_border_color { $_[0]->{'border_color'} }
sub set_border_color {
    my ( $self, $border_color, $passive) = @_;
    return if ref $border_color ne 'ARRAY' or @$border_color != 3;
    $self->{'border_color'} = $self->_put_color_in_range( $border_color );
    $self->Refresh unless defined $passive and $passive;
    return $border_color;
}

sub _put_color_in_range {
    my ($self, $color) = @_;
    return if ref $color ne 'ARRAY' or @$color != 3;
    for my $index (0 .. 2){
        $color->[$index] =   0 if $color->[$index] <   0;
        $color->[$index] = 255 if $color->[$index] > 255;
    }
    return $color;
}

1;
