# q1_Video_Player_Migration Cangjie TPC Implementation Guide

## Original Request

Migrate Android gallery app media playback from Java ExoPlayer 2.6.0 to Cangjie/HarmonyOS: open local file/content/http/https video URIs from an activity route, keep playback controls/fullscreen/back navigation, and identify the closest production-path APIs or examples for a LeafPic-style video player page.

## Task Segments

| Segment | Task |
| --- | --- |
| q1_s1 | Open video URIs from supported schemes (file, content, http, https). |
| q1_s2 | Implement basic playback controls (play, pause, seek). |
| q1_s3 | Implement fullscreen toggle for the video player. |
| q1_s4 | Implement back navigation from the video player page. |

## Recommended Repository Overview

| Repository | Path | Covered Segments | Status |
| --- | --- | --- | --- |
| ijkplayer-ffi | `/Users/xutangzhi/Desktop/exp_projects/x2cangjie/plugins/cangjie-tpc-mcp/repos/ijkplayer-ffi` | q1_s1, q1_s2, q1_s3, q1_s4 | Succeeded |

## ijkplayer-ffi

### Covered Tasks

- **q1_s1** (Open video URIs from file, content, http, https): Supported via `setDataSource(url)` — the same API handles all schemes. The `setDataSourceHeader` method explicitly sets a `protocol_whitelist` that includes `file`, `http`, `https`, and `data`.
- **q1_s2** (Playback controls: play, pause, seek): Fully covered by `start()`, `pause()`, and `seekTo(msec)`.
- **q1_s3** (Fullscreen toggle): No dedicated API; the player component uses `XComponent` with `aspectRatio`. Fullscreen would be achieved by toggling the page/window display mode manually (e.g., via `window.setWindowLayoutFullScreen`).
- **q1_s4** (Back navigation): No dedicated API; back navigation is handled via HarmonyOS `@ohos.router` APIs (e.g., `router.back()`) in the page's `@Entry` component, not exposed by this library.

### Conclusion

The `ijkplayer-ffi` package directly covers opening multi-scheme video URIs and implementing play/pause/seek controls. Fullscreen and back navigation are page-level concerns that must be built on top of the library using standard HarmonyOS ArkUI patterns. The primary public API is the ArkTS class `IjkMediaPlayer`, exposed via `ijkplayer/index.ets`. The Cangjie FFI bindings live in the `ijkforcj` module using `foreign` blocks.

### Matching APIs or Implementation Locations

| API / Implementation | Type | File | Description |
|---|---|---|---|
| `IjkMediaPlayer.getInstance()` | Class (ETS) | `ijkplayer/src/main/ets/ijkplayer/IjkMediaPlayer.ets:96` | Singleton access to the player |
| `setDataSource(url: string)` | Method | `ijkplayer/src/main/ets/ijkplayer/IjkMediaPlayer.ets:134` | Set video URI (file, http, https, content, etc.) |
| `setDataSourceHeader(headers)` | Method | `ijkplayer/src/main/ets/ijkplayer/IjkMediaPlayer.ets:144` | Set HTTP headers and whitelist `protocol_whitelist` |
| `prepareAsync()` | Method | `ijkplayer/src/main/ets/ijkplayer/IjkMediaPlayer.ets:192` | Async prepare |
| `start()` | Method | `ijkplayer/src/main/ets/ijkplayer/IjkMediaPlayer.ets:198` | Start/resume playback |
| `pause()` | Method | `ijkplayer/src/main/ets/ijkplayer/IjkMediaPlayer.ets:207` | Pause playback |
| `stop()` | Method | `ijkplayer/src/main/ets/ijkplayer/IjkMediaPlayer.ets:213` | Stop playback |
| `seekTo(msec: string)` | Method | `ijkplayer/src/main/ets/ijkplayer/IjkMediaPlayer.ets:225` | Seek to position in ms |
| `setOption(category, key, value)` | Method | `ijkplayer/src/main/ets/ijkplayer/IjkMediaPlayer.ets:173` | Set player/format options |
| `setSpeed(speed: string)` | Method | `ijkplayer/src/main/ets/ijkplayer/IjkMediaPlayer.ets:241` | Set playback speed (0.25–4) |
| `setLoopCount(looping: boolean)` | Method | `ijkplayer/src/main/ets/ijkplayer/IjkMediaPlayer.ets:338` | Set loop playback |
| `setVolume(leftVolume, rightVolume)` | Method | `ijkplayer/src/main/ets/ijkplayer/IjkMediaPlayer.ets:330` | Set left/right volume |
| `setScreenOnWhilePlaying(on: boolean)` | Method | `ijkplayer/src/main/ets/ijkplayer/IjkMediaPlayer.ets:233` | Keep screen on during playback |
| `getCurrentPosition(): number` | Method | `ijkplayer/src/main/ets/ijkplayer/IjkMediaPlayer.ets:299` | Current playback position |
| `getDuration(): number` | Method | `ijkplayer/src/main/ets/ijkplayer/IjkMediaPlayer.ets:295` | Total video duration |
| `isPlaying(): boolean` | Method | `ijkplayer/src/main/ets/ijkplayer/IjkMediaPlayer.ets:253` | Check if currently playing |
| `native_setup()` | Method | `ijkplayer/src/main/ets/ijkplayer/IjkMediaPlayer.ets:576` | Initialize native player |
| `OnPreparedListener` | Interface | `ijkplayer/src/main/ets/ijkplayer/callback/OnPreparedListener.ets` | Prepared callback |
| `OnCompletionListener` | Interface | `ijkplayer/src/main/ets/ijkplayer/callback/OnCompletionListener.ets` | Completion callback |
| `OnErrorListener` | Interface | `ijkplayer/src/main/ets/ijkplayer/callback/OnErrorListener.ets` | Error callback |
| `OnSeekCompleteListener` | Interface | `ijkplayer/src/main/ets/ijkplayer/callback/OnSeekCompleteListener.ets` | Seek complete callback |
| `cjSetDataSource` / `cjSetOption` (Cangjie FFI) | Cangjie func | `ijkforcj/src/main/cangjie/src/ijkplayer_cj.cj:30` | Cangjie native FFI binding for data source |
| `ijkplayer_napi_proxy.cpp` | C++ NAPI | `ijkplayer/src/main/cpp/proxy/ijkplayer_napi_proxy.cpp` | Native proxy bridging C++ and ArkTS |
| `entry/src/main/ets/entryability/EntryAbility.ets` | Ability | `entry/src/main/ets/entryability/EntryAbility.ets` | Entry point; loads `SampleVideoListPage` |
| `entry/src/main/ets/pages/SampleVideoListPage.ets` | Page | `entry/src/main/ets/pages/SampleVideoListPage.ets` | Sample page with `XComponent` usage pattern |

