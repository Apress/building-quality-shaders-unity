using UnityEngine;

public class GreyscaleEffect : MonoBehaviour
{
    private Material mat;

    void Start()
    {
        mat = new Material(Shader.Find("Examples/ImageEffect/Greyscale"));
    }
    
    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        Graphics.Blit(src, dst, mat);
    }
}
