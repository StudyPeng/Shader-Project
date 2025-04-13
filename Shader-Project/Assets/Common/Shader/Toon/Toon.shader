Shader "Unlit/Toon"
{
    Properties
    {
        _Color("_StainColor", Color) = (1, 1, 1, 1)
        _MainTex ("MainTex", 2D) = "white" {}
        _UVScale ("UV Scale", Range(0, 100)) = 0
        [HDR]
        _AmbientColor("Ambient Color", Color) = (0.4, 0.4, 0.4,1)
        [HDR]
        _SpecularColor("Specular Color", Color) = (0.9, 0.9, 0.9, 1)
        _Glossiness("Glossiness", Float) = 32
        [HDR]
        _RimColor("Rim Color", Color) = (1, 1, 1, 1)
        _RimAmount("Rim Amount", Range(0, 1)) = 0.716
    }
    SubShader
    {
        ZWrite On
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "LightMode" = "UniversalForward"
            "PassFlags" = "OnlyDirectional"
        }
        LOD 100
        Cull Back
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            struct appdata
            {
                float3 normal : NORMAL;
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldNormal : NORMAL;
                float4 vertex : SV_POSITION;
                float3 viewDir : TEXCOORD1;
                float4 shadowCoord : TEXCOORD2;
            };

            sampler2D _MainTex;
            float _UVScale;
            float4 _MainTex_ST;
            float _Glossiness;
            float4 _SpecularColor;
            float4 _RimColor;
            float _RimAmount;
            float4 _Color;
            float4 _AmbientColor;

            v2f vert(appdata i)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(i.vertex.xyz);
                o.worldNormal = TransformObjectToWorldNormal(i.normal);
                o.uv = TRANSFORM_TEX(i.uv, _MainTex);
                o.viewDir = GetWorldSpaceViewDir(i.vertex.xyz);
                o.shadowCoord = GetShadowCoord(GetVertexPositionInputs(i.vertex.xyz));
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float3 normal = normalize(i.worldNormal);
                float3 viewDir = normalize(i.viewDir);
                float4 color = tex2D(_MainTex, i.uv * _UVScale);

                // Ambient Light
                float NdotL = dot(GetMainLight().color, normal);
                float shadowIntensity = MainLightRealtimeShadow(i.shadowCoord);
                // float lightIntensity = smoothstep(0, 0.01, NdotL * shadowIntensity);
                float lightIntensity = smoothstep(0, 0.01, NdotL);
                // Specular Light
                float3 halfVector = normalize(_MainLightPosition.xyz + viewDir);
                float NdotH = dot(normal, halfVector);
                float specularIntensity = pow(abs(NdotH) * lightIntensity, _Glossiness);
                float specularSmooth = smoothstep(0.05, 0.1, specularIntensity);
                float4 specular = specularSmooth * _SpecularColor;
                // Rim Light
                float rimDot = 1 - dot(viewDir, normal);
                float rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimDot);
                float4 rim = rimIntensity * _RimColor;
                // Color
                float4 light = lightIntensity * _MainLightColor;
                return color * (_AmbientColor + light + specular + rim);
            }
            ENDHLSL
        }
    }
}