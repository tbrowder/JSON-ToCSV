unit module JSON::ToCSV;

use JSON::Fast;

#export &json-to-csv, &flatten-json;

sub escape-csv(Str $v --> Str) {
    my $s = $v;
    # this ChatGPT line throws:
    #    $s ~~ s:g/"/""/;
    $s ~~ s:g/\"/""/;
    # this ChatGPT line throws:
    #    return $s ~~ /[",\n]/ ?? "\"$s\"" !! $s;
    if $s ~~ /[\"\,\n]/ {
        $s = "\"$s\"";
    }
    $s
}

sub flatten-json(
    $data,
    :$dot = True,
    :$with-types = True,
    :$prefix = '',
    --> Hash
) is export {
    my %flat;

    given $data {
        when Hash {
            for $data.kv -> $k, $v {
                my $key = $prefix eq ''
                    ?? $k
                    !! $dot
                        ?? "$prefix.$k"
                        !! "$prefix" ~ '_' ~ $k;
                %flat.append: flatten-json($v, :$dot, :$with-types, :prefix($key));
            }
        }
        when Array {
            for $data.kv -> $i, $v {
                my $key = $prefix ~ ($dot ?? ".{$i}" !! "_$i");
                %flat.append: flatten-json($v, :$dot, :$with-types, :prefix($key));
            }
        }
        default {
            my $type = $with-types ?? ':' ~ $data.^name.lc !! '';
            %flat{$prefix ~ $type} = $data;
        }
    }

    return %flat;
}

sub json-to-csv(
    $json-data,
    :$dot = True,
    :$with-types = True,
    :@filter-keys = (),
    :$escape = True,
    --> Str
) is export {

    die "Input must be an array of hashes" unless $json-data ~~ Array;

    my @flat = $json-data.map({
        flatten-json($_, :$dot, :$with-types);
    });

    my @headers = @flat.map(*.keys).flat.unique.sort;
    @headers = @headers.grep({ @filter-keys.grep(* eq $_).elems }) if @filter-keys.elems;

    my @lines;
    @lines.push: @headers.join(',');

    for @flat -> %row {
        my @values = @headers.map({
            my $val = %row{$_} // '';
            $escape ?? escape-csv($val.Str) !! $val.Str
        });
        @lines.push: @values.join(',');
    }

    return @lines.join("\n");
}

