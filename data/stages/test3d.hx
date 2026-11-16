
import flixel.addons.util.FlxScene;
import foxlite.FoxScene;
import foxlite.renderer.FoxRenderer;
import foxlite.lights.FoxPointLight;
import foxlite.lights.FoxSpotLight;
import foxlite.loaders.FoxLoaderUtil;
import flixel.FlxG;
import openfl.filters.BitmapFilter;

var cam:FoxFPSCamera;
var floor:FoxModel;

var camOther = new FlxCamera();
var tweenSprite = new FlxSprite();
var floorMat:FoxMaterial;
var spot:FoxSpotLight;

var bfSprite:FoxFlxSprite;
var dadSprite:FoxFlxSprite;

function create() {
	FoxRenderer.initLibs();
	FoxLoaderUtil.initPathClass(Paths);

	var bg = new FlxSprite();
	bg.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	bg.scrollFactor.set(0, 0);
	PlayState.instance.add(bg);

	var scene = new FoxScene(FlxG.width+200, FlxG.height+200);
	scene.setPosition(-100,-100);
	scene.scrollFactor.set(0, 0);

	cam = new FoxFPSCamera();
	scene.foxCameras.push(cam);

	cam.enableControls = false;
	cam.bgColor = 0xFF000000;

	floor = new FoxModel();
	scene.add(floor);

	// Minimal 3D unshaded shader (no lights)
	var basic = FoxShader.fromAsset("foxlite/basic");
	var basicSprite = FoxShader.fromAsset("foxlite/basic", ["UNSHADED"]);

	var floorBitmap = Assets.getBitmapData(Paths.image("stages/floor_pattern"));
	var floorTexture = FoxTexture.wrap(floorBitmap);
	floorTexture.wrapMode = 2;
	floorMat = FoxMaterial.create(basic, ["bitmap" => floorTexture]);

	var mesh = new FoxQuadMesh(200, 200, floorMat, 1);
	mesh.material.params.set("uvScale", [100, 100]);

	floor.addMesh(mesh);
    
	bfSprite = new FoxFlxSprite(PlayState.instance.bf, FoxMaterial.create(basic), .0027);
	bfSprite.material.depthWrite = PlayState.instance.downscroll;
	bfSprite.material.renderPriority = 2;
	scene.add(bfSprite);
	bfSprite.y = 0.5;
	bfSprite.x = 1.25;
	bfSprite.z = .5;
	bfSprite.angleY = -15;

	dadSprite = new FoxFlxSprite(PlayState.instance.dad, FoxMaterial.create(basic), .0027);
	dadSprite.material.alphaScissor = 0.8;
	dadSprite.material.renderPriority = 2;
	scene.add(dadSprite);
	dadSprite.y = .95;
	dadSprite.x = -1.45;
	dadSprite.z = .5;
	dadSprite.angleY = 15;
	// Configure lights
	cam.lightData.ambientLight.setTo(0.05,0.05,0.05);

    var lightness = new FoxPointLight();
    lightness.range = 0.5;
	lightness.color(2,0.1,0.1);
    scene.add(lightness);
    lightness.y = 10;

	spot = new FoxSpotLight();
	spot.range = 20;
	spot.energy = 2;
	spot.shadow = true;
	scene.add(spot);
	spot.z = 10;
	spot.x = -1;
	spot.y = 5;
	//var sun = new FoxDirectionalLight();
	//sun.shadow = true;
	//sun.angleX = -15;
	//sun.angleY = 15;
    //sun.range = 2;
	//scene.add(sun);

	PlayState.instance.add(scene);

	trace("all good");
}

function postCreate() {
	defaultCamZoom = 1;
}

var angle:Float = 0;
var speed:Float = 2; // Radians per frame
var radius:Float = 1;
var centerX:Float = -1; // Screen center X
var centerY:Float = 5; // Screen center Y

function update(dt) {
	var cg = PlayState.instance.camGame;
	var ch = PlayState.instance.camHUD;
	var x = cg.scroll.x/2;
	var y = cg.scroll.y/2;
	cam.position.setTo(
		(x*0.005)*2,
		1 + y*-.0002, 2.5
	);
	cam.rotation.x = 0.1 - y*.001;
	cam.rotation.y = x*.001;
	cam.fov = 85 - ch.zoom*2;

	angle += speed * dt;

	spot.x = centerX + radius * Math.cos(angle);
    spot.y = centerY + radius * Math.sin(angle);

}

function destroy() {
	FoxCache.instance.freeResources();
}