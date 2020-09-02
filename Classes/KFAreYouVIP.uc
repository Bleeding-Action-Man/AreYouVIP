//=============================================================================
// Check for VIP players on your server and give them VIP status
// Written by Vel-San
// for more information, feedback, questions or requests please contact
// https://steamcommunity.com/id/Vel-San/
//=============================================================================

Class KFAreYouVIP extends Mutator config(KFAreYouVIP);

var() config bool bDEBUG;
var() config string sVIP;

var bool DEBUG;
var string VIP;

// Colors from Config
struct ColorRecord
{
  var config string ColorName; // Color name, for comfort
  var config string ColorTag; // Color tag
  var config Color Color; // RGBA values
};
var() config array<ColorRecord> ColorList; // Color list

// VIP Players from Config, might change later to default values
struct VipPlayer
{
  var config string PName; // PlayerName, won't be checked
  var config string PID; // Steam ID, will always be checked
  var config Color Color; // RGBA values, custom for any player
};
var() config array<VipPlayer> PlayersAsVIP; // VIP list

function PostBeginPlay()
{
  VIP = sVIP;
  DEBUG = bDEBUG;

  // TO-DO Complete this to show player name who sees Fleshpounds and Scrakes first
  // MutLog("-----|| Changing SC & FP Controller ||-----");
  // class'ZombieFleshpound'.Default.ControllerClass = Class'FPCustomController';
  // class'ZombieScrake'.Default.ControllerClass = Class'SCCustomController';

  SetTimer( 1, false);
}

/*static function FillPlayInfo(PlayInfo PlayInfo)
{
  Super.FillPlayInfo(PlayInfo);
  PlayInfo.AddSetting("KFAreYouVIP", "sVIP", "VIP Text", 0, 0, "text");
  PlayInfo.AddSetting("KFAreYouVIP", "bDEBUG", "Debug", 0, 0, "check");
}

static function string GetDescriptionText(string SettingName)
{
	switch(SettingName)
	{
    case "sVIP":
		return "Text to show next to player names in case they are VIP";
	case "bDEBUG":
		return "Shows some Debugging messages in the LOG. Keep OFF unless you know what you are doing!";
    default:
		return Super.GetDescriptionText(SettingName);
	}
}*/

simulated function TimeStampLog(coerce string s)
{
  log("["$Level.TimeSeconds$"s]" @ s, 'AreYouVIP');
}

simulated function MutLog(string s)
{
  log(s, 'AreYouVIP');
}

function Timer()
{
  local array<string> PlayerIDs;
  local string tmpMSG;

  tmpMSG = VIP;
  SetColor(tmpMSG);
  GetPlayerIDs( tmpMSG , PlayerIDs );
}

function array<string> GetPlayerIDs(string VipText, out array<string> PlayerIDs){

  local int i;
  local string PN, PID, NewName;
  local PlayerReplicationInfo PRI;
  local PlayerController PC;

  foreach DynamicActors(class'PlayerController', PC){
    PN = PC.PlayerReplicationInfo.GetHumanReadableName();
    PID = PC.GetPlayerIDHash();
    if (PN != "WebAdmin" || PC.PlayerReplicationInfo.PlayerID != 0){
        PlayerIDs[i] = PID;
        i = i + 1;
        SetColor(VipText);
        NewName $= PN;
        NewName $= VipText;
        MutLog("-----|| DEBUG - VipText: " $VipText$ " ||-----");
        PC.PlayerReplicationInfo.SetPlayerName(NewName);
        if(DEBUG){
            MutLog("-----|| DEBUG - Player [" $i$ "] Name: " $PN$ " | ID: " $PID$ " | New Name: " $NewName$ " ||-----");
        }
    }
  }
  return PlayerIDs;
}

/////////////////////////////////////////////////////////////////////////
// BELOW SECTION IS CREDITED FOR NikC //

// Apply Color Tags To Message
function SetColor(out string Msg)
{
  local int i;
  for(i=0; i<ColorList.Length; i++)
  {
    if(ColorList[i].ColorTag!="" && InStr(Msg, ColorList[i].ColorTag)!=-1)
    {
      ReplaceText(Msg, ColorList[i].ColorTag, FormatTagToColorCode(ColorList[i].ColorTag, ColorList[i].Color));
    }
  }
}

// Format Color Tag to ColorCode
function string FormatTagToColorCode(string Tag, Color Clr)
{
  Tag=Class'GameInfo'.Static.MakeColorCode(Clr);
  Return Tag;
}

function string RemoveColor(string S)
{
  local int P;
  P=InStr(S,Chr(27));
  While(P>=0)
  {
    S=Left(S,P)$Mid(S,P+4);
    P=InStr(S,Chr(27));
  }
  Return S;
}
//////////////////////////////////////////////////////////////////////


defaultproperties
{
	// Mut Vars
  GroupName="KF-AreYouVIP"
  FriendlyName="Are You VIP - v1.0"
  Description="Checks for VIP Players on your server (Or Donators); By Vel-San"
  bAlwaysRelevant=True
  RemoteRole=ROLE_SimulatedProxy
  bNetNotify=True
}
