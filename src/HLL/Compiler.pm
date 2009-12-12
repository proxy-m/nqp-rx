INIT {
    pir::load_bytecode('PCT/HLLCompiler.pbc');
}


class HLL::Compiler is PCT::HLLCompiler {

    has $!language;

    INIT {
        HLL::Compiler.language('parrot');
    }
    
    my sub value_type($value) {
        pir::isa($value, 'NameSpace') 
        ?? 'namespace'
        !! (pir::isa($value, 'Sub') ?? 'sub' !! 'var')
    }
        
    method get_exports($module, :$tagset, *@symbols) {
        # convert a module name to something hash-like, if needed
        if (!pir::does($module, 'hash')) {
            $module := self.get_module($module);
        }

        $tagset := $tagset // (@symbols ?? 'ALL' !! 'DEFAULT');
        my %exports;
        my %source := $module{'EXPORT'}{~$tagset};
        if !pir::defined(%source) {
            %source := $tagset eq 'ALL' ?? $module !! {};
        }
        if @symbols {
            for @symbols {
                my $value := %source{~$_};
                %exports{value_type($value)}{$_} := $value;
            }
        }
        else {
            for %source {
                my $value := $_.value;
                %exports{value_type($value)}{$_.key} := $value;
            }
        }
        %exports;
    }

    method get_module($name) {
        my @name := self.parse_name($name);
        @name.unshift(pir::downcase($!language));
        pir::get_root_namespace__PP(@name);
    }

    method language($name?) {
        if $name {
            $!language := $name;
            pir::compreg__0sP($name, self);
        }
        $!language;
    }

    method load_module($name) {
        my $base := pir::join('/', self.parse_name($name));
        my $loaded := 0;
        try { pir::load_bytecode("$base.pbc"); $loaded := 1 };
        unless $loaded { pir::load_bytecode("$base.pir"); $loaded := 1 }
        self.get_module($name);
    }

    method import($target, %exports) {
        for %exports {
            my $type := $_.key;
            my %items := $_.value;
            if pir::can(self, "import_$type") {
                for %items { self."import_$type"($target, $_.key, $_.value); }
            }
            elsif pir::can($target, "add_$type") {
                for %items { $target."add_$type"($_.key, $_.value); }
            }
            else {
                for %items { $target{~$_.key} := $_.value; }
            }
        }
    }

}