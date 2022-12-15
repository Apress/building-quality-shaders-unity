using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InteractiveSnow : MonoBehaviour
{
    public Vector2Int snowResolution = new Vector2Int(1024, 1024);
    public float meshSize = 10.0f;
    public float maxSnowHeight = 0.5f;
    public float snowFalloff = 0.25f;
    public float snowEngulf = 0.1f;
    public int maxSnowActors = 20;
    public ComputeShader snowOffsetShader;

    private RenderTexture snowOffsetTex;
    private Material snowMaterial;
    private BoxCollider boxCollider;

    private List<SnowActor> snowActors = new List<SnowActor>();

    private GraphicsBuffer snowActorBuffer;

    struct SnowActorInfo
    {
        public Vector3 position;
        public float radius;
    }

    private void Start()
    {
        snowOffsetTex = new RenderTexture(snowResolution.x, snowResolution.y, 0, RenderTextureFormat.ARGBFloat);
        snowOffsetTex.enableRandomWrite = true;
        snowOffsetTex.Create();

        snowMaterial = GetComponent<Renderer>().material;
        boxCollider = GetComponent<BoxCollider>();

        Vector3 size = boxCollider.size;
        size.y = maxSnowHeight;
        boxCollider.size = size;

        Vector3 center = boxCollider.center;
        center.y = maxSnowHeight / 2.0f;
        boxCollider.center = center;

        snowActorBuffer = new GraphicsBuffer(GraphicsBuffer.Target.Structured, maxSnowActors, sizeof(int) * 4);

        // Set properties that stay constant forever.
        snowOffsetShader.SetFloat("_SnowFalloff", snowFalloff / meshSize);
        snowOffsetShader.SetVector("_SnowResolution", (Vector2)snowResolution);

        snowMaterial.SetFloat("_MaxSnowHeight", maxSnowHeight);
        snowMaterial.SetTexture("_SnowOffset", snowOffsetTex);

        int kernel = snowOffsetShader.FindKernel("InitializeOffsets");
        snowOffsetShader.SetTexture(kernel, "_SnowOffset", snowOffsetTex);
        snowOffsetShader.Dispatch(kernel, snowResolution.x / 8, snowResolution.y / 8, 1);
    }

    private void Update()
    {
        if (snowActors.Count == 0)
        {
            return;
        }

        ResetSnowActorBuffer();

        int kernel = snowOffsetShader.FindKernel("ApplyOffsets");
        snowOffsetShader.SetTexture(kernel, "_SnowOffset", snowOffsetTex);
        snowOffsetShader.SetBuffer(kernel, "_SnowActors", snowActorBuffer);
        snowOffsetShader.SetInt("_SnowActorCount", snowActors.Count);
        snowOffsetShader.Dispatch(kernel, snowResolution.x / 8, snowResolution.y / 8, 1);
    }

    private void ResetSnowActorBuffer()
    {
        var snowActorInfoList = new SnowActorInfo[snowActors.Count];

        for(int i = 0; i < snowActors.Count; ++i)
        {
            var snowActor = snowActors[i];
            Vector3 relativePos = transform.InverseTransformPoint(snowActor.GetGroundPos());

            if (snowActors[i].IsMoving() && relativePos.y >= 0.0f)
            {
                relativePos.x /= meshSize;
                relativePos.z /= meshSize;
                relativePos.y /= maxSnowHeight;
                relativePos += new Vector3(0.5f, 0.0f, 0.5f);

                var snowActorInfo = new SnowActorInfo()
                {
                    position = relativePos,
                    radius = (snowActor.GetRadius() - snowEngulf) / meshSize
                };

                snowActorInfoList[i] = snowActorInfo;
            }
        }
        
        snowActorBuffer.SetData(snowActorInfoList);
    }

    private void OnTriggerEnter(Collider other)
    {
        var snowActor = other.GetComponent<SnowActor>();

        if(snowActor != null && snowActors.Count < maxSnowActors)
        {
            snowActors.Add(snowActor);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        var snowActor = other.GetComponent<SnowActor>();

        if (snowActor != null)
        {
            snowActors.Remove(snowActor);
        }
    }

    private void OnDestroy()
    {
        snowActorBuffer.Dispose();
    }
}
