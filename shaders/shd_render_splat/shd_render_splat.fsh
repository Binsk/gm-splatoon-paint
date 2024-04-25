varying vec2 v_vTexcoord;
varying vec4 v_vColor;

uniform vec3 u_vColorA;  // Team A color
uniform vec3 u_vColorB;  // Team B color
uniform sampler2D u_sTeamData;

void main()
{
    int iTeam = int(texture2D(u_sTeamData, v_vTexcoord).r * 2.0);
    vec4 vColor = v_vColor * texture2D(gm_BaseTexture, v_vTexcoord);
    if (iTeam > 0){ // If 0, no team was specified; only blend if there is a team
        if (iTeam == 1)
            vColor.rgb = u_vColorA;
        else
            vColor.rgb = u_vColorB;
        
        vColor.a = 1.0;
    }
    gl_FragColor = vColor;
}
