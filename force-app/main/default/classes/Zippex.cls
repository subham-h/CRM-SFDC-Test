//
//Copyright (c) 2015 Pedro Dal Col, Pliny Smith
//
public class Zippex{    
    private Map<String, FileObject> zipFileMap = new Map<String, FileObject>{};
        protected String zipFileString = '';  // stores the Hex version of the file blob
        
    public Zippex(){
        
    }
    // Instantiates a new Zippex object from an existing Zip archive passed as a Blob
    public Zippex(Blob filedata){
        zipFileString = EncodingUtil.convertToHex(filedata);
        Integer offsetOfEndCentralDirSignature = zipFileString.lastIndexOf(endCentralDirSignature);
        Integer numberOfFiles = HexUtil.hexToIntLE(zipFileString.mid(offsetOfEndCentralDirSignature+10*2, 2*2));
        offsetOfStartOfCentralDir = zipFileString.mid(offsetOfEndCentralDirSignature+16*2, 4*2);
        Integer offset = HexUtil.hexToIntLE(offsetOfStartOfCentralDir);
        
        for (Integer fileLoop = 0; fileLoop < numberOfFiles; fileLoop++){
            FileObject tempFile = new FileObject(zipfileString, offset);
            zipFileMap.put(EncodingUtil.convertFromHex(tempFile.fileName).toString(), tempFile);
            offset = tempFile.c_offsetToNextRecord;
        }
    }
    
    //  Returns a set of filenames from the current Zip archive.
    public Set<String> getFileNames(){
        return zipFileMap.keySet().clone();
    }
    
    public Boolean containsFile(String fileName){
        return zipFileMap.containsKey(fileName);
    }
        
    // Extracts the specified file contents from the current Zip archive.  If the file does not exist, returns null.
    public Blob getFile(String fileName){
        if(!zipFileMap.containsKey(fileName)){return null;}
        FileObject tempFileObject = zipFileMap.get(fileName);
        if(tempFileObject.fileDataInZipStr) {
            tempFileObject.readLocalFileHeader(zipFileString, HexUtil.hexToIntLE(tempFileObject.offsetOfLH));
        }
        
        if(tempFileObject.compressionMethod == '0000'){
            return EncodingUtil.convertFromHex(tempFileObject.compressedFileData);
        }
        else if(tempFileObject.compressionMethod == '0800'){
            return EncodingUtil.convertFromHex(new Puff(tempFileObject.compressedFileData,
                                                        HexUtil.hexToIntLE(tempFileObject.compressedSize),
                                                        HexUtil.hexToIntLE(tempFileObject.uncompressedSize)).inflate());
        }
        else{
            return null;
        }
    }
    
    public void addFile(String fileName, Blob fileData, String crc32){
        FileObject tempFileObject = new FileObject();
        
        tempFileObject.crc32              = crc32;
        tempFileObject.uncompressedSize   = HexUtil.intToHexLE(fileData.size(), 4);// (4 bytes) 
        tempFileObject.compressedSize     = tempFileObject.uncompressedSize;// (4 bytes), creates (n)    
        tempFileObject.extraFieldLength   = '0000';// (2 bytes) , creates (e)
        tempFileObject.fileCommentLength  = '0000';// (2 bytes), creates (c)
        tempFileObject.diskNumStart       = '0000';// (2 bytes) 
        tempFileObject.internalFileAtt    = '0000';// (2 bytes) //Internal file attributes
        tempFileObject.externalFileAtt    = '0000A481';// (4 bytes) //External file attributes
        tempFileObject.fileName           = EncodingUtil.convertToHex(Blob.valueOf(fileName));// (f bytes) // from the parameters passed
        tempFileObject.fileNameLength     = HexUtil.intToHexLE(tempFileObject.fileName.length()/2, 2);//HexUtil.intToHexLE(fileName.length(), 2);// (2 bytes), creates (f)
        tempFileObject.extraField         = '';
        tempFileObject.fileComment        = '';// (c bytes) 
        tempFileObject.compressedFileData = EncodingUtil.convertToHex(fileData); // (n bytes) // from the parameters passed
        tempFileObject.fileDataInZipStr   = false;

        zipFileMap.put(fileName, tempFileObject);  //add the new file to the file map
    }
    
    public Blob getZipArchive(){
        Integer zipFileSize;

        // delete central directory and end of Central directory
        zipFileString = zipFileString.left(HexUtil.hexToIntLE(offsetOfStartOfCentralDir)*2);

        //Writing Local Headers and data for each file not already in Zip string
        zipfileSize = zipFileString.length()/2;
        for (FileObject tempFileObject : zipFileMap.values()){
            if (!tempFileObject.fileDataInZipStr) {
                tempFileObject.offsetOfLH = HexUtil.intToHexLE(zipfileSize, 4);
                zipFileString += tempFileObject.assembleLocalFileHeader();
                zipfileSize = zipFileString.length()/2;
                tempFileObject.fileDataInZipStr = true;
                tempFileObject.compressedFileData = null;
            }
        }

        //Writing Central Directory
        offsetOfStartOfCentralDir = HexUtil.intToHexLE(zipfileSize,4);
        for (FileObject tempFileObject : zipFileMap.values()){
            zipFileString += tempFileObject.assembleCentralFileHeader();
        }
        sizeOfCentralDir = HexUtil.intToHexLE(zipFileString.length()/2 - zipfileSize,4);
        entriesInCentralDirOnThisDisk = HexUtil.intToHexLE(zipFileMap.size(),2);
        entriesCentralDir = HexUtil.intToHexLE(zipFileMap.size(),2);
        
        //Write End of Central Directory
        zipFileString += assembleEndOfCentralDir();
        
        //System.debug(zipFileString);
        return EncodingUtil.convertFromHex(zipFileString);
    }
    
    private String assembleEndOfCentralDir (){
        return endCentralDirSignature + numberOfThisDisk + numberOfTheDiskWithStartCentralDir + entriesInCentralDirOnThisDisk +
            entriesCentralDir  + sizeOfCentralDir + offsetOfStartOfCentralDir +
            zipfileCommentLength + zipfileComment;
    }
    
    // Local File Header Signature
    private final static String LFHSignature = '504b0304';      
    
    // Central Directory Signature
    private final static String CFHSignature = '504b0102';
    
    // Data Descriptor Signature
    private final static String DDSignature  = '504b0708';
    
    // End of Central Directory records
    private final String endCentralDirSignature  = '504b0506'; //Little Endian formatted signature (4 bytes)
    private final String numberOfThisDisk        = '0000'; // (2 bytes)
    private final String numberOfTheDiskWithStartCentralDir = '0000'; //(2 bytes)
    private String entriesInCentralDirOnThisDisk = '0000' ;//(2 bytes)
    private String entriesCentralDir             = '0000'; //(2 bytes)
    private String sizeOfCentralDir              = '00000000'; //(4 bytes)
    private String offsetOfStartOfCentralDir     = '00000000'; //(4 bytes)
    private String zipfileCommentLength          = '0000';  //(this is c), (2 bytes)
    private String zipfileComment                = ''; // (c bytes)
    
    public class FileObject{
        //All strings are hex representations in little endian format
        public String creatorVersion      = '0A00';     // (2 bytes) likely Windows NT
        public String minExtractorVersion = '0A00';     // (2 bytes) likely Windows NT
        public String gPFlagBit           = '0000';     // (2 bytes) general purpose flag bit
        public String compressionMethod   = '0000';     // (2 bytes) 0 = no compression
        public String lastModTime         = '0000';     // (2 bytes) 
        public String lastModDate         = '0000';     // (2 bytes) 
        public String crc32               = null;       // (4 bytes) 
        public String compressedSize      = '00000000'; // (4 bytes), creates (n)
        public String uncompressedSize    = '00000000'; // (4 bytes) 
        public String fileNameLength      = '00000000'; // (2 bytes), creates (f)
        public String extraFieldLength    = '0000';     // (2 bytes), creates (e)
        public String fileCommentLength   = '0000';     // (2 bytes), creates (c)
        public String diskNumStart        = '0000';     // (2 bytes) 
        public String internalFileAtt     = '0000';     // (2 bytes) 
        public String externalFileAtt     = '00000000'; // (4 bytes) 
        public String offsetOfLH          = '00000000'; // (4 bytes) 
        public String fileName            = '';         // (f bytes) 
        public String extraField          = '';         // (e bytes) 
        public String fileComment         = '';         // (c bytes) 
        public String compressedFileData  = '';         // (n bytes)
        
