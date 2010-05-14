#! nqp

=begin

Regex methods and functions

=end

=begin item match
Match C<$text> against C<$regex>.  If the C<$global> flag is
given, then return an array of all non-overlapping matches.
=end item

sub match ($text, $regex, :$global?) {
    my $match := $text ~~ regex;
    if $global {
        my @matches;
        while $match {
            @matches.push($match);
            $match := $match.CURSOR.parse($text, :rule($regex), :c($match.to));
        }
        @matches;
    }
    else {
        $match;
    }
}


=begin item subst
Substitute an match of C<$regex> in C<$text> with C<$replacement>,
returning the substituted string.  If C<$global> is given, then
perform the replacement on all matches of C<$text>.
=end item

sub subst ($text, $regex, $repl, :$global?) {
    my @matches := $global ?? match($text, $regex, :global)
                           !! [ $text ~~ $regex ];
    my $is_code := pir::isa($repl, 'Sub');
    my $offset  := 0;
    my @pieces;

    for @matches -> $match {
        my $repl_string := $is_code ?? $repl($match) !! $repl;
        @pieces.push( pir::substr($text, $offset, $match.from - $offset))
            if $match.from > $offset;
        @pieces.push($repl_string);
        $offset := $match.to;
    }

    my $chars := pir::length($text);
    @pieces.push(pir::substr($text, $offset, $chars))
        if $chars > $offset;

    @pieces.join('');
}

# vim: ft=perl6