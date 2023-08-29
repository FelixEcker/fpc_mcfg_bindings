
unit mcfg;
interface

uses
  ctypes;

{
  Automatically converted by H2Pas 1.0.0 from mcfg/src/mcfg.h
  The following command line parameters were used:
    -C
    -D
    -l
    mcfg
    mcfg/src/mcfg.h
    -o
    src/mcfg.pas
}

{$LINKLIB c}
  const
    External_library='mcfg'; {Setup as you need}

{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}

  {
   * mcfg.h ; author: Marie Eckert
   *
   * mcfg parser and utilities.
   * This header and its source file originally stem from mariebuild and have
   * been partially rewritten to be used as a general configuration file.
   *
   * Copyright (c) 2023, Marie Eckert
   * Licensed under the BSD 3-Clause License
   * <https://github.com/FelixEcker/mcfg/blob/master/LICENSE>
    }
{$ifndef MCFG_H}
{$define MCFG_H}  

  const
    MCFG_OK = 0;    
    MCFG_ERR_UNKNOWN = $00000001;    
    MCFG_PERR_MASK = $10000000;    
    MCFG_PERR_MISSING_REQUIRED = $10000001;    
    MCFG_PERR_DUPLICATE_SECTION = $10000002;    
    MCFG_PERR_DUPLICATE_SECTOR = $10000003;    
    MCFG_PERR_DUPLICATE_FIELD = $10000004;    
    MCFG_PERR_INVALID_IDENTIFIER = $10000005;    
    MCFG_PERR_INVALID_SYNTAX = $10000006;    
    MCFG_PERR_INVALID_FTYPE = $10000007;    
    MCFG_PERR_INVALID_STYPE = $10000008;    
    MCFG_ERR_MASK_ERRNO = $f0000000;    
  { Used to set the type of a field. If the type ever is FT_UNKOWN an error
   * should be thrown
    }

  type
    Pmcfg_file  = ^mcfg_file;
    Pmcfg_section  = ^mcfg_section;
    Pmcfg_sector  = ^mcfg_sector;
    Pmcfg_field = ^mcfg_field;
    mcfg_ftype = (FT_STRING,FT_LIST,FT_UNKNOWN);
  { Used to set the type of a sector. If the type ever is ST_UNKNOWN an error
   * should be thrown
    }

    mcfg_stype = (ST_FIELDS,ST_LINES,ST_UNKNOWN);
  { Holds a field specified within a config section.
    }

    mcfg_field = record
        _type : mcfg_ftype;
        name : PChar;
        value : PChar;
      end;
  { Defines a section of a sector within a mcfg file
    }

    mcfg_section = record
        _type : mcfg_stype;
        name : PChar;
        section_type : cint;
        lines : PChar;
        field_count : cint;
        fields : ^mcfg_field;
      end;
  { Defines a sector of a mcfg file
    }

    mcfg_sector = record
        name : PChar;
        section_count : cint;
        sections : ^mcfg_section;
      end;
  { C-Representation of a mcfg file
    }

    mcfg_file = record
        path : Pchar;
        line : cint;
        sector_count : cint;
        sectors : ^mcfg_sector;
      end;
  { Completely and recursively free a mcfg_file struct
    }

  procedure free_mcfg_file(_file:Pmcfg_file);cdecl;external External_library name 'free_mcfg_file';

  { Parsing Functions  }
  { NOTE: After using any of these registering functions, pointers to members
   *       of the targeted mcfg-file need to be reassigned since registering
   *       breaks the old pointers.
    }
  { Register a sector into the provided mcfg_file struct
   *
   * Parameters:
   *   _file: The file to which the sector is to be added
   *   name: The name of the sector to be added
   *
   * Returns:
   *  One of the declared MCFG return codes; MCFG_OK if everything was successful
    }
  function register_sector(_file:Pmcfg_file; name:pcchar):cint;cdecl;external External_library name 'register_sector';

  { Register a section into the provided mcfg_sector struct
   *
   * Parameters:
   *   sector: The sector to which the section is to be added to
   *   type  : The type of the section to be added
   *   name  : The name of the section to be added
   *
   * Returns:
   *  One of the declared MCFG return codes; MCFG_OK if everything was successful
    }
  function register_section(sector:Pmcfg_sector; _type:mcfg_stype; name:pcchar):cint;cdecl;external External_library name 'register_section';

  { Register a field into the provided mcfg_section struct
   *
   * Parameters:
   *   section: The section to which the field is to be added to
   *   type   : The type of the field which is to be added
   *   name   : The name of the section which is to be added
   *   value  : The value of the section which is to be added
   *
   * Returns:
   *  One of the declared MCFG return codes; MCFG_OK if everything was successful
    }
  function register_field(section:Pmcfg_section; _type:mcfg_ftype; name:pcchar; value:pcchar):cint;cdecl;external External_library name 'register_field';

  { Parses the provided line for the provided mcfg_file struct
    }
  function parse_line(_file:Pmcfg_file; line:pcchar):cint;cdecl;external External_library name 'parse_line';

  { Parses the file under the path in file->path line by line,
   * will return MCFG_OK if there were no errors.
    }
  function parse_file(_file:Pmcfg_file):cint32;cdecl;external External_library name 'parse_file';

  { Navigation Functions  }
  function find_sector(_file:Pmcfg_file; sector_name:pcchar):Pmcfg_sector;cdecl;external External_library name 'find_sector';

  function find_section(_file:Pmcfg_file; path:pcchar):Pmcfg_section;cdecl;external External_library name 'find_section';

  function find_field(_file:Pmcfg_file; path:pcchar):Pmcfg_field;cdecl;external External_library name 'find_field';

  { Formats the contents of a list field.
   *
   * Parameters:
   *   file   : The file structure from which to take the files field
   *   field  : The field to be formatted
   *   context: Path of the section which is to be used for local fields
   *   in     : The string in which the files field is embedded
   *   in_offs: Offset for the input string
   *   len    : Length of the embed including $()
   *
   * Returns:
   *   A dynamically allocated string with the formatted result.
   *   The caller is responsible for freeing the memory.
   *
   * Notes:
   *   - The list is inserted with space-seperation. Chars which come immediatly
   *     after or before the embed are post- or prefixed to every file.
   *
   * Example:
   *  files = 'file1:file2'
   *  format_files_field(file, ".config/mariebuild", "out/$(files).o", offs, len)
   *  = out/file1.o out/file2.o
    }
  function format_list_field(_file:mcfg_file; field:mcfg_field; context:pcchar; _in:pcchar; in_offs:cint; 
             len:cint):Pcchar;cdecl;external External_library name 'format_list_field';

  {
   * Resolve the field values in the given input string by replacing field-
   * references with their corresponding values.
   *
   * Parameters:
   *   file       : The build file structure containing the sectors,
   *              | sections, and fields.
   *   in         : The input string to be resolved.
   *   context    : The context in which the field references should be resolved.
   *              | It specifies the path prefix for the field lookups.
   *   leave_lists: If set to 1 lists are not formatted, any other value will
   *                cause lists to be formatted
   *
   * Returns:
   *   A dynamically allocated string containing the resolved input string.
   *   The caller is responsible for freeing the memory allocated for the
   *   resolved string.
   *
   * Notes:
   *   - The input string may contain field references in the format
   *     "$(path/to/field)".
   *   - Field references will be replaced with their corresponding values
   *     found in the mcfg file.
   *   - Field references can include the context prefix to specify the
   *     location of the field lookup.
   *   - If a field reference cannot be resolved or a field value is NULL,
   *     it will not be replaced in the output string.
   *   - The resolved string is returned as a dynamically allocated string.
   *     The caller must free the memory allocated for the resolved string
   *     when it's no longer needed.
    }
  function resolve_fields(_file:mcfg_file; _in:pcchar; context:pcchar; leave_lists:cint):Pcchar;cdecl;external External_library name 'resolve_fields';

{$endif}

implementation


end.
