class ClientHandler extends Info;

var PlayerController Client;
var AreYouVIP MasterHandler;
var string NewClientName, OldClientName;

function PostBeginPlay()
{
  SetTimer(0.1, false);
}

function Timer() {
  if (Client == none)
  {
  Destroy();
  return;
  }

  // Check for spectators.. whoever joins as spec joins with no name aparently :/
  if (Client.PlayerReplicationInfo != none && Client.PlayerReplicationInfo.PlayerName != OldClientName)
  {
  NewClientName = ApplySpecialPlayerNames();
  OldClientName = NewClientName;
  Client.PlayerReplicationInfo.PlayerName = OldClientName;
  Client.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
  }
}

// Apply New Name if player found in Config
final function string ApplySpecialPlayerNames()
{
  local int j, iCutName;
  local string PN, PID, NewName, PName, ConfigPID, Color, sVIP;
  local bool isVIP;

  if (NetConnection(Client.Player) == none) Destroy();

  PN = Client.PlayerReplicationInfo.PlayerName;
  PID = Client.GetPlayerIDHash();
  if (PN != "WebAdmin" || Client.PlayerReplicationInfo.PlayerID != 0)
  {
  if(MasterHandler.bDebug) MutLog("-----|| Debug - Checking Player: " $PN$ " | ID: " $PID$ " ||-----");

  if(FindSteamID(j, PID))
  {
    PName = MasterHandler.SpecialPlayers[j].PName;
    ConfigPID = MasterHandler.SpecialPlayers[j].SteamID;
    Color = MasterHandler.SpecialPlayers[j].Color;
    isVIP = MasterHandler.SpecialPlayers[j].isVIP;
    sVIP = MasterHandler.SpecialPlayers[j].sVIP;
    iCutName = MasterHandler.iCutName;

    if(MasterHandler.bDebug) MutLog("-----|| Debug - Found Player In Config: " $PName$ " | " $ConfigPID$ " ||-----");

    // In case CntryTags mut is installed
    // Cut the first X count letters which resemble the tag
    // This is only done so the tag isn't duplicated
    // Your CntryTag will stay regardless :)
    if (iCutName > 0) PN = Right(PN, Len(PN) - iCutName);

    NewName $= Color;
    NewName $= PN;

    if (isVIP)
    {
    if ( sVIP != "" ) NewName $= sVIP;
    else NewName $= MasterHandler.sVIPText;
    }

    if(MasterHandler.bDebug) MutLog("-----|| Debug - New Player Name: " $NewName$ " ||-----");
    MasterHandler.SetColor(NewName);
    return NewName;
  }
  else return PN;
  }
}

// Matches SteamIDs for each player
final function bool FindSteamID(out int i, string ID){

  for(i=0; i<MasterHandler.SpecialPlayers.Length; i++)
  {
  if (ID == MasterHandler.SpecialPlayers[i].SteamID) return true;
  }
  return false;
}

function MutLog(string s)
{
  log(s, 'AreYouVIP');
}