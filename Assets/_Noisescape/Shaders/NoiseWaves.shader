Shader "Noise/NoiseWaves"
{
    Properties
    {
        _Intensity ("Intensity", Range(0, 1)) = .5
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 worldPos: TEXCOORD1;
            };

            float _Intensity;
            float4 _MainTex_ST;

            float rand(float2 co) {
                return frac(sin(dot(co, float2(28.9874, 87.2637))) * 39.7645);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float t = _Time;
                float2 uv = i.uv * 10;
                float2 intPos = floor(uv);
                float noiseMask = rand(intPos);
                float4 col = noiseMask;
                return col;
            }
            ENDCG
        }
    }
}
