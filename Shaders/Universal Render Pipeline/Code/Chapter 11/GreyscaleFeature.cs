using UnityEngine.Rendering.Universal;

public class GreyscaleFeature : ScriptableRendererFeature
{
    GreyscaleRenderPass pass;

    public override void Create()
    {
        name = "Greyscale";
        pass = new GreyscaleRenderPass();
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        pass.Setup(renderer, "Greyscale Post Process");
    }
}
