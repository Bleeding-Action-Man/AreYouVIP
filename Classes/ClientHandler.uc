class ClientHandler extends Info;

var PlayerController Client;
var KFAreYouVIP MasterHandler;
var string NewClientName, OldClientName;

function PostBeginPlay() {
	SetTimer(0.1, false);
}

function Timer() {
	if (Client == none) {
		Destroy();
		return;
	}
	if (Client.PlayerReplicationInfo != none && Client.PlayerReplicationInfo.PlayerName != OldClientName) {
		NewClientName = ApplySpecialPlayerNames();
    OldClientName = NewClientName;
		Client.PlayerReplicationInfo.PlayerName = OldClientName;
		Client.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
	}
}

// Apply New Name if player found in Config
final function string ApplySpecialPlayerNames()
{
  local int j;
  local string PN, PID, NewName;

  local string PName;
  local string ConfigPID;
  local string Color;
  local bool   isVIP;
  local string sVIP;
  local bool   isDonator;
  local string sDonator;
  local bool   isGodLike;
  local string sGodLike;

  if (NetConnection(Client.Player) == none) {
	Destroy();
    }
  PN = Client.PlayerReplicationInfo.PlayerName;
  PID = Client.GetPlayerIDHash();
  if (PN != "WebAdmin" || Client.PlayerReplicationInfo.PlayerID != 0){
      if(MasterHandler.DEBUG){
          MutLog("-----|| DEBUG - Checking Player: " $PN$ " | ID: " $PID$ " ||-----");
      }
    if(FindSteamID(j, PID)){
        PName = MasterHandler.SpecialPlayers[j].PName;
        ConfigPID = MasterHandler.SpecialPlayers[j].SteamID;
        Color = MasterHandler.SpecialPlayers[j].Color;
        isVIP = MasterHandler.SpecialPlayers[j].isVIP;
        sVIP = MasterHandler.SpecialPlayers[j].sVIP;
        isDonator = MasterHandler.SpecialPlayers[j].isDonator;
        sDonator = MasterHandler.SpecialPlayers[j].sDonator;
        isGodLike = MasterHandler.SpecialPlayers[j].isGodLike;
        sGodLike = MasterHandler.SpecialPlayers[j].sGodLike;
        if(MasterHandler.DEBUG){
          MutLog("-----|| DEBUG - Found Player In Config: " $PName$ " | " $ConfigPID$ " ||-----");
        }
        if (Left(PN, 1) == "["){
            // Removing [XXX] From CountryTags
            PN = Right(PN, Len(PN) - 6);
        }
        NewName $= Color;
        NewName $= PN;
        if (isVIP){
            if ( sVIP != "" ){
                NewName $= sVIP;
            } else{
              NewName $= MasterHandler.VIP;
            }
        }
        if (isDonator){
            if ( sDonator != "" ){
                NewName $= sDonator;
            } else{
              NewName $= MasterHandler.Donator;
            }
        }
        if (isGodLike){
            if ( sGodLike != "" ){
                NewName $= sGodLike;
            } else{
              NewName $= MasterHandler.Godlike;
            }
        }
        if(MasterHandler.DEBUG){
          MutLog("-----|| DEBUG - New Player Name: " $NewName$ " ||-----");
        }
        MasterHandler.SetColor(NewName);
    }
    else{
      return PN;
    }
  }
}

// Matches SteamIDs for each player
final function bool FindSteamID(out int i, string ID){

    for(i=0; i<MasterHandler.SpecialPlayers.Length; i++){
        if (ID == MasterHandler.SpecialPlayers[i].SteamID){
            return true;
        }
    }
    return false;
}

simulated function MutLog(string s)
{
  log(s, 'AreYouVIP');
}