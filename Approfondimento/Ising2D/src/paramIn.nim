#-----------------------------------------------------------------------#
#       Modulo per leggere il file dei parametri che fissano le         #
#       condizioni in cui viene effettuata la simulazione. Questa       #
#       libreria è una semplificazione dei lexer & parser scritti       #
#       durante il corso di Generazione di Immagini Fotorealistiche     #
#                 tenuto dal professor Maurizio Tomasi.                 #
#-----------------------------------------------------------------------#
import std/[streams, tables, options]
from std/strformat import fmt
from std/strutils import isDigit, parseFloat, isAlphaNumeric, join

const 
    WHITESPACE* = ['\t', '\n', '\r', ' '] 

#----------------------------------------------------#
#                SourceLocation type                 #
#----------------------------------------------------#
type SourceLocation* = object
    filename*: string = ""
    lineNum*: int = 0
    colNum*: int = 0

proc newSourceLocation*(name = "", line: int = 0, col: int = 0): SourceLocation {.inline.} = 
    # SourceLocation variable constructor
    SourceLocation(filename: name, lineNum: line, colNum: col)


proc `$`*(location: SourceLocation): string {.inline.} =
    # Procedure that prints SourceLocation contents, useful for error signaling
    result = "File: " & location.filename & ", Line: " & $location.lineNum & ", Column: " & $location.colNum



#---------------------------------------------------#
#                    Token type                     #
#---------------------------------------------------#
type KeywordKind* = enum
    # Different kinds of key
    
    TEMP = 1,
    NSPIN = 2,
    ACC = 3,
    LSIM = 4,
    NBLK = 5,
    STATE = 6, 
    INCR = 7, 
    TERM = 8


const KEYWORDS* = {
    "temp": KeywordKind.TEMP,
    "nspin": KeywordKind.NSPIN,
    "acc": KeywordKind.ACC,    
    "lsim": KeywordKind.LSIM,
    "nblk": KeywordKind.NBLK,
    "state": KeywordKind.STATE,
    "incr": KeywordKind.INCR, 
    "term": KeywordKind.TERM
}.toTable


type 
    
    TokenKind* = enum
        # Defining possible token kinds

        KeywordToken,
        LiteralNumberToken,
        StopToken

    Token* = object
        # Token type 
        location*: SourceLocation

        case kind*: TokenKind
        of KeywordToken: 
            keyword*: KeywordKind
        of LiteralNumberToken:
            value*: float32
        of StopToken: 
            flag*: bool



                #       Token variables constructors      #

proc newKeywordToken*(location: SourceLocation, keyword: KeywordKind): Token {.inline.} =
    Token(kind: KeywordToken, location: location, keyword: keyword)

proc newLiteralNumberToken*(location: SourceLocation, value: float32): Token {.inline.} =
    Token(kind: LiteralNumberToken, location: location, value: value)

proc newStopToken*(location: SourceLocation, flag = false): Token {.inline.} =
    Token(kind: StopToken, location: location, flag: flag)


#---------------------------------------------------#
#                InputStream type                   #
#---------------------------------------------------#
type 

    GrammarError* = object of CatchableError

    InputStream* = object
        # Necessary to parse scene files

        # Input stream variables
        tabs*: int
        stream*: FileStream
        location*: SourceLocation

        # Variables to be able to unread a character
        savedChar*: char
        savedToken*: Option[Token]
        savedLocation*: SourceLocation


proc newInputStream*(stream: FileStream, filename: string, tabs = 4): InputStream = 
    # InputStream variable constructor
    InputStream(
        tabs: tabs, stream: stream, 
        location: newSourceLocation(filename, 1, 1), savedChar: '\0', 
        savedToken: none Token, savedLocation: newSourceLocation(filename, 1, 1)
        )


proc updateLocation*(inStr: var InputStream, ch: char) = 
    # Procedure to update stream location whenever a character is ridden

    if ch == '\0': discard
    elif ch == '\n':
        # Starting to read a new line
        inStr.location.colNum = 1
        inStr.location.lineNum += 1
    elif ch == '\t':
        inStr.location.colNum += inStr.tabs
    else:
        inStr.location.colNum += 1


proc readChar*(inStr: var InputStream): char =
    # Procedure to read a new char from the stream

    # What if we have an unread character?
    if inStr.savedChar != '\0':
        result = inStr.savedChar
        inStr.savedChar = '\0'
    
    # Otherwise we read a new character from the stream
    else:
        result = inStr.stream.readChar()

        # What if we have a \r character? The problem is that 
        # we would like to know if the following char is a \n or not
        if result == '\r':

            # Reading the following character
            result = inStr.stream.readChar()

            if result != '\n':
                let msg = "Ising1D doesn't run on old macOS versions."
                raise newException(CatchableError, msg)

    inStr.savedLocation = inStr.location
    inStr.updateLocation(result)


proc unreadChar*(inStr: var InputStream, ch: char) = 
    # Procedure to push a character back to the stream
   
    assert inStr.savedChar == '\0'
    inStr.savedChar = ch
    inStr.location = inStr.savedLocation


proc skipWhitespaceComments*(inStr: var InputStream) = 
    # We just want to avoid whitespace and comments 
    var ch: char

    ch = inStr.readChar()
    while (ch in WHITESPACE) or (ch == '#'):

        # Dealing with comments
        if ch == '#':
            while not (inStr.readChar() in ['\r','\n','\0']):
                discard
            
        ch = inStr.readChar()
        if ch == '\0':
            return

    # Unreading non whitespace or comment char read
    inStr.unreadChar(ch)


