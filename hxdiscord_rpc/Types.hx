package hxdiscord_rpc;

class Types {}

enum abstract DiscordPremiumType(Int) from Int to Int
{
	var DiscordPremiumType_None = 0;
	var DiscordPremiumType_NitroClassic = 1;
	var DiscordPremiumType_Nitro = 2;
	var DiscordPremiumType_NitroBasic = 3;

	public inline function toInt():Int
		return this;
}

enum abstract DiscordActivityPartyPrivacy(Int) from Int to Int
{
	var DiscordActivityPartyPrivacy_Private = 0;
	var DiscordActivityPartyPrivacy_Public = 1;

	public inline function toInt():Int
		return this;
}

enum abstract DiscordActivityType(Int) from Int to Int
{
	var DiscordActivityType_Playing = 0;
	var DiscordActivityType_Listening = 2;
	var DiscordActivityType_Watching = 3;
	var DiscordActivityType_Competing = 5;

	public inline function toInt():Int
		return this;
}

enum abstract DiscordStatusDisplayType(Int) from Int to Int
{
	var DiscordStatusDisplayType_Name = 0;
	var DiscordStatusDisplayType_State = 1;
	var DiscordStatusDisplayType_Details = 2;

	public inline function toInt():Int
		return this;
}

enum abstract DiscordActivityJoinRequestReply(Int) from Int to Int
{
	var DiscordActivityJoinRequestReply_No = 0;
	var DiscordActivityJoinRequestReply_Yes = 1;
	var DiscordActivityJoinRequestReply_Ignore = 2;

	public inline function toInt():Int
		return this;
}

#if (cpp && !(android || ios))
@:noCompletion
extern abstract NativePremiumType(NativePremiumType_Impl)
{
	@:from static inline function fromInt(i:Int):NativePremiumType
		return cast i;

	@:to inline function toInt():Int
		return untyped this;
}

@:buildXml('<include name="${haxelib:freak_discord_rpc}/project/Build.xml" />')
@:include('discord_rpc.hpp')
@:native('DiscordPremiumType')
private extern class NativePremiumType_Impl {}

@:noCompletion
extern abstract NativeActivityPartyPrivacy(NativeActivityPartyPrivacy_Impl)
{
	@:from static inline function fromInt(i:Int):NativeActivityPartyPrivacy
		return cast i;

	@:to inline function toInt():Int
		return untyped this;
}

@:buildXml('<include name="${haxelib:freak_discord_rpc}/project/Build.xml" />')
@:include('discord_rpc.hpp')
@:native('DiscordActivityPartyPrivacy')
private extern class NativeActivityPartyPrivacy_Impl {}

@:noCompletion
extern abstract NativeActivityType(NativeActivityType_Impl)
{
	@:from static inline function fromInt(i:Int):NativeActivityType
		return cast i;

	@:to inline function toInt():Int
		return untyped this;
}

@:buildXml('<include name="${haxelib:freak_discord_rpc}/project/Build.xml" />')
@:include('discord_rpc.hpp')
@:native('DiscordActivityType')
private extern class NativeActivityType_Impl {}

@:noCompletion
extern abstract NativeStatusDisplayType(NativeStatusDisplayType_Impl)
{
	@:from static inline function fromInt(i:Int):NativeStatusDisplayType
		return cast i;

	@:to inline function toInt():Int
		return untyped this;
}

@:buildXml('<include name="${haxelib:freak_discord_rpc}/project/Build.xml" />')
@:include('discord_rpc.hpp')
@:native('DiscordStatusDisplayType')
private extern class NativeStatusDisplayType_Impl {}

@:noCompletion
extern abstract NativeActivityJoinRequestReply(NativeActivityJoinRequestReply_Impl)
{
	@:from static inline function fromInt(i:Int):NativeActivityJoinRequestReply
		return cast i;

	@:to inline function toInt():Int
		return untyped this;
}

@:buildXml('<include name="${haxelib:freak_discord_rpc}/project/Build.xml" />')
@:include('discord_rpc.hpp')
@:native('DiscordActivityJoinRequestReply')
private extern class NativeActivityJoinRequestReply_Impl {}

@:buildXml('<include name="${haxelib:freak_discord_rpc}/project/Build.xml" />')
@:include('discord_rpc.hpp')
@:unreflective
@:structAccess
@:native('DiscordButton')
extern class DiscordButton
{
	function new():Void;

	var label:cpp.ConstCharStar;
	var url:cpp.ConstCharStar;
}

@:buildXml('<include name="${haxelib:freak_discord_rpc}/project/Build.xml" />')
@:include('discord_rpc.hpp')
@:unreflective
@:structAccess
@:native('DiscordRichPresence')
extern class DiscordRichPresence
{
	function new():Void;

	var type:NativeActivityType;
	var statusDisplayType:NativeStatusDisplayType;
	var state:cpp.ConstCharStar;
	var stateUrl:cpp.ConstCharStar;
	var details:cpp.ConstCharStar;
	var detailsUrl:cpp.ConstCharStar;
	var startTimestamp:cpp.Int64;
	var endTimestamp:cpp.Int64;
	var largeImageKey:cpp.ConstCharStar;
	var largeImageText:cpp.ConstCharStar;
	var largeImageUrl:cpp.ConstCharStar;
	var smallImageKey:cpp.ConstCharStar;
	var smallImageText:cpp.ConstCharStar;
	var smallImageUrl:cpp.ConstCharStar;
	var partyId:cpp.ConstCharStar;
	var partySize:Int;
	var partyMax:Int;
	var partyPrivacy:NativeActivityPartyPrivacy;
	var buttons:cpp.RawPointer<DiscordButton>;
	var matchSecret:cpp.ConstCharStar;
	var joinSecret:cpp.ConstCharStar;
	var spectateSecret:cpp.ConstCharStar;
	var instance:Bool;
}

@:buildXml('<include name="${haxelib:freak_discord_rpc}/project/Build.xml" />')
@:include('discord_rpc.hpp')
@:unreflective
@:structAccess
@:native('DiscordUser')
extern class DiscordUser
{
	function new():Void;

	var userId:cpp.ConstCharStar;
	var username:cpp.ConstCharStar;
	var globalName:cpp.ConstCharStar;
	var discriminator:cpp.ConstCharStar;
	var avatar:cpp.ConstCharStar;
	var premiumType:NativePremiumType;
	var bot:Bool;
}

@:buildXml('<include name="${haxelib:freak_discord_rpc}/project/Build.xml" />')
@:include('discord_rpc.hpp')
@:unreflective
@:structAccess
@:native('DiscordEventHandlers')
extern class DiscordEventHandlers
{
	function new():Void;

	var ready:cpp.Callable<(request:cpp.RawConstPointer<DiscordUser>) -> Void>;
	var disconnected:cpp.Callable<(errorCode:Int, message:cpp.ConstCharStar) -> Void>;
	var errored:cpp.Callable<(errorCode:Int, message:cpp.ConstCharStar) -> Void>;
	var joinGame:cpp.Callable<(joinSecret:cpp.ConstCharStar) -> Void>;
	var spectateGame:cpp.Callable<(spectateSecret:cpp.ConstCharStar) -> Void>;
	var joinRequest:cpp.Callable<(request:cpp.RawConstPointer<DiscordUser>) -> Void>;
}
#end
