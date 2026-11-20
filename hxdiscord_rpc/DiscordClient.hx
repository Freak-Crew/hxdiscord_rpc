package hxdiscord_rpc;

import hxdiscord_rpc.RichPresence;
import hxdiscord_rpc.Types;
#if (cpp && !(android || ios))
import haxe.io.Bytes;
import hxdiscord_rpc.Discord;
#end

typedef DiscordUserInfo =
{
	var id:String;
	var username:String;
	var globalName:String;
	var discriminator:Int;
	var avatar:String;
	var premiumType:Int;
	var bot:Bool;
}

typedef DiscordClientOptions =
{
	var ?autoRegister:Bool;
	var ?steamId:String;
}

class DiscordClient
{
	public static final supported:Bool = #if (cpp && !(android || ios)) true #else false #end;

	public static var onReady:DiscordUserInfo->Void = null;
	public static var onDisconnected:Int->String->Void = null;
	public static var onError:Int->String->Void = null;
	public static var onJoinGame:String->Void = null;
	public static var onSpectateGame:String->Void = null;
	public static var onJoinRequest:DiscordUserInfo->Void = null;
	public static var onIdleChanged:Bool->Void = null;
	public static var log:String->Void = null;

	public static var applicationId(default, null):String = null;
	public static var initialized(default, null):Bool = false;
	public static var connected(default, null):Bool = false;
	public static var user(default, null):DiscordUserInfo = null;
	public static var idle(default, null):Bool = false;

	public static var rateLimit:Float = 4.0;
	public static var focused(default, set):Bool = true;
	public static var idleWhenUnfocused(default, set):Bool = false;
	public static var idleTimeout(default, set):Float = 0;
	public static var idlePresence(default, set):RichPresence = null;

	static var options:DiscordClientOptions = {};
	static var wanted:RichPresence = null;
	static var wantedSignature:String = '';
	static var idleSignature:String = '';
	static var sentSignature:String = null;
	static var lastSent:Float = -1;
	static var dirty:Bool = false;
	static var nextIdleCheck:Float = 0;
	static var events:Array<Void->Void> = [];

	public static function initialize(applicationId:String, ?options:DiscordClientOptions):Void
	{
		if (initialized)
		{
			if (applicationId == DiscordClient.applicationId)
				return;

			shutdown();
		}

		DiscordClient.applicationId = applicationId;
		DiscordClient.options = options != null ? options : {};

		initialized = true;
		connected = false;
		user = null;
		sentSignature = null;
		lastSent = -1;
		dirty = true;
		nextIdleCheck = 0;

		#if (cpp && !(android || ios))
		final handlers:DiscordEventHandlers = new DiscordEventHandlers();
		handlers.ready = cpp.Function.fromStaticFunction(handleReady);
		handlers.disconnected = cpp.Function.fromStaticFunction(handleDisconnected);
		handlers.errored = cpp.Function.fromStaticFunction(handleError);
		handlers.joinGame = cpp.Function.fromStaticFunction(handleJoinGame);
		handlers.spectateGame = cpp.Function.fromStaticFunction(handleSpectateGame);
		handlers.joinRequest = cpp.Function.fromStaticFunction(handleJoinRequest);

		Discord.Initialize(cstr(applicationId, 64), cpp.RawPointer.addressOf(handlers), DiscordClient.options.autoRegister == true,
			cstr(DiscordClient.options.steamId, 64));
		scratch.resize(0);
		#end

		report('initialized $applicationId');
	}

	public static function update():Void
	{
		if (!initialized)
			return;

		#if (cpp && !(android || ios))
		#if DISCORD_DISABLE_IO_THREAD
		Discord.UpdateConnection();
		#end
		Discord.RunCallbacks();
		#end

		if (events.length > 0)
		{
			final pending:Array<Void->Void> = events;
			events = [];

			for (event in pending)
				event();
		}

		updateIdle();
		flush();
	}

	public static function setPresence(presence:RichPresence, force:Bool = false):Void
	{
		if (presence == null)
		{
			clearPresence();
			return;
		}

		final signature:String = presence.signature();

		if (!force && wanted != null && signature == wantedSignature)
			return;

		if (wanted == null)
			wanted = presence.clone();
		else
			wanted.copyFrom(presence);

		wantedSignature = signature;
		dirty = true;

		if (force)
			sentSignature = null;

		flush();
	}

	public static function clearPresence():Void
	{
		if (wanted == null && wantedSignature == '')
			return;

		wanted = null;
		wantedSignature = '';
		dirty = true;
		flush();
	}

	public static function getPresence():RichPresence
	{
		return wanted != null ? wanted.clone() : null;
	}

	public static function respond(userId:String, reply:DiscordActivityJoinRequestReply):Void
	{
		if (!connected || userId == null)
			return;

		#if (cpp && !(android || ios))
		Discord.Respond(cstr(userId, 64), reply.toInt());
		scratch.resize(0);
		#end
	}

