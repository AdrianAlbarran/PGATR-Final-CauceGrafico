Shader "Custom/WireframeSeaShader"
{
    Properties
    {
        _TessellationUniform("Tessellation Uniform", Range(1, 64)) = 1
        _Color ("Color", Color) = (0,0,1,1)
        _WaveAmplitude("Wave Amplitude", Float) = 0.2
        _WaveFrequency("Wave Frequency", Float) = 2.0

        _DisplacementTex ("Displacement Texture", 2D) = "white" {}
        _DisplacementIntensity ("Displacement Intensity", Range(0, 50)) = 12
    
		_WireColor ("Wire Color", Color) = (1, 1, 1, 1)
        _WireWidth ("Wire Width", Range(0, 0.5)) = 0.05
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
			#pragma geometry geom

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
				float3 barycentric : TEXCOORD1;
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
			float4 _WireColor;
            float _WireWidth;

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
			
			[maxvertexcount(3)]
			void geom(triangle vertexOutput IN[3], inout TriangleStream<geometryOutput> triStream)
			{
				geometryOutput o;
                
                o.vertex = IN[0].vertex;
                o.uv = IN[0].uv;
                o.barycentric = float3(1, 0, 0);
                triStream.Append(o);
                
                o.vertex = IN[1].vertex;
                o.uv = IN[1].uv;
                o.barycentric = float3(0, 1, 0);
                triStream.Append(o);
                
                o.vertex = IN[2].vertex;
                o.uv = IN[2].uv;
                o.barycentric = float3(0, 0, 1);
                triStream.Append(o);
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
                float3 deltas = fwidth(i.barycentric);
                float3 smoothing = deltas * _WireWidth;
                float3 thickness = deltas * (_WireWidth * 0.5);
                
                float3 bary = smoothstep(thickness, thickness + smoothing, i.barycentric);
                float edge = min(min(bary.x, bary.y), bary.z);
                
                float4 seaColor = _Color;
                float4 wireColor = _WireColor * (1.0 - edge);
                
                return lerp(seaColor, wireColor, (1.0 - edge));
            }
            ENDCG
        }
    }
}
