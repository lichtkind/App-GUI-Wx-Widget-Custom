
# slider widget with display of value and nudge buttons

package Wx::Custom::Widget::PositionMarker;
use v5.12;
use warnings;
use Wx;
use Wx::Custom::Widget::ColorDisplay;
use base qw/Wx::Custom::Widget::ColorDisplay/;

sub new {
    my ( $class, $parent, $size, $foreground_color, $state ) = @_;
    $size             //= [15, 15];
    $foreground_color //= [0, 0, 0];
    $state            //= 'empty';
    return if ref $size ne 'ARRAY' or @$size != 2;

    my $self = $class->SUPER::new( $parent, $size, [255, 255, 255]);
    return $self unless ref $self;
    return unless ref $self->set_foreground_color( $foreground_color, 'passive' );
    $self->set_border_color( [0, 0, 0],'passive' );
    $self->set_paint_callback( sub {
        my ($dc, $x, $y) = @_;
        return if $self->{'state'} eq 'empty';
        my $fg_color = Wx::Colour->new( @{$self->get_foreground_color} );
        if ($self->{'state'} eq 'disabled'){
            $dc->SetPen( Wx::Pen->new( $fg_color, 1, &Wx::wxPENSTYLE_SOLID ) );
            $dc->DrawLine( 0,  0, $x-1, $y-1);
            $dc->DrawLine( 0,  $y-1, $x-1, 0);
            return;
        }
        my $line_thick = 4;
        $dc->SetPen( Wx::Pen->new( $fg_color, $line_thick, &Wx::wxPENSTYLE_SOLID ) );
        my $left  = $line_thick + 1;
        my $right = $x - $line_thick - 1;
        my $up    = $line_thick + 1;
        my $down  = $x - $line_thick - 1;
        my $mid_x = int($x / 2);
        my $mid_y = int($y / 2);
        if      ($self->{'state'} eq 'up'){   $dc->DrawLine( $left,  $down,  $mid_x, $up   );
                                              $dc->DrawLine( $mid_x, $up,    $right, $down );
        } elsif ($self->{'state'} eq 'down'){ $dc->DrawLine( $left,  $up,    $mid_x, $down );
                                              $dc->DrawLine( $mid_x, $down,  $right, $up   );
        } elsif ($self->{'state'} eq 'left'){ $dc->DrawLine( $right, $up,    $left,  $mid_y );
                                              $dc->DrawLine( $left,  $mid_y, $right, $down  );
        } elsif ($self->{'state'} eq 'right'){$dc->DrawLine( $left,  $up,    $right, $mid_y );
                                              $dc->DrawLine( $right, $mid_y, $left,  $down  );
        }
    } );
    return unless $self->set_state( $state );
    return $self;
}

sub get_state { $_[0]->{'state'} }
sub set_state {
    my ( $self, $state, $passive ) = @_;
    return '' unless $state eq 'empty' or $state eq 'disabled' or
                     $state eq 'left' or $state eq 'right' or $state eq 'up' or $state eq 'down';
    $self->{'state'} = $state;
    $self->Refresh unless defined $passive and $passive;
    return $state;
}

sub get_foreground_color { $_[0]->{'foreground_color'} }
sub set_foreground_color {
    my ( $self, $foreground_color, $passive) = @_;
    return if ref $foreground_color ne 'ARRAY' or @$foreground_color != 3;
    $self->{'foreground_color'} = $self->_put_color_in_range( $foreground_color );
    $self->Refresh unless defined $passive and $passive;
    return $foreground_color;
}

1;