	public static function reconnect():Void
	{
		if (!initialized)
			return;

		final id:String = applicationId;
		final opts:DiscordClientOptions = options;

		shutdown();
		initialize(id, opts);
	}

	public static function shutdown():Void
	{
		if (!initialized)
			return;

		#if (cpp && !(android || ios))
		Discord.Shutdown();
		#end

		initialized = false;
		connected = false;
		user = null;
		idle = false;
		sentSignature = null;
		lastSent = -1;
		events = [];

		report('shut down');
	}

	public static function idleTime():Float
	{
		#if (cpp && !(android || ios))
		return DiscordExtras.GetIdleTime();
		#else
		return -1;
		#end
	}

	static function flush():Void
	{
		if (!dirty || !initialized || !connected)
			return;

		final target:RichPresence = idle ? idlePresence : wanted;
		final signature:String = idle ? idleSignature : wantedSignature;

		if (signature == sentSignature)
		{
			dirty = false;
			return;
		}

		final stamp:Float = haxe.Timer.stamp();

		if (lastSent >= 0 && stamp - lastSent < rateLimit)
			return;

		send(target);

		sentSignature = signature;
		lastSent = stamp;
		dirty = false;
	}

	static function updateIdle():Void
	{
		final stamp:Float = haxe.Timer.stamp();

		if (stamp < nextIdleCheck)
			return;

		nextIdleCheck = stamp + 0.5;

		var away:Bool = idleWhenUnfocused && !focused;

		if (!away && idleTimeout > 0)
		{
			final time:Float = idleTime();
			away = time >= 0 && time >= idleTimeout;
		}

		if (away == idle)
			return;

		idle = away;
		dirty = true;

		report(idle ? 'idle' : 'back from idle');

		if (onIdleChanged != null)
			onIdleChanged(idle);
	}

	static function report(message:String):Void
	{
		if (log != null)
			log('[hxdiscord_rpc] $message');
		#if DISCORD_RPC_DEBUG
		else
			trace('[hxdiscord_rpc] $message');
		#end
	}

	static function set_focused(value:Bool):Bool
	{
		if (focused != value)
			nextIdleCheck = 0;

		return focused = value;
	}

	static function set_idleWhenUnfocused(value:Bool):Bool
	{
		nextIdleCheck = 0;
		return idleWhenUnfocused = value;
	}

	static function set_idleTimeout(value:Float):Float
	{
		nextIdleCheck = 0;
		return idleTimeout = value;
	}

	static function set_idlePresence(value:RichPresence):RichPresence
	{
		idlePresence = value != null ? value.clone() : null;
		idleSignature = value != null ? idlePresence.signature() : '';

		if (idle)
			dirty = true;

		return value;
	}

	#if (cpp && !(android || ios))
	static var scratch:Array<Bytes> = [];
	static var empty:Bytes = {
		final bytes:Bytes = Bytes.alloc(1);
		bytes.set(0, 0);
		bytes;
	};

	static function send(presence:RichPresence):Void
	{
		if (presence == null)
		{
			Discord.ClearPresence();
			report('presence cleared');
			return;
		}

		final native:DiscordRichPresence = new DiscordRichPresence();
		native.type = presence.type.toInt();
		native.statusDisplayType = presence.statusDisplayType.toInt();
		native.state = text(presence.state);
		native.stateUrl = link(presence.stateUrl, RichPresence.MAX_URL_LENGTH);
		native.details = text(presence.details);
		native.detailsUrl = link(presence.detailsUrl, RichPresence.MAX_URL_LENGTH);
		native.largeImageKey = cstr(presence.largeImageKey, RichPresence.MAX_IMAGE_KEY_LENGTH);
		native.largeImageText = text(presence.largeImageText);
		native.largeImageUrl = link(presence.largeImageUrl, RichPresence.MAX_URL_LENGTH);
		native.smallImageKey = cstr(presence.smallImageKey, RichPresence.MAX_IMAGE_KEY_LENGTH);
		native.smallImageText = text(presence.smallImageText);
		native.smallImageUrl = link(presence.smallImageUrl, RichPresence.MAX_URL_LENGTH);
		native.partyId = cstr(presence.partyId, RichPresence.MAX_ID_LENGTH);
		native.partySize = presence.partySize > 0 ? presence.partySize : 0;
		native.partyMax = presence.partyMax > 0 ? presence.partyMax : 0;
		native.partyPrivacy = presence.partyPrivacy.toInt();
		native.matchSecret = cstr(presence.matchSecret, RichPresence.MAX_ID_LENGTH);
		native.joinSecret = cstr(presence.joinSecret, RichPresence.MAX_ID_LENGTH);
		native.spectateSecret = cstr(presence.spectateSecret, RichPresence.MAX_ID_LENGTH);
		native.instance = presence.instance;

		final start:Float = presence.startTimestamp > 0 ? presence.startTimestamp : 0;
		final end:Float = presence.endTimestamp > 0 && (start <= 0 || presence.endTimestamp >= start) ? presence.endTimestamp : 0;
		native.startTimestamp = Std.int(start);
		native.endTimestamp = Std.int(end);

		var count:Int = 0;

		for (button in presence.buttons)
		{
			if (count >= RichPresence.MAX_BUTTONS)
				break;

			if (button == null || !RichPresence.isFilled(button.label) || !RichPresence.isLink(button.url))
				continue;

			final entry:DiscordButton = new DiscordButton();
			entry.label = cstr(button.label, RichPresence.MAX_BUTTON_LABEL_LENGTH);
			entry.url = cstr(button.url, RichPresence.MAX_BUTTON_URL_LENGTH);
			native.buttons[count++] = entry;
		}

		while (count < RichPresence.MAX_BUTTONS)
		{
			final entry:DiscordButton = new DiscordButton();
			entry.label = pointer(empty);
			entry.url = pointer(empty);
			native.buttons[count++] = entry;
		}

		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(native));
		scratch.resize(0);

