
# colored bar shows canvas status colors used in drawing

package Wx::Custom::Widget::ProgressBar;
use base qw/Wx::Panel/;
use v5.12;
use warnings;
use Wx;

sub new {
    my ( $class, $parent, $size, $background_color ) = @_;
    $size = [200, 10] unless defined $size;
    return if ref $size ne 'ARRAY' or @$size != 2;
    $background_color = [255, 255, 255] unless defined $background_color;
    return if ref $background_color ne 'ARRAY' or @$background_color != 3;

    my $self = $class->SUPER::new( $parent, -1, [-1,-1], $size);
    $self->{'size'}{'x'} = $size->[0];
    $self->{'size'}{'y'} = $size->[1];
    $self->{'progress'} = 0;
    $self->{'color_count'} = 0;
    $self->{'foreground_colors'} = [];
    $self->{'background_color'} = $background_color;

    Wx::Event::EVT_PAINT( $self, sub {
        my( $cpanel, $event ) = @_;
        my $dc = Wx::PaintDC->new( $cpanel );
        my $bg_color = Wx::Colour->new( @{$self->{'background_color'}} );
        $dc->SetBackground( Wx::Brush->new( $bg_color, &Wx::wxBRUSHSTYLE_SOLID ) );
        $dc->Clear();
        return unless $self->{'color_count'} and $self->{'progress'};

        my ($x, $y) = ( $self->GetSize->GetWidth, $self->GetSize->GetHeight );
        my $max_pos = $x * $self->{'progress'} / 100;
        if ($self->{'color_count'} == 1){
            my $fg_color = Wx::Colour->new( @{$self->{'foreground_colors'}[0]} );
            return $dc->GradientFillLinear( Wx::Rect->new( 0, 0, $max_pos, $y ), $fg_color, $fg_color );
        }
        my $start_pos = 0;
        my $start_color = Wx::Colour->new( @{$self->{'foreground_colors'}[0]} );
        my $segment_size = $x / ($self->{'color_count'} - 1);
        for my $segment_index (1 .. $self->{'color_count'} - 1){
            my $end_pos = $segment_index + $segment_size;
            my $end_color = Wx::Colour->new( @{$self->{'foreground_colors'}[$segment_index]} );
            return $dc->GradientFillLinear( Wx::Rect->new( $start_pos, 0, $max_pos, $y ), $start_color, $end_color )
                if $end_pos > $max_pos;
            $dc->GradientFillLinear( Wx::Rect->new( $start_pos, 0, $end_pos, $y ), $start_color, $end_color );
            $start_pos = $end_pos;
            $start_color = $end_color;
        }
    } );
    $self;
}

sub set_background_color {
    my ( $self, $background_color) = @_;
    return if ref $background_color ne 'ARRAY' or @$background_color != 3;
    for my $index (0 .. 2){
        $background_color->[$index] =   0 if $background_color->[$index] <   0;
        $background_color->[$index] = 255 if $background_color->[$index] > 255;
    }
    $self->{'background_color'} = $background_color;
}
sub set_foreground_colors {
    my ( $self, @colors) = @_;
    for my $color (@colors) {
        return unless ref $color ne 'ARRAY' or @$color != 3;
        for my $index (0 .. 2){
            $color->[$index] =   0 if $color->[$index] <   0;
            $color->[$index] = 255 if $color->[$index] > 255;
        }
    }
    $self->{'foreground_colors'} = [@colors];
    $self->{'color_count'} = int @colors;
}


sub get_progress { $_[0]->{'progress'} }
sub set_progress {
    my ( $self, $percent ) = @_;
    return if ref $percent or $percent < 0 or $percent > 100;
    $self->{'progress'} = $percent;
    $self->Refresh;
}
sub add_progress {
    my ( $self, $percent ) = @_;
    return if ref $percent or $percent < 0 or $percent > 100;
    $self->{'progress'} = $percent;
    $self->Refresh;
}
sub reset {
    my ($self) = @_;
    $self->{'progress'} = 0;
    $self->Refresh;
}

1;
