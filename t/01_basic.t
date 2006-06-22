# -*- perl -*-

# t/01_basic.t - basic module functionality test

use Test::More tests => 7;
use Parse::RecDescent;

#01
BEGIN { use_ok( 'Parse::RecDescent::Topiary' ); }

# Example taken from parsetree.pl demo in Parse::RecDescent distribution

my $grammar1 = <<'END';

	<autotree>
	
	expr	:	disj
	
	disj	:	conj 'or' disj | conj

	conj	:	unary 'and' conj | unary

	unary	:	'not' atom
		|	'(' expr ')'
		|	atom

	atom	:	/[a-z]+/i

END

my $parser1 = Parse::RecDescent->new($grammar1);

#02
isa_ok($parser1, 'Parse::RecDescent');

my $tree1 = $parser1->expr('a and b and not c');

#03
isa_ok($tree1, 'expr');

use Parse::RecDescent::Topiary::Base;
@Foo::Bar::expr::ISA = qw(Parse::RecDescent::Topiary::Base);
@Foo::Bar::disj::ISA = qw(Parse::RecDescent::Topiary::Base);
@Foo::Bar::conj::ISA = qw(Parse::RecDescent::Topiary::Base);
@Foo::Bar::unary::ISA = qw(Parse::RecDescent::Topiary::Base);
@Foo::Bar::atom::ISA = qw(Parse::RecDescent::Topiary::Base);

my $tree2 = topiary(
		tree => $tree1,
		namespace => 'Foo::Bar'
		);

#04
isa_ok($tree2, 'Foo::Bar::expr');

@Foo::Bar::Expr::ISA = qw(Parse::RecDescent::Topiary::Base);
@Foo::Bar::Disj::ISA = qw(Parse::RecDescent::Topiary::Base);
@Foo::Bar::Conj::ISA = qw(Parse::RecDescent::Topiary::Base);
@Foo::Bar::Unary::ISA = qw(Parse::RecDescent::Topiary::Base);
@Foo::Bar::Atom::ISA = qw(Parse::RecDescent::Topiary::Base);

$tree2 = topiary(
		tree => $tree1,
		namespace => 'Foo::Bar',
		ucfirst => 1,
		args => 'wombat',
		);

#05
isa_ok($tree2, 'Foo::Bar::Expr');

#06
is($tree2->{test},'OK',"Node was constructed properly");

#07
is($tree2->{args},'wombat',"Args passed in properly");

package Foo::Bar::Expr;

sub new {
	my $pkg = shift;

	my $self = $pkg->SUPER::new(@_);
	$self->{test} = 'OK';
	$self;
}
