package hxdiscord_rpc;

import hxdiscord_rpc.RichPresence;
import hxdiscord_rpc.Types;

class MusicPresence extends RichPresence
{
	public var title:String = null;
	public var artist:String = null;
	public var album:String = null;
	public var artworkKey:String = null;
	public var artworkUrl:String = null;
	public var trackUrl:String = null;
	public var artistUrl:String = null;
	public var playingIconKey:String = null;
	public var pausedIconKey:String = null;
	public var source:String = null;
	public var duration:Float = 0;
	public var paused(default, set):Bool = false;
	public var position(get, set):Float;

	var positionValue:Float = 0;
	var positionStamp:Float = 0;

	public function new():Void
	{
		super();
		positionStamp = haxe.Timer.stamp();
		type = DiscordActivityType_Listening;
		statusDisplayType = DiscordStatusDisplayType_State;
	}

	public function play(title:String, ?artist:String, duration:Float = 0, ?album:String):MusicPresence
	{
		this.title = title;
		this.artist = artist;
		this.duration = duration;
		this.album = album;
		@:bypassAccessor paused = false;
		position = 0;
		return sync();
	}

	public function seek(seconds:Float):MusicPresence
	{
		position = seconds;
		return sync();
	}

	public function pause():MusicPresence
	{
		paused = true;
		return sync();
	}

	public function resume():MusicPresence
	{
		paused = false;
		return sync();
	}

	public function stop():MusicPresence
	{
		title = artist = album = null;
		duration = 0;
		@:bypassAccessor paused = false;
		position = 0;
		return sync();
	}

	public function sync():MusicPresence
	{
		final hasAlbum:Bool = RichPresence.isFilled(album);

		details = title;
		detailsUrl = trackUrl;
		state = artist != null && hasAlbum ? '$artist • $album' : artist;
		stateUrl = artistUrl;
		largeImageKey = artworkKey;
		largeImageText = hasAlbum ? album : title;
		largeImageUrl = artworkUrl;
		smallImageKey = paused ? pausedIconKey : playingIconKey;
		smallImageText = source;

		if (paused || !RichPresence.isFilled(title))
			clearTimestamps();
		else
			setProgress(position, duration);

		return this;
	}

	function get_position():Float
	{
		final value:Float = positionValue + (paused ? 0 : haxe.Timer.stamp() - positionStamp);
		return duration > 0 && value > duration ? duration : value;
	}

	function set_position(value:Float):Float
	{
		positionValue = value < 0 ? 0 : value;
		positionStamp = haxe.Timer.stamp();
		return positionValue;
	}

	function set_paused(value:Bool):Bool
	{
		if (paused != value)
		{
			positionValue = position;
			positionStamp = haxe.Timer.stamp();
		}

		return paused = value;
	}
}
