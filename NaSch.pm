###filename NaSch.pm
package NaSch;

use strict;
use warnings;

use Data::Dumper;

sub init_uniform_pos {
  my ($length, $density) = @_;
  my @lane = ();
  for my $i (1..$length) {
    if (rand() <= $density) {
      push(@lane, {'pos' => $i, 'speed' => 0});
    }
  }
  return \@lane;
}

sub update_periodic_lane {
  my ($lane, $length, $maxspeed, $loiter) = @_;
  my $next_pos = $length + %$lane[0]->{pos};

  foreach my $car (reverse(@$lane)) {
    update_car_speed($car, $next_pos - $car->{pos}, $maxspeed, $loiter);
    $next_pos = $car->{pos};
    $car->{pos} += $car->{speed}; # advance the car
  }

  if (@$lane[-1]->{pos} > $length) { # wrap cars around the lane's end
    unshift(@$lane, pop(@$lane));
    @$lane[0]->{pos} -= $length;
  }

  return $lane;
}

sub update_car_speed {
  my ($car, $dist, $maxspeed, $loiter) = @_;
  my $lm = $car->{speed} > 0 ? 1 : 2;

  unless ($car->{speed} >= $maxspeed) { # accelerate unless maxspeed is reached
    $car->{speed}++;
  }
  if ($car->{speed} >= $dist) { # brake when approaching obstacle
    $car->{speed} = $dist - 1;
  }
  if (rand() <= $lm * $loiter and $car->{speed} > 0) { # loiter randomly
    $car->{speed}--;
    $car->{loiter} = 1;
  } else {
    $car->{loiter} = 0;
  }

  return $car->{speed};
}

sub draw_lane {
  my ($lane, $image, $palette, $size, $offset) = @_;
  my ($px, $py);

  $py = $offset * $size;
  foreach my $car (@$lane) {
    $px = $car->{pos} * $size;
    $image->rectangle($px,$py, $px+$size,$py+$size, @$palette[$car->{speed}], 1);
    if ($car->{loiter}) {
      $image->diamond($px,$py, $px+$size,$py+$size, '#ff00ff', 1);
    }
  }

  return $image;
}

sub init_palette {
  my ($range) = @_;

  my $c_max = 255.0;
  my $steps = @$range - 1;
  my $inc = $c_max / $steps;

  return [map {sprintf('#%02lx%02lx00', int($c_max - $_ * $inc), int($_ * $inc))} @$range];
}

1
