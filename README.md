# hxdiscord_rpc

Discord Rich Presence for Haxe/hxcpp, built on [discord-rpc](https://github.com/discord/discord-rpc).

Fork of [MAJigsaw77/hxdiscord_rpc](https://github.com/MAJigsaw77/hxdiscord_rpc).

```haxe
DiscordClient.initialize('APPLICATION_ID');

final presence = new RichPresence();
presence.setText('Details', 'State');
presence.setAssets('icon', 'Hover text');
presence.setElapsed();
presence.addButton('Website', 'https://example.com');
DiscordClient.setPresence(presence);
```

Call `DiscordClient.update()` once per frame on the main thread. Event handlers run inside it.

Desktop C++ only (Windows, macOS, Linux). On other targets everything compiles and does nothing, `DiscordClient.supported` is `false`.

`Discord` and `Types` are the raw C API externs.

Defines: `DISCORD_RPC_DEBUG` traces client activity, `DISCORD_DISABLE_IO_THREAD` drives the connection from `update()` instead of a native thread.
