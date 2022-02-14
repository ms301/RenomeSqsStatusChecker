unit Sqs.Types;

interface

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
    FNumber: string;
    FService: string;
    FClient: string;
    FStatus: string;
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
