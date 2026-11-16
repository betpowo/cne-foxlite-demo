import foxlite.FoxScene;
import foxlite.FoxCamera;
import foxlite.renderer.FoxRenderer;
import foxlite.loaders.FoxLoaderUtil;
import foxlite.mesh.FoxMesh;
import foxlite.lights.FoxDirectionalLight;
import foxlite.lights.FoxPointLight;
import foxlite.FoxModel;
import foxlite.FoxCache;

var scene;
var fih;
var lights = [for (i in 0...8) new FoxPointLight()];

function create() {
	FoxRenderer.initLibs();
	FoxLoaderUtil.initPathClass(Paths);

	scene = new FoxScene(FlxG.width, FlxG.height);
	scene.antialiasing = true;
	scene.zoomFactor = 0;
	scene.scrollFactor.set(0, 0);

	var cam = new FoxCamera();
	scene.foxCameras.push(cam);
	scene.environment.ambientLight = 0x666666;
	cam.bgColor = 0x99000000;

	fih = new FoxModel();
	fih.loadOBJ("models/fish.obj", ["NO_SHADOW_CODE"]);
	fih.z = -20;
	scene.add(fih);

	for (i in lights) scene.add(i);

	PlayState.instance.add(scene);

	/*
	var met = new FoxRenderMetrics();
	met.y = 360;
	met.camera = camHUD;
	add(met);
	*/
}

function update(elapsed) {
	if (fih != null) {
		fih.angleY = lerp(fih.angleY, (curCameraTarget == 1) ? 180 : 0, 0.05);
		fih.z = lerp(fih.z, -20 + (inst.amplitude * 15), 0.2);

		fih.x = FlxG.random.float(-1, 1) * inst.amplitude * inst.amplitude * 0.125;
		fih.y = FlxG.random.float(-1, 1) * inst.amplitude * inst.amplitude * 0.125;

		fih.scale.x = lerp(fih.scale.x, 1, 0.15);
		fih.scale.y = lerp(fih.scale.y, 1, 0.15);
		fih.scale.z = lerp(fih.scale.z, 1, 0.15);

		fih.angleZ = 0;
		if (Conductor.curBeatFloat >= 32) {
			fih.angleX = (Conductor.curBeatFloat % 2) * 180;
		}

		if ((Conductor.curBeatFloat < 80) || (Conductor.curBeatFloat >= 217)) {
			if (Conductor.curBeatFloat >= 56) {
				fih.angleX = FlxG.random.float(-180, 180);
				fih.angleY = FlxG.random.float(-180, 180);
				fih.angleZ = FlxG.random.float(-180, 180);
				fih.x = FlxG.random.float(-8, 8);
				fih.y = FlxG.random.float(-8, 8);
				fih.z = FlxG.random.float(-16, -2);
				fih.scale.x = FlxG.random.float(0.1, 10);
				fih.scale.y = FlxG.random.float(0.1, 10);
				fih.scale.z = FlxG.random.float(0.1, 10);
			}

			if (Conductor.curBeatFloat >= 58.2 && Conductor.curBeatFloat < 79.8) {
				fih.angleX = 15;
				fih.angleY = 24;
				fih.angleZ = 67;
				fih.position.setTo(5, 3, -16);
				fih.scale.setTo(1.2, 0.5, 0.8);
			}
		}
	}
	var time = Math.max(0, Conductor.songPosition * 0.001);
	for (x => i in lights) {
		var d = x / lights.length;
		i.x = Math.cos(time + d * Math.PI * 2) * 5;
		i.z = Math.sin(time + d * Math.PI * 2) * 5 + fih.z;
		i.range = 6 + (inst.amplitude + vocals.amplitude) * 3;
		i.colorHex = FlxColor.fromHSB((time + x) * 180, 0.6 + vocals.amplitude * 0.4, 1);
	}
	scene.environment.ambientLight = FlxColor.fromHSB(time * 90, 1, 0.3 + inst.amplitude);
}

function onNoteHit(e) {
	fih.scale.x = FlxG.random.float(0.75, 1.25);
	fih.scale.y = FlxG.random.float(0.75, 1.25);
	fih.scale.z = FlxG.random.float(0.75, 1.25);
}

function destroy() {
	FoxCache.instance.freeResources();
}