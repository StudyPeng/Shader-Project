Shader "Unlit/WaterShader"
{
    Properties
    {
        _NoiseTex ("_NoiseTex", 2D) = "white" {}
        _Scale ("Scale", Vector) = (1,1,1,1)
        _ShallowColor ("ShallowColor", Color) = (1,1,1,1)
        _DeepColor ("DeepColor", Color) = (1,1,1,1)
        _RampDistance("RampDistance", Float) = 1
        _NoiseCutOff("NoiseCutOff", Float) = 1
        _FoamThickness("FoamThickness", Float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
        }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

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
            float4 _ShallowColor;
            float4 _DeepColor;
            float _RampDistance;
            float _NoiseCutOff;
            float _FoamThickness;
            VECTOR _Scale;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.worldPos = mul(v.vertex, unity_ObjectToWorld);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 noise = tex2D(_NoiseTex, float2(i.worldPos.x * _Scale.x, i.worldPos.z) + _Time.x) +
                    tex2D(_NoiseTex, float2(i.worldPos.x * -_Scale.y, i.worldPos.z * _Scale.z) + _Time.x);
                float2 uv = i.screenPos.xy / i.screenPos.w;
                float depth = LinearEyeDepth(SampleSceneDepth(uv), _ZBufferParams);
                float waterDepthDiff = clamp((depth - i.screenPos.w) / _RampDistance, 0, 1);
                float foamDepthDiff = clamp(depth - i.screenPos.w, 0, 1);
                foamDepthDiff *= _NoiseCutOff;
                noise = step(foamDepthDiff, noise);
                half4 waterColor = lerp(_ShallowColor, _DeepColor, noise);
                return waterColor;
            }
            ENDHLSL
        }
    }
}