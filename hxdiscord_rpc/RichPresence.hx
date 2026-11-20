package hxdiscord_rpc;

import hxdiscord_rpc.Types;

typedef PresenceButton =
{
	var label:String;
	var url:String;
}

class RichPresence
{
	public static inline final MIN_TEXT_LENGTH:Int = 2;
	public static inline final MAX_TEXT_LENGTH:Int = 128;
	public static inline final MAX_URL_LENGTH:Int = 256;
	public static inline final MAX_IMAGE_KEY_LENGTH:Int = 313;
	public static inline final MAX_ID_LENGTH:Int = 128;
	public static inline final MAX_BUTTON_LABEL_LENGTH:Int = 32;
	public static inline final MAX_BUTTON_URL_LENGTH:Int = 512;
	public static inline final MAX_BUTTONS:Int = 2;

	public var type:DiscordActivityType = DiscordActivityType_Playing;
	public var statusDisplayType:DiscordStatusDisplayType = DiscordStatusDisplayType_Name;
	public var state:String = null;
	public var stateUrl:String = null;
	public var details:String = null;
	public var detailsUrl:String = null;
	public var startTimestamp:Float = 0;
	public var endTimestamp:Float = 0;
	public var largeImageKey:String = null;
	public var largeImageText:String = null;
	public var largeImageUrl:String = null;
	public var smallImageKey:String = null;
	public var smallImageText:String = null;
	public var smallImageUrl:String = null;
	public var partyId:String = null;
	public var partySize:Int = 0;
	public var partyMax:Int = 0;
	public var partyPrivacy:DiscordActivityPartyPrivacy = DiscordActivityPartyPrivacy_Private;
	public var buttons:Array<PresenceButton> = [];
	public var matchSecret:String = null;
	public var joinSecret:String = null;
	public var spectateSecret:String = null;
	public var instance:Bool = false;

	public function new():Void {}

	public static inline function now():Float
	{
		return Date.now().getTime() / 1000;
	}

	public function setText(?details:String, ?state:String):RichPresence
	{
		this.details = details;
		this.state = state;
		return this;
	}

	public function setAssets(?largeKey:String, ?largeText:String, ?smallKey:String, ?smallText:String):RichPresence
	{
		largeImageKey = largeKey;
		largeImageText = largeText;
		smallImageKey = smallKey;
		smallImageText = smallText;
		return this;
	}

	public function setParty(id:String, size:Int, max:Int, ?privacy:DiscordActivityPartyPrivacy):RichPresence
	{
		partyId = id;
		partySize = size;
		partyMax = max;

		if (privacy != null)
			partyPrivacy = privacy;

		return this;
	}

	public function clearParty():RichPresence
	{
		partyId = null;
		partySize = partyMax = 0;
		partyPrivacy = DiscordActivityPartyPrivacy_Private;
		return this;
	}

	public function addButton(label:String, url:String):RichPresence
	{
		buttons.push({label: label, url: url});
		return this;
	}

	public function clearButtons():RichPresence
	{
		buttons.resize(0);
		return this;
	}

	public function setElapsed(elapsed:Float = 0):RichPresence
	{
		startTimestamp = now() - elapsed;
		endTimestamp = 0;
		return this;
	}

	public function setRemaining(remaining:Float):RichPresence
	{
		startTimestamp = 0;
		endTimestamp = now() + remaining;
		return this;
	}

	public function setProgress(elapsed:Float, total:Float):RichPresence
	{
		startTimestamp = now() - elapsed;
		endTimestamp = total > 0 ? startTimestamp + total : 0;
		return this;
	}

	public function clearTimestamps():RichPresence
	{
		startTimestamp = endTimestamp = 0;
		return this;
	}

	public function reset():RichPresence
	{
		type = DiscordActivityType_Playing;
		statusDisplayType = DiscordStatusDisplayType_Name;
		state = stateUrl = details = detailsUrl = null;
		largeImageKey = largeImageText = largeImageUrl = null;
		smallImageKey = smallImageText = smallImageUrl = null;
		matchSecret = joinSecret = spectateSecret = null;
		instance = false;
		clearTimestamps();
		clearParty();
		return clearButtons();
	}

	public function clone():RichPresence
	{
		final copy:RichPresence = new RichPresence();
		copy.copyFrom(this);
		return copy;
	}

	public function copyFrom(other:RichPresence):Void
	{
		type = other.type;
		statusDisplayType = other.statusDisplayType;
		state = other.state;
		stateUrl = other.stateUrl;
		details = other.details;
		detailsUrl = other.detailsUrl;
		startTimestamp = other.startTimestamp;
		endTimestamp = other.endTimestamp;
		largeImageKey = other.largeImageKey;
		largeImageText = other.largeImageText;
		largeImageUrl = other.largeImageUrl;
		smallImageKey = other.smallImageKey;
		smallImageText = other.smallImageText;
		smallImageUrl = other.smallImageUrl;
		partyId = other.partyId;
		partySize = other.partySize;
		partyMax = other.partyMax;
		partyPrivacy = other.partyPrivacy;
		buttons = [for (button in other.buttons) if (button != null) {label: button.label, url: button.url}];
		matchSecret = other.matchSecret;
		joinSecret = other.joinSecret;
		spectateSecret = other.spectateSecret;
		instance = other.instance;
	}

