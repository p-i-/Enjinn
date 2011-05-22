//
//  Shader.frag
//  F33rsmEnjinn
//

precision mediump float;

uniform lowp    sampler2D   U1_srcTexture;             
uniform mediump float       U2_blurSize;

varying mediump vec2  vTexCoord;         
//varying lowp    vec4  V1_glColor_rgba;                 

void main( void )                       
{                                  
   // gl_FragColor = texture2D( S0, V0_glTexCoord_st ).a; // * V1_glColor_rgba ;
    
    vec4 sum = vec4(0.0);
    
    // blur in y (vertical)
    // take nine samples, with the distance blurSize between them
    sum += 0.05 * texture2D( U1_srcTexture, vec2( vTexCoord.x - 4.0 * U2_blurSize, vTexCoord.y ) ) ;
    sum += 0.09 * texture2D( U1_srcTexture, vec2( vTexCoord.x - 3.0 * U2_blurSize, vTexCoord.y ) ) ;
    sum += 0.12 * texture2D( U1_srcTexture, vec2( vTexCoord.x - 2.0 * U2_blurSize, vTexCoord.y ) ) ;
    sum += 0.15 * texture2D( U1_srcTexture, vec2( vTexCoord.x -       U2_blurSize, vTexCoord.y ) ) ;
    sum += 0.16 * texture2D( U1_srcTexture, vec2( vTexCoord.x                    , vTexCoord.y ) ) ;
    sum += 0.15 * texture2D( U1_srcTexture, vec2( vTexCoord.x +       U2_blurSize, vTexCoord.y ) ) ;
    sum += 0.12 * texture2D( U1_srcTexture, vec2( vTexCoord.x + 2.0 * U2_blurSize, vTexCoord.y ) ) ;
    sum += 0.09 * texture2D( U1_srcTexture, vec2( vTexCoord.x + 3.0 * U2_blurSize, vTexCoord.y ) ) ;
    sum += 0.05 * texture2D( U1_srcTexture, vec2( vTexCoord.x + 4.0 * U2_blurSize, vTexCoord.y ) ) ;
    
    gl_FragColor = sum;

}