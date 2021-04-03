//=============================================================================
// Check for VIP players on your server and give them VIP status
// Written by Vel-San
// for more information, feedback, questions or requests please contact
// https://steamcommunity.com/id/Vel-San/
//=============================================================================

Class AreYouVIP extends Mutator config(AreYouVIP_Config);

var config bool bDebug;
// Default VIP Text, in case none is specified for a special player
var config string sVIPText;

// Mut Vars
var string VIP;

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
};
var config array<SP> aSpecialPlayers; // PlayersList to be declared in the Config
var array<SP> SpecialPlayers; // PlayersList to be declared in the Config


function PostBeginPlay()
{
  local int i;

  VIP = sVIPText;
  for(i=0; i<aSpecialPlayers.Length; i=i++)
  {
    SpecialPlayers[i] = aSpecialPlayers[i];
  }

  if(bDebug)
  {
    MutLog("-----|| Debug - VipText: " $VIP$ " ||-----");
    MutLog("-----|| Debug - # Of Config Players: " $SpecialPlayers.Length$ " ||-----");
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
  FriendlyName="Are You VIP - v1.4"
  Description="Mark special players (ViP) on your server; By Vel-San"
}
