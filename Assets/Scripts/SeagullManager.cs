using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SeaFullManager : MonoBehaviour
{
public Material geomMaterial;
    public int birdCount = 1;
    public float areaSize = 5f;

    private ComputeBuffer positionBuffer;

    struct SeagullData {
        public Vector3 position;
        public float phase;
    }

    void Start() {
        CreateSeagullData();
    }

    void CreateSeagullData() {
        SeagullData[] data = new SeagullData[birdCount];
        
        for(int i = 0; i < birdCount; i++) {
            data[i].position = new Vector3(
                Random.Range(-areaSize, areaSize),
                Random.Range(10f, 20f),
                Random.Range(-areaSize, areaSize)
            );
            
            data[i].phase = Random.Range(0f, 2f * Mathf.PI);
        }

        positionBuffer = new ComputeBuffer(birdCount, sizeof(float) * 4);
        positionBuffer.SetData(data);
        geomMaterial.SetBuffer("_SeagullBuffer", positionBuffer);
    }

    void OnDestroy() {
        positionBuffer.Release();
    }
}
