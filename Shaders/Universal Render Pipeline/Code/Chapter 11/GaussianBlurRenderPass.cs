using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class GaussianBlurRenderPass : ScriptableRenderPass
{
    private Material material;
    private GaussianBlurSettings settings;

    private RenderTargetIdentifier source;
    private RenderTargetIdentifier mainTex;
    private RenderTargetIdentifier tempTex;
    private string profilerTag;

    public void Setup(ScriptableRenderer renderer, string profilerTag)
    {
        this.profilerTag = profilerTag;

        source = renderer.cameraColorTarget;
        VolumeStack stack = VolumeManager.instance.stack;
        settings = stack.GetComponent<GaussianBlurSettings>();
        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

        if (settings != null && settings.IsActive())
        {
            material = new Material(Shader.Find("Examples/ImageEffects/GaussianBlur"));
            renderer.EnqueuePass(this);
        }
    }

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        if (settings == null)
        {
            return;
        }

        int id = Shader.PropertyToID("_MainTex");
        mainTex = new RenderTargetIdentifier(id);
        cmd.GetTemporaryRT(id, cameraTextureDescriptor);

        id = Shader.PropertyToID("_TempTex");
        tempTex = new RenderTargetIdentifier(id);
        cmd.GetTemporaryRT(id, cameraTextureDescriptor);

        base.Configure(cmd, cameraTextureDescriptor);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (!settings.IsActive())
        {
            return;
        }

        CommandBuffer cmd = CommandBufferPool.Get(profilerTag);

        cmd.Blit(source, mainTex);

        material.SetInt("_KernelSize", settings.kernelSize.value);

        cmd.Blit(mainTex, tempTex, material, 0);
        cmd.Blit(tempTex, source, material, 1);

        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();
        CommandBufferPool.Release(cmd);
    }

    public override void FrameCleanup(CommandBuffer cmd)
    {
        cmd.ReleaseTemporaryRT(Shader.PropertyToID("_MainTex"));
        cmd.ReleaseTemporaryRT(Shader.PropertyToID("_TempTex"));
    }
}
