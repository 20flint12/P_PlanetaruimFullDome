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
	[PluginInfo(Name = "CiantSplitLine", Category = "Value", Help = "Basic template with one value in/out", Tags = "")]
	#endregion PluginInfo
	public class ValueCiantSplitLineNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Input XYZ Vector", DefaultValue = 0.0)]
		ISpread<double> FInput1;
		[Input("Input2 XYZ Vector", DefaultValue = 1.0)]
		ISpread<double> FInput2;
		[Input("Count", DefaultValue = 4.0)]
		ISpread<int> VertexCount;

		[Output("Output")]
		ISpread<double> FOutput;

		[Import()]
		ILogger FLogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			FOutput.SliceCount = SpreadMax*VertexCount[0];
			double step = 1.0/(VertexCount[0]-1);
			int countVerts = 0;
			int vertexStep = VertexCount[0]*3;

			for (int i = 0; i<SpreadMax; i++) {
				for (int j = 0; j<VertexCount[0]; j++)
					FOutput[countVerts*vertexStep + (i%3) + j*3] = FInput1[i] + (FInput2[i]-FInput1[i])*(j*step);
				if (i%3==2) countVerts++;
			}
		}

		//FLogger.Log(LogType.Debug, "hi tty!");
	}
}

