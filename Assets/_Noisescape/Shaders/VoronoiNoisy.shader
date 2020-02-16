Shader "Voronoi/VoronoiNoisy"
{
    Properties
    {
        _Intensity ("Intensity", Range(0, 1)) = .5
        _Speed ("Speed", Range (1, 100)) = 10
        _Density ("Point Density", Range (1., 20.)) = 5.
        _Brighten ("Brighten", Range(0, 1)) = .2
        _LineColor("Line Color", Color) = (1,0,0,1)
        _CellColor("Cell Color", Color) = (0,0,1,1)
        _IntenseCellColor("Intense Cell Color", Color) = (1,0,1,1)
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
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 vertex : SV_POSITION;
                float4 worldPos : TEXCOORD1; 
            };

            float _Intensity;
            float _Speed;
            int _Density;
            float _Brighten;
            float4 _LineColor;
            float4 _CellColor;
            float4 _IntenseCellColor;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul (unity_ObjectToWorld, v.vertex);
                return o;
            }

            float2 N22(float2 p) {
                float3 a = frac(p.xyx*float3(123.34, 234.34, 345.65));
                a += dot(a, a+34.45);
                return frac(float2(a.x*a.y, a.y*a.z));
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv*2 - 1;
                // uv *= 60;
                // uv = floor(uv);

                float t = _Time*_Speed;
                float m = 0;

                float minDist = 100.;
                
                uv *= _Density;
                float2 gv = frac(uv)-.5;
                float2 id = floor(uv);
                float2 cid = 0;
                
                for(float y=-1; y<=1; y++) {
                    for(float x=-1; x<=1; x++) {
                        float2 offs = float2(x, y);
                        float2 n = N22(id+offs);
                        float2 p = offs+sin(n*t)*.5;
                        p -= gv;
                        float d = length(p);
                        if(d<minDist) {
                            minDist = d;
                            cid = id+offs;
                        }
                    }
                }

                float lfo = sin(t+uv.x) * cos(t+uv.y); // waves, smoother
                // float lfo = sin(t*uv.x) * cos(t*uv.y); // glitchier variant
                minDist = lerp(minDist, lfo, _Intensity*.24);
                float3 col = minDist;
                float4 brightness = float4(col, 1);
                float4 darkness = float4(1-col.x, 1-col.y, 1-col.z, 1);

                float4 lineCol = _LineColor*brightness;
                float4 normalCellCol = _CellColor*darkness;
                float4 intenseCellCol = _IntenseCellColor*darkness;
                float4 cellCol = lerp(normalCellCol, intenseCellCol, _Intensity);
                float4 brightenCol = _Brighten;

                float4 fragCol = lerp(lineCol,cellCol,.5);
                float4 posCol = float4(i.worldPos / 3);
                posCol.y *= -1;
                fragCol = lerp(fragCol, posCol, _Intensity*.1);
                fragCol += normalize(fragCol) * (_Brighten * _Intensity);
                return fragCol;
            }
            ENDCG
        }
    }
}