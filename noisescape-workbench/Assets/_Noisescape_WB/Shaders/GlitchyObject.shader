Shader "Raymarching/GlitchyObject"
{
    Properties
    {
        _Intensity ("Intensity", Range(0, 1)) = 0.1
        _RaymarchingMod ("Raymarching Mod", Range(0, 10)) = 1
        _ColorAnimMod ("Color Anim Mod", Range(1, 10)) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define MAX_STEPS 100
            #define MAX_DIST 100
            #define SURF_DIST 1e-3

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
                float3 ro : TEXCOORD1;
                float3 hitPos : TEXCOORD2;
            };

            float _Intensity;
            float _RaymarchingMod;
            float _ColorAnimMod;

            v2f vert (appdata v) 
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                // Use world space origin
                 o.ro = _WorldSpaceCameraPos;
                o.hitPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            // Different positioning convention than other shapes - xyz of float4 s = Sphere
            float sdSphere(float3 p, float4 s) {
                return length(p-s.xyz)-s.w; // s.w is radius of sphere
            }

            float sdOctahedron(float3 p, float s)
            {
                p = abs(p);
                return (p.x+p.y+p.z-s)*0.57735027;
            }

            float GetDist(float3 p) {
                float t = _Time * (_RaymarchingMod*2) ;
                float _i = _Intensity + _RaymarchingMod*_Intensity;
                // Sphere
                float sd = sdSphere(p, float4(0, 1, 0, 1));
                // Plane
                float pd = p.y;
                float d = min(sd, pd);
                // return d+sin(t);
                return d+(sin(p.x*t)*_i)*(cos(p.y*t*.2)*_i); // Intensity sets glitchyness
            }

            float RayMarch(float3 ro, float3 rd) {
                float dO = 0;
                for (int i = 0; i<MAX_STEPS; i++) {
                    float3 p = ro + rd*dO;
                    float dS = GetDist(p);
                    dO += dS;
                    if(dO>MAX_DIST || dS<SURF_DIST) break;
                }
                return dO;
            }

            float3 GetNormal(float3 p) {
                float2 e = float2(1e-2, 0);
                float3 n = GetDist(p) - float3(
                    GetDist(p - e.xyy),
                    GetDist(p - e.yxy),
                    GetDist(p - e.yyx)
                );
                return normalize(n);
            }

            float GetLight(float3 p) {
                float t = _Time;
         
                float3 lightPos = float3(0, 5, 2);
                lightPos.x += sin(_Time)*20;
                lightPos.z += cos(_Time)*20;
                float3 l = normalize(lightPos-p);
                float3 n = GetNormal(p);

                float dif = clamp(dot(n, l), 0, 1);
                float d = RayMarch(p+n*SURF_DIST*2, l);
                if(d<length(lightPos-p)) dif *= .08;
                return dif;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float t = _Time * _ColorAnimMod;
                float _i = _Intensity;
                
                float2 uv = i.uv-.5;
                float3 ro = i.ro;
                float3 rd = normalize(i.hitPos - ro);
                float d = RayMarch(ro, rd);
                
                float3 p = ro + rd * d;
                float dif = GetLight(p);
                float3 col = dif;

                col = lerp(col, p, sin(t)*_i);

                fixed4 fragCol = 1;
                fragCol.xyz = col.xyz;
                return fragCol;
            }
            ENDCG
        }
    }
}