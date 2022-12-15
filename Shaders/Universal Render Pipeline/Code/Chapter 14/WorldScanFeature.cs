using UnityEngine.Rendering.Universal;

public class WorldScanFeature : ScriptableRendererFeature
{
    WorldScanRenderPass pass;

    public override void Create()
    {
        name = "World Scanner";
        pass = new WorldScanRenderPass();
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        pass.Setup(renderer, "World Scan Post Process");
    }
}
