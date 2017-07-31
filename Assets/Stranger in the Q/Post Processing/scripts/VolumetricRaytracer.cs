using UnityEngine;
using System.Collections.Generic;

[AddComponentMenu("Effects/Volumetric Clouds")]
public class VolumetricRaytracer : PostProcessing {

	public Transform targetVolume;
	public Vector3 repeat;

	override public void setMaterialProperties (Material EffectMaterial) {
		EffectMaterial.SetVector ("_TargetVolumePosition", targetVolume.position);
		EffectMaterial.SetVector ("_TargetVolumeScale", targetVolume.localScale);
		EffectMaterial.SetVector ("_Repeat", repeat);
    }
}
