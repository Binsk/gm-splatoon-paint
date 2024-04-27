uniform vec3 u_vColor;

varying vec2 v_vTexcoord;

void main()
{
    gl_FragColor = vec4(u_vColor.rgb, 1.0) * texture2D( gm_BaseTexture, v_vTexcoord );
    if (gl_FragColor.a <= 0.0) // Inefficient but... screw it
        discard;
}
