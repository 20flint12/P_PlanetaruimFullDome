#region usings
using System;
using System.ComponentModel.Composition;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.IO;
using System.Drawing;
using System.Collections.Generic;

using SlimDX;
using SlimDX.Direct3D9;
using VVVV.Core.Logging;
using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.PluginInterfaces.V2.EX9;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;
using VVVV.Utils.SlimDX;

using PdfSharp;
using PdfSharp.Pdf;
using PdfSharp.Pdf.IO;
using PdfSharp.Drawing;
using PdfSharp.Forms; 

#endregion usings

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "PDFTexture",
				Category = "EX9.Texture",
				Help = "Creates a texture from PD",
				Tags = "")]
	#endregion PluginInfo
	public class EX9_TexturePDFTextureNode : DXTextureOutPluginBase, IPluginEvaluate
	{
		#region fields & pins
        [Input("FileName", StringType = StringType.Filename, FileMask = "PDF File (*.pdf)|*.pdf", AllowDefault=false)]
		IDiffSpread<string> FFileNameIn;

		[Input("Weight", DefaultValue = 256, AsInt = true, IsSingle = true)]
		ISpread<int> FWeightIn;

        [Input("Format", DefaultEnumEntry = "A8R8G8B8", IsSingle = true)]
		ISpread<Format> FFormatIn;

        [Input("Reload", DefaultValue = 0, AsInt = true, IsSingle = true)]
		ISpread<bool> FReloadIn;
		
		[Output("String Output")]
		ISpread<string> FStringOut;
		
		[Output("HTTP Output")]
		ISpread<string> FHTTPOut;
		
		[Output("ScaleFactor")]
		ISpread<double> FScaleFactorOut;
		
		[Output("SpreadCount")]
		ISpread<int> FSpreadCountOut;

        [Output("Up And Running")]
        ISpread<int> FUpRunningOut;
        
		[Import()]
		ILogger FLogger;

        #endregion fields & pins

        #region local variables
        private List<string> FStringLocal;
        private List<string> FHTTPLocal;
        private List<double> FScaleFactorLocal;
        private List<int> FSpreadCountLocal;
        private List<string> texFileNames;
        private List<byte[]> texBytes;
        private int pagesCount;

        private bool reLoadFlag;
        private bool doReloadNextFrame;

        private int curSlice;
        #endregion

        // import host and hand it to base constructor
		[ImportingConstructor()]
		public EX9_TexturePDFTextureNode(IPluginHost host) : base(host)
		{
            reLoadFlag = true;
            FStringLocal = new List<string>();
            FHTTPLocal = new List<string>();
            FScaleFactorLocal = new List<double>();
            FSpreadCountLocal = new List<int>();
            texFileNames = new List<string>();
            texBytes = new List<byte[]>();
            doReloadNextFrame = true;
		}

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
            if (FReloadIn[0] || FFileNameIn.IsChanged)
            {
                doReloadNextFrame = true;
            }

            if (doReloadNextFrame)
            {
                FStringLocal.Clear();
                FHTTPLocal.Clear();
                FScaleFactorLocal.Clear();
                FSpreadCountLocal.Clear();
                texFileNames.Clear();
                texBytes.Clear();

                FStringOut.SliceCount = 0;
                FHTTPOut.SliceCount = 0;
                FScaleFactorOut.SliceCount = 0;
                FSpreadCountOut.SliceCount = 0;

                FUpRunningOut[0] = 0;
                FUpRunningOut.SliceCount = 1;

                doReloadNextFrame = false;
                reLoadFlag = true;

                return;
            }

            if (reLoadFlag)
            {
                Initialize();
                reLoadFlag = false;
            }

            // just perform copying to output fields
            FStringOut.SliceCount = pagesCount;
            FHTTPOut.SliceCount = pagesCount;
            FScaleFactorOut.SliceCount = SpreadMax;
            FSpreadCountOut.SliceCount = SpreadMax;
            FUpRunningOut.SliceCount = 1;

            for (int k = 0; k < pagesCount; k++)
            {
                FStringOut[k] = FStringLocal[k];
                FHTTPOut[k] = FHTTPLocal[k];
            }
            for (int k = 0; k < SpreadMax; k++)
            {
                FScaleFactorOut[k] = FScaleFactorLocal[k];
                FSpreadCountOut[k] = FSpreadCountLocal[k];
            }
            FUpRunningOut[0] = 1;

            SetSliceCount(pagesCount);
		}

        private void Initialize()
        {
            // find plugins folder
            string pluginPath = System.Reflection.Assembly.GetExecutingAssembly().Location;
            pluginPath = Path.GetDirectoryName(pluginPath);

            pagesCount = 0;
            for (int i = 0; i < FFileNameIn.SliceCount; i++)
            {
                // open and parse each .pdf
                // Open the file
                PdfDocument document = PdfReader.Open(FFileNameIn[i], PdfDocumentOpenMode.ReadOnly);
                FSpreadCountLocal.Add(document.PageCount);
                FScaleFactorLocal.Add(document.Pages[0].Width / document.Pages[0].Height);

                // render .png files for each page
                string pngName = i + "_%d.png";
                Process exe = new System.Diagnostics.Process();
                exe.StartInfo.UseShellExecute = true;
                exe.StartInfo.FileName = "pdfdraw.exe";
                exe.StartInfo.WorkingDirectory = pluginPath;
                exe.StartInfo.Arguments = "-o " + pngName + " -r 144 \"";
                exe.StartInfo.Arguments += @FFileNameIn[i];
                exe.StartInfo.Arguments += "\" ";
                exe.StartInfo.ErrorDialog = false;
                exe.StartInfo.CreateNoWindow = true;
                exe.Start();
                exe.WaitForExit();

                for (int j = 0; j < FSpreadCountLocal[i]; j++)
                {
                    // get image
                    string curPngName = i + "_" + (j + 1) + ".png";
                    Image img = Image.FromFile(pluginPath + "\\" + curPngName);
                    Image.GetThumbnailImageAbort myCallBack = new Image.GetThumbnailImageAbort(ThumbnailCallback);
                    Image texImg = img.GetThumbnailImage(FWeightIn[0], FWeightIn[0], myCallBack, IntPtr.Zero);
                    img.Dispose();
                    File.Delete(pluginPath + "\\" + curPngName);

                    // create a byte-array for a picture content
                    MemoryStream ms = new MemoryStream();
                    texImg.Save(ms, System.Drawing.Imaging.ImageFormat.Bmp);
                    texImg.Dispose();

                    ms.Seek(54, SeekOrigin.Begin);
                    byte[] bytes = new byte[(int)ms.Length - 54];
                    ms.Read(bytes, 0, (int)ms.Length - 54);
                    texBytes.Add(bytes);
                    ms.Close();

                    // get text
                    string pageText = "";
                    System.Text.StringBuilder sb = new System.Text.StringBuilder();

                    PdfPage curPage = document.Pages[j];
                    for (int index = 0; index < curPage.Contents.Elements.Count; index++)
                    {
                        PdfDictionary.PdfStream stream = curPage.Contents.Elements.GetDictionary(index).Stream;
                        pageText += new PDFParser().ExtractTextFromPDFBytes(stream.Value);
                    }
                    FStringLocal.Add(pageText);

                    // parse text and find hyperlinks
                    string hyperLinks = "";
                    string pattern = @"(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])";
                    System.Text.RegularExpressions.Regex regex = new System.Text.RegularExpressions.Regex(pattern);
                    System.Text.RegularExpressions.MatchCollection matches = regex.Matches(pageText);
                    for (int l = 0; l < matches.Count; l++)
                    {
                        hyperLinks += matches[l].Value + " ";
                    }

                    // parse text and find email addresses
                    pattern = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";
                    System.Text.RegularExpressions.Regex regex2 = new System.Text.RegularExpressions.Regex(pattern);
                    System.Text.RegularExpressions.MatchCollection matches2 = regex2.Matches(pageText);
                    for (int l = 0; l < matches2.Count; l++)
                    {
                        hyperLinks += matches2[l].Value + " ";
                    }
                    FHTTPLocal.Add(hyperLinks);
                }

                pagesCount += FSpreadCountLocal[i];
            }
        }

        #region texture routines
        //this method gets called, when Reinitialize() was called in evaluate,
		//or a graphics device asks for its data
		protected override Texture CreateTexture(int Slice, Device device)
		{
            FLogger.Log(LogType.Debug, "Creating new texture at slice: " + Slice);
            Texture tex = new Texture(device, FWeightIn[0], FWeightIn[0], 1, Usage.None, FFormatIn[0], Pool.Managed);
            return tex;
		}

		//this method gets called, when Update() was called in evaluate,
		//or a graphics device asks for its texture, here you fill the texture with the actual data
		//this is called for each renderer, careful here with multiscreen setups, in that case
		//calculate the pixels in evaluate and just copy the data to the device texture here
        protected unsafe override void UpdateTexture(int Slice, Texture texture)
        {
            curSlice = Slice;
            TextureUtils.Fill32BitTexInPlace(texture, FillTexure);
        }

        //this is a pixelshader like method, which we pass to the fill function
        private unsafe void FillTexure(uint* data, int row, int col, int width, int height)
        {
            int index = (width * (height - row - 1) + col) * 4;
            byte R = texBytes[curSlice][index + 2];
            byte G = texBytes[curSlice][index + 1];
            byte B = texBytes[curSlice][index];
            byte A = 255;

            // trasparency
/*          
			byte bgR = 255;
            byte bgG = 255;
            byte bgB = 255;
            int precision = 15;
            
            if ((Math.Abs(R - bgR) < precision) &&
                (Math.Abs(G - bgG) < precision) &&
                (Math.Abs(B - bgB) < precision))
                A = 0;
*/

            var pixel = UInt32Utils.fromARGB(A, R, G, B);

            TextureUtils.SetPtrVal2D(data, pixel, row, col, width);
        }

        private bool ThumbnailCallback()
        {
            return false;
        }
        #endregion
    }

    #region PDFParser
    public class PDFParser
    {
        /// BT = Beginning of a text object operator 
        /// ET = End of a text object operator
        /// Td move to the start of next line
        ///  5 Ts = superscript
        /// -5 Ts = subscript

        #region Fields

        #region _numberOfCharsToKeep
        /// <summary>
        /// The number of characters to keep, when extracting text.
        /// </summary>
        private static int _numberOfCharsToKeep = 15;
        #endregion

        #endregion



        #region ExtractTextFromPDFBytes
        /// <summary>
        /// This method processes an uncompressed Adobe (text) object 
        /// and extracts text.
        /// </summary>
        /// <param name="input">uncompressed</param>
        /// <returns></returns>
        public string ExtractTextFromPDFBytes(byte[] input)
        {
            if (input == null || input.Length == 0) return "";

            try
            {
                string resultString = "";

                // Flag showing if we are we currently inside a text object
                bool inTextObject = false;

                // Flag showing if the next character is literal 
                // e.g. '\\' to get a '\' character or '\(' to get '('
                bool nextLiteral = false;

                // () Bracket nesting level. Text appears inside ()
                int bracketDepth = 0;

                // Keep previous chars to get extract numbers etc.:
                char[] previousCharacters = new char[_numberOfCharsToKeep];
                for (int j = 0; j < _numberOfCharsToKeep; j++) previousCharacters[j] = ' ';


                for (int i = 0; i < input.Length; i++)
                {
                    char c = (char)input[i];

                    if (inTextObject)
                    {
                        // Position the text
                        if (bracketDepth == 0)
                        {
                            if (CheckToken(new string[] { "TD", "Td" }, previousCharacters))
                            {
                                resultString += " ";
                            }
                            else
                            {
                                if (CheckToken(new string[] { "'", "T*", "\"" }, previousCharacters))
                                {
                                    resultString += " ";
                                }
                                else
                                {
                                    if (CheckToken(new string[] { "Tj", "TJ" }, previousCharacters))
                                    {
                                        resultString += " ";
                                    }
                                }
                            }
                        }

                        // End of a text object, also go to a new line.
                        if (bracketDepth == 0 &&
                            CheckToken(new string[] { "ET" }, previousCharacters))
                        {

                            inTextObject = false;
                            resultString += " ";
                        }
                        else
                        {
                            // Start outputting text
                            if ((c == '(') && (bracketDepth == 0) && (!nextLiteral))
                            {
                                bracketDepth = 1;
                            }
                            else
                            {
                                // Stop outputting text
                                if ((c == ')') && (bracketDepth == 1) && (!nextLiteral))
                                {
                                    bracketDepth = 0;
                                }
                                else
                                {
                                    // Just a normal text character:
                                    if (bracketDepth == 1)
                                    {
                                        // Only print out next character no matter what. 
                                        // Do not interpret.
                                        if (c == '\\' && !nextLiteral)
                                        {
                                            nextLiteral = true;
                                        }
                                        else
                                        {
                                            if (((c >= ' ') && (c <= '~')) ||
                                                ((c >= 128) && (c < 255)))
                                            {
                                                resultString += c.ToString();
                                            }

                                            nextLiteral = false;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Store the recent characters for 
                    // when we have to go back for a checking
                    for (int j = 0; j < _numberOfCharsToKeep - 1; j++)
                    {
                        previousCharacters[j] = previousCharacters[j + 1];
                    }
                    previousCharacters[_numberOfCharsToKeep - 1] = c;

                    // Start of a text object
                    if (!inTextObject && CheckToken(new string[] { "BT" }, previousCharacters))
                    {
                        inTextObject = true;
                    }
                }
                // do some clean of the text here

                return resultString;
            }
            catch
            {
                return "";
            }
        }
        #endregion

        #region CheckToken
        /// <summary>
        /// Check if a certain 2 character token just came along (e.g. BT)
        /// </summary>
        /// <param name="search">the searched token</param>
        /// <param name="recent">the recent character array</param>
        /// <returns></returns>
        private bool CheckToken(string[] tokens, char[] recent)
        {
            foreach (string token in tokens)
            {
                if (token.Length > 1)
                {
                    if ((recent[_numberOfCharsToKeep - 3] == token[0]) &&
                        (recent[_numberOfCharsToKeep - 2] == token[1]) &&
                        ((recent[_numberOfCharsToKeep - 1] == ' ') ||
                        (recent[_numberOfCharsToKeep - 1] == 0x0d) ||
                        (recent[_numberOfCharsToKeep - 1] == 0x0a)) &&
                        ((recent[_numberOfCharsToKeep - 4] == ' ') ||
                        (recent[_numberOfCharsToKeep - 4] == 0x0d) ||
                        (recent[_numberOfCharsToKeep - 4] == 0x0a))
                        )
                    {
                        return true;
                    }
                }
                else
                {
                    return false;
                }

            }
            return false;
        }
        #endregion
    }
    #endregion
}