		report('presence sent: ${presence.details} | ${presence.state}');
	}

	static function text(value:String):cpp.ConstCharStar
	{
		if (value == null || value.length < RichPresence.MIN_TEXT_LENGTH)
			return pointer(empty);

		return cstr(value, RichPresence.MAX_TEXT_LENGTH);
	}

	static function link(value:String, max:Int):cpp.ConstCharStar
	{
		return RichPresence.isLink(value) ? cstr(value, max) : pointer(empty);
	}

	static function cstr(value:String, max:Int):cpp.ConstCharStar
	{
		if (value == null || value.length == 0)
			return pointer(empty);

		final bytes:Bytes = Bytes.ofString(value);
		var length:Int = bytes.length;

		if (length > max)
		{
			length = max;

			while (length > 0 && (bytes.get(length) & 0xC0) == 0x80)
				length--;
		}

		final out:Bytes = Bytes.alloc(length + 1);
		out.blit(0, bytes, 0, length);
		out.set(length, 0);
		scratch.push(out);

		return pointer(out);
	}

	static inline function pointer(bytes:Bytes):cpp.ConstCharStar
	{
		return untyped __cpp__('(const char *){0}->getBase()', bytes.getData());
	}

	static function string(value:cpp.ConstCharStar):String
	{
		if (untyped __cpp__('{0} == nullptr', value))
			return '';

		return value.toString();
	}

	static function toUserInfo(request:cpp.RawConstPointer<DiscordUser>):DiscordUserInfo
	{
		final username:String = string(request[0].username);
		final globalName:String = string(request[0].globalName);
		final discriminator:Null<Int> = Std.parseInt(string(request[0].discriminator));

		return {
			id: string(request[0].userId),
			username: username,
			globalName: globalName.length > 0 ? globalName : username,
			discriminator: discriminator != null ? discriminator : 0,
			avatar: string(request[0].avatar),
			premiumType: request[0].premiumType.toInt(),
			bot: request[0].bot
		};
	}

	static function handleReady(request:cpp.RawConstPointer<DiscordUser>):Void
	{
		final info:DiscordUserInfo = toUserInfo(request);

		connected = true;
		user = info;
		sentSignature = '';
		lastSent = -1;
		dirty = true;

		report('connected as ${info.username}');

		events.push(function():Void
		{
			if (onReady != null)
				onReady(info);
		});
	}

	static function handleDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		final reason:String = string(message);

		connected = false;
		user = null;
		sentSignature = null;
		dirty = true;

		report('disconnected ($errorCode: $reason)');

		events.push(function():Void
		{
			if (onDisconnected != null)
				onDisconnected(errorCode, reason);
		});
	}

	static function handleError(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		final reason:String = string(message);

		report('error ($errorCode: $reason)');

		events.push(function():Void
		{
			if (onError != null)
				onError(errorCode, reason);
		});
	}

	static function handleJoinGame(secret:cpp.ConstCharStar):Void
	{
		final value:String = string(secret);

		events.push(function():Void
		{
			if (onJoinGame != null)
				onJoinGame(value);
		});
	}

	static function handleSpectateGame(secret:cpp.ConstCharStar):Void
	{
		final value:String = string(secret);

		events.push(function():Void
		{
			if (onSpectateGame != null)
				onSpectateGame(value);
		});
	}

	static function handleJoinRequest(request:cpp.RawConstPointer<DiscordUser>):Void
	{
		final info:DiscordUserInfo = toUserInfo(request);

		events.push(function():Void
		{
			if (onJoinRequest != null)
				onJoinRequest(info);
		});
	}
	#else
	static function send(presence:RichPresence):Void {}
	#end
}
