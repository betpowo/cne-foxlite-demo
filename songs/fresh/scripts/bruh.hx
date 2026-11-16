
import flixel.addons.util.FlxScene;
import foxlite.FoxScene;
import foxlite.FoxModel;
import foxlite.FoxShader;
import foxlite.texture.FoxTexture;
import foxlite.material.FoxMaterial;
import foxlite.mesh.FoxQuadMesh;
import foxlite.stencil.FoxStencilAction;
import foxlite.sky.FoxPanoramaSky;
import foxlite.flixel.FoxFlxSprite;
import foxlite.flixel.FoxFunkinSprite;
import foxlite.cache.FoxCache;
import foxlite.lights.FoxDirectionalLight;
import foxlite.flixel.FoxRenderMetrics;
import foxlite.renderer.FoxRenderer;
import foxlite.loaders.FoxLoaderUtil;
import flixel.FlxG;
import openfl.filters.BitmapFilter;
import foxlite.extras.FoxFPSCamera;

var cam:FoxFPSCamera;
var floor:FoxModel;

var camOther = new FlxCamera();
var uiMatTextures:Map<String, FoxTexture>;

// Reflections
var reflMat:FoxMaterial;
var uiModelRefl:FoxModel;
var bfSprRef:FoxFlxSprite;
var dadSprRef:FoxFlxSprite;

var tweenSprite = new FlxSprite();
var floorMat:FoxMaterial;
var floorMatReflective:FoxMaterial;
var sky:FoxPanoramaSky;

var bfSprite:FoxFlxSprite;
var dadSprite:FoxFlxSprite;

var fih:FoxModel;


// Resources
// Minimal 3D unshaded shader (no lights)
var unshader = FoxShader.fromAsset("foxlite/minimal");
var basicSprite = FoxShader.fromAsset("foxlite/basic", ["UNSHADED"]);

var floorTexture = FoxTexture.fromImage("stages/floor_pattern");
floorTexture.wrapMode = 2;
floorMat = FoxMaterial.create(unshader, ["bitmap" => floorTexture]);

floorMatReflective = FoxMaterial.createBasic(
	["UNSHADED", "SKY_REFLECTIONS"],
	["bitmap" => floorTexture],
	["uMetallic" => 0.6]
);

var skyTexture = FoxTexture.fromImage("stages/material_emissive");
skyTexture.wrapMode = 2;