        public Integer c_offsetToNextRecord = 0;  //offsetToNext Central Dir Record
        public Integer l_offsetToNextRecord = 0;  //offsetToNext Local Header Record
        public Boolean fileDataInZipStr     = false;
        
        
        // Constructor
        public FileObject(){
            fileDataInZipStr = false;
        }
        
        //Reading Central Directory File Header
        public FileObject (String zipFileString, Integer offset){
            offset *= 2;
            creatorVersion      = zipFileString.mid(offset+4*2,  2*2);// (2 bytes) likely Windows NT  Offset 4
            minExtractorVersion = zipFileString.mid(offset+6*2,  2*2);// (2 bytes) likely Windows NT  Offset 6
            gPFlagBit           = zipFileString.mid(offset+8*2,  2*2);// (2 bytes) general purpose flag bit  Offset 8
            compressionMethod   = zipFileString.mid(offset+10*2, 2*2);// (2 bytes) no compression  Offset 10
            lastModTime         = zipFileString.mid(offset+12*2, 2*2);// (2 bytes)   Offset 12
            lastModDate         = zipFileString.mid(offset+14*2, 2*2);// (2 bytes)   Offset 14
            crc32               = zipFileString.mid(offset+16*2, 4*2);// (4 bytes)   Offset 16
            compressedSize      = zipFileString.mid(offset+20*2, 4*2);// (4 bytes)   creates (n) Offset 20
            uncompressedSize    = zipFileString.mid(offset+24*2, 4*2);// (4 bytes)   Offset 24
            fileNameLength      = zipFileString.mid(offset+28*2, 2*2);// (2 bytes)   creates (f) Offset 28
            extraFieldLength    = zipFileString.mid(offset+30*2, 2*2);// (2 bytes)   creates (e) Offset 30
            fileCommentLength   = zipFileString.mid(offset+32*2, 2*2);// (2 bytes)   creates (c) Offset 32
            diskNumStart        = zipFileString.mid(offset+34*2, 2*2);// (2 bytes)   Offset 34
            internalFileAtt     = zipFileString.mid(offset+36*2, 2*2);// (2 bytes)   Offset 36
            externalFileAtt     = zipFileString.mid(offset+38*2, 4*2);// (4 bytes)   Offset 38
            offsetOfLH          = zipFileString.mid(offset+42*2, 4*2);// (4 bytes)   Offset 42
            
            offset /= 2;
            
            Integer theStart = offset+46;
            Integer theEnd = theStart + HexUtil.hexToIntLE(fileNameLength);
            fileName = zipFileString.substring(theStart*2, theEnd*2);// (f bytes)       Offset 46
            theStart = theEnd;
            theEnd = theStart + HexUtil.hexToIntLE(extraFieldLength);
            extraField = zipFileString.substring(theStart*2, theEnd * 2);// (e bytes)        Offset 46 + fileNameLength
            theStart = theEnd;
            theEnd = theStart + HexUtil.hexToIntLE(fileCommentLength);
            fileComment = zipFileString.substring(theStart*2, theEnd*2);// (c bytes)        Offset 46 + fileNameLength + extraFieldLength
            c_offsetToNextRecord = theEnd;
            fileDataInZipStr = true; //true because we are reading an existing Zip archive
            //System.debug(this);
        }
        
