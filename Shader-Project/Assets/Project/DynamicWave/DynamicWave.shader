Shader "Unlit/DynamicWave"
{
    Properties
    {
        _MainTex ("Texture 1", 2D) = "white" {}
        _SecondTex ("Texture 2", 2D) = "white" {}
        _RoundRadius ("Radius", Range(0, .5)) = 0
        _Width ("Width", Float) = 0
        _Height ("Height", Float) = 0
        _Offset ("Offset", Float) = 0
        _OffsetSpeed ("OffsetSpeed", Float) = 0
        _Rotation ("Rotation", Float) = 0
        _Threshold ("Threshold", Range(0, 1)) = 0.65
        _Amplitude ("Amplitude", Range(0, 1)) = 0.06
        _Frequency ("Frequncy", Float) = 9
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
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
                float2 uv2 : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _SecondTex;
            float4 _MainTex_ST;
            float _RoundRadius;
            float _Width;
            float _Height;
            float _Rotation;
            float _Threshold;
            float _Amplitude;
            float _Frequency;
            float _Offset;
            float _OffsetSpeed;

            v2f vert(appdata i)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(i.vertex);
                o.uv = TRANSFORM_TEX(i.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float aspect = _Height / _Width;
                float threshold = _Threshold - sin(i.uv.y * _Frequency) * _Amplitude * _SinTime;
                i.uv.y += abs(_Time.x) * _OffsetSpeed;
                float a = step(threshold, i.uv.x);
                float4 color = tex2D(_MainTex, i.uv);
                return float4(color.x, color.y, color.z, a);
            }
            ENDCG
        }
    }
}