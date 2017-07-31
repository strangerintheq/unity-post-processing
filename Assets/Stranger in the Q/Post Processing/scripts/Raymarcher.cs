using UnityEngine;
using System.Collections.Generic;

[AddComponentMenu("Effects/Raymarcher")]
public class Raymarcher : PostProcessing {

	public enum Primitive {
		BOX, ELLIPSOID
	}

	public List<Primitive> primitivesTypes;
	public List<Transform> primitivesTranforms;

	override public void setMaterialProperties (Material EffectMaterial) {
		List<Matrix4x4> primitivesAsArray = new List<Matrix4x4>();
		for (int i = 0; i < primitivesTypes.Count; i++) {
			Matrix4x4 m = new Matrix4x4();
			m.m00 = ((int) primitivesTypes [i]) + 1;
			m.SetRow (1, primitivesTranforms [i].position);
			m.SetRow (2, primitivesTranforms [i].localScale);
			primitivesAsArray.Add (m);
		}
		EffectMaterial.SetMatrixArray ("_Primitives", primitivesAsArray);		
	}
}
