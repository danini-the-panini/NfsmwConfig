# NfsmwConfig

A config editor for [Need for Speed Most Wanted (2005)](https://en.wikipedia.org/wiki/Need_for_Speed:_Most_Wanted_(2005_video_game)) [Widescreen Patch (by thirteenag)](https://thirteenag.github.io/wfp#nfsmw), useful if you are running the game under Wine on macOS.

# How it works

Run the app via the command line passing in a path to the Widescreen Patch .ini file.

```bash
NfsmwConfig.app/Contents/MacOS/NfsmwConfig "path/to/scripts/nfsmw_res.ini"
```

It will read the contents, detect and list available screen resolutions, and present a form allowing for easy configuration of the Widescreen Patch settings.

Once you click "Okay", the new settings will be written back to the .ini file and the application will close.

# Intended Use

I originally built this to allow for an easier way to customize the screen resolution when launching Need for Speed Most Wanted via my custom built [Wineskin Wrapper](http://wineskin.urgesoftware.com/).
My Wineskin Wrapper contains the NfsmwConfig.app in the root, and in `Contents/Resources/WineskinStartupScript` there is a line similar to the following:

```sh
$CONTENTSFOLD/../NfsmwConfig.app/Contents/MacOS/NfsmwConfig "$CONTENTSFOLD/../drive_c/Path/To/Need for Speed Most Wanted/scripts/nfsmw_res.ini"
```
(If you use this script, make sure you set the correct path to your "Need for Speed" installation within the Winesckin Wrapper and **do not** escape the spaces with `\` otherwise it won't find the file)

With that installed, the configuration app opens before the game, and upon clicking okay the new settings are written and the game then opens with the new configuration.

# Known issues

1. If you click the close button (red circle), the window disappears but the application continues to run. This will prevent game launch until you quit the application with `⌘-Q`.
2. With the above Wineskin startup script, if you quit the application with `⌘-Q`, new settings will not be written but the game will still run. This is because Wineskin has no way of knowing how NfsmwConfig was quit.
3. NfsmwConfig was built for an _older_ version of thirteenag's Widescreen fix (I don't know which version it is exactly), because I was having an issue with the newer version on macOS. However, it may still work with newer versions as long as the .ini properties match.
4. There is no cancel button (see point 2).

# Credits

1. [thirteenag](https://thirteenag.github.io) for the Widescreen Patch for which this is built.
2. [G-rawl](https://g-rawl.deviantart.com/) for the [NFS Most Wanted iCon](https://g-rawl.deviantart.com/art/NFS-Most-Wanted-iCon-220078613). (Licensed under [CC BY-NC 3.0](https://creativecommons.org/licenses/by-nc/3.0/))

# Contributing:

1. Fork it
2. Branch it
3. Change it
4. Pull-Request it
