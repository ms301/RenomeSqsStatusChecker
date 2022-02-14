unit Sqs.Client;

interface

uses
  Sqs.Types,
  ParsingTools,
  CloudAPI.Client.Sync;

type
  TsqsClient = class
  private
    FCloud: TCloudApiClient;
    FAccount: TsqsAccount;
  public
  public
    constructor Create(const AUrl: string);
    destructor Destroy; override;
    function Auth(const AUsername, APassword: string): TsqsAccount;
    function getStatus(const ARegNumber: string): TsqsSearchResult;
    property Account: TsqsAccount read FAccount write FAccount;
  end;

implementation

uses
  System.SysUtils,
  CloudAPI.Request, CloudAPI.Response, CloudAPI.Parameter, CloudAPI.Types;

{ TsqsClient }

function TsqsClient.Auth(const AUsername, APassword: string): TsqsAccount;
var
  lReq: IcaRequest;
  lRes: IcaResponseBase;
  AData: string;
  Pars: IParsTools;
begin
  lRes := FCloud.Execute(nil);
  AData := lRes.HttpResponse.ContentAsString();
  AData := ParsingTool(AData).First('<input type="hidden" name="_token" value="', '">');
  lReq := TcaRequest.Create('login', TcaMethod.POST);
  lReq.AddParam(TcaParameter.Create('_token', AData, '', TcaParameterType.GetOrPost, true));
  lReq.AddParam(TcaParameter.Create('login', AUsername, '', TcaParameterType.GetOrPost, true));
  lReq.AddParam(TcaParameter.Create('password', APassword, '', TcaParameterType.GetOrPost, true));
  lRes := FCloud.Execute(lReq);
  Pars := ParsingTool(lRes.HttpResponse.ContentAsString());
  FAccount.Name := Pars.First('<h2>', '</h2>');
  FAccount.CrefToken := Pars.First('<meta name="csrf-token" content="', '">');
  Result := FAccount;
end;

constructor TsqsClient.Create(const AUrl: string);
begin
  FCloud := TCloudApiClient.Create(AUrl);
  FCloud.DefaultParams.Add(TcaParameter.Create('Accept',
    'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    '', TcaParameterType.HttpHeader, true));

  FCloud.DefaultParams.Add(TcaParameter.Create('Accept-Language', 'ru', '', TcaParameterType.HttpHeader, true));
  FCloud.DefaultParams.Add(TcaParameter.Create('Cache-Control', 'max-age=0', '', TcaParameterType.HttpHeader, true));
  FCloud.DefaultParams.Add(TcaParameter.Create('Cache-Control', 'max-age=0', '', TcaParameterType.HttpHeader, true));

end;

destructor TsqsClient.Destroy;
begin
  FCloud.Free;
  inherited;
end;

function TsqsClient.getStatus(const ARegNumber: string): TsqsSearchResult;
var
  lReq: IcaRequest;
  lRes: IcaResponseBase;
  AData: string;
  LPars: IParsTools;
begin
  lReq := TcaRequest.Create('request', TcaMethod.POST);
  lReq.AddParam(TcaParameter.Create('_token', FAccount.CrefToken, '', TcaParameterType.GetOrPost, true));
  lReq.AddParam(TcaParameter.Create('search[case_number]', ARegNumber, '', TcaParameterType.GetOrPost, true));
  lRes := FCloud.Execute(lReq);
  AData := lRes.HttpResponse.ContentAsString();
  try
    LPars := ParsingTool(AData) //
      .FirstAnd('<tr class="request_status_working">', '</tr>') //
      .AllAnd('<td>', '</td>');
  except
    exit;
  end;

  Result.Number := LPars[0].First('>', '</a>').Trim;
  Result.Service := LPars[1].First('>', '</a>').Trim;
  Result.Client := LPars[2].First('>', '</a>').Trim;
  Result.Status := LPars[4].First('<div>', '<br>').Trim;
  Result.LastUpdate := LPars[4].First('<br>', '</div>').Trim;
end;

end.
