Shader "Unlit/StencilMaterialShader"
{
    Properties
    {
        [IntRange] _StencilID ("Stencil ID", Range(0, 255)) = 0
        _MainTex("Texture", 2D) = "white" {}
        _Strength("_Strength", float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry-1"
            "RendererPipeline" = "UniversalPipeline"
            "LightMode" = "UniversalForward"
        }

        Pass
        {
            Blend Off
            ZWrite On
            
            Stencil
            {
                Ref [_StencilID]
                Comp Always
                Pass Replace
            }

            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
            #include "UnityInstancing.cginc"

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float, _Strength)
            UNITY_INSTANCING_BUFFER_END(Props)
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv);
                float strength = UNITY_ACCESS_INSTANCED_PROP(Props, _Strength);
                return col * strength;
            }
            ENDHLSL
        }
    }
}