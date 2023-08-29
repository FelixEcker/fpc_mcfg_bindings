program testing;

uses sysutils, ctypes, mcfg;

{$H+}

procedure printstruct(fl: mcfg_file);
var
  i, j, k: Integer;
begin
  writeln('FILE');
  for i := 0 to fl.sector_count - 1 do
  begin
    writeln('  name: ', fl.sectors[i].name);
    writeln('  sections:');
    for j := 0 to fl.sectors[i].section_count - 1 do
    begin
      writeln('    name: ', fl.sectors[i].sections[j].name);
      writeln('    stype: ', fl.sectors[i].sections[j]._type);
      if (fl.sectors[i].sections[j]._type = ST_LINES) then
      begin
        writeln(fl.sectors[i].sections[j].lines);
        continue;
      end;

      for k := 0 to fl.sectors[i].sections[j].field_count - 1 do
      begin
        writeln('      ftype: ', fl.sectors[i].sections[j].fields[k]._type);
        writeln('      name: ', fl.sectors[i].sections[j].fields[k].name);
        writeln('      value: ', fl.sectors[i].sections[j].fields[k].value);
      end;
    end;
  end;
end;

var
  path: Pchar;
  fl: mcfg_file; 
  res: Integer;
begin
  path := './test.mcfg';
  fl.path := path;
  res := parse_file(@fl);
  writeln(Format('%.8x', [res]));
  printstruct(fl);
  free_mcfg_file(@fl);
end.
