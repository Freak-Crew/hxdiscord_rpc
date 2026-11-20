package;

import hxdiscord_rpc.DiscordClient;
import hxdiscord_rpc.RichPresence;
import hxdiscord_rpc.Types;

class Main
{
	public static function main():Void
	{
		DiscordClient.log = Sys.println;
		DiscordClient.onReady = function(user:DiscordUserInfo):Void
		{
			Sys.println('ready: ${user.globalName} (${user.id})');
		};
		DiscordClient.onDisconnected = function(code:Int, message:String):Void
		{
			Sys.println('disconnected: $code $message');
		};
		DiscordClient.onError = function(code:Int, message:String):Void
		{
			Sys.println('error: $code $message');
		};

		DiscordClient.initialize('345229890980937739');

		final presence:RichPresence = new RichPresence();
		presence.statusDisplayType = DiscordStatusDisplayType_Details;
		presence.setText('Testing hxdiscord_rpc', 'Ünïcödé • テスト');
		presence.setAssets('icon', 'hxdiscord_rpc');
		presence.setElapsed();
		presence.addButton('GitHub', 'https://github.com');

		for (problem in presence.validate())
			Sys.println('problem: $problem');

		DiscordClient.setPresence(presence);

		final end:Float = Sys.time() + 60;

		while (Sys.time() < end)
		{
			DiscordClient.update();
			Sys.sleep(1 / 60);
		}

		DiscordClient.shutdown();
	}
}
