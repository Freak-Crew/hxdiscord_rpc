package hxdiscord_rpc;

class DiscordAssets
{
	public static inline final CDN:String = 'https://cdn.discordapp.com';

	public static inline function mediaProxy(imageId:String):String
		return 'mp:$imageId';

	public static inline function spotify(spotifyId:String):String
		return 'spotify:$spotifyId';

	public static inline function youtube(videoId:String):String
		return 'youtube:$videoId';

	public static inline function twitch(username:String):String
		return 'twitch:$username';

	public static function avatarUrl(userId:String, ?avatar:String, size:Int = 128):String
	{
		if (userId == null || userId.length == 0)
			return null;

		if (avatar == null || avatar.length == 0)
			return '$CDN/embed/avatars/${defaultAvatarIndex(userId)}.png';

		final extension:String = StringTools.startsWith(avatar, 'a_') ? 'gif' : 'png';
		return '$CDN/avatars/$userId/$avatar.$extension?size=$size';
	}

	public static function applicationAssetUrl(applicationId:String, assetId:String, size:Int = 128):String
	{
		if (applicationId == null || assetId == null)
			return null;

		return '$CDN/app-assets/$applicationId/$assetId.png?size=$size';
	}

	static function defaultAvatarIndex(userId:String):Int
	{
		try
		{
			final id:haxe.Int64 = haxe.Int64.parseString(userId);
			return haxe.Int64.toInt(haxe.Int64.mod(haxe.Int64.shr(id, 22), 6));
		}
		catch (e:Dynamic)
		{
			return 0;
		}
	}
}
