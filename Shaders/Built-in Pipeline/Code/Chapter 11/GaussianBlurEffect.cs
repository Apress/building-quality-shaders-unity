using UnityEngine;

public class GaussianBlurEffect : MonoBehaviour
{
    [Range(1, 101)]
    public int kernelSize = 1;
    private Material mat;

    void Start()
    {
        mat = new Material(Shader.Find("Examples/ImageEffect/GaussianBlur"));
    }

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        RenderTexture tmp = RenderTexture.GetTemporary(src.descriptor);

        mat.SetInt("_KernelSize", kernelSize);

        Graphics.Blit(src, tmp, mat, 0);
        Graphics.Blit(tmp, dst, mat, 1);

        RenderTexture.ReleaseTemporary(tmp);
    }
}
