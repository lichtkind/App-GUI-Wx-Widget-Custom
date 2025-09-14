
# slider widget with display of value and nudge buttons

package Wx::Custom::Widget::PositionMarker;
use v5.12;
use warnings;
use Wx;
use base qw/Wx::Panel/;

sub new {
    my ( $class, $parent, $size, $foreground_color, $state, $data ) = @_;
    $size             //= [15, 15];
    $foreground_color //= [0, 0, 0];
    $state            //= 'empty';
    $data             //= '';
    return if ref $size ne 'ARRAY' or @$size != 2;

    my $self = $class->SUPER::new( $parent, -1, [-1,-1], $size);
    return unless ref $self->set_foreground_color( $foreground_color, 'passive' );
    $self->set_background_color( [255, 255, 255] );
    $self->set_data( $data );
    return unless $self->set_state( $state );

    Wx::Event::EVT_PAINT( $self, sub {
say "paint";
        my( $panel, $event ) = @_;
        my $dc = Wx::PaintDC->new( $panel );
        $dc->SetBackground(
            Wx::Brush->new( Wx::Colour->new( @{$self->{'background_color'}} ),
                            &Wx::wxBRUSHSTYLE_SOLID ),
        );
        $dc->Clear();
        return if $self->{'state'} eq 'empty';
        my ($x, $y) = ( $self->GetSize->GetWidth, $self->GetSize->GetHeight );
        my $fg_color = Wx::Colour->new( @{$self->{'foreground_color'}} );
        if ($self->{'state'} eq 'disabled'){
            $dc->SetPen( Wx::Pen->new( $fg_color, 1, &Wx::wxPENSTYLE_SOLID ) );
            $dc->DrawLine( 0,  0, $x, $y);
            $dc->DrawLine( 0,  $y, $x, 0);
            return;
        }
        my $line_thick = 4;
        $dc->SetPen( Wx::Pen->new( $fg_color, $line_thick, &Wx::wxPENSTYLE_SOLID ) );
        my $left  = $line_thick;
        my $right = $x - $line_thick;
        my $up    = $line_thick;
        my $down  = $x - $line_thick;
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

    $self;
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
say "set";
    return if ref $foreground_color ne 'ARRAY' or @$foreground_color != 3;
say "set";
    for my $index (0 .. 2){
        $foreground_color->[$index] =   0 if $foreground_color->[$index] <   0;
        $foreground_color->[$index] = 255 if $foreground_color->[$index] > 255;
    }
    $self->{'foreground_color'} = $foreground_color;
    $self->Refresh unless defined $passive and $passive;
    return $foreground_color;
}

sub get_background_color { $_[0]->{'background_color'} }
sub set_background_color {
    my ( $self, $background_color, $passive) = @_;
    return if ref $background_color ne 'ARRAY' or @$background_color != 3;
    for my $index (0 .. 2){
        $background_color->[$index] =   0 if $background_color->[$index] <   0;
        $background_color->[$index] = 255 if $background_color->[$index] > 255;
    }
    $self->Refresh unless defined $passive and $passive;
    $self->{'background_color'} = $background_color;
    return $background_color;
}

sub get_data  { $_[0]->{'data'} }
sub set_data  { $_[0]->{'data'} = $_[1] if defined $_[1] }

1;
