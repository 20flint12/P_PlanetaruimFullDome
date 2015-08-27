#region usings
using System;
using System.ComponentModel.Composition;

using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;

using VVVV.Core.Logging;
#endregion usings

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "convertQuaternionToEuler", Category = "Value", Help = "Simple function that converts Quaternion to euler angles. Beware, there is a pretty mess in what is heading, alttitude and bank. Author: Martin Zrcek", Tags = "")]
	#endregion PluginInfo
	public class convertQuaternionToEuler : IPluginEvaluate
	{
		#region fields & pins
		[Input("Input", DefaultValue = 1.0)]
		ISpread<double> FInput;

		[Output("OutputHeading")]
		ISpread<double> FOutputH;
		[Output("OutputAttitude")]
		ISpread<double> FOutputA;
		[Output("OutputBank")]
		ISpread<double> FOutputB;

		[Import()]
		ILogger Flogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			int quatsCount = SpreadMax/4;
			FOutputH.SliceCount = quatsCount;
			FOutputA.SliceCount = quatsCount;
			FOutputB.SliceCount = quatsCount;
			Vector3D mezivysledek;
			for (int i = 0; i < quatsCount; i++) {
				mezivysledek = vypocti(new Vector4D(FInput[4*i], FInput[4*i+1], FInput[4*i+2], FInput[4*i+3]));
				FOutputH[i] = mezivysledek.x;
				FOutputA[i] = mezivysledek.y;
				FOutputB[i] = mezivysledek.z;
			}

			Flogger.Log(LogType.Debug, "Logging to Renderer (TTY)");
		}
	
	
	/** assumes q1 is a normalised quaternion */

public Vector3D vypocti(Vector4D q1) {
	double test = q1.x*q1.y + q1.z*q1.w;
	double heading, attitude, bank;
	if (test > 0.499) { // singularity at north pole
		heading = 2 * Math.Atan2(q1.x,q1.w);
		attitude = Math.PI/2;
		bank = 0;
	}
	else if (test < -0.499) { // singularity at south pole
		heading = -2 * Math.Atan2(q1.x,q1.w);
		attitude = - Math.PI/2;
		bank = 0;
	} else {
    double sqx = q1.x*q1.x;
    double sqy = q1.y*q1.y;
    double sqz = q1.z*q1.z;
    heading = Math.Atan2(2*q1.y*q1.w-2*q1.x*q1.z , 1 - 2*sqy - 2*sqz);
	attitude = Math.Asin(2*test);
	bank = Math.Atan2(2*q1.x*q1.w-2*q1.y*q1.z , 1 - 2*sqx - 2*sqz);
	} 
	return new Vector3D(heading,attitude,bank);
}

	}
}
