Shader "Noise/NoiseWaves"
{
    Properties
    {
        _Intensity ("Intensity", Range(0, 1)) = .5
        _Speed ("Speed", Range (0, 1)) = .5
        _Color ("Color", Color) = (1,1,1,1)
        _AmbientColor ("AmbientColor", Color) = (.1,.1,.1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 worldPos: TEXCOORD1;
            };

            float _Intensity;
            float _Speed;
            float4 _Color;
            float4 _AmbientColor;

            float rand(float2 co) {
                return frac(sin(dot(co, float2(28.9874, 87.2637))) * 39.7645);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = v.normal;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float t = _Time;
                float s = 0.01 * _Speed;
                float _i = _Intensity;
                float3 n = i.normal;
                float2 uv = i.uv;

                // Lighting
                float3 lightDir = float3(sin(t), cos(t), sin(uv.x)); // Weird light dir
                float3 lightColor = 1;
                float lightFalloff = max(dot(lightDir, n), 0);
                float3 directDiffuseLight = lightColor * lightFalloff;
                float3 ambientLight = _AmbientColor;
                float3 diffuseLight = ambientLight + directDiffuseLight;
                float4 lightMask = float4(diffuseLight * _Color.rgb, 0);

                // Pos color
                float4 posCol = float4(i.worldPos / 3);

                float4 diffCol = lightMask + posCol * _i * .4;

                // Make uv a pixely grid
                uv *= 10;
                float2 intPos = floor(uv);
                // Intensity blends noise masks
                float2 intPosWave = intPos; // Intpos for wavy random mask
                intPosWave.x += sin(t * s);
                intPosWave.y += cos(t * s);
                float noiseMaskWave = rand(intPosWave);
                float noiseMaskFlicker = rand(intPos + sin(t));
                // Blended with bias towards wavy noise
                float noiseMask = lerp(noiseMaskWave, noiseMaskFlicker, _i * .6);
                noiseMask = lerp(1, noiseMask, _i * .6 + .2);
                // float4 col = lightCol * noiseMask;
                float4 col = diffCol * noiseMask;
                return col;
            }
            ENDCG
        }
    }
}
