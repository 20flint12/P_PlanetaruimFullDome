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
	[PluginInfo(Name = "convertEulerToQuaternion", Category = "Value", Help = "Simple function that converts euler angles to quaternions. Beware, there is a pretty mess in what is heading, alttitude and bank. Author: Martin Zrcek", Tags = "")]
	#endregion PluginInfo
	public class convertEulerToQuaternion : IPluginEvaluate
	{
		#region fields & pins
		[Input("InputHeading", DefaultValue = 0.0)]
		ISpread<double> FInputH;
		[Input("InputAltitude", DefaultValue = 0.0)]
		ISpread<double> FInputA;
		[Input("InputBank", DefaultValue = 0.0)]
		ISpread<double> FInputB;

		[Output("OutputQuaternions")]
		ISpread<double> FOutputQuaternions;

		[Import()]
		ILogger Flogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			int quatsCount = SpreadMax;
			FOutputQuaternions.SliceCount = quatsCount*4;
			Vector4D mezivysledek;
			for (int i = 0; i < quatsCount; i++) {
				mezivysledek = vypoctiQ(FInputH[i], FInputA[i], FInputB[i]);
				FOutputQuaternions[4*i] = mezivysledek.x;
				FOutputQuaternions[4*i+1] = mezivysledek.y;
				FOutputQuaternions[4*i+2] = mezivysledek.z;
				FOutputQuaternions[4*i+3] = mezivysledek.w;
			}

			Flogger.Log(LogType.Debug, "Logging to Renderer (TTY)");
		}

		 public Vector4D vypoctiQ(double heading, double attitude, double bank) {
		    // Assuming the angles are in radians.
		    Vector4D rotace = new Vector4D();
		    double c1 = Math.Cos(heading/2);
		    double s1 = Math.Sin(heading/2);
		    double c2 = Math.Cos(attitude/2);
		    double s2 = Math.Sin(attitude/2);
		    double c3 = Math.Cos(bank/2);
		    double s3 = Math.Sin(bank/2);
		    double c1c2 = c1*c2;
		    double s1s2 = s1*s2;
		    rotace.w =c1c2*c3 - s1s2*s3;
		  	rotace.x =c1c2*s3 + s1s2*c3;
			rotace.y =s1*c2*c3 + c1*s2*s3;
			rotace.z =c1*s2*c3 - s1*c2*s3;
			return rotace;
		  }
	}
}
