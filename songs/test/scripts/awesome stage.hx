import foxlite.flixel.FoxRenderMetrics;
import foxlite.renderer.FoxRenderer;
import foxlite.loaders.FoxLoaderUtil;
import foxlite.FoxCache;
import foxlite.FoxModel;
import foxlite.FoxScene;
import foxlite.FoxShader;
import foxlite.FoxCamera;
import foxlite.material.FoxMaterial;
import flixel.graphics.tile.FlxGraphicsShader;
import foxlite.funkin.FoxFunkinSprite;

var scene:FoxScene;
var camera:FoxCamera = new FoxCamera();
var t = new FoxRenderMetrics();
var camOther = new FlxCamera();
var basicSprite = FoxShader.fromAsset('foxlite/basic', ["UNSHADED"]);
var light = new FoxDirectionalLight();

var dad3D:FoxFunkinSprite;
var gf3D:FoxFunkinSprite;
var boyfriend3D:FoxFunkinSprite;
var glCube:FoxModel;

function postCreate() {
    FlxG.cameras.add(camOther, false);
    camOther.bgColor = 0;
	FlxG.mouse.visible = true;

	// Foxlite init
	FoxRenderer.initLibs();
	FoxLoaderUtil.initPathClass(Paths);

    FoxShader.GLOBAL_FLAGS.resize(0);
    FoxShader.GLOBAL_FLAGS.push('MAX_DIRECTIONAL_LIGHTS=1');
    FoxShader.GLOBAL_FLAGS.push('NO_SHADOW_CODE');

	scene = new FoxScene(FlxG.width, FlxG.height);
    scene.zoomFactor = 0;
    scene.scrollFactor.set();
    scene.environment.ambientLight = 0x666666;
	add(scene);

    camera.bgColor = 0xfffade65;
    camera.z = 1.25;
	scene.foxCameras.push(camera);

    light.angleX = -45;
	scene.add(light);

    t.text.font = Paths.font('StatusPlz.ttf');
    t.text.borderStyle = flixel.text.FlxTextBorderStyle.OUTLINE;
    t.text.borderColor = 0xff000000;
    t.text.borderSize = 2;
    t.camera = camOther;
    t.extraInfo = 'Test (G-Side Remix)';
	add(t);

    var pixelSize = 0.003;

    for (i in [dad, boyfriend, gf]) {
        i.useRenderTexture = true;
        i.shader = new FlxGraphicsShader();
    }
    gf3D = new FoxFunkinSprite(gf, FoxMaterial.create(basicSprite), pixelSize);
    scene.add(gf3D);
    gf3D.position.setTo(0, 0.4, -0.25);
    gf3D.useMatrixOffsets = false; // for some reason i have to do that

    dad3D = new FoxFunkinSprite(dad, FoxMaterial.create(basicSprite), pixelSize);
    scene.add(dad3D);
    dad3D.position.setTo(-1.25, -0.05, 0);
    dad3D.scale.setTo(dad.scale.x, dad.scale.y, 1);
    if (dad.flipX) dad3D.scale.x *= -1;
    for (x => i in dad3D.material.textures) { i.filter = 5; }

    boyfriend3D = new FoxFunkinSprite(boyfriend, FoxMaterial.create(basicSprite), pixelSize);
    scene.add(boyfriend3D);
    boyfriend3D.position.setTo(1.25, -0.1, 0);

    var cubeTexture = FoxTexture.fromImage("opengl");
    cubeTexture.wrapMode = 2;

    glCube = new FoxModel();
    var cubeMesh = new foxlite.mesh.FoxCubeMesh(0.4, 0.4, 0.4, FoxMaterial.create(FoxShader.fromAsset('foxlite/basic'), ["bitmap" => cubeTexture]));
    cubeMesh.material.params.set('uvScale', [1, -1]);
    glCube.addMesh(cubeMesh);
    scene.add(glCube);
}

var stopped = false;
function stop() stopped = !stopped;
function update(elapsed) {
    t.setPosition(50, FlxG.height - t.text.height - 50);
    camera.position.x = lerp(camera.position.x, -0.6 * ((curCameraTarget == 1) ? -1 : 1), 0.04);
    camera.position.z = 1.25;
    if (Conductor.curMeasure < 8) {
        camera.position.z += (4 - Math.floor(Conductor.curMeasure * 0.5)) * 0.2 - (Conductor.curMeasureFloat * 0.5 - Math.floor(Conductor.curMeasure * 0.5)) * 0.1;
    }

    if (!stopped) {
        glCube.rotation.x += elapsed;
        glCube.rotation.y += elapsed;
        glCube.rotation.z += elapsed;
    }
}

function destroy() {
	FoxCache.instance.freeResources();
	scene?.set_visible(false);
	scene?.destroy();

    FoxShader.GLOBAL_FLAGS.resize(0);
}