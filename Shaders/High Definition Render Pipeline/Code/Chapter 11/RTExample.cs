using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RTExample : MonoBehaviour
{
    public Camera exampleCamera;
    public Material exampleMaterial;

    private RenderTexture rt;

    private void Start()
    {
        rt = new RenderTexture(1920, 1080, 32, RenderTextureFormat.ARGB32);
        rt.Create();

        exampleCamera.targetTexture = rt;
        exampleMaterial.SetTexture("_MainTex", rt);
    }
}