proc parseNumberToken*(inStr: var InputStream, firstCh: char, tokenLocation: SourceLocation): Token = 
    # Procedure to parse a number, the output will be a LiteralNumberToken with value field float32
    var 
        ch: char
        numStr = ""
        val: float32
    numStr = numStr & firstCh
    
    # Number reading proc ends if we get a non-digit as char
    while true:
        ch = inStr.readChar()

        if not (ch.isDigit() or (ch == '.') or (ch in ['e', 'E'])):
            inStr.unreadChar(ch)
            break
        
        numStr = numStr & ch
    
    try:
        val = parseFloat(numStr)
    except ValueError:
        let e = fmt"{numStr} is an invalid floating-point number"
        raise newException(GrammarError, e)

    return newLiteralNumberToken(tokenLocation, val)


proc parseKeywordToken*(inStr: var InputStream, firstCh: char, tokenLocation: SourceLocation): Token = 
    # Procedure to read wether a keyword token 
    var
        ch: char
        tokStr = ""
    tokStr = tokStr & firstCh

    while true:
        ch = inStr.readChar()

        if not (ch.isAlphaNumeric or ch == '_'):
            inStr.unreadChar(ch)
            break
        
        tokStr = tokStr & ch
    
    return newKeywordToken(tokenLocation, KEYWORDS[tokStr])


proc readToken*(inStr: var InputStream): Token =
    # Procedure to read a token from input stream
    var
        ch: char
        tokenLocation: SourceLocation

    # Checking wether we already have a saved token or not
    if inStr.savedToken.isSome:
        result = inStr.savedToken.get
        inStr.savedToken = none Token
        return result

    inStr.skipWhitespaceComments()
    
    # Reading a char that we know is not a whitespace or part of a comment line
    # We first need to check wether we are in eof condition
    ch = inStr.readChar()
    if ch == '\0':
        return newStopToken(inStr.location, true)
    
    # We now have to chose between five possible different token
    tokenLocation = inStr.location

    if ch.isDigit or (ch in ['+', '-', '.']):
        # Literal number token
        return inStr.parseNumberToken(ch, tokenLocation)

    elif ch.isAlphaNumeric() or (ch == '_'):
        # Keyword or identifier token
        return inStr.parseKeywordToken(ch, tokenLocation)
    
    else:
        # Error condition, something wrong is happening
        let msg = fmt"Invalid character: {ch} in: " & $inStr.location
        raise newException(GrammarError, msg)


proc unreadToken*(inStr: var InputStream, token: Token) =
    # Procedure to unread a whole token from stream file
    assert inStr.savedToken.isNone
    inStr.savedToken = some token


#----------------------------------------------------------------#
#       DefMod type: everything needed to define a scene       #
#----------------------------------------------------------------#
type DefMod* = object
    params*: seq[float32]


proc newDefMod*(par: seq[float32]): DefMod {.inline.} = 
    # Procedure to initialize a new DefMod variable, needed at the end of the parsing proc
    DefMod(params: par)



#---------------------------------------------------------------#
#                        Expect procedures                      #
#---------------------------------------------------------------#
proc expectNumber*(inStr: var InputStream, dMod: var DefMod): float32 =
    # Procedure to read a LiteralNumberToken and check if is a literal number or a variable
    var 
        tok: Token
    
    tok = inStr.readToken()
    # If it's a literal number token i want to return its value
    if tok.kind == LiteralNumberToken:
        return tok.value

    let msg = fmt"Got {tok.kind} instead of LiteralNumberToken. Error in: " & $inStr.location
    raise newException(GrammarError, msg)



proc parseDefModel*(inStr: var InputStream): DefMod = 
    # Procedure to parse the whole file and to create the DefMod variable 
    # that will be the starting point of the simulation
    var 
        dMod: DefMod
        tryTok: Token
        varVal: float32

    while true:
        tryTok = inStr.readToken()
        
        # What if we are in Eof condition?
        if tryTok.kind == StopToken:
            break
        
        # The only thing that is left is reading Keywords
        if tryTok.kind != KeywordToken:
            let msg = fmt"Expected a keyword instead of {tryTok.kind}. Error in: " & $inStr.location
            raise newException(GrammarError, msg)


        # Temperatura 
        if tryTok.keyword == KeywordKind.TEMP:

            varVal = inStr.expectNumber(dMod)
            dMod.params.add(varVal)

        # Numero di spin 
        if tryTok.keyword == KeywordKind.NSPIN:

            varVal = inStr.expectNumber(dMod)
            dMod.params.add(varVal)

        # Parametro J 
        if tryTok.keyword == KeywordKind.ACC:

            varVal = inStr.expectNumber(dMod)
            dMod.params.add(varVal)

        # Lunghezza della simulazione (numero di mosse) 
        if tryTok.keyword == KeywordKind.LSIM:

            varVal = inStr.expectNumber(dMod)
            dMod.params.add(varVal)

        # Numero di blocchi 
        if tryTok.keyword == KeywordKind.NBLK:

            varVal = inStr.expectNumber(dMod)
            dMod.params.add(varVal)

        # Stato PCG 
        if tryTok.keyword == KeywordKind.STATE:

            varVal = inStr.expectNumber(dMod)
            dMod.params.add(varVal)

        # Incremento PCG 
        if tryTok.keyword == KeywordKind.INCR:

            varVal = inStr.expectNumber(dMod)
            dMod.params.add(varVal)

        # Lunghezza termalizzazione 
        if tryTok.keyword == KeywordKind.TERM:

            varVal = inStr.expectNumber(dMod)
            dMod.params.add(varVal)
        
    # We get here only when file ends
    return dMod
