# libmcfg bindings for freepascal
## Usage
Simply include the mcfg unit (`src/mcfg.pas`) within your project, make sure to
add a build of the library to your library search path (e.g. `fpc -Fl"lib/"`)

## Generation
The bindings were generated using `h2pas` from the fpc utils. The output of this
tool is not always 100% valid code.

The exact command is: `h2pas -C -D -l mcfg mcfg/src/mcfg.h -o src/mcfg.pas`

### Common Issues
* Pointer types are declared in a type block before their destination type
Example: ```pascal
type
    Pmcfg_file = ^mcfg_file;
    
{ Other code }

type
    mcfg_file = record
        {...}
    end;
```

* Variables names are freepascal keywords (e.g. `type` or `in`)
* Wrong types are used (e.g. `^cchar` instead of `PChar`)
