package Parse::RecDescent::Topiary;
use strict;

BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    $VERSION     = '0.01';
    @ISA         = qw(Exporter);
    @EXPORT      = qw(topiary);
    @EXPORT_OK   = qw(topiary);
    %EXPORT_TAGS = (all => [qw/topiary/]);
}


=head1 NAME

Parse::RecDescent::Topiary - tree surgery for Parse::RecDescent autotrees

=head1 SYNOPSIS

  use Parse::RecDescent::Topiary;
  my $parser = Parse::RecDescent->new($grammar);
  ...
  my $tree = topiary(
  		tree => $parser->mainrule,
		namespace => 'MyModule::Foo',
		ucfirst => 1
		);

=head1 DESCRIPTION

L<Parse::RecDescent> has a mechanism for automatically generating parse trees.
What this does is to bless each resulting node into a package namespace
corresponding to the rule. This might not be desirable, for a couple of
reasons:

=over 4

=item *

You probably don't want to pollute the top-level namespace with packages,
and you probably don't want your grammar rules to be named according to CPAN
naming conventions. Also, the namespaces could collide if an application has
two different RecDescent grammars, that share some rule names.

=item *

Parse::RecDescent merely blesses the data structures. It does not call a
constructor. Parse::RecDescent::Topiary calls C<new> for each class. A base
class, l<Parse::RecDescent::Topiary::Base> is provided in the distribution,
to construct hashref style objects. The user can always supply their own -
inside out or whatever.

=back

=head2 topiary

This exported function takes a list of option / value pairs:

=over 4

=item C<tree>

Pass in the resulting autotree returned by a Parse::RecDescent object.

=item C<namespace>

Optional prefix to use for package names.

=item C<ucfirst>

Optional flag to upper case the first character of the rule when forming the
class name.

=back

=head1 BUGS

Please report bugs to http://rt.cpan.org

=head1 AUTHOR

    Ivor Williams
    CPAN ID: IVORW
     
    ivorw@cpan.org
     

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

L<Parse::RecDescent>.

=cut

use Params::Validate::Dummy qw();
use Module::Optional qw(Params::Validate :all);
use Scalar::Util qw(blessed reftype);


sub topiary {
	my %par = validate( @_, {
		tree => 1,
		namespace => {
			regex => qr/\w+(\:\:\w+)*/,
			type => SCALAR,
			default => '',
			},
		ucfirst => 0,
		} );

	my $tree = $par{tree};
	my $namespace = $par{namespace};
	my $class = blessed $tree;
	$class = ucfirst $class if $par{ucfirst};
	if ($class && $namespace) {
		$class = $namespace . '::' . $class;
	}

	my $type = reftype($tree) || '';
	my $rv;
	if ($type eq 'ARRAY') {
		my @proto = map {topiary(%par,tree => $_)} @$tree;
		if ($class) {
			$rv = $class->new(@proto);
		}
		else {
			$rv = \@proto;
		}
	}
	elsif ($type eq 'HASH') {
		my %proto = map {$_, topiary(%par, tree => $tree->{$_})} 
			keys %$tree;
		if ($class) {
			$rv = $class->new(%proto);
		}
		else {
			$rv = \%proto;
		}
	}
	else {
		$rv = $class ? $class->new($tree) : $tree;
	}
	return $rv;
}
	

1;
# The preceding line will help the module return a true value

