using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MasterIntensity : MonoBehaviour
{
    [Range(0f, 1f)]
    public float Intensity = 0f;
    private float _intensity = 0f;

    public List<Material> Materials;
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void FixedUpdate() {
        if(_intensity == Intensity) return;

        _intensity = Intensity;
        foreach (Material m in Materials)
        {
            m.SetFloat("_Intensity", _intensity);
        }
    }
}
