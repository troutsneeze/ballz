//
//  Shader.fsh
//  Bobby Lite
//
//  Created by Trent Gamblin on 11-09-03.
//  Copyright 2011 Nooskewl. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
