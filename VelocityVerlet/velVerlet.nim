from std/streams import FileStream, newFileStream
import src/lexer

const fileIn = "initialchain3D.xyz"
var
    fStr: FileStream
    inStr: InputStream
    dSy: DefSystem
    

fStr = newFileStream(fileIn, fmRead)
inStr = newInputStream(fStr, fileIn, 4)
echo "Parsing scene"
dSy = inStr.parseDefSystem()

echo dSy.config[0]

