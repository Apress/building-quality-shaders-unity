using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

[Serializable, VolumeComponentMenu("Post-processing/Examples/Gaussian Blur")]
public sealed class GaussianBlurVolume : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("How large the convolution kernel is. " +
        "A larger kernel means stronger blurring.")]
    public ClampedIntParameter kernelSize = new ClampedIntParameter(1, 1, 101);

    Material m_Material;
    RTHandle tempTex;

    public bool IsActive() => m_Material != null && kernelSize.value > 1;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    const string kShaderName = "Examples/ImageEffects/GaussianBlur";

    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume Gaussian Blur is unable to load.");
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        tempTex = RTHandles.Alloc(Vector2.one);

        m_Material.SetInt("_KernelSize", kernelSize.value);

        m_Material.SetTexture("_SourceTex", source);
        HDUtils.DrawFullScreen(cmd, m_Material, tempTex, shaderPassId: 0);

        m_Material.SetTexture("_TempTex", tempTex);
        HDUtils.DrawFullScreen(cmd, m_Material, destination, shaderPassId: 1);
    }

    public override void Cleanup()
    {
        tempTex.Release();
        CoreUtils.Destroy(m_Material);
    }
}