function create() {
	FoxRenderer.initLibs();
	FoxLoaderUtil.initPathClass(Paths);

	var bg = new FlxSprite();
	bg.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	bg.scrollFactor.set(0, 0);
	PlayState.instance.add(bg);

	var scene = new FoxScene(FlxG.width, FlxG.height);
	scene.scrollFactor.set(0, 0);
	scene.zoomFactor = 0;

	cam = new FoxFPSCamera();
	scene.foxCameras.push(cam);

	cam.enableControls = false;
	cam.bgColor = 0xFF8CE9DB;

	floor = new FoxModel();
	scene.add(floor);

	var mesh = new FoxQuadMesh(6, 6, floorMat, 1);
	mesh.material.params.set("uvScale", [10, 10]);

	floor.addMesh(mesh);

	// Jiji
	var W = FlxG.width / FlxG.height * 3;
	var uiModel = new FoxModel();
	var uiMesh = new FoxQuadMesh(W, 3, FoxMaterial.create(unshader));
	uiMesh.material.blendMode = 5; // Premultipled alpha (for glowing effects)
	uiMesh.material.depthWrite = false;
	uiMesh.material.renderPriority = 1;
	uiMatTextures = uiMesh.material.textures;
	uiModel.addMesh(uiMesh);
	scene.add(uiModel);
	uiModel.y = PlayState.instance.downscroll ? 1.35 : 0.9;
	uiModel.z = .15;

	var reflMask = new FoxModel();
	var maskMat = FoxMaterial.createMinimal(["SOLID"]);
	maskMat.depthWrite = false;
	maskMat.stencil = new FoxStencilAction();
	maskMat.stencil.write = true;
	maskMat.stencil.value = 1;
	maskMat.stencil.setActions(0, 5, 6, 5); // Write on depth fail
	reflMask.addMesh(new FoxQuadMesh(W, 3, maskMat));
	reflMask.y = -1.5;
	scene.add(reflMask);

	uiModelRefl = new FoxModel();
	var reflMesh = uiMesh.copy();
	uiModelRefl.addMesh(reflMesh);
	uiModelRefl.visible = false;

	reflMat = uiMesh.material.copy();
	reflMat.depthTest = false; // Show above
	reflMat.depthWrite = false; 
	reflMat.stencil = new FoxStencilAction();
	reflMat.stencil.read = true;
	reflMat.stencil.value = 1;
	reflMat.stencil.setActions(1);
	reflMat.blendMode = 1;
	reflMat.params.set("color", [1, 1, 1, 0.25]);

	reflMesh.material = reflMat;
	uiModelRefl.scale.y = -1;
	uiModelRefl.y = -uiModel.y;
	scene.add(uiModelRefl);

	sky = new FoxPanoramaSky(FoxMaterial.createSkyCustom("sky_wavy", skyTexture));
	scene.add(sky);
	sky.visible = false;

	// Characters
	bfSprite = new FoxFlxSprite(PlayState.instance.bf, FoxMaterial.create(basicSprite), .0027);
	bfSprite.material.depthWrite = PlayState.instance.downscroll;
	bfSprite.material.renderPriority = 2;
	scene.add(bfSprite);
	bfSprite.y = 0.5;
	bfSprite.x = 1.25;
	bfSprite.z = .5;
	bfSprite.scale.setTo(bf.scale.x, bf.scale.y, 1);
	//bfSprite.angleY = -15;

	dadSprite = new FoxFlxSprite(PlayState.instance.dad, FoxMaterial.create(basicSprite), .0027);
	dadSprite.material.alphaScissor = 0.8;
	dadSprite.material.renderPriority = 2;
	scene.add(dadSprite);
	dadSprite.y = .95;
	dadSprite.x = -1.45;
	dadSprite.z = .5;
	dadSprite.scale.setTo(dad.scale.x, dad.scale.y, 1);
	//dadSprite.angleY = 15;

	// Reflections
	bfSprRef = new FoxFlxSprite(PlayState.instance.bf, bfSprite.material.copy(), .0027);
	bfSprRef.material.depthTest = false;
	bfSprRef.material.depthWrite = false;
	bfSprRef.material.blendMode = 1;
	bfSprRef.material.params.set("color", [1,1,1,0.25]);
	bfSprRef.material.stencil = reflMat.stencil;
	bfSprRef.position.copyFrom(bfSprite.position);
	bfSprRef.rotation.copyFrom(bfSprite.rotation);
	bfSprRef.scale.copyFrom(bfSprite.scale);
	bfSprRef.scale.y *= -1;
	bfSprRef.position.y *= -1;
	scene.add(bfSprRef);
	bfSprRef.visible = false;
	
	dadSprRef = new FoxFlxSprite(PlayState.instance.dad, dadSprite.material.copy(), .0027);
	dadSprRef.material.depthTest = false;
	dadSprRef.material.depthWrite = false;
	dadSprRef.material.blendMode = 1;
	dadSprRef.material.params.set("color", [1,1,1,0.25]);
	dadSprRef.material.stencil = reflMat.stencil;
	dadSprRef.position.copyFrom(dadSprite.position);
	dadSprRef.rotation.copyFrom(dadSprite.rotation);
	dadSprRef.scale.copyFrom(dadSprite.scale);
	dadSprRef.scale.y *= -1;
	dadSprRef.position.y *= -1;
	scene.add(dadSprRef);
	dadSprRef.visible = false;

	// Fih
	fih = new FoxModel();
	fih.loadOBJ("models/fish.obj", ["NO_ALPHA_SCISSOR", "NO_SHADOW_CODE"]);
	scene.add(fih);

	fih.angleY = 90;
	fih.scale.setTo(0.75, 0.75, 0.75);
	fih.y = 10;
	fih.z = -1.5;

	// Configure lights
	scene.environment.ambientLight = FlxColor.fromRGBFloat(0.4, 0.4, 0.4);

	var sun = new FoxDirectionalLight();
	scene.add(sun);

	PlayState.instance.add(scene);

	// Stuff
	camOther.width = FlxG.width;
	camOther.height = FlxG.height;
	camOther.bgColor = 0x0;
	FlxG.cameras.add(camOther, false);

	var met = new FoxRenderMetrics();
	met.y = 360;
	met.camera = camOther;
	PlayState.instance.add(met);

	FlxTimer.wait(0.01, () -> {
		PlayState.instance.healthBarBG.camera =
		PlayState.instance.healthBar.camera = 
		PlayState.instance.scoreTxt.camera = 
		PlayState.instance.missesTxt.camera = 
		PlayState.instance.accuracyTxt.camera = 
		PlayState.instance.iconP1.camera = 
		PlayState.instance.iconP2.camera = camOther;
	});

	// Add a fake filter to our UI
	PlayState.instance.camHUD.filters = [new BitmapFilter()];
	PlayState.instance.camHUD.y = 9999999;

	trace("all good");
}

