attribute vec3 in_Position;                  // (x,y,z)
attribute vec2 in_TextureCoord;              // (u,v)

uniform float u_fScale;

varying vec2 v_vTexcoord;

void main()
{
    vec4 vPosition = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    mat4 mWorldView = gm_Matrices[MATRIX_WORLD_VIEW];
    
    for (int i = 0; i < 3; ++i){
        for (int j = 0; j < 3; ++j){
            mWorldView[i][j] = 0.0;
        }
    }
    mWorldView[0][0] = u_fScale;
    mWorldView[1][1] = u_fScale;
    mWorldView[2][2] = u_fScale;
    
    vPosition = mWorldView * vPosition;
    
    gl_Position = gm_Matrices[MATRIX_PROJECTION] * vPosition;
    
    v_vTexcoord = in_TextureCoord;
}