        //Reading Local File Header (which also contains the data)
        public void readLocalFileHeader (String zipFileString, Integer offset){
            Integer strOffset = offset *2;
            
            minExtractorVersion  = zipFileString.mid(strOffset+4*2,  2*2);// (2 bytes) likely Windows NT  Offset 4
            gPFlagBit            = zipFileString.mid(strOffset+6*2,  2*2);// (2 bytes) general purpose flag bit  Offset 6
            compressionMethod    = zipFileString.mid(strOffset+8*2,  2*2);// (2 bytes) no compression  Offset 8
            lastModTime          = zipFileString.mid(strOffset+10*2, 2*2);// (2 bytes)  Offset 10
            lastModDate          = zipFileString.mid(strOffset+12*2, 2*2);// (2 bytes)  Offset 12
            
            //System.debug('gPFlagBit '+gPFlagBit);
            if ((HexUtil.hexToIntLE(gPFlagBit.left(2)) & 8 ) == 0) {
                crc32            = zipFileString.mid(strOffset+14*2, 4*2);// (4 bytes)  Offset 14
                compressedSize   = zipFileString.mid(strOffset+18*2, 4*2);// (4 bytes), creates (n) Offset 18
                uncompressedSize = zipFileString.mid(strOffset+22*2, 4*2);// (4 bytes)  Offset 22
            }
            
            fileNameLength       = zipFileString.mid(strOffset+26*2, 2*2);// (2 bytes), creates (f)     Offset 26
            extraFieldLength     = zipFileString.mid(strOffset+28*2, 2*2);// (2 bytes), creates (e)     Offset 28
            
            Integer theStart = offset+30;
            Integer theEnd = theStart + HexUtil.hexToIntLE(fileNameLength);
            fileName = zipFileString.substring(theStart*2, theEnd*2);// (f bytes)       Offset 30
            theStart = theEnd;
            theEnd = theStart + HexUtil.hexToIntLE(extraFieldLength);
            extraField = zipFileString.substring(theStart*2, theEnd*2);// (e bytes)        Offset 30 + fileNameLength
            theStart = theEnd;
            theEnd = theStart + HexUtil.hexToIntLE(compressedSize);
            compressedFileData = zipFileString.substring(theStart*2, theEnd*2);// (c bytes)        Offset 30 + fileNameLength + extraFieldLength
            l_offsetToNextRecord = theEnd;
            
            if ((HexUtil.hexToIntLE(gPFlagBit.left(2)) & 8 ) != 0) {
                l_offsetToNextRecord *= 2;
                String signature = zipFileString.mid(l_offsetToNextRecord+0*2, 4*2); // (4 bytes)
                if (signature != DDSignature) {l_offsetToNextRecord -= 4*2;}
                crc32            = zipFileString.mid(l_offsetToNextRecord+4*2, 4*2); // (4 bytes)  Offset 0/4
                compressedSize   = zipFileString.mid(l_offsetToNextRecord+8*2, 4*2); // (4 bytes), creates (n)     Offset 4/8
                uncompressedSize = zipFileString.mid(l_offsetToNextRecord+12*2, 4*2);// (4 bytes)  Offset 8/12
                l_offsetToNextRecord /= 2;
                l_offsetToNextRecord += 16; 
            }
        }
        
        public String assembleLocalFileHeader(){
            if (String.isBlank(crc32)) {  
                crc32 = HexUtil.intToHexLE(HexUtil.CRC32Table(compressedFileData), 4);// (4 bytes) 
            }
            
            l_offsetToNextRecord = HexUtil.hexToIntLE(offsetOfLH) 
                + 30 
                + HexUtil.hexToIntLE(fileNameLength)
                + HexUtil.hexToIntLE(extraFieldLength)
                + HexUtil.hexToIntLE(compressedSize);
            
            return Zippex.LFHSignature + minExtractorVersion + gPFlagBit + compressionMethod + lastModTime 
                + lastModDate + crc32 + compressedSize + uncompressedSize + fileNameLength + extraFieldLength 
                + fileName + extraField + compressedFileData;
        }
        
        public String assembleCentralFileHeader(){
            if (String.isBlank(crc32)) {  
                crc32 = HexUtil.intToHexLE(HexUtil.CRC32Table(compressedFileData), 4);// (4 bytes) 
            }
            return Zippex.CFHSignature + creatorVersion + minExtractorVersion + gPFlagBit + compressionMethod + lastModTime 
                + lastModDate + crc32 + compressedSize + uncompressedSize + fileNameLength + extraFieldLength
                + fileCommentLength + diskNumStart + internalFileAtt + externalFileAtt + offsetOfLH + fileName 
                + extraField + fileComment;
        }
    }// end of FileObject class
}