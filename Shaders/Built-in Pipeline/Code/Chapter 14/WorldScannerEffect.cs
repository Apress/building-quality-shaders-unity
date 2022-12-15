using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WorldScannerEffect : MonoBehaviour
{
    [Tooltip("Is the effect active?")]
    public new bool enabled = false;

    [Tooltip("The world space origin point of the scan.")]
    public Vector3 scanOrigin = Vector3.zero;

    [Tooltip("How quickly, in units per second, the scan propogates.")]
    public float scanSpeed = 1.0f;

    [Tooltip("How far, in Unity units, the scan has travelled from the origin.")]
    public float scanDist = 0.0f;

    [Tooltip("The distance, in Unity units, the scan texture gets applied over.")]
    public float scanWidth = 1.0f;

    [Tooltip("An x-by-1 ramp texture representing the scan color.")]
    public Texture2D overlayRampTex;

    [ColorUsage(true, true)]
    [Tooltip("An additional HDR color tint applied to the scan.")]
    public Color overlayColor = Color.white;

    private Material mat;
    private Camera cam;

    private void Start()
    {
        mat = new Material(Shader.Find("Examples/ImageEffect/WorldScan"));
        cam = Camera.main;

        cam.depthTextureMode = DepthTextureMode.Depth;
    }

    private void Update()
    {
        if (Input.GetButtonDown("Fire1"))
        {
            StartScan(transform.position);
        }
        else if (Input.GetButtonDown("Fire2"))
        {
            StopScan();
        }

        if (enabled)
        {
            scanDist += scanSpeed * Time.deltaTime;
        }
    }

    private void StartScan(Vector3 origin)
    {
        enabled = true;
        scanOrigin = origin;
        scanDist = 0.0f;
    }

    private void StopScan()
    {
        enabled = false;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        if(!enabled || overlayRampTex == null)
        {
            Graphics.Blit(src, dst);
            return;
        }

        Matrix4x4 view = cam.worldToCameraMatrix;
        Matrix4x4 proj = GL.GetGPUProjectionMatrix(cam.projectionMatrix, false);
        
        Matrix4x4 clipToWorld = Matrix4x4.Inverse(proj * view);

        mat.SetMatrix("_ClipToWorld", clipToWorld);
        mat.SetVector("_ScanOrigin", scanOrigin);
        mat.SetFloat("_ScanDist", scanDist);
        mat.SetFloat("_ScanWidth", scanWidth);
        mat.SetTexture("_OverlayRampTex", overlayRampTex);
        mat.SetColor("_OverlayColor", overlayColor);

        Graphics.Blit(src, dst, mat);
    }
}
