using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[System.Serializable, VolumeComponentMenu("Examples/World Scanner")]
public class WorldScanSettings : VolumeComponent, IPostProcessComponent
{
    [Tooltip("Is the effect active?")]
    public BoolParameter enabled = new BoolParameter(false);

    [Tooltip("The world space origin point of the scan.")]
    public Vector3Parameter scanOrigin = new Vector3Parameter(Vector3.zero);

    [Tooltip("How quickly, in units per second, the scan propogates.")]
    public FloatParameter scanSpeed = new FloatParameter(1.0f);

    [Tooltip("How far, in Unity units, the scan has travelled from the origin.")]
    public FloatParameter scanDist = new FloatParameter(0.0f);

    [Tooltip("The distance, in Unity units, the scan texture gets applied over.")]
    public FloatParameter scanWidth = new FloatParameter(1.0f);

    [Tooltip("An x-by-1 ramp texture representing the scan color.")]
    public Texture2DParameter overlayRampTex = new Texture2DParameter(null);

    [Tooltip("An additional HDR color tint applied to the scan.")]
    public ColorParameter overlayColor = new ColorParameter(Color.white, true, true, true);

    public void StartScan(Vector3 origin)
    {
        enabled.Override(true);
        scanOrigin.Override(origin);
        scanDist.Override(0.0f);
    }

    public void UpdateScan()
    {
        scanDist.value += scanSpeed.value * Time.deltaTime;
    }

    public void StopScan()
    {
        enabled.Override(false);
    }

    public bool IsActive() => overlayRampTex.value != null && enabled.value && active;

    public bool IsTileCompatible() => false;
}
