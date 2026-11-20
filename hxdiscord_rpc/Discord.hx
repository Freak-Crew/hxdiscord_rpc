package hxdiscord_rpc;

#if (cpp && !(android || ios))
import hxdiscord_rpc.Types;

@:buildXml('<include name="${haxelib:hxdiscord_rpc}/project/Build.xml" />')
@:include('discord_rpc.hpp')
@:unreflective
extern class Discord
{
	@:native('DISCORD_RPC_VERSION')
	static var RPC_VERSION:Int;

	@:native('Discord_Register')
	static function Register(applicationId:cpp.ConstCharStar, command:cpp.ConstCharStar):Void;

	@:native('Discord_RegisterSteamGame')
	static function RegisterSteamGame(applicationId:cpp.ConstCharStar, steamId:cpp.ConstCharStar):Void;

	@:native('Discord_Initialize')
	static function Initialize(applicationId:cpp.ConstCharStar, handlers:cpp.RawPointer<DiscordEventHandlers>, autoRegister:Bool,
		optionalSteamId:cpp.ConstCharStar):Void;

	@:native('Discord_Shutdown')
	static function Shutdown():Void;

	@:native('Discord_RunCallbacks')
	static function RunCallbacks():Void;

	#if DISCORD_DISABLE_IO_THREAD
	@:native('Discord_UpdateConnection')
	static function UpdateConnection():Void;
	#end

	@:native('Discord_UpdatePresence')
	static function UpdatePresence(presence:cpp.RawConstPointer<DiscordRichPresence>):Void;

	@:native('Discord_ClearPresence')
	static function ClearPresence():Void;

	@:native('Discord_Respond')
	static function Respond(userid:cpp.ConstCharStar, reply:NativeActivityJoinRequestReply):Void;

	@:native('Discord_UpdateHandlers')
	static function UpdateHandlers(handlers:cpp.RawPointer<DiscordEventHandlers>):Void;
}

@:buildXml('<include name="${haxelib:hxdiscord_rpc}/project/Build.xml" />')
@:include('discord_extras.hpp')
@:unreflective
extern class DiscordExtras
{
	@:native('DiscordExtras_GetIdleTime')
	static function GetIdleTime():Float;
}
#end
