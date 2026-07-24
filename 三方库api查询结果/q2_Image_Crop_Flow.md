# q2_Image_Crop_Flow Cangjie TPC Implementation Guide

## Original Request

Migrate Android image crop/edit flow from Java UCrop 2.2.2 plus file-copy-back behavior to Cangjie/HarmonyOS: open an image from gallery detail, crop it, write the edited result back to the album/gallery path, and note any capability limits or required workarounds.

## Task Segments

| Segment | Task |
| --- | --- |
| q2_s1 | Open an image from the gallery for cropping. |
| q2_s2 | Perform image crop operation on the selected image. |
| q2_s3 | Write the cropped image back to the original gallery path. |

## Recommended Repository Overview

| Repository | Path | Covered Segments | Status |
| --- | --- | --- | --- |
| photoview4cj | `/Users/xutangzhi/Desktop/exp_projects/x2cangjie/plugins/cangjie-tpc-mcp/repos/photoview4cj` | q2_s1, q2_s2, q2_s3 | Succeeded |

## photoview4cj

### Covered Tasks

- **q2_s1** — Open an image from the gallery for cropping. Not directly covered. The library provides `PhotoView` which can display images from `String` (URI), `AppResource`, or `PixelMap`, but there is no gallery picker or file-open API.
- **q2_s2** — Perform image crop operation on the selected image. Not directly covered. The library provides interactive zoom/pan/rotate display (gesture-based matrix transforms), but it does not expose a crop region selection or a crop output mechanism.
- **q2_s3** — Write the cropped image back to the original gallery path. Not covered at all. No file I/O, no `PhotoAccessHelper` / `MediaDataHelper` / file-write APIs exist in the repository.

### Conclusion

This repository is a **photoview4cj** Cangjie image-viewer component for HarmonyOS applications. It provides a `PhotoView` UI component and a `PhotoViewModel` data class for displaying, zooming, panning, and rotating images. The library:

- Does **not** include any gallery-picker or album-browsing APIs.
- Does **not** implement any crop-user-interface (e.g., selection rectangle, crop confirmation).
- Does **not** perform image pixel-level crop operations.
- Does **not** contain any file-write, `PhotoAccessHelper`, or gallery-path persistence code.

The crop-and-save-back-to-gallery flow described in the query must be built on top of this library using HarmonyOS system capabilities (`ohos.multimedia.media`, `PhotoAccessHelper`, `ohos.file.fs`, etc.) that are not present in this repository.

### Matching APIs or Implementation Locations

| API / Implementation | Type | File | Description |
|---|---|---|---|
| `PhotoView` (component) | UI Component | `photoView/src/main/cangjie/photo_view.cj:18` | Displays an image with zoom/pan/rotate gestures. Supports image sources: `String` URI, `AppResource`, `PixelMap`. |
| `PhotoViewModel` | Data class | `photoView/src/main/cangjie/photo_view_model.cj:24` | Observable model holding image source, scale, rotation, offset, and matrix transform state. |
| `PhotoViewModel.setImageURI(src: String)` | Method | `photoView/src/main/cangjie/photo_view_model.cj:72` | Sets image source from a URI string (e.g., network URL or local file path). |
| `PhotoViewModel.setImageElement(src: PixelMap)` | Method | `photoView/src/main/cangjie/photo_view_model.cj:80` | Sets image source from a `PixelMap` object (potentially loaded from gallery). |
| `PhotoViewModel.setImageResource(src: AppResource)` | Method | `photoView/src/main/cangjie/photo_view_model.cj:76` | Sets image source from an `@r` resource. |
| `PhotoView.zoomTo(scale, durationMs)` | Method | `photoView/src/main/cangjie/photo_view.cj:26` | Animates zoom to a given scale factor, clamped by min/max scale. |
| `PhotoViewModel.updateMatrix()` | Method | `photoView/src/main/cangjie/photo_view_model.cj:142` | Recalculates the transform matrix after scale/offset/rotation changes. |
| `PhotoViewModel.getRectF()` | Method | `photoView/src/main/cangjie/photo_view_model.cj:239` | Returns the current visible rectangle (`RectF`) of the displayed image. |
| `RectF` | Class | `photoView/src/main/cangjie/rect_f.cj:6` | Represents a float-precision rectangle used for hit-testing and bounds reporting. |
| Interpolated listener interfaces | Interfaces | `photoView/src/main/cangjie/interfaces.cj:1-109` | `OnPhotoTapListener`, `OnMatrixChangedListener`, `OnScaleChangedListener`, `OnViewDragListener`, etc. |

### Usage

The library is imported as a module dependency (`photoView`) and used in ArkUI-style Cangjie components. The typical integration pattern is:

1. Create a `PhotoViewModel` instance.
2. Call `initMatrix()` followed by image source setters (`setImageURI`, `setImageResource`, or `setImageElement`).
3. Pass the model to the `PhotoView` component in the `build()` tree.

### Minimal Example

```cangjie
import photoView.*
import ohos.state_macro_manage.*

@Entry
@Component
public class CropShell {
    @State
    var model: PhotoViewModel = PhotoViewModel()

    func aboutToAppear(): Unit {
        model.initMatrix()
        model.setImageURI("file://data/storage/el2/base/haps/entry/files/photo.jpg")
    }

    func build(): Unit {
        Column() {
            PhotoView(model: model)
        }.width(100.percent).height(100.percent)
    }
}
```

### Notes

The `PhotoViewModel` exposes the current visible image rectangle through `getRectF()`, which returns the display bounds after zoom/pan transforms. This rectangle could theoretically be used to derive a crop region, but the library does not provide a cropping UI, pixel extraction, output encoding, or file-writing capability. For a full crop-and-save-back flow, developers must supplement this library with:

- HarmonyOS `ohos.multimedia.media` / `ohos.multimedia.image` APIs (`ImagePacker`, `PixelMap` creation and cropping).
- HarmonyOS `PhotoAccessHelper` for reading gallery images and writing back to the album path.
- Manual selection rectangle UI (or reuse of the internal `RectF` as a crop region).
- On HarmonyOS, writing to the original gallery path after edit requires `PhotoAccessHelper.createAsset()` (since direct file path replacement is not supported), and the edited image must be URI-based, not directly overwriting the original source.
