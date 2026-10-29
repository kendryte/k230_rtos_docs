# Image Sensor Support List

The current SDK includes built-in driver support for multiple image sensor models. The list is as follows (for Timing, refer to each Sensor's `sensor_csi*_mode_list.c`):

| Model | Supported Timing List |
| :--- | :--- |
| GC2093 | 1920x1080@30、1920x1080@60、1280x960@90、1280x720@90 |
| OV5647 | 2592x1944@15、1920x1080@30、1280x960@45、1280x720@60、640x480@90、640x480@60 |
| IMX290 | 1920x1080@30 |
| IMX335 | 1920x1080@30（2-lane）、2592x1944@30（2-lane / 4-lane；4-lane requires `CSI0 LANE NUM=4LANE` and enabling `Enable 4LANE Configure`） |
| IMX415 | 3840x2160@30（4-lane only；requires `CSI0 LANE NUM=4LANE`） |
| IMX675 | 2592x1944@30 |
| SC130GS | 1280x1024@90（MONO） |
| SC132GS | 1080x1280@120、640x480@240（MONO） |
| XS9950 | 1280x720@25（YUV422） |
| BF3238 | 1920x1080@30、1280x960@30 |
| OV13850 | 3840x2160@7（2-lane）；4-lane: 3840x2160@27、1920x1080@30、1920x1080@60、2112x1568@30、2112x1568@60（requires `CSI0 LANE NUM=4LANE` and enabling `Enable 4LANE Configure`） |

> Note:
>
> - The support list is continuously updated as the code evolves; on the board, use the `list_sensor` output as the source of truth
> - CSI0 defaults to **2LANE**; after selecting **4LANE**, CSI0 4-lane mode can be compiled in. `Enable CSI1` can still be compiled, but at runtime CSI0 4LANE and CSI1 cannot be initialized simultaneously (the original wiring still shares the PHY)
> - For the same resolution with 2L/4L, use `sample_vicap_sensor -lane 2|4` (or `-stype`) at runtime to distinguish them. For details, see [How to Configure a Sensor](../userguide/how_to_configure_sensor.md)
> - 4K Sensor limitations: **YUV/RGB preview** acquisition above approximately 3072×2160 requires `VICAP_WORK_SW_TILE_MODE`, and usually supports only one Sensor; `sample_vicap_sensor -ofmt 3` (RAW Dump) uses **ONLINE** by default (use `-tile 1` to force SW_TILE). For details, see [VICAP Sensor Demo](../app_develop_guide/media/vicap.md).

## Related Documentation

- [How to Configure a Sensor](../userguide/how_to_configure_sensor.md): menuconfig (including **CSI0 LANE NUM**), CSI/4LANE, application-layer `-lane` matching, ISP bin/XML switching, and `list_sensor` verification
- [VICAP Sensor Demo](../app_develop_guide/media/vicap.md): `sample_vicap_sensor` parameters, operating modes (including `-ofmt 3` ONLINE), and Dump usage
- [How to Add a Sensor](../advanced_development_guide/how_to_add_sensor.md): integrating a new model driver from scratch, mode tables, and application-layer integration
- [How to Perform ISP Calibration](../advanced_development_guide/how_to_calibrate_isp.md)
- [How to Perform ISP Tuning](../advanced_development_guide/how_to_tune_isp.md)

## Board-Side Verification

After confirming that the target Sensor driver has been enabled in the image, run `list_sensor` on the board to view the supported cameras and modes, and then run the corresponding VICAP/Sensor example for verification. For configuration steps, see [How to Configure a Sensor](../userguide/how_to_configure_sensor.md).
