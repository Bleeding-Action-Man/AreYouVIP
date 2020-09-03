//=============================================================================
// Check for VIP players on your server and give them VIP status
// Written by Vel-San
// for more information, feedback, questions or requests please contact
// https://steamcommunity.com/id/Vel-San/
//=============================================================================

Class KFAreYouVIP extends Mutator config(KFAreYouVIP);

var() config bool bDEBUG;
var() config string sVIPText; // Default VIP Text
var() config string sDonatorText; // Default Donator Text
var() config string sGodLikeText; // Default Godlike Text


var bool DEBUG;
var string VIP;
var string Donator;
var string Godlike;

// Colors from Config
struct ColorRecord
{
  var config string ColorName; // Color name, for comfort
  var config string ColorTag; // Color tag
  var config Color Color; // RGBA values
};
var() config array<ColorRecord> ColorList; // Color list

// Players to be marked as either VIP or Donator
struct SP
{
  var config string PName; // PlayerName, won't be checked
  var config string PID; // Steam ID, will always be checked
  var config string Color; // e.g. "%w" Gives White - "%g" Gives Green, custom for any player to change their NAME Color
  var config bool   isVIP; // Mark Player as VIP
  var config string sVIP; // Give Custom VIP Text
  var config bool   isDonator; // Mark Player as Donator
  var config string sDonator; // Give custom Donator Text
  var config bool   isGodLike; // Mark Player as GodLike ( Ultra Special )
  var config string sGodLike; // Give custom Godlike Text ( Ultra Special )
};
var() config array<SP> aSpecialPlayers; // PlayersList to be declared in the Config
var array<SP> SpecialPlayers; // PlayersList to be declared in the Config


function PostBeginPlay()
{
  local int i;

  VIP = sVIPText;
  Donator = sDonatorText;
  Godlike = sGodLikeText;
  DEBUG = bDEBUG;
  for(i=0; i<aSpecialPlayers.Length; i=i++){
    SpecialPlayers[i] = aSpecialPlayers[i];
  }

  if(DEBUG){
    MutLog("-----|| DEBUG - VipText: " $VIP$ " ||-----");
    MutLog("-----|| DEBUG - Donator: " $Donator$ " ||-----");
    MutLog("-----|| DEBUG - Godlike: " $Godlike$ " ||-----");
  }

  // TO-DO Complete this to show player name who sees Fleshpounds and Scrakes first
  // MutLog("-----|| Changing SC & FP Controller ||-----");
  // class'ZombieFleshpound'.Default.ControllerClass = Class'FPCustomController';
  // class'ZombieScrake'.Default.ControllerClass = Class'SCCustomController';

  SetTimer( 1, false);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
  Super.FillPlayInfo(PlayInfo);
  PlayInfo.AddSetting("KFAreYouVIP", "sVIPText", "VIP Text", 0, 0, "text");
  PlayInfo.AddSetting("KFAreYouVIP", "sDonatorText", "Donator Text", 0, 0, "text");
  PlayInfo.AddSetting("KFAreYouVIP", "sGodLikeText", "Godlike Text", 0, 0, "text");
  PlayInfo.AddSetting("KFAreYouVIP", "bDEBUG", "Debug", 0, 0, "check");
}

static function string GetDescriptionText(string SettingName)
{
	switch(SettingName)
	{
  case "sVIPText":
		return "Text to show next to player names in case they are VIP";
  case "sDonatorText":
		return "Text to show next to player names in case they are Donators";
  case "sGodLikeText":
		return "Text to show next to player names in case they are GodLike";
	case "bDEBUG":
		return "Shows some Debugging messages in the LOG. Keep OFF unless you know what you are doing!";
  default:
		return Super.GetDescriptionText(SettingName);
	}
}

simulated function TimeStampLog(coerce string s)
{
  log("["$Level.TimeSeconds$"s]" @ s, 'AreYouVIP');
}

simulated function MutLog(string s)
{
  log(s, 'AreYouVIP');
}

// To-DO Research how to detect Login events, or player join event
// to trigger the timer
function Timer()
{
  local int i;
  local string tmpVIP, tmpDonator, tmpGodlike;
  local array<SP> tmpSpecialPlayers;

  tmpVIP = VIP;
  tmpDonator = Donator;
  tmpGodlike = Godlike;
  for(i=0; i<SpecialPlayers.Length; i=i++){
    tmpSpecialPlayers[i] = SpecialPlayers[i];
  }

  ApplySpecialPlayerNames(tmpVIP, tmpDonator, tmpGodlike, tmpSpecialPlayers);
}

// Get Player Steam HASH, Compare with Config HASH, If found, Apply New Name
function array<string> ApplySpecialPlayerNames(string VipText, string DonatorText, string GodLikeText, array<SP> ConfigPlayers)
{
  local int i, j;
  local string PN, PID, NewName;
  local array<string> PlayerIDs;
  local PlayerController PC;

  local string PName;
  local string ConfigPID;
  local string Color;
  local bool   isVIP;
  local string sVIP;
  local bool   isDonator;
  local string sDonator;
  local bool   isGodLike;
  local string sGodLike;

  foreach DynamicActors(class'PlayerController', PC){
    PN = PC.PlayerReplicationInfo.GetHumanReadableName();
    PID = PC.GetPlayerIDHash();
    if (PN != "WebAdmin" || PC.PlayerReplicationInfo.PlayerID != 0){
        PlayerIDs[i] = PID;
        i = i + 1;
        if(DEBUG){
            MutLog("-----|| DEBUG - Player [" $i$ "] Name: " $PN$ " | ID: " $PID$ " ||-----");
        }
        for(j=0; j<ConfigPlayers.Length; j++){
          PName = ConfigPlayers[j].PName;
          ConfigPID = ConfigPlayers[j].PID;
          Color = ConfigPlayers[j].Color;
          isVIP = ConfigPlayers[j].isVIP;
          sVIP = ConfigPlayers[j].sVIP;
          isDonator = ConfigPlayers[j].isDonator;
          sDonator = ConfigPlayers[j].sDonator;
          isGodLike = ConfigPlayers[j].isGodLike;
          sGodLike = ConfigPlayers[j].sGodLike;
          if(DEBUG){
            MutLog("-----|| DEBUG - Found Player In Config: " $PName$ " | " $ConfigPID$ " ||-----");
          }
          if (ConfigPID == PID){
          NewName $= Color;
          NewName $= PN;
          if (isVIP){
              if ( sVIP != "" ){
                  NewName $= sVIP;
              } else{
                NewName $= VipText;
              }
          }
          if (isDonator){
              if ( sDonator != "" ){
                  NewName $= sDonator;
              } else{
                NewName $= DonatorText;
              }
          }
          if (isGodLike){
              if ( sGodLike != "" ){
                  NewName $= sGodLike;
              } else{
                NewName $= Godlike;
              }
          }
          SetColor(NewName);
          if(DEBUG){
            MutLog("-----|| DEBUG - New Player Name: " $NewName$ " ||-----");
          }
          PC.PlayerReplicationInfo.SetPlayerName(NewName);
          break;
          }
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