	public function signature():String
	{
		final buf:StringBuf = new StringBuf();
		final fields:Array<String> = [
			Std.string(type.toInt()),
			Std.string(statusDisplayType.toInt()),
			state,
			stateUrl,
			details,
			detailsUrl,
			Std.string(Math.ffloor(startTimestamp)),
			Std.string(Math.ffloor(endTimestamp)),
			largeImageKey,
			largeImageText,
			largeImageUrl,
			smallImageKey,
			smallImageText,
			smallImageUrl,
			partyId,
			Std.string(partySize),
			Std.string(partyMax),
			Std.string(partyPrivacy.toInt()),
			matchSecret,
			joinSecret,
			spectateSecret,
			instance ? '1' : '0'
		];

		for (button in buttons)
		{
			if (button == null)
				continue;

			fields.push(button.label);
			fields.push(button.url);
		}

		for (field in fields)
		{
			if (field == null)
				buf.add('-:');
			else
			{
				buf.add(field.length);
				buf.add(':');
				buf.add(field);
			}
		}

		return buf.toString();
	}

	public function validate():Array<String>
	{
		final problems:Array<String> = [];

		checkText(problems, 'details', details);
		checkText(problems, 'state', state);
		checkText(problems, 'largeImageText', largeImageText);
		checkText(problems, 'smallImageText', smallImageText);
		checkUrl(problems, 'detailsUrl', detailsUrl, MAX_URL_LENGTH);
		checkUrl(problems, 'stateUrl', stateUrl, MAX_URL_LENGTH);
		checkUrl(problems, 'largeImageUrl', largeImageUrl, MAX_URL_LENGTH);
		checkUrl(problems, 'smallImageUrl', smallImageUrl, MAX_URL_LENGTH);
		checkLength(problems, 'largeImageKey', largeImageKey, MAX_IMAGE_KEY_LENGTH);
		checkLength(problems, 'smallImageKey', smallImageKey, MAX_IMAGE_KEY_LENGTH);
		checkLength(problems, 'partyId', partyId, MAX_ID_LENGTH);
		checkLength(problems, 'matchSecret', matchSecret, MAX_ID_LENGTH);
		checkLength(problems, 'joinSecret', joinSecret, MAX_ID_LENGTH);
		checkLength(problems, 'spectateSecret', spectateSecret, MAX_ID_LENGTH);

		if (isLink(largeImageKey) || isLink(smallImageKey))
			problems.push('image keys are asset names or mp:/spotify:/youtube: keys, not links');

		if (partySize > partyMax && partyMax > 0)
			problems.push('partySize is bigger than partyMax');

		if (startTimestamp > 0 && endTimestamp > 0 && endTimestamp < startTimestamp)
			problems.push('endTimestamp is before startTimestamp, it is dropped');

		if (buttons.length > MAX_BUTTONS)
			problems.push('only $MAX_BUTTONS buttons are sent');

		for (i in 0...buttons.length)
		{
			final button:PresenceButton = buttons[i];

			if (button == null || !isFilled(button.label))
				problems.push('button ${i + 1} has no label, it is dropped');
			else
				checkLength(problems, 'button ${i + 1} label', button.label, MAX_BUTTON_LABEL_LENGTH);

			if (button != null)
				checkUrl(problems, 'button ${i + 1} url', button.url, MAX_BUTTON_URL_LENGTH, true);
		}

		if (buttons.length > 0 && (isFilled(matchSecret) || isFilled(joinSecret) || isFilled(spectateSecret)))
			problems.push('buttons are hidden while a secret is set');

		return problems;
	}

	public static inline function isFilled(value:String):Bool
	{
		return value != null && value.length > 0;
	}

	public static function isLink(value:String):Bool
	{
		return isFilled(value) && (StringTools.startsWith(value, 'https://') || StringTools.startsWith(value, 'http://'));
	}

	public static function byteLength(value:String):Int
	{
		return isFilled(value) ? haxe.io.Bytes.ofString(value).length : 0;
	}

	static function checkText(problems:Array<String>, name:String, value:String):Void
	{
		if (!isFilled(value))
			return;

		if (value.length < MIN_TEXT_LENGTH)
			problems.push('$name is shorter than $MIN_TEXT_LENGTH characters, it is dropped');
		else
			checkLength(problems, name, value, MAX_TEXT_LENGTH);
	}

	static function checkUrl(problems:Array<String>, name:String, value:String, max:Int, required:Bool = false):Void
	{
		if (!isFilled(value))
		{
			if (required)
				problems.push('$name is empty, it is dropped');

			return;
		}

		if (!isLink(value))
			problems.push('$name is not a http/https link, it is dropped');
		else
			checkLength(problems, name, value, max);
	}

	static function checkLength(problems:Array<String>, name:String, value:String, max:Int):Void
	{
		if (byteLength(value) > max)
			problems.push('$name is longer than $max bytes, it is cut');
	}
}
