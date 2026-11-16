import foxlite.FoxScene;
import foxlite.FoxCamera;
import foxlite.renderer.FoxRenderer;
import foxlite.loaders.FoxLoaderUtil;
import foxlite.mesh.FoxMesh;
import foxlite.lights.FoxDirectionalLight;
import foxlite.FoxModel;
import foxlite.FoxCache;

var cat;
var light = new FoxDirectionalLight(); // Light from the sun, points at +Z (forward)

function create() {
	FoxRenderer.initLibs();
	FoxLoaderUtil.initPathClass(Paths);

	var scene = new FoxScene(FlxG.width, FlxG.height);
	scene.antialiasing = true;
	scene.zoomFactor = 0;
	scene.scrollFactor.set(0, 0);

	var cam = new FoxCamera();
	scene.foxCameras.push(cam);
	scene.environment.ambientLight = 0x666666;
	cam.bgColor = 0x99000000;

	cat = new FoxModel();
	cat.loadOBJ("models/cat.obj", ["MAX_DIRECTIONAL_LIGHTS=1"]);
	cat.z = -20;
	scene.add(cat);

	light.angleZ = 90;
	scene.add(light);

	PlayState.instance.add(scene);

	/*
	var met = new FoxRenderMetrics();
	met.y = 360;
	met.camera = camHUD;
	add(met);
	*/
}

function update(elapsed) {
	if (cat != null) {
		cat.angleY = lerp(cat.angleY, (curCameraTarget == 1) ? 180 : 0, 0.05);
		cat.z = lerp(cat.z, ((Conductor.curBeatFloat >= 32) ? -15 : -20) + (inst.amplitude * ((Conductor.curBeatFloat >= 32) ? 8 : 15)), 0.2);

		cat.x = FlxG.random.float(-1, 1) * inst.amplitude * inst.amplitude * 0.125;
		cat.y = FlxG.random.float(-1, 1) * inst.amplitude * inst.amplitude * 0.125;

		cat.scale.x = lerp(cat.scale.x, 1, 0.15);
		cat.scale.y = lerp(cat.scale.y, 1, 0.15);
		cat.scale.z = lerp(cat.scale.z, 1, 0.15);

		if (Conductor.songPosition >= 0) {
			cat.y += Math.abs(Math.sin(Conductor.curBeatFloat * Math.PI)) * (0.4 + ((Conductor.curBeatFloat >= 32) ? 1.5 : 0));
			if (Conductor.curBeatFloat >= 32) {
				cat.angleZ = (Math.abs((Conductor.curBeatFloat % 2) - 1) - 0.5) * 2 * 30;
				if (Conductor.curBeat % 8 == 0) {
					cat.angleZ += (Conductor.curBeatFloat % 1) * 360;
				}
			}
		}
	}
}

function onNoteHit(e) {
	cat.scale.x = FlxG.random.float(0.75, 1.25);
	cat.scale.y = FlxG.random.float(0.75, 1.25);
	cat.scale.z = FlxG.random.float(0.75, 1.25);
}

function destroy() {
	FoxCache.instance.freeResources();
}