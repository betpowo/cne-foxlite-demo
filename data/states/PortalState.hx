
import foxlite.renderer.FoxRenderer;
import foxlite.loaders.FoxLoaderUtil;
import foxlite.FoxCache;
import foxlite.FoxModel;
import foxlite.texture.FoxTexture;
import foxlite.mesh.FoxQuadMesh;
import foxlite.material.FoxMaterial;
import foxlite.flixel.FoxRenderMetrics;

import foxlite.FoxScene;
import foxlite.FoxCamera;
import foxlite.extras.FoxFPSCamera;
import foxlite.texture.FoxFramebuffer;

import flixel.FlxSprite;

var scene:FoxScene;
var camera:FoxFPSCamera = new FoxFPSCamera();
var otherCamera:FoxCamera = new FoxCamera();
var bfmodel:FoxModel = new FoxModel();
var velocityY = 0;
function create() {
	FlxG.sound.music.stop();
	FlxG.mouse.visible = true;

	// Foxlite init
	FoxRenderer.initLibs();
	FoxLoaderUtil.initPathClass(Paths);

	scene = new FoxScene(FlxG.width, FlxG.height);
	add(scene);
	camera.enableYMovement = false;
	camera.y = 0.6;
	camera.speed = 2;

	scene.foxCameras.push(camera);

	var skyDome = new FoxModel();
	
	var data = skyDome.loadOBJ("models/SkyDome.obj", ['NO_SHADOW_CODE']);
	scene.add(skyDome);
	data.meshes[0].material.culling = 1;
	data.meshes[0].material.alphaScissor = 0.5;

	var floor = new FoxModel();
	var floorMat = FoxMaterial.createMinimal(null, ["bitmap" => FoxTexture.fromImage("stages/floor_pattern")]);
	{
		floorMat.params.set("uvScale", [20, 20]);
		var tex = floorMat.textures.get("bitmap");
		tex.wrapMode = 2;
		tex.filter = 5;
	}
	floor.addMesh(new FoxQuadMesh(20, 20, floorMat, 1));
	
	floor.y = 0.01;
	//scene.add(floor);

	// Add our boy
	data = bfmodel.loadOBJ("models/bfloading.obj", ['NO_SHADOW_CODE']);
	scene.add(bfmodel);

	// Configure the model correctly (objs doesn't have face information)
	data.meshes[0].material.culling = 0;
	data.meshes[0].material.alphaScissor = 0.5;

	bfmodel.setScale(.1, .1, .1);
	bfmodel.y = .38;

	bfmodel.groups = [1]; // Don't render in main camera (renders group 0 only by default)

	// Setup render target for other camera
	var framebuffer = FoxFramebuffer.create3D(256, 256, false); // false cuz we don't need alpha channel
	scene.renderTargets.set("otherBuffer1", framebuffer);

	// Configure other camera
	otherCamera.setPosition(0, 0.6, 0);
	otherCamera.passes[0].target = "otherBuffer1"; // Output
	otherCamera.passes[0].groups = [0, 1]; // Render groups 0 and 1

	// We'll need that other draw group
	var groupIndex = scene.addDrawGroup();

	// Add to our scene and hope for the best
	scene.foxCameras.push(otherCamera);

	// Display our texture in flixel
	var viewSprite = new FlxSprite();
	viewSprite.pixels = framebuffer.colorBuffers[0].asBitmapData();
	add(viewSprite);
	// The rendered contents are flipped on the Y axis, so we flip the sprite to correct it
	viewSprite.flipY = true;
	viewSprite.screenCenter();
	viewSprite.x += 400;

	var t = new FoxRenderMetrics();
	t.y = 100;
	add(t);
}

function update(elapsed) {
	velocityY -= elapsed * 0.6;
	if (FlxG.keys.pressed.SPACE && camera.position.y <= 0.6) velocityY = 0.1;
	if (FlxG.keys.justPressed.P) returnToMainMenu();
	camera.position.y += velocityY;
	camera.position.y = Math.max(camera.position.y, 0.6);
	// // Move him
	bfmodel.x = camera.globalPosition.x;
	bfmodel.z = camera.globalPosition.z;

	bfmodel.y = camera.globalPosition.y + 0.38 - 0.6;

	// // Rotate him
	bfmodel.rotation.y = camera.rotation.y + Math.PI/2;
}

function returnToMainMenu() {
	FlxG.mouse.visible = false;
	FlxG.switchState(new MainMenuState());
}

function destroy() {
	FoxCache.instance.freeResources();
	scene?.set_visible(false);
	scene?.destroy();
}