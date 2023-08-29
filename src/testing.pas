program testing;

uses sysutils, ctypes, mcfg;

{$H+}

var
  path: Pchar;
  fl: mcfg_file; 
  res: Integer;
begin
  path := './test.mcfg';
  fl.path := path;
  res := parse_file(@fl);
  writeln(Format('%.8x', [res]));
  writeln(fl.sectors[0].sections[0].name);
end.
