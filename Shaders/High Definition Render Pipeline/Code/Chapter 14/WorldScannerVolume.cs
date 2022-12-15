using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

[Serializable, VolumeComponentMenu("Post-processing/Examples/WorldScan")]
public sealed class WorldScannerVolume : CustomPostProcessVolumeComponent, IPostProcessComponent
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

    Material m_Material;

    public bool IsActive() => m_Material != null && overlayRampTex.value != null && enabled.value;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.BeforePostProcess;

    const string kShaderName = "Examples/ImageEffects/WorldScan";

    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume WorldScannerVolume is unable to load.");
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        m_Material.SetVector("_ScanOrigin", scanOrigin.value);
        m_Material.SetFloat("_ScanDist", scanDist.value);
        m_Material.SetFloat("_ScanWidth", scanWidth.value);
        m_Material.SetTexture("_OverlayRampTex", overlayRampTex.value);
        m_Material.SetColor("_OverlayColor", overlayColor.value);

        m_Material.SetTexture("_InputTexture", source);
        HDUtils.DrawFullScreen(cmd, m_Material, destination);
    }

    public override void Cleanup()
    {
        CoreUtils.Destroy(m_Material);
    }

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
}
