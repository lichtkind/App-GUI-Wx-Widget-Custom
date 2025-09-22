
# select between colors by left or right click

package Wx::Custom::Widget::ColorToggle;
use v5.12;
use warnings;
use Wx;
use Wx::Custom::Widget::ColorDisplay;
use base qw/Wx::Custom::Widget::ColorDisplay/;

sub new {
    my ( $class, $parent, $size, $colors, $start_nr  ) = @_;
    $colors //= [[0,0,0], [255, 255, 255],];
    $start_nr //= 1;
    return if ref $colors ne 'ARRAY' or not exists $colors->[ $start_nr-1 ];
    my $start_color = $colors->[ $start_nr-1 ];

    my $self = $class->SUPER::new( $parent, $size, $start_color );
    return $self unless ref $self;
    return unless ref $self->set_background_colors( $colors, 'passive' );
    $self->{'value'} = $start_nr;

    $self->set_left_click_callback( sub {
        my ($event) = @_;
        $self->{'value'}++;
        $self->{'value'} = 1 if $self->{'value'} > $self->max_value;
        $self->{'update'}->( $event ) if ref $self->{'update'};
    });
    $self->set_right_click_callback( sub {
        my ($event) = @_;
        $self->{'value'}--;
        $self->{'value'} = $self->max_value if $self->{'value'} < 1;
        $self->{'update'}->( $event ) if ref $self->{'update'};
    });
    $self;
}

sub get_background_colors { $_[0]->{'background_colors'} }
sub set_background_colors {
    my ( $self, $background_colors, $passive) = @_;
    return if ref $background_colors ne 'ARRAY' or not @$background_colors;
    for my $color (@$background_colors){
        return if ref $color ne 'ARRAY' or @$color != 3;
        $self->_put_color_in_range( $color );
    }
    $self->{'background_colors'} = $background_colors;
    $self->Refresh unless defined $passive and $passive;
    return $background_colors;
}

sub GetValue { $_[0]->{'value'} }
sub SetValue {
    my ( $self, $value ) = @_;
    return unless defined $value and $value > -1 and $value <= $self->GetMaxValue;
    return if $self->{'value'} == $value;
    $self->{'value'} = $value;
    $self->Refresh;
}

sub max_value { int @{$_[0]->{'background_colors'}} }

sub set_update_callback {
    my ( $self, $code ) = @_;
    return unless ref $code eq 'CODE';
    $self->{'update'} = $code;
}

1;

