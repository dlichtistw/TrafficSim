use warnings;
use strict;

use lib '.';
use NaSch;

use Image::Base::Imager;

# Model parameters
my $m = 5; # maximal velocity
my $p = 0.15; # loiter probability
my $n = 1000; # lane length
my $d = 0.2; # traffic density

# Output parameters
my $filename = 'demo.png'; # output file name
my $cell_size = 5; # cell width (in pixels)
my $iterations = 500; # number of iterations

# Initialize output image
my $image = Image::Base::Imager->new(-width => $n * $cell_size, -height => ($iterations + 1) * $cell_size);
my $palette = NaSch::init_palette([0..$m]);

# Initialize cells
my $lane = NaSch::init_uniform_pos($n, $d);
NaSch::draw_lane($lane, $image, $palette, $cell_size, 0);

# Iterate Nagel Schreckenberg model
for my $i (1..$iterations) {
  $lane = NaSch::update_periodic_lane($lane, $n, $m, $p);
  NaSch::draw_lane($lane, $image, $palette, $cell_size, $i);
}

# Save results as graphic
$image->save($filename);
