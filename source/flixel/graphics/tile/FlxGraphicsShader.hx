package flixel.graphics.tile;

import openfl.display.GraphicsShader;

class FlxGraphicsShader extends GraphicsShader
{
	@:glVertexHeader("
		attribute float alpha;
		attribute vec4 colorMultiplier;
		attribute vec4 colorOffset;
		uniform bool hasColorTransform;
	", true)
	@:glVertexBody("
		openfl_Alphav = openfl_Alpha * alpha;
		
		if (hasColorTransform)
		{
			if (openfl_HasColorTransform)
			{
				openfl_ColorOffsetv = (openfl_ColorOffsetv * colorMultiplier) + (colorOffset / 255.0);
				openfl_ColorMultiplierv *= colorMultiplier;
			}
			else
			{
				openfl_ColorOffsetv = colorOffset / 255.0;
				openfl_ColorMultiplierv = colorMultiplier;
			}
		}
	", true)
	@:glFragmentHeader("
		uniform bool hasTransform;  // TODO: Is this still needed? Apparently, yes!
		uniform bool hasColorTransform;
		vec4 flixel_texture2D(sampler2D bitmap, vec2 coord)
		{
			vec4 color = texture2D(bitmap, coord);
			if (!(hasTransform || openfl_HasColorTransform))
				return color;
			
			if (color.a == 0.0)
				return vec4(0.0, 0.0, 0.0, 0.0);
			
			if (openfl_HasColorTransform || hasColorTransform)
			{
				color = vec4 (color.rgb / color.a, color.a);
				vec4 mult = vec4 (openfl_ColorMultiplierv.rgb, 1.0);
				color = clamp (openfl_ColorOffsetv + (color * mult), 0.0, 1.0);
				
				if (color.a == 0.0)
					return vec4 (0.0, 0.0, 0.0, 0.0);
				
				return vec4 (color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
			}
			
			return color * openfl_Alphav;
		}
	", true)
	@:glFragmentBody("
		gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
	", true)
    public var custom:Bool = false;
	public var save:Bool = true;
	private static var glslVersion:Null<Int> = null;

	public override function new(?save:Bool)
	{
		if (save != null)
			this.save = save;
		super();
	}

	@:noCompletion private override function __initGL():Void
	{
		if (__glSourceDirty || __paramBool == null)
		{
			__glSourceDirty = false;
			program = null;

			__inputBitmapData = new Array();
			__paramBool = new Array();
			__paramFloat = new Array();
			__paramInt = new Array();

			__processGLData(glVertexSource, "attribute");
			__processGLData(glVertexSource, "uniform");
			__processGLData(glFragmentSource, "uniform");
		}

		if (__context != null && program == null)
			initGLforce();
	}

	public function initGLforce()
	{
		if (!custom)
			initGood(glFragmentSource, glVertexSource);
	}

	public function initGood(glFragmentSource:String, glVertexSource:String)
	{
		@:privateAccess
		var gl = __context.gl;

		if(glslVersion == null) {
			var version_str = gl.getParameter(gl.SHADING_LANGUAGE_VERSION);
			glslVersion = Std.parseInt(StringTools.replace(version_str.split(" ")[0],".",""));
		}
		
		#if lime_opengles
			var prefix = "#version 300 es\n";
		#else
		var prefix = "";
		if(glslVersion>=330) prefix = '#version 330\n';
		else prefix = '#version 130\n';
		#end
		#if ((js && html5) || macos)
			prefix = "";
		#end

		#if (js && html5)
		prefix += (precisionHint == FULL ? "precision mediump float;\n" : "precision lowp float;\n");
		#else
		prefix += "#ifdef GL_ES\n"
			+ (precisionHint == FULL ? "#ifdef GL_FRAGMENT_PRECISION_HIGH\n"
				+ "precision highp float;\n"
				+ "#else\n"
				+ "precision mediump float;\n"
				+ "#endif\n" : "precision lowp float;\n")
			+ "#endif\n\n";
		#end

		#if lime_opengles
		prefix += 'out vec4 output_FragColor;\n';
		var vertex = prefix
			+ glVertexSource.replace("attribute", "in")
				.replace("varying", "out")
				.replace("texture2D", "texture")
				.replace("gl_FragColor", "output_FragColor");
		var fragment = prefix + glFragmentSource.replace("varying", "in").replace("texture2D", "texture").replace("gl_FragColor", "output_FragColor");
		#else
		var vertex = prefix + glVertexSource;
		var fragment = prefix + glFragmentSource;
		#end

		var id = vertex + fragment;

		@:privateAccess
		if (__context.__programs.exists(id) && save)
		{
			@:privateAccess
			program = __context.__programs.get(id);
		}
		else
		{
			program = __context.createProgram(GLSL);

			@:privateAccess
			program.__glProgram = __createGLProgram(vertex, fragment);

			@:privateAccess
			if (save)
				__context.__programs.set(id, program);
		}

		if (program != null)
		{
			@:privateAccess
			glProgram = program.__glProgram;

			for (input in __inputBitmapData)
			{
				@:privateAccess
				if (input.__isUniform)
				{
					@:privateAccess
					input.index = gl.getUniformLocation(glProgram, input.name);
				}
				else
				{
					@:privateAccess
					input.index = gl.getAttribLocation(glProgram, input.name);
				}
			}

			for (parameter in __paramBool)
			{
				@:privateAccess
				if (parameter.__isUniform)
				{
					@:privateAccess
					parameter.index = gl.getUniformLocation(glProgram, parameter.name);
				}
				else
				{
					@:privateAccess
					parameter.index = gl.getAttribLocation(glProgram, parameter.name);
				}
			}

			for (parameter in __paramFloat)
			{
				@:privateAccess
				if (parameter.__isUniform)
				{
					@:privateAccess
					parameter.index = gl.getUniformLocation(glProgram, parameter.name);
				}
				else
				{
					@:privateAccess
					parameter.index = gl.getAttribLocation(glProgram, parameter.name);
				}
			}

			for (parameter in __paramInt)
			{
				@:privateAccess
				if (parameter.__isUniform)
				{
					@:privateAccess
					parameter.index = gl.getUniformLocation(glProgram, parameter.name);
				}
				else
				{
					@:privateAccess
					parameter.index = gl.getAttribLocation(glProgram, parameter.name);
				}
			}
		}
	}
}
