@isTest
private class ZippexTests{
    @isTest static void testHexUtil() {
        String testData = 'This is a test';  //test data
        Integer expectedCRC32 = (Integer)(3229261618L);
        System.assertEquals(HexUtil.CRC32Table(Blob.valueOf(testData)) , expectedCRC32);
        System.assertEquals(HexUtil.CRC32Table(EncodingUtil.convertToHex(Blob.valueOf(testData))) , expectedCRC32);
        
        testData = 'test two';
        expectedCRC32 = 1542186603;
        System.assertEquals(HexUtil.CRC32Table(Blob.valueOf(testData)) , expectedCRC32);
        System.assertEquals(HexUtil.CRC32Table(EncodingUtil.convertToHex(Blob.valueOf(testData))) , expectedCRC32);
        
        testData = '';
        expectedCRC32 = 0;
        System.assertEquals(HexUtil.CRC32Table(Blob.valueOf(testData)) , expectedCRC32);
        System.assertEquals(HexUtil.CRC32Table(EncodingUtil.convertToHex(Blob.valueOf(testData))) , expectedCRC32);
        
        // public static Integer hexToIntLE(String hexString)
        System.assertEquals(HexUtil.hexToIntLE('ffffffff'),(Integer)(4294967295L));
        System.assertEquals(HexUtil.hexToIntLE('feffffff'),(Integer)(4294967294L));
        System.assertEquals(HexUtil.hexToIntLE('ffffff7f'),(Integer)(2147483647 ));
        System.assertEquals(HexUtil.hexToIntLE('00000080'),(Integer)(2147483648L));
        System.assertEquals(HexUtil.hexToIntLE('00000000'),0);
        
        // public static String intToHexLE(Integer decNumber, Integer sizeInBytes)
        System.assertEquals(HexUtil.intToHexLE((Integer)(4294967295L),4),'ffffffff');
        System.assertEquals(HexUtil.intToHexLE((Integer)(4294967294L),4),'feffffff');
        System.assertEquals(HexUtil.intToHexLE((Integer)(2147483647 ),4),'ffffff7f');
        System.assertEquals(HexUtil.intToHexLE((Integer)(2147483648L),4),'00000080');
        System.assertEquals(HexUtil.intToHexLE(0,4),'00000000');
        System.assertEquals(HexUtil.intToHexLE(878678,4),'56680d00');
        System.assertEquals(HexUtil.intToHexLE(878678,2),'5668');
        System.assertEquals(HexUtil.intToHexLE(878678,0),'');
    }
    
    @isTest static void zipTest(){
        Zippex sampleZip = new Zippex();
        Blob fileData = Blob.valueOf('Sample text.');
        sampleZip.addFile('E2C Package/test.txt', fileData, null);
        Blob zipData = sampleZip.getZipArchive();

        Zippex zip = new Zippex(zipData);
        String str = '';
        for(String st : zip.getFileNames()){
            str = st;
            break;
        }
        zip.containsFile(str);
        zip.getFile(str);
        
        Zippex.FileObject fileObj = new Zippex.FileObject();
        fileObj.assembleLocalFileHeader();
        fileObj.assembleCentralFileHeader();
        
    }
    
    
    @isTest static void puffTest(){
        String source='CB48CD29C840C25C00';
        Integer srclen = source.length()/2;
        System.assertEquals('helphelphelphelp\n', EncodingUtil.convertFromHex(new Puff(source, srclen, null).inflate()).toString());
        
        source='F3C8E40200';
        srclen = source.length()/2;
        System.assertEquals('Hi\n', EncodingUtil.convertFromHex(new Puff(source, srclen, null).inflate()).toString());
        
        source='01050099996562616670';
        srclen = source.length()/2;
        System.assertEquals('ebafp', EncodingUtil.convertFromHex(new Puff(source, srclen, null).inflate()).toString());
        
        source='8cd0514bc3301007f077c1ef50f2bea6952152d60e4126be0c61fa01d2f4da06935cc8658bfbf6de3615c497bde5b8dc8fbbff6afde96c718048067d2beab21205788d83f1532bdedf368b075150527e50163db4e20824d6ddedcd2a3719fa1da4c43fa960c553e3742be694422325e9199ca21203786e8e189d4a5cc6493a153ff661a1d105954c6fac4947795755f7e29b89d728388e46c313eabd039fcef3328265113dcd26d08f96afd132c62144d440c4f7387bf19c32fe97a997ff20677444c231957c8cbc6c244f148fd7d5f9e5ac289c6e5e268f51f59613ccf552741c9fb216f3ebf6599e8a01b79876ea008fb4e3052c6c8c05eec83f31775f000000ffff0300';
        srclen = source.length()/2;
        System.assertEquals('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\r\n<w:webSettings xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" mc:Ignorable="w14"><w:allowPNG/><w:doNotSaveAsSingleFile/></w:webSettings>',
        EncodingUtil.convertFromHex(new Puff(source, srclen, null).inflate()).toString());
    }
}