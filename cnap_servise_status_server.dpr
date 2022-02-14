program cnap_servise_status_server;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  Horse,
  Horse.Logger, // It's necessary to use the unit
  Horse.Logger.Provider.LogFile, // It's necessary to use the unit
  Horse.Logger.Provider.Console, // It's necessary to use the unit
  System.JSON.Serializers,
  System.SysUtils,
  Sqs.Client in 'Sqs.Client.pas',
  Sqs.Types in 'Sqs.Types.pas', System.JSON.Types;

type
  TsqsResponse<T> = class
  private
    [JsonName('Ok')]
    FOk: Boolean;
    [JsonName('Description')]
    FDescription: string;
    [JsonName('ErrorCode')]
    FErrorCode: Integer;
    [JsonName('Data')]
    FData: T;
  public
    constructor Create;
    property Ok: Boolean read FOk write FOk;
    property ErrorCode: Integer read FErrorCode write FErrorCode;
    property Description: string read FDescription write FDescription;
    property Data: T read FData write FData;
  end;

procedure test;
const
  LOG_FMT = '${request_clientip} [${time}] ${response_status}' +
    ' "${request_method} ${request_path_info} ${request_query} ${request_version}"' +
    ' ${response_status} ${response_content_length} ${request_user_agent}';
var
  lCli: TsqsClient;
  lSerializer: TJsonSerializer;
  LLogFileConfig: THorseLoggerLogFileConfig;
  LLogConsoleConfig: THorseLoggerConsoleConfig;
begin
  LLogFileConfig := THorseLoggerLogFileConfig.New.SetLogFormat(LOG_FMT).SetDir('.\Log');
  LLogConsoleConfig := THorseLoggerConsoleConfig.New.SetLogFormat(LOG_FMT);
  // Here you will define the provider that will be used.
  THorseLoggerManager.RegisterProvider(THorseLoggerProviderLogFile.New(LLogFileConfig));
  THorseLoggerManager.RegisterProvider(THorseLoggerProviderConsole.New(LLogConsoleConfig));
  // It's necessary to add the middleware in the Horse:
  THorse.Use(THorseLoggerManager.HorseCallback);
  // need vpn access
  lCli := TsqsClient.Create('http://192.168.78.100:8095');
  lSerializer := TJsonSerializer.Create;
  try

    lSerializer.Formatting := TJsonFormatting.Indented;
    lCli.Auth('status_checker_b0t', 'status_checker_b0t');
    THorse.Get('/api/check',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      var
        lCaseNumber: string;
        LResult: string;
        lReturn: TsqsResponse<TsqsSearchResult>;
      begin
        lReturn := TsqsResponse<TsqsSearchResult>.Create;
        try
          try
            lCaseNumber := Req.Query.AsString('case_number'); // 6599/18-07/22
            lReturn.FData := lCli.getStatus(lCaseNumber);
            if lReturn.Data.Number.IsEmpty then
            begin
              lReturn.Ok := False;
              lReturn.Description := 'Unknown case_number.';
              lReturn.ErrorCode := 404;
            end;
          except
            on E: Exception do
            begin
              lReturn.Ok := False;
              lReturn.Description := E.Message;
              lReturn.ErrorCode := 500;
            end;
          end;
          LResult := lSerializer.Serialize < TsqsResponse < TsqsSearchResult >> (lReturn);
          Res.Status(lReturn.ErrorCode).Send(LResult);
        finally
          lReturn.Free;
        end;
      end);
    THorse.Get('/api/reauth',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      var
        lAuth: TsqsAccount;
      begin
        lAuth := lCli.Auth('status_checker_b0t', 'status_checker_b0t');
        Res.Send(lAuth.Name);
      end);
    THorse.Listen(9000);
  finally
    lCli.Free;
    lSerializer.Free;
  end;
end;

{ TsqsResponse<T> }

constructor TsqsResponse<T>.Create;
begin
  FOk := True;
  FDescription := '';
  FErrorCode := 200;
  FData := Default (T);
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
