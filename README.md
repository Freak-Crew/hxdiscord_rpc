# freak_discord_rpc

Discord Rich Presence for Haxe/hxcpp, built on [discord-rpc](https://github.com/discord/discord-rpc).
Fork of [MAJigsaw77/hxdiscord_rpc](https://github.com/MAJigsaw77/hxdiscord_rpc). The haxelib name is `freak_discord_rpc`, the package is still `hxdiscord_rpc`.

## Install

```
haxelib install freak_discord_rpc
```

Lime project:

```xml
<haxelib name="freak_discord_rpc" />
```

## Platforms

| Target | Status |
| --- | --- |
| Windows, macOS, Linux (hxcpp) | Works |
| Android, iOS, HTML5, HashLink, others | Compiles, does nothing |

`DiscordClient.supported` tells which one you are on.

## Usage

```haxe
import hxdiscord_rpc.DiscordClient;
import hxdiscord_rpc.RichPresence;
import hxdiscord_rpc.Types;

DiscordClient.onReady = user -> trace('connected as ${user.username}');
DiscordClient.initialize('APPLICATION_ID', {autoRegister: true});

final presence = new RichPresence();
presence.setText('In a song', 'Hard');
presence.setAssets('icon', 'Freak Engine');
presence.setElapsed();
presence.addButton('Website', 'https://example.com');
DiscordClient.setPresence(presence);
```

Call `DiscordClient.update()` once per frame on the main thread:

```haxe
FlxG.signals.postUpdate.add(DiscordClient.update);
```

Event handlers run inside `update()`, never on another thread.

`setPresence()` copies the presence, so the same object can be changed and sent again. A presence that didn't change is skipped, so calling it every frame is fine.

Close the connection on exit:

```haxe
DiscordClient.shutdown();
```

Discord removes the presence when the connection closes.

## How it behaves

- **Reconnect.** If Discord isn't running, or gets closed, the client keeps retrying every 0.5 to 5 seconds. The last presence is sent again once it connects.
- **Before connecting.** `setPresence()` works before `initialize()` and while disconnected. The presence goes out when the connection is ready.
- **Rate limit.** At most one update every `rateLimit` seconds (default 4). Newer updates replace a waiting one, and the latest is sent when the time is up.
- **Text limits.** Fields are cut to Discord's byte limits on UTF-8 character boundaries. Text under 2 characters is dropped, since Discord refuses the whole presence otherwise. Links that aren't `http`/`https` are dropped. `RichPresence.validate()` lists what would be cut or dropped.
- **Idle.** With `idleWhenUnfocused` or `idleTimeout` set, the client switches to `idlePresence` (or clears the presence if it is `null`) and switches back on return.

## DiscordClient

| Member | |
| --- | --- |
| `initialize(applicationId, ?options)` | Opens the connection. Calling it again with another ID restarts with that ID. |
| `update()` | Runs callbacks, idle checks and pending sends. Main thread, every frame. |
| `setPresence(presence, force = false)` | Sets the presence. `force` sends it even if nothing changed. |
| `clearPresence()` | Removes the presence. |
| `getPresence()` | Copy of the current presence, or `null`. |
| `respond(userId, reply)` | Answers a join request. |
| `reconnect()` | Closes and reopens the connection with the same settings. |
| `shutdown()` | Closes the connection. |
| `idleTime()` | Seconds since the last keyboard or mouse input, system wide. `-1` if unknown. |
| `supported` | `true` on targets where Discord works. |
| `initialized`, `connected` | Connection state. |
| `user` | `DiscordUserInfo` of the connected account, or `null`. |
| `applicationId` | The ID passed to `initialize`. |
| `rateLimit` | Seconds between updates, default `4`. |
| `focused` | Set this from your window focus events. |
| `idleWhenUnfocused` | Go idle while `focused` is `false`. |
| `idleTimeout` | Go idle after this many seconds without input, `0` to disable. |
| `idlePresence` | Presence shown while idle, `null` to show nothing. |
| `idle` | Whether the client is idle right now. |
| `log` | `String->Void` that receives client messages. |

Options for `initialize`:

| Field | |
| --- | --- |
| `autoRegister` | Registers the `discord-<id>://` protocol so Discord can launch the game. |
| `steamId` | Registers the game through Steam instead. |

Events:

| Handler | Arguments |
| --- | --- |
| `onReady` | `DiscordUserInfo` |
| `onDisconnected` | error code, message |
| `onError` | error code, message |
| `onJoinGame` | join secret |
| `onSpectateGame` | spectate secret |
| `onJoinRequest` | `DiscordUserInfo` |
| `onIdleChanged` | `Bool` |

`DiscordUserInfo` has `id`, `username`, `globalName`, `discriminator`, `avatar`, `premiumType` and `bot`.

## RichPresence

| Field | Limit |
| --- | --- |
| `details`, `state` | 2 to 128 bytes |
| `detailsUrl`, `stateUrl` | 256 bytes |
| `largeImageKey`, `smallImageKey` | 313 bytes |
| `largeImageText`, `smallImageText` | 2 to 128 bytes |
| `largeImageUrl`, `smallImageUrl` | 256 bytes |
| `startTimestamp`, `endTimestamp` | Unix seconds |
| `partyId`, `partySize`, `partyMax`, `partyPrivacy` | ID 128 bytes |
| `matchSecret`, `joinSecret`, `spectateSecret` | 128 bytes |
| `buttons` | 2 buttons, label 32 bytes, URL 512 bytes |
| `type` | `Playing`, `Listening`, `Watching`, `Competing` |
| `statusDisplayType` | What the status line shows: `Name`, `State` or `Details` |
| `instance` | |

Helpers, all chainable: `setText`, `setAssets`, `setParty`, `clearParty`, `addButton`, `clearButtons`, `setElapsed`, `setRemaining`, `setProgress`, `clearTimestamps`, `reset`. Also `clone`, `copyFrom`, `validate`.

Discord hides the buttons when a secret is set.

## MusicPresence

A `RichPresence` for music, with a playback clock.

```haxe
final music = new MusicPresence();
music.artworkKey = 'cover';
music.play('Song', 'Artist', 184.5, 'Album');
DiscordClient.setPresence(music);

music.pause();
DiscordClient.setPresence(music, true);
```

`play`, `pause`, `resume`, `seek`, `stop`, and `sync` after changing fields directly. `position` and `paused` follow playback.

## DiscordAssets

Image keys and CDN links:

| Function | Result |
| --- | --- |
| `mediaProxy(id)` | `mp:<id>` |
| `spotify(id)`, `youtube(id)`, `twitch(name)` | Keys Discord resolves itself |
| `avatarUrl(userId, ?avatar, size)` | User avatar, or the default one |
| `applicationAssetUrl(appId, assetId, size)` | Uploaded app asset |

## Raw API

`Discord` and `Types` map one to one onto `discord_rpc.hpp`, on desktop hxcpp only. You don't need them when using `DiscordClient`.

## Defines

| Define | |
| --- | --- |
| `DISCORD_RPC_DEBUG` | Traces client messages when `log` isn't set. |
| `DISCORD_DISABLE_IO_THREAD` | No native IO thread. `update()` drives the connection. |

## Sample

```
cd sample
haxe build.hxml
```

## License

MIT, see [LICENSE](LICENSE). discord-rpc is MIT, see [project/discord-rpc/LICENSE](project/discord-rpc/LICENSE). RapidJSON is MIT.
