#region usings
using System;
using System.ComponentModel.Composition;

using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;

using VVVV.Core.Logging;
#endregion usings
//@author: Martin Zrcek, for CIANT
//@help: Creates a movement cycle initialTex shaders. Input and output fields are textures.
//@tags: shade
//@credits:


namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "apuSkeleton12", Category = "Spectral", Help = "Computes orientations of single bones from 12 sensors.", Tags = "")]
	#endregion PluginInfo
	public class apuSkeleton12 : IPluginEvaluate
	{
		#region fields & pins
		[Input("InputPositions")]
		ISpread<Vector3D> pozice;
		[Input("InputQuaternionOrientations", DefaultValue=1.0)]
		ISpread<Vector4D> orientace;
		[Input("UpperArmSize", DefaultValue=1.0)]
		ISpread<double> upperArmSize;
		//[Input("HandSize", DefaultValue=1.0)]
		ISpread<double> handSize;

		[Output("OutputQuaternionRotations")]
		ISpread<Vector4D> rotaceKosti;
		//[Output("Test position")]
		//ISpread<Vector3D> testovaciPos;
		// = bone rotation
		[Import()]
		ILogger Flogger;
		#endregion fields & pins

		#region Quaternion operations
		//quaternion multiplication	
/*
				x = w1x2 + x1w2 + y1z2 - z1y2
				y = w1y2 + y1w2 + z1x2 - x1z2
				z = w1z2 + z1w2 + x1y2 - y1x2
				w = w1w2 - x1x2 - y1y2 - z1z2*/
		public Vector4D qMultiply(Vector4D quat1, Vector4D quat2) 
		{
		
			Vector4D result = new Vector4D();
			result.x = quat2.w * quat1.x + quat2.x * quat1.w + quat2.y * quat1.z - quat2.z * quat1.y;
			result.y = quat2.w * quat1.y + quat2.y * quat1.w + quat2.z * quat1.x - quat2.x * quat1.z;
			result.z = quat2.w * quat1.z + quat2.z * quat1.w + quat2.x * quat1.y - quat2.y * quat1.x;
			result.w = quat2.w * quat1.w - quat2.x * quat1.x - quat2.y * quat1.y - quat2.z * quat1.z;
			return result;
		}
		//quaternion inverse
		public Vector4D qInverse(Vector4D quat)
		{
			Vector4D result = new Vector4D();
			result.x = -quat.x;
			result.y = -quat.y;
			result.z = -quat.z;
			result.w = quat.w;
			return result;
		}
		//quaternion unify, puts it to length 1
		public Vector4D qUnify(Vector4D quat)
		{
			Vector4D result;
			if (quat.x == 0 && quat.y == 0 && quat.z == 0 && quat.w == 0)
				result = new Vector4D(0, 0, 0, 1);
			else {
				double length = Math.Sqrt(quat.x * quat.x + quat.y * quat.y + quat.z * quat.z + quat.w * quat.w);
				result.x = quat.x / length;
				result.y = quat.y / length;
				result.z = quat.z / length;
				result.w = quat.w / length;
			}
			return result;
		}
		public Vector4D qReferencePlane(Vector4D quat) 
		{
			Vector4D nasobitel = new Vector4D (0,0,.7071,.7071);
			quat = qMultiply( qMultiply(nasobitel,quat) , qInverse(nasobitel) );
			return quat;
		}

		public double dotVectors(Vector3D vecA, Vector3D vecB) {
			return vecA.x*vecB.x+vecA.y*vecB.y+vecA.z*vecB.z;
		}
		public Vector3D crossVectors(Vector3D vecA, Vector3D vecB) {
			return new Vector3D(vecA.y*vecB.z-vecA.z*vecB.y, vecA.z*vecB.x-vecA.x*vecB.z, vecA.x*vecB.y-vecA.y*vecB.x);
		}
		public Vector3D normalizeVector(Vector3D vec) {
			double invL = 1 / Math.Sqrt(vec.x*vec.x+vec.y*vec.y+vec.z*vec.z);
			return new Vector3D(vec.x*invL, vec.y*invL, vec.z*invL);
		}
		//use quaternion to rotate a vector
		public Vector3D qRotateVector(Vector4D quat, Vector3D vect) {
			Vector3D result;
			if (quat.x==0 && quat.y==0 && quat.z==0 && quat.w==0) 
				result = new Vector3D(0,0,0);
			else {
				Vector4D vect2;
				vect2.x=vect.x; vect2.y=vect.y; vect2.z=vect.z; vect2.w=0;
				vect2 = qUnify( qMultiply( qMultiply(quat, vect2) , qInverse(quat) ) );
				result = vect2.xyz; 
			}
			return result;
		}
		//gets the shortest quaternion between two vectors
		public Vector4D qGetQuaternionToPoint(Vector3D vecA, Vector3D vecB) {
			Vector4D result;
			if ( (vecA.x==0 && vecA.y==0 && vecA.z==0) || (vecB.x==0 && vecB.y==0 && vecB.z==0) )  
				result = new Vector4D(0,0,0,1);
			else {
				vecA = normalizeVector(vecA);
				vecB = normalizeVector(vecB);
				double d = dotVectors(vecA,vecB);
				double s = Math.Sqrt( (1+d)*2 );
				double invs = 1 / s;
				Vector3D c = crossVectors(vecA,vecB);
				result.x = c.x * invs;
				result.y = c.y * invs;
				result.z = c.z * invs;
				result.w = s * 0.5;
			}
			return qUnify(result);
		}
		#endregion Quaternion operations
		
		// SENSORS (orientace): 0-Pelvis 1-Head
		// 2-lThigh  3-lCalf  4-lUpperArm  5-lHand 
		// 6-rThigh  7-rCalf  8-rUpperArm  9-rHand 10-Spine1 11-Spine2

		// BONES (rotaceKosti, vystup):  0-Pelvis 1-Head 2-Spine 3-Spine1 4-Spine2 5-Neck
		// 6-lThigh  7-lCalf  8-lFoot 9-lClavicle 10-lUpperArm  11-lForearm  12-lHand 
		// 13-rThigh 14-rCalf 15-rFoot 16-rClavicle 17-rUpperArm 18-rForearm 19-rHand 
		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{

			//rotaceKosti.SliceCount = orientace.SliceCount;
			//rotaceKosti[0] = qInverse(orientace[0]);
			rotaceKosti.SliceCount = 20;  
			// jednotkovani velikosti quaternionu .. pro kontrolu
			Vector4D nullovy = new Vector4D(0, 0, 0, 1);
			Vector3D xVector = new Vector3D(1, 0, 0);
			
/*			
			// 0 .. Pelvis			(sensor 0)	[11]
			rotaceKosti[0] = qUnify(orientace[0]);
			// 3 .. Spine1			(sensor 10)	[1]
			rotaceKosti[2]  = qMultiply( qUnify(orientace[1]), qInverse( qUnify(orientace[0]) ) );
			// 1 .. Head			(sensor 1)	[14]
			rotaceKosti[3] = qMultiply( qUnify(orientace[2]), qInverse( qUnify(orientace[1]) ) );
			
*/
			// 0 .. Pelvis			(sensor 0)  .. is rotation parrent for upper body and position parrent for everything
			rotaceKosti[0] = orientace[0];
			//rotaceKosti[0] = qMultiply(orientace[0], new Vector4D(0, 0, 0.7071, 0.7071));
			// 1 .. Head			(sensor 1)
			rotaceKosti[1] = qMultiply(orientace[1] , qInverse(orientace[11]) );
			// 2 .. Spine
			// 3 .. Spine1			(sensor 10)
			rotaceKosti[2] = qMultiply(orientace[10], qInverse(orientace[0]) );
			// 4 .. Spine2			(sensor 11)
			rotaceKosti[3] = qMultiply(orientace[11], qInverse(orientace[10]) );
			// 5 .. Neck
	
			// 6 .. left tigh		(sensor 2)
			rotaceKosti[6] = qMultiply(orientace[2] , qInverse(orientace[0]) );
			// 7 .. left calf		(sensor 3)
			rotaceKosti[7] = qMultiply(orientace[3] , qInverse(orientace[2]) );
			// 8 .. left foot
			rotaceKosti[8] = rotaceKosti[7] / 1.3;
			// 9 .. left clavicle
			// 10 .. left upper arm	(sensor 4)
			rotaceKosti[10] = qMultiply(orientace[4] , qInverse(orientace[11]) );
			rotaceKosti[11] = qMultiply(orientace[5] , qInverse(orientace[4]) );
			rotaceKosti[12] = rotaceKosti[11] / 1.3;
			// 11 .. left forearm		
	/*		Vector3D IKBegin = pozice[4] + qRotateVector(orientace[4],xVector) * upperArmSize[0];
			Vector3D IKEnd = pozice[5];
			Vector3D IKDirection = IKEnd - IKBegin;
			//IKDirection = qRotateVector( qInverse(orientace[4]) , IKDirection);
			rotaceKosti[11] =  qMultiply(qGetQuaternionToPoint(xVector,IKDirection), qInverse(orientace[4]));
			// 12 .. left hand		(sensor 5)
			rotaceKosti[12] = qMultiply(orientace[5] , qInverse(  qMultiply(orientace[4],rotaceKosti[11])  ));
	/**/		// the forearm should inherit rotation from a hand
	
			// 13 .. right tigh		(sensor 6)
			rotaceKosti[13] = qMultiply(orientace[6] , qInverse(orientace[0]) );			
			// 14 .. right calf		(sensor 7)
			rotaceKosti[14] = qMultiply(orientace[7] , qInverse(orientace[6]) );
			// 15 .. right foot
			rotaceKosti[15] = rotaceKosti[14] / 1.3;
			// 16 .. right clavicle
			// 17 .. right upper arm(sensor 8)
			rotaceKosti[17] = qMultiply(orientace[8] , qInverse(orientace[11]) );
			rotaceKosti[18] = qMultiply(orientace[9] , qInverse(orientace[8]) );
			rotaceKosti[19] = rotaceKosti[18] / 1.3;
	/*		// 18 .. right forearm	
			IKBegin = pozice[8] + qRotateVector(orientace[8],-1*xVector) * upperArmSize[0];
			IKEnd = pozice[9];
			IKDirection = IKEnd - IKBegin;
			//testovaciPos[0]=IKBegin;
			rotaceKosti[18] =  qMultiply( qInverse(qUnify(orientace[8])) , qGetQuaternionToPoint(-1*xVector,IKDirection) );
			//rotaceKosti[18] = qMultiply(qInverse(qUnify(orientace[8])), qUnify(orientace[9]));
			
			// 19 .. right hand		(sensor 9)
			rotaceKosti[19] = qMultiply(qInverse(  qMultiply(qUnify(orientace[8]),rotaceKosti[18])  ), qUnify(orientace[9]));
			// the forearm should inherit rotation from a hand
	/**/
			for (int i=0; i<20; i++) 
				rotaceKosti[i] = qReferencePlane( rotaceKosti[i] );
				
		}
	}
}
