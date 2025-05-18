Shader "Custom/SeaShader"
{
    Properties
    {
        _TessellationUniform("Tessellation Uniform", Range(1, 64)) = 1
        _Color ("Color", Color) = (0,0,1,1)
        _WaveAmplitude("Wave Amplitude", Float) = 0.2
        _WaveFrequency("Wave Frequency", Float) = 2.0

        _DisplacementTex ("Displacement Texture", 2D) = "white" {}
        _DisplacementIntensity ("Displacement Intensety", Range(0, 50)) = 12
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        Pass
        {

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            CGPROGRAM
            #pragma target 4.6
            #pragma vertex vert
            #pragma fragment frag
            #pragma hull hull
            #pragma domain domain

            #include "UnityCG.cginc"

            struct vertexInput {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct vertexOutput {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            struct geometryOutput {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            struct TessellationFactors
            {
                float edge[3] : SV_TessFactor;
                float inside : SV_InsideTessFactor;
            };

            float4 _Color;
            float _TessellationUniform;
            float _WaveAmplitude;
            float _WaveFrequency;
            sampler2D _DisplacementTex;
            float _DisplacementIntensity;

            vertexOutput vert(vertexInput v)
            {
                vertexOutput o;
                o.vertex = mul(UNITY_MATRIX_M, v.vertex);
                o.uv = v.uv;
                return o;
            }

            vertexOutput VertexOutput(float3 pos, float2 uv)
            {
                vertexOutput aux;
                aux.vertex = UnityObjectToClipPos(pos);
                aux.uv = uv;
                return aux;
            }

            // hull shader
            [UNITY_domain("tri")]
            [UNITY_outputcontrolpoints(3)]
            [UNITY_outputtopology("triangle_cw")]
            [UNITY_partitioning("integer")]
            [UNITY_patchconstantfunc("patchConstantFunction")]
            vertexOutput hull(InputPatch<vertexOutput, 3> patch, uint id : SV_OutputControlPointID)
            {
                return patch[id];
            }

            TessellationFactors patchConstantFunction(InputPatch<vertexOutput, 3> patch)
            {
                TessellationFactors f;
                f.edge[0] = _TessellationUniform;
                f.edge[1] = _TessellationUniform;
                f.edge[2] = _TessellationUniform;
                f.inside = _TessellationUniform;
                return f;
            }


            // domain shader
            [UNITY_domain("tri")]
            vertexOutput domain(TessellationFactors factors, OutputPatch<vertexOutput, 3> patch, float3 bary : SV_DomainLocation)
            {
                vertexOutput v;

                #define MY_DOMAIN_PROGRAM_INTERPOLATE(fieldName) v.fieldName = patch[0].fieldName * bary.x + patch[1].fieldName * bary.y + patch[2].fieldName * bary.z;

                MY_DOMAIN_PROGRAM_INTERPOLATE(vertex)
                MY_DOMAIN_PROGRAM_INTERPOLATE(uv)

                float wave = sin(v.vertex.x * _WaveFrequency + _Time.y) + cos(v.vertex.z * _WaveFrequency + _Time.y);
                v.vertex.y += wave * _WaveAmplitude;

                v.vertex = mul(UNITY_MATRIX_VP, v.vertex);

                // Mapa de desplazamiento
                float height = tex2Dlod(_DisplacementTex, float4(v.uv, 0, 0)).r * _DisplacementIntensity;
                v.vertex.y += height;

                return v;
            }

            float4 frag(geometryOutput i) : SV_Target
            {
                float4 color = _Color;
                color.a = 0.5;
                return color;
            }
            ENDCG
        }
    }
}
