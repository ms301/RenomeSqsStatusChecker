unit Sqs.Types;

interface

uses
  System.JSON.Serializers;

type
  TsqsAccount = record
  private
    FName: string;
    FCrefToken: string;
  public
    property Name: string read FName write FName;
    property CrefToken: string read FCrefToken write FCrefToken;
  end;

  TsqsSearchResult = record
  private
    [JsonName('Number')]
    FNumber: string;
    [JsonName('Service')]
    FService: string;
    [JsonName('Client')]
    [JsonIgnore]
    FClient: string;
    [JsonName('Status')]
    FStatus: string;
    [JsonName('LastUpdate')]
    FLastUpdate: string;
  public
    property Number: string read FNumber write FNumber;
    property Service: string read FService write FService;
    property Client: string read FClient write FClient;
    property Status: string read FStatus write FStatus;
    property LastUpdate: string read FLastUpdate write FLastUpdate;
  end;

implementation

end.
