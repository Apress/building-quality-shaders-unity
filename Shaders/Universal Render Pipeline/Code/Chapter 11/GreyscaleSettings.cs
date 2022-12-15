using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[System.Serializable, VolumeComponentMenu("Examples/Greyscale")]
public sealed class GreyscaleSettings : VolumeComponent, IPostProcessComponent
{
    [Tooltip("How strongly the effect is applied. " +
        "0 = original image, 1 = fully greyscale.")]
    public ClampedFloatParameter strength = new ClampedFloatParameter(0.0f, 0.0f, 1.0f);

    public bool IsActive() => strength.value > 0.0f && active;

    public bool IsTileCompatible() => false;
}
