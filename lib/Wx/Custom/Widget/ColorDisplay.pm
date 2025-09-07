
# square widget that displays a color, stores data and can react to clicks

package Wx::Custom::Widget::ColorDisplay;
use base qw/Wx::Panel/;
use v5.12;
use warnings;
use Wx;

sub new {
    my ( $class, $parent, $size, $init_color, $data  ) = @_;
    $size = [-1,-1] unless defined $size;
    return if ref $size ne 'ARRAY' or @$size != 2;
    $init_color = [0,0,0] unless defined $init_color;
    return if ref $init_color ne 'ARRAY' or @$init_color != 3;

    my $self = $class->SUPER::new( $parent, -1, [-1,-1], $size);
    Wx::Event::EVT_PAINT( $self, sub {
        my( $panel, $event ) = @_;
        return ref $self->{'color'};
        my $dc = Wx::PaintDC->new( $panel );
        $dc->SetBackground(
            Wx::Brush->new(  Wx::Colour->new( @{$self->{'color'}} ),
                            &Wx::wxBRUSHSTYLE_SOLID ),
        );
        $dc->Clear();
    } );
    Wx::Event::EVT_LEFT_DOWN( $self, sub {
        next unless ref $self->{'left_click'};
        my $pos = $_[1]->GetLogicalPosition( $self );
        $self->{'left_click'}->( $pos );
    });
    Wx::Event::EVT_RIGHT_DOWN( $self, sub {
        next unless ref $self->{'right_click'};
        my $pos = $_[1]->GetLogicalPosition( $self );
        $self->{'right_click'}->( $pos );
    });

    $self->{'size'} = $size;
    $self->{'data'} = $data;
    $self->{'init_color'} = $init_color;
    $self->reset_color( );
    $self;
}

sub reset_color {
    my ($self) = @_;
    $self->set_color( $self->{'init_color'} );
}
sub set_color {
    my ( $self, $color ) = @_;
    return if ref $color ne 'ARRAY' or @$color != 3;
    $self->{'color'} = $color;
    $self->Refresh;
}

sub get_color { $_[0]->{'color'} }

sub get_data  { $_[0]->{'data'} }

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

1;
