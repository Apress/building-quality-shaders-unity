using UnityEngine;
using UnityEngine.Rendering;

public class Scanner : MonoBehaviour
{
    public Volume volume;
    private WorldScanSettings scanSettings = null;

    private bool isScanning = false;

    private void Start()
    {
        if(volume == null || volume.profile == null)
        {
            return;
        }

        if(volume.profile.TryGet(out scanSettings))
        {
            scanSettings.StopScan();
        }
    }

    private void Update()
    {
        if(Input.GetButtonDown("Fire1"))
        {
            isScanning = true;
            scanSettings?.StartScan(transform.position);
        }
        else if(Input.GetButtonDown("Fire2"))
        {
            isScanning = false;
            scanSettings?.StopScan();
        }

        if(isScanning)
        {
            scanSettings?.UpdateScan();
        }
    }
}
