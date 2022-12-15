using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[System.Serializable, VolumeComponentMenu("Examples/Gaussian Blur")]
public class GaussianBlurSettings : VolumeComponent, IPostProcessComponent
{
    [Tooltip("How large the convolution kernel is. " +
        "A larger kernel means stronger blurring.")]
    public ClampedIntParameter kernelSize = new ClampedIntParameter(1, 1, 1001);

    public bool IsActive() => kernelSize.value > 1 && active;

    public bool IsTileCompatible() => false;
}
