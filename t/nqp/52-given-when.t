#! nqp

say('1..8');

given 42 {
    say('ok 1 - code inside given');
    print('not ') if $_ != 42;
    say('ok 2 - $_ is 42');
}

class Foo { }
class Bar { }

my $_ := Foo.new;
say('ok 3 - postfix when') when Foo;

given Foo.new {
    say('ok 4 - code before match run');
    when Bar {
        say('not ok 5 - matches Foo');
    }
    when Foo {
        say('ok 5 - matches Foo');
    }
    print('not ');
}
say('ok 6 - code after match not run');

given Foo.new {
    when Bar {
        say('# Matched Bar?');
    }
    default {
        say('ok 7 - default matches');
    }
    print('not ');
}
print('ok 8 - code after default not run');
