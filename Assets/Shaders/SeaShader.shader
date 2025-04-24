Shader "Custom/SeaShader"
{
    Properties
    {
        _TessellationUniform("Tessellation Uniform", Range(1, 64)) = 1
        _Color ("Color", Color) = (1,1,1,1)
        _WaveAmplitude("Wave Amplitude", Float) = 0.2
        _WaveFrequency("Wave Frequency", Float) = 2.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
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
                float4 pos : SV_POSITION;
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


            vertexInput vert(vertexInput v)
            {
                return v;
            }

            // hull shader
            [UNITY_domain("tri")]
            [UNITY_outputcontrolpoints(3)]
            [UNITY_outputtopology("triangle_cw")]
            [UNITY_partitioning("integer")]
            [UNITY_patchconstantfunc("patchConstantFunction")]
            vertexInput hull(InputPatch<vertexInput, 3> patch, uint id : SV_OutputControlPointID)
            {
                return patch[id];
            }

            TessellationFactors patchConstantFunction(InputPatch<vertexInput, 3> patch)
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
            vertexOutput domain(TessellationFactors factors, OutputPatch<vertexInput, 3> patch, float3 bary : SV_DomainLocation)
            {
                vertexInput v;

                #define MY_DOMAIN_PROGRAM_INTERPOLATE(fieldName) v.fieldName = patch[0].fieldName * bary.x + patch[1].fieldName * bary.y + patch[2].fieldName * bary.z;

                MY_DOMAIN_PROGRAM_INTERPOLATE(vertex)
                MY_DOMAIN_PROGRAM_INTERPOLATE(uv)

                float wave = sin(v.vertex.x * _WaveFrequency + _Time.y) + cos(v.vertex.z * _WaveFrequency + _Time.y);
                v.vertex.y += wave * _WaveAmplitude;

                vertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            float4 frag(vertexOutput i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}
