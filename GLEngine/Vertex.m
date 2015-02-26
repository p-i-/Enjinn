//
//  Vertex.m
//  GLEngine
//
//  Created by Pi on 21/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import "glHelper.h"

#import "Vertex.h"


@implementation Vertex

+ (void) setupVertexArrayPointers: ( ATTRIBUTE [] ) in_attributeArray
               returningVertBufId: (GLuint *)       p_id_vertBuf
{
    // NOTE: *Must* do: glBindBuffer( GL_ARRAY_BUFFER, tqVert_BufID ); 
    //       before glEnableVertexAttribArray(...) and glVertexAttribPointer(...)  
    //       ie WHICH vertex-buffer are we working on / structuring?
    
    LOG( @"GLView: setupVertexArrayPointers:" );
    
    glGenBuffers( 1, p_id_vertBuf ); 
    glBindBuffer( GL_ARRAY_BUFFER, * p_id_vertBuf ); 
    
    int attribBytesTotal, attribCount;
    {
        int i=0, floatsTotal = 0;
        while( YES )
        {
            ATTRIBUTE* pA = & in_attributeArray[ i ];
            
            if ( pA->token == END_OF_ATTRIBUTES )
                break;
            
            floatsTotal += pA->glFloats;
            i++;
        } ;
        
        glLogAndFlushErrors();
        
        attribBytesTotal = floatsTotal * sizeof( GLfloat );
        attribCount = i;
    }
    
    {
        for (int j=0;  j < attribCount;  j++)
        {
            ATTRIBUTE* pA = & in_attributeArray[ j ];
            
            glEnableVertexAttribArray( pA->id_ );
            glVertexAttribPointer(
                                  pA->id_,                          // 0,1,2,...
                                  pA->glFloats,                     // # components for this attrib (MUST be 1,2,3,4)
                                  GL_FLOAT,                         // type of each components
                                  GL_FALSE,                         // normalized?
                                  attribBytesTotal,                 // stride (bytes)
                                  (const GLvoid *)NULL + pA->byteOffset  // byte-offset within struct
                                  );
        }
        
        glLogAndFlushErrors();
    }    
    
}


@end