function postCreate() {
	defaultCamZoom = 1;
}

function update(dt) {
	var cg = PlayState.instance.camGame;
	var ch = PlayState.instance.camHUD;
	var x = cg.scroll.x;
	var y = cg.scroll.y;
	cam.position.setTo(
		(x*.003 + 0.5)*2,
		1 + y*.001+.5, 2.5
	);
	cam.rotation.x = -0.3 - y*.001;
	//cam.rotation.y = x*.001;

	cam.position.setTo(0, 1, 2.5);
	cam.rotation.setTo(0, lerp(cam.rotation.y, 0.3 * ((curCameraTarget == 1) ? -1 : 1), camGame.followLerp), 0);

	var uiBitmapData = ch?.flashSprite?.__cacheBitmapData;
	if(uiBitmapData != null && !uiMatTextures.exists("bitmap")) {
		var tex = FoxTexture.wrap(uiBitmapData);
		uiMatTextures.set("bitmap", tex);
		reflMat.textures.set("bitmap", tex);
	}

	cam.fov = 75 - ch.zoom*2;

	sky.material.params.set("iTime", FlxG.sound.music.time/1000);
	sky.offset.x += dt*.015;

	fih.rotation.y += dt;

	//trace(bf.animation.name);
	//trace(bf.frame.offset + bf.frameOffset);
}

function beatHit(beat) {
	switch(beat) {
		case 46: {
			FlxTween.color(tweenSprite, 0.5, 0xFF8CE9DB, 0xFF000000, {
				onUpdate: () -> {
					cam.bgColor = tweenSprite.color;
				}
			});
		};
		case 48: {
			sky.visible = true;
			floorMatReflective.params.set("uvOffset", floorMat.params.get("uvOffset"));
			floorMatReflective.params.set("uvScale", floorMat.params.get("uvScale"));
			floor.meshes[0].material = floorMatReflective;

			uiModelRefl.visible = true;
			bfSprRef.visible = true;
			dadSprRef.visible = true;
		};
		case 108: {
			FlxTween.tween(fih, {y: 1}, 2.5, {ease: FlxEase.sineOut});
		}
	}
	if(beat >= 49) {
		var uvo = floorMat.params.get("uvOffset");
		var q = Math.random() > 0.5 ? 0 : 1;
		var v = Math.random() > 0.5 ? 0.5 : -0.5;
		var o = {v:uvo[q]};
		FlxTween.tween(o, {v:uvo[q]+v}, 0.25, {
			ease: FlxEase.sineOut,
			onUpdate:()-> {
				uvo[q] = o.v;
			}
		});
	}
}

function destroy() {
	FoxCache.instance.freeResources();
	FlxG.cameras.remove(camOther);
}