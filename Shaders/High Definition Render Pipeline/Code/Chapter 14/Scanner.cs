using UnityEngine;
using UnityEngine.Rendering;

public class Scanner : MonoBehaviour
{
    public Volume volume;
    private WorldScannerVolume worldScanner;

    private bool isScanning = false;

    private void Start()
    {
        worldScanner = null;
        volume.profile.TryGet(out worldScanner);

        worldScanner?.StopScan();
    }

    private void Update()
    {
        if (Input.GetButtonDown("Fire1"))
        {
            isScanning = true;
            worldScanner?.StartScan(transform.position);
        }
        else if (Input.GetButtonDown("Fire2"))
        {
            isScanning = false;
            worldScanner?.StopScan();
        }

        if (isScanning)
        {
            worldScanner?.UpdateScan();
        }
    }
}
