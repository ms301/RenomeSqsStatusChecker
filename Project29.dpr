program Project29;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Sqs.Client in 'Sqs.Client.pas',
  Sqs.Types in 'Sqs.Types.pas';

procedure test;
var
  lCli: TsqsClient;
begin
  // need vpn access
  lCli := TsqsClient.Create('http://192.168.78.100:8095');
  try
    lCli.Auth('status_checker_b0t', 'status_checker_b0t');
    lCli.getStatus('6599/18-07/22');
  finally
    lCli.Free;
  end;
end;

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    test;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