### Usage

The library is consumed as an ArkTS/ETS `har` package (`ijkplayer`). The typical integration pattern is:

1. Add a `XComponent` with `libraryname: 'ijkplayer_napi'` in the page.
2. In the `onLoad` callback, call `IjkMediaPlayer.getInstance().setContext(id, context)`.
3. Call `native_setup()`, then `setDataSource(url)`, attach listeners, and `prepareAsync()` + `start()`.

### Minimal Example

```ets
// Page.ets — requires XComponent in template
import { IjkMediaPlayer, OnPreparedListener, OnErrorListener } from 'ijkplayer'

@Entry
@Component
struct VideoPage {
  private mIjkPlayer: IjkMediaPlayer = IjkMediaPlayer.getInstance()
  private mXComponentId: string = 'xcomponentId'

  build() {
    Column() {
      XComponent({ id: this.mXComponentId, type: 'surface', libraryname: 'ijkplayer_napi' })
        .onLoad((context) => {
          this.mIjkPlayer.setContext(this.mXComponentId, context)
          this.mIjkPlayer.setDebug(true)
          this.mIjkPlayer.native_setup()
          this.mIjkPlayer.setDataSource('https://example.com/sample.mp4')
          this.mIjkPlayer.setOnPreparedListener({ onPrepared: () => { this.mIjkPlayer.start() } })
          this.mIjkPlayer.setOnErrorListener({ onError: (what, extra) => { console.error('Error', what, extra) } })
          this.mIjkPlayer.prepareAsync()
        })
        .width('100%').aspectRatio(16 / 9)
    }.width('100%').height('100%')
  }

  aboutToDisappear() {
    this.mIjkPlayer.stop()
    this.mIjkPlayer.release()
  }
}
```

### Notes

- **Scheme support**: The `setDataSource(url)` accepts `file://`, `http://`, `https://`, and content URIs. The library whitelists these in `setDataSourceHeader`.
- **Fullscreen**: Not provided by the library; implement via `window.getTopWindow().setWindowLayoutFullScreen(true)` and toggle `XComponent` dimensions.
- **Back navigation**: Not part of the library; use HarmonyOS `router.back()` or `NavPathStack.pop()` in the `@Entry` page.
- **Cangjie FFI layer** is in package `ijkplayer4cj` within `ijkforcj/src/main/cangjie/src/` and is bridged to ETS via `requireCJLib("libijkplayer4cj.so")`.
- **Entry point**: The sample app entry loads `SampleVideoListPage` (`entry/src/main/ets/pages/SampleVideoListPage.ets`).
