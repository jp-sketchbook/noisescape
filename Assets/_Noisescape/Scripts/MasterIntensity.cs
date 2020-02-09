using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MasterIntensity : MonoBehaviour
{
    [Range(0f, 1f)]
    public float Intensity = 0f;
    private float _intensity = 0f;

    public float Increment = 0.01f;
    private bool _direction; // false for up, true for down

    public List<Material> Materials;
    
    // Start is called before the first frame update
    void Start()
    {
        Intensity = 0f;
        _direction = false;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void FixedUpdate() {
        if(_direction) {
            Intensity -= Increment * Time.deltaTime;
            if(Intensity <= 0f) {
                Intensity = 0f;
                _direction = false;
            }
        }
        else {
            Intensity += Increment * Time.deltaTime;
            if(Intensity >= 1f) {
                Intensity = 1f;
                _direction = true;
            }
        }
        
        if(_intensity == Intensity) return;
        _intensity = Intensity;
        foreach (Material m in Materials)
        {
            m.SetFloat("_Intensity", _intensity);
        }
    }

    void OnDisable() {
        foreach (Material m in Materials)
        {
            Intensity = 0f;
            m.SetFloat("_Intensity", Intensity);
        }
    }
}
