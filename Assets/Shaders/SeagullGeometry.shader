Shader "Custom/SeagullGeometry"
{
    Properties
    {
        _PlaneSize ("Tamaño del Plano", Float) = 1.0
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Textura", 2D) = "white" {}
    }

    CGINCLUDE
	#include "UnityCG.cginc"
	#include "Autolight.cginc"
   
    ////////////////////////////////////////////////////////////////////
    ///// STRUCTS
    ////////////////////////////////////////////////////////////////////
    struct appData {
        float4 vertex : POSITION;
    };

    struct vert2geo {
        float4 pos : SV_POSITION;
    };

    struct geom2frag {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
    };

    ////////////////////////////////////////////////////////////////////
    ///// GLOBALS
    ////////////////////////////////////////////////////////////////////

    float _PlaneSize;
    sampler2D _MainTex;
    float4 _Color;


    ////////////////////////////////////////////////////////////////////
    ///// AUX FUNCS
    ////////////////////////////////////////////////////////////////////

	float rand(float3 co)
	{
		return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 53.539))) * 43758.5453);
	}

    float3x3 AngleAxis3x3(float angle, float3 axis)
	{
		float c, s;
		sincos(angle, s, c);

		float t = 1 - c;
		float x = axis.x;
		float y = axis.y;
		float z = axis.z;

		return float3x3(
			t * x * x + c, t * x * y - s * z, t * x * z + s * y,
			t * x * y + s * z, t * y * y + c, t * y * z - s * x,
			t * x * z - s * y, t * y * z + s * x, t * z * z + c
			);
	}

    ////////////////////////////////////////////////////////////////////
    ///// MAIN FUNCS
    ////////////////////////////////////////////////////////////////////

	float4 vert(appData vertex) : SV_POSITION
	{
        vert2geo o;
        o.pos = vertex.vertex;
		return o;
	}

    [maxvertexcount(4)]
    void geom(point vert2geo IN[1], inout TriangleStream<geom2frag> triStream)
    {
        // Vectores para billboarding
        float3 camRight = UNITY_MATRIX_V[0].xyz;
        float3 camUp = UNITY_MATRIX_V[1].xyz;

        float3 center = IN[0].pos.xyz;
        float halfSize = _PlaneSize * 0.5;

        g2f o;
        
        // Generar 4 vértices del plano
        o.pos = UnityWorldToClipPos(center + (-camRight - camUp) * halfSize);
        o.uv = float2(0, 0);
        stream.Append(o);

        o.pos = UnityWorldToClipPos(center + (camRight - camUp) * halfSize);
        o.uv = float2(1, 0);
        stream.Append(o);

        o.pos = UnityWorldToClipPos(center + (-camRight + camUp) * halfSize);
        o.uv = float2(0, 1);
        stream.Append(o);

        o.pos = UnityWorldToClipPos(center + (camRight + camUp) * halfSize);
        o.uv = float2(1, 1);
        stream.Append(o);
    }

    fixed4 frag(geom2frag i) : SV_Target {
        return tex2D(_MainTex, i.uv) * _Color;
    }

    ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        


        Pass { 

            CGPROGRAM
            #pragma vertex   vert
            #pragma geometry geom
            #pragma fragment frag
			#pragma target 4.6
            

            ENDCG
        }
    }
}
