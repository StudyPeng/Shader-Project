Shader "Custom/Grass"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _WindDirection("Wind Direction", Vector) = (0,0,0,0)
        _WindSpeed("Wind Speed", Float) = 0
        _SwingStrength ("Swing Strength", Float) = 0
        _SwingOffset ("Swing Offset", Float) = 0
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200
        Cull Off
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
                float4 vertex : POSITION;
                float4 vertexColor : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 vertexColor : COLOR;
                float4 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float3 _WindDirection;
            float _WindStrength;

            v2f vert(appdata i)
            {
                v2f o;
                o.vertexColor = i.vertexColor;
                o.worldPos = mul(unity_ObjectToWorld, i.vertex);
                const float3 strength = mul(normalize(_WindDirection.xyz), _SinTime.w * _WindStrength);
                float3 swingOffset = mul(strength, o.vertexColor.x);
                o.pos = mul(unity_MatrixVP, o.worldPos + float4(swingOffset.x, 0, swingOffset.z, 0));
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return float4(0, i.vertexColor.x, 0, 1);
            }
            ENDHLSL
        }

    }
}