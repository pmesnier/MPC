package JSONProjectCreator;

# ************************************************************
# Description   : A JSON project creator
# Author        : Justin Michel & Chad Elliott
# Create Date   : 8/25/2003
# ************************************************************

# ************************************************************
# Pragmas
# ************************************************************

use strict;

use ProjectCreator;

use vars qw(@ISA);
@ISA = qw(ProjectCreator);

# ************************************************************
# Data Section
# ************************************************************

my $style_indent = .5;

# ************************************************************
# Subroutine Section
# ************************************************************

sub file_sorter {
  #my $self  = shift;
  #my $left  = shift;
  #my $right = shift;
  return lc($_[1]) cmp lc($_[2]);
}


sub label_nodes {
  my($self, $hash, $nodes, $level) = @_;

  foreach my $key (sort keys %$hash) {
    push(@$nodes, [$level, $key]);
    $self->label_nodes($$hash{$key}, $nodes, $level + 1);
  }
}


sub count_levels {
  my($self, $hash, $current, $count) = @_;

  foreach my $key (keys %$hash) {
    $self->count_levels($$hash{$key}, $current + 1, $count);
  }
  $$count = $current if ($current > $$count);
}

sub translate_after_value {
  my($self, $val) = @_;

  if ($val ne '') {
    my $arr = $self->create_array($val);
    $val = '';
    if ($self->require_dependencies()) {
        foreach my $entry (@$arr) {
            if ($self->get_apply_project()) {
                my $nmod = $self->get_name_modifier();
                if (defined $nmod) {
                    $nmod =~ s/\*/$entry/g;
                    $entry = $nmod;
                }
            }

#            my $entry_text = '"' . ($self->dependency_is_filename() ?
#                           $self->project_file_name($entry) : $entry) . '"';
            my $entry_text = '"' . $entry . '"';


            if (index ($val, $entry_text) == -1) {
                $val .= ",\n      " if ($val ne '');
                $val .= $entry_text ;
            }
        }
        $val =~ s/\s+$//;
    }
  }
  return $val;
}

sub fill_value {
  my($self, $name) = @_;
  my $value;

  if ($name eq 'after_list') {
      $value = $self->get_assignment ('after');
      return $self->translate_after_value ($value);
  }
  elsif ($name eq 'inheritance_nodes') {
    ## Get the nodes with numeric labels for the level
    my @nodes;
    $self->label_nodes($self->get_inheritance_tree(), \@nodes, 0);

    ## Push each node onto the value array
    $value = [];
    for(my $i = 0; $i <= $#nodes; ++$i) {
      my $file = $nodes[$i]->[1];
      my $dir  = $self->mpc_dirname($file);
      my $base = $self->mpc_basename($file);

      ## Relative paths do not work at all in a web browser
      $file = $base if ($dir eq '.');

      my $path = ($base eq $file ? $self->getcwd() . '/' : '');
      my $name;

      if ($i == 0) {
        ## If this is the first node, then replace the base filename
        ## with the actual project name.
        $name = $self->project_name();
      }
      else {
        ## This is a base project, so we use the basename and
        ## remove the file extension.
        $name = $base;
        $name =~ s/\.[^\.]+$//;
      }

      ## Create the div and a tags.
      push(@$value, '"' . $name.'" : "' . $path . $file .'"');
    }
  }

  return $value;
}


sub project_file_extension {
  #my $self = shift;
  return '.json';
}


1;
