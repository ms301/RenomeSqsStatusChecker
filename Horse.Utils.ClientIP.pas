unit Horse.Utils.ClientIP;

interface

uses
  Horse.HTTP,
{$IFDEF FPC }
  SysUtils;
{$ELSE}
System.SysUtils;
{$ENDIF}
function ClientIP(const Req: THorseRequest): string;

implementation

function ClientIP(const Req: THorseRequest): string;
var
  LIP: string;
begin
  Result := EmptyStr;

  if not Trim(Req.Headers.AsString('HTTP_CLIENT_IP', False)).IsEmpty then
    Exit(Trim(Req.Headers['HTTP_CLIENT_IP']));

  for LIP in Trim(Req.Headers.AsString('HTTP_X_FORWARDED_FOR', False)).Split([',']) do
    if not Trim(LIP).IsEmpty then
      Exit(Trim(LIP));

  for LIP in Trim(Req.Headers.AsString('x-forwarded-for', False)).Split([',']) do
    if not Trim(LIP).IsEmpty then
      Exit(Trim(LIP));

  if not Trim(Req.Headers.AsString('HTTP_X_FORWARDED', False)).IsEmpty then
    Exit(Trim(Req.Headers['HTTP_X_FORWARDED']));

  if not Trim(Req.Headers.AsString('HTTP_X_CLUSTER_CLIENT_IP', False)).IsEmpty then
    Exit(Trim(Req.Headers.AsString('HTTP_X_CLUSTER_CLIENT_IP', False)));

  if not Trim(Req.Headers.AsString('HTTP_FORWARDED_FOR', False)).IsEmpty then
    Exit(Trim(Req.Headers['HTTP_FORWARDED_FOR']));

  if not Trim(Req.Headers.AsString('HTTP_FORWARDED', False)).IsEmpty then
    Exit(Trim(Req.Headers['HTTP_FORWARDED']));

  if not Trim(Req.Headers.AsString('REMOTE_ADDR', False)).IsEmpty then
    Exit(Trim(Req.Headers['REMOTE_ADDR']));

{$IF DEFINED(FPC)}
  if not Trim(THorseHackRequest(Req).RawWebRequest.RemoteAddress).IsEmpty then
    Exit(Trim(THorseHackRequest(Req).RawWebRequest.RemoteAddress));
{$ELSE}
  if not Trim((Req).RawWebRequest.RemoteIP).IsEmpty then
    Exit(Trim((Req).RawWebRequest.RemoteIP));
{$ENDIF}
  if not Trim((Req).RawWebRequest.RemoteAddr).IsEmpty then
    Exit(Trim((Req).RawWebRequest.RemoteAddr));

  if not Trim((Req).RawWebRequest.RemoteHost).IsEmpty then
    Exit(Trim((Req).RawWebRequest.RemoteHost));
end;

end.
