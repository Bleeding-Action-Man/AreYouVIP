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
  var config string SteamID; // Steam ID, will always be checked
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
  for(i=0; i<aSpecialPlayers.Length; i=i++)
  {
    SpecialPlayers[i] = aSpecialPlayers[i];
  }

  if(DEBUG)
  {
    MutLog("-----|| DEBUG - VipText: " $VIP$ " ||-----");
    MutLog("-----|| DEBUG - Donator: " $Donator$ " ||-----");
    MutLog("-----|| DEBUG - Godlike: " $Godlike$ " ||-----");
    MutLog("-----|| DEBUG - # Of Config Players: " $SpecialPlayers.Length$ " ||-----");
  }
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
  Super.FillPlayInfo(PlayInfo);
  PlayInfo.AddSetting("KFAreYouVIP", "sVIPText", "VIP Text", 0, 1, "text");
  PlayInfo.AddSetting("KFAreYouVIP", "sDonatorText", "Donator Text", 0, 2, "text");
  PlayInfo.AddSetting("KFAreYouVIP", "sGodLikeText", "Godlike Text", 0, 3, "text");
  PlayInfo.AddSetting("KFAreYouVIP", "bDEBUG", "Debug", 0, 4, "check");
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

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
  if (Other.IsA('PlayerController')) AddHandler(PlayerController(Other));
  return true;
}

final function AddHandler(PlayerController PC)
{
  local ClientHandler C;
  C = Spawn(class'ClientHandler');
  C.Client = PC;
  C.MasterHandler = self;
}

simulated function TimeStampLog(coerce string s)
{
  log("["$Level.TimeSeconds$"s]" @ s, 'AreYouVIP');
}

simulated function MutLog(string s)
{
  log(s, 'AreYouVIP');
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
  FriendlyName="Are You VIP - v1.3"
  Description="Mark special players (ViP, Donators or Godlike) on your server; By Vel-San"
}
