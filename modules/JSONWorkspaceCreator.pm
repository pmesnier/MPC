package JSONWorkspaceCreator;

# ************************************************************
# Description   : An html workspace creator
# Author        : Justin Michel
# Create Date   : 8/25/2003
# ************************************************************

# ************************************************************
# Pragmas
# ************************************************************

use strict;

use JSONProjectCreator;
use WorkspaceCreator;

use vars qw(@ISA);
@ISA = qw(WorkspaceCreator);

# ************************************************************
# Subroutine Section
# ************************************************************

sub workspace_file_extension {
  #my $self = shift;
  return '_workspace.json';
}


sub pre_workspace {
  my($self, $fh) = @_;
  my $crlf = $self->crlf();

  ## Next, goes the workspace comment
  $self->print_workspace_comment($fh,
            "// MPC Command:", $crlf,
            "//", $self->create_command_line_string($0, @ARGV), $crlf);
  print $fh "{" . $crlf;
}

sub write_comps {
  my($self, $fh, $creator) = @_;
  my $crlf = $self->crlf();

  ## Start the table for all of the projects
  print $fh "  \"projects\" : {$crlf";

  ## Sort the projects in build order instead of alphabetical order
  my $project_info = $self->get_project_info();
  my @projects = $self->sort_dependencies($self->get_projects(), 0);
  for (my $i = 0; $i <= $#projects; $i++) {
      my $project = $projects[$i];
      print $fh "    \"",
           $$project_info{$project}->[ProjectCreator::PROJECT_NAME],
           "\" : \"$project\"";
      if ($i < $#projects) {
          print $fh ',';
      }
      print $fh $crlf;
  }
  print $fh "  }" . $crlf;
}


sub post_workspace {
  my($self, $fh) = @_;
  print $fh "}" . $self->crlf();
}


1;
