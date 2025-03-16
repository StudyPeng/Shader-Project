Shader "Unlit/BuiltInWater"
{
    Properties
    {
        _NoiseTex ("_NoiseTex", 2D) = "white" {}
        _Scale ("Scale", Vector) = (1,1,1,1)
        _ShallowColor ("ShallowColor", Color) = (1,1,1,1)
        _DeepColor ("DeepColor", Color) = (1,1,1,1)
        _RampDistance("RampDistance", Float) = 1
        _NoiseCutoff("NoiseCutoff", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
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
            };

            struct v2f
            {
                float4 screenPos : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _NoiseTex;
            sampler2D _CameraDepthTexture;
            float4 _ShallowColor;
            float4 _DeepColor;
            float _RampDistance;
            float _NoiseCutoff;
            VECTOR _Scale;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.worldPos = mul(v.vertex, unity_ObjectToWorld);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half4 noise = tex2D(_NoiseTex, float2(i.worldPos.x * _Scale.x, i.worldPos.z) + _Time.x) +
                    tex2D(_NoiseTex, float2(i.worldPos.x, i.worldPos.z * _Scale.y) + _Time.x);
                float2 uv = i.screenPos.xy / i.screenPos.w;
                float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, uv));
                float waterDepthDifference = clamp((depth - i.screenPos.w) / _RampDistance, 0, 1);
                half4 waterColor = lerp(_ShallowColor, _DeepColor, waterDepthDifference);
                return noise;
            }
            ENDCG
        }
    }
}