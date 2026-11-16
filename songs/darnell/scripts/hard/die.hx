import foxlite.FoxScene;
import foxlite.FoxCamera;
import foxlite.renderer.FoxRenderer;
import foxlite.loaders.FoxLoaderUtil;
import foxlite.mesh.FoxMesh;
import foxlite.lights.FoxDirectionalLight;
import foxlite.FoxModel;
import foxlite.FoxCache;

var fih;
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

	fih = new FoxModel();
	fih.loadOBJ("models/fish.obj", ["NO_SHADOW_CODE"]);
	fih.z = -20;
	scene.add(fih);

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
	if (fih != null) {
		fih.angleY = lerp(fih.angleY, (curCameraTarget == 1) ? 180 : 0, 0.05);
		fih.z = lerp(fih.z, -20 + (inst.amplitude * 15), 0.2);

		fih.x = FlxG.random.float(-1, 1) * inst.amplitude * inst.amplitude * 0.125;
		fih.y = FlxG.random.float(-1, 1) * inst.amplitude * inst.amplitude * 0.125;

		fih.scale.x = lerp(fih.scale.x, 1, 0.15);
		fih.scale.y = lerp(fih.scale.y, 1, 0.15);
		fih.scale.z = lerp(fih.scale.z, 1, 0.15);
	}
}

function onNoteHit(e) {
	fih.scale.x = FlxG.random.float(0.75, 1.25);
	fih.scale.y = FlxG.random.float(0.75, 1.25);
	fih.scale.z = FlxG.random.float(0.75, 1.25);
}

function destroy() {
	FoxCache.instance.freeResources();
}