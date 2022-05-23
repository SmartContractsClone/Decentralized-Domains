// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//importing libraries
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/structs/DoubleEndedQueue.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./strings.sol";

contract Domains is ERC721URIStorage {

    // using libraries for specifics
    using SafeMath for uint256;
    using EnumerableSet for *;
    using EnumerableMap for EnumerableMap.Bytes32ToBytes32Map;
    using DoubleEndedQueue for DoubleEndedQueue.Bytes32Deque;
    using BitMaps for BitMaps.BitMap;
    using strings for *;
    using Strings for *;
  
    EnumerableSet.Bytes32Set extensions;   

    struct Domain {

        string NAME;
        string EXTENSION;
        bool ISTOPLEVELDOMAIN;
        uint256 TLDID;

        EnumerableSet.UintSet SUBDOMAINS;
        EnumerableMap.Bytes32ToBytes32Map DOMAINDATA;

    }

    mapping (string => uint256) domainNameToIds;
    mapping (uint256 => Domain) domains;

    uint256 internal totalDomains;

    string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="720" height="720" fill="none"><path fill="url(#B)" d="M0 0h720v720H0z"/><defs><filter id="A" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="720" width="720"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><path d="M72.863 42.949c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-10.081 6.032-6.85 3.934-10.081 6.032c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-8.013-4.721a4.52 4.52 0 0 1-1.589-1.616c-.384-.665-.594-1.418-.608-2.187v-9.31c-.013-.775.185-1.538.572-2.208a4.25 4.25 0 0 1 1.625-1.595l7.884-4.59c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v6.032l6.85-4.065v-6.032c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595L41.456 24.59c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-14.864 8.655a4.25 4.25 0 0 0-1.625 1.595c-.387.67-.585 1.434-.572 2.208v17.441c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l10.081-5.901 6.85-4.065 10.081-5.901c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v9.311c.013.775-.185 1.538-.572 2.208a4.25 4.25 0 0 1-1.625 1.595l-7.884 4.721c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-7.884-4.59a4.52 4.52 0 0 1-1.589-1.616c-.385-.665-.594-1.418-.608-2.187v-6.032l-6.85 4.065v6.032c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l14.864-8.655c.657-.394 1.204-.95 1.589-1.616s.594-1.418.609-2.187V55.538c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595l-14.993-8.786z" fill="#fff"/><defs><linearGradient id="B" x1="0" y1="0" x2="720" y2="720" gradientUnits="userSpaceOnUse"><stop stop-color="#cb5eee"/><stop offset="1" stop-color="#0cd7e4" stop-opacity=".99"/></linearGradient></defs><text x="50%" y="50%" font-size="30px" dominant-baseline="middle" text-anchor="middle" fill="#fff" filter="url(#A)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
    string svgPartTwo = '</text></svg>';


    constructor() ERC721("Domains", "Dom")  {
        
    }

// Functions start here

    /* 
        Add a top level domain. 
        This can only be done by owner. 
        The lower function ensures that the tld and domain names are always in lowercase.

    */

    function addExtension(string memory _ext) public {
        extensions.add(convertToBytes32(converttolower(_ext)));
    }

    function checkExtensionExists(string memory _ext) public view returns (bool) {
        return extensions.contains(convertToBytes32(converttolower(_ext)));
    }

    function checkDomainExists(string memory _domain) public view returns (bool) {
        return (domainNameToIds[converttolower(_domain)] != 0);
    }

    function svgToImageURI(string memory _name) public view returns (string memory){

        string memory finalSvg = string(abi.encodePacked(svgPartOne, _name, svgPartTwo));
        string memory json = Base64.encode(
        abi.encodePacked(
        '{"name": "',
        _name,
        '", "description": "A domain name service", "image": "data:image/svg+xml;base64,',
        Base64.encode(bytes(finalSvg)),
        '"}'
        )        
        );

        string memory finalTokenUri = string(abi.encodePacked("data:application/json;base64,", json));

        return finalTokenUri;

    }


    /*
        Minter functions to mint the domain without the domain data.
        For current version, data will be added seperately.
    */

    function mintTopLevelDomain(string memory _domainName) public {       
        
        /*
            1. Input must be in format "example.domain"
            2. String must have only one '.' else minting will fail
            3. It is advisable to use only alphabets for name however, the code will convert any string to lowercase
        */
        
        _domainName = converttolower(_domainName);
        
        require(_domainName.toSlice().count(".".toSlice()) == 1, "Invalid String: Please mint TLD in format 'name.extension'");

        string[] memory s = _splitString(_domainName,".");

        string memory name_ = s[0];
        string memory extension_ = s[1];

        require(checkExtensionExists(extension_),"Extension doesnt exist");
        require(checkDomainExists(_domainName) == false, "Domain already exists");

        totalDomains = totalDomains.add(1);       
        
        _safeMint(msg.sender, totalDomains);
        _setTokenURI(totalDomains, svgToImageURI(_domainName));     
        
        domainNameToIds[_domainName] = totalDomains;

        domains[totalDomains].NAME = name_;
        domains[totalDomains].EXTENSION = extension_;
        domains[totalDomains].ISTOPLEVELDOMAIN = true;
        
        // Freeing up the memory for solidity
        delete name_;
        delete extension_;
        delete s;
        
    }   

    function mintSubLevelDomain(string memory _domainName,address _to) public {       
        
        /*
            1. Input must be in format "subdomain.example.domain"
            2. String must have only two '.' else minting will fail
            3. It is advisable to use only alphabets for name however, the code will convert any string to lowercase
            4. "example.domain" should exists and minter must be owner of the domain

        */
        
        _domainName = converttolower(_domainName);
        
        require(_domainName.toSlice().count(".".toSlice()) == 2, "Invalid String: Please mint SLD in format 'name.topdomain.extension'");

        string[] memory s = _splitString(_domainName,".");

        string memory name_ = s[0];
        string memory tld_ = s[1];
        string memory extension_ = s[2];
        string memory tldExt = string(abi.encodePacked(tld_,".",extension_));


        require(checkExtensionExists(extension_),"Extension doesnt exist");
        require(checkDomainExists(tldExt), "Top Level Domain doesnt exists");  
        require(checkDomainExists(_domainName) == false, "Domain already exists");
        require(ownerOf(getDomainIdFromName(tldExt)) == msg.sender, "Caller not owner of TLD");

        totalDomains = totalDomains.add(1);       
        
        _safeMint(_to, totalDomains);
        _setTokenURI(totalDomains, svgToImageURI(_domainName));     
        
        domainNameToIds[_domainName] = totalDomains;

        domains[totalDomains].NAME = name_;
        domains[totalDomains].EXTENSION = tldExt;
        domains[totalDomains].TLDID = domainNameToIds[tldExt];
        domains[getDomainIdFromName(tldExt)].SUBDOMAINS.add(totalDomains);
        
        // Freeing up the memory for solidity
        delete name_;
        delete tld_;
        delete extension_;
        delete tldExt;
        delete s;
        
    }   

    function setDomainData(uint256 _id, string[] memory _keys, string[] memory _values) public {
        
        require(_keys.length == _values.length,"Invalid input data");
        require(checkDomainExists(getDomainNameFromId(_id)), "Domain doesnt exists");
        require(ownerOf(_id) == msg.sender, "Caller not owner of Domain with given id");

        for (uint i = 0; i < _keys.length; i++) { 
            domains[_id].DOMAINDATA.set(convertToBytes32(_keys[i]),convertToBytes32(_values[i]));
        }
    }
   
    // reverse functions to fetch the domain data. useful for integrating with dapps

    function getDomainIdFromName (string memory _name) public view returns (uint256) {
        
        return domainNameToIds[_name];

    }

    function getDomainNameFromId (uint256 _id) public view returns (string memory) {
        
        return string(abi.encodePacked(domains[_id].NAME,".",domains[_id].EXTENSION));

    }

    function getDomainSubDomains (uint256 _id) public view returns (uint256[] memory) {
        return domains[_id].SUBDOMAINS.values();
    }

    function getDomainTldId (uint256 _id) public view returns (uint256) {
        return domains[_id].TLDID;
    }

    function getDomainData (uint256 _id, string memory _key) public view returns (string memory) {
        
        bytes32 key_ = convertToBytes32(_key);    
        return bytes32ToString(domains[_id].DOMAINDATA.get(key_));

    }

    /*
        String functions :
        To split string into array on delimiter
        to convert the string to lowercase - to ensure that all the domains are in lowercase

    */

    function _splitString(string memory _str, string memory _delim) internal pure returns (string[] memory) { 

        strings.slice memory s = _str.toSlice();                
        strings.slice memory delim = _delim.toSlice();

        string[] memory parts = new string[](s.count(delim) + 1);  
                        
        for (uint i = 0; i < parts.length; i++) {                              
           parts[i] = s.split(delim).toString();                               
        }      
        return parts;                                                                
    }                                                                          

    function _toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            // Uppercase character...
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                // So we add 32 to make it lowercase
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }

    function converttolower(string memory _str) internal pure returns (string memory) {
        return _toLower(_str);
    }

    function convertToBytes32( string memory _str) public pure returns (bytes32) {
        return bytes32(abi.encodePacked(_str));
    }

    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    /*
        Reset Functions:

        1. When a SLD is transferred or burned, its details deleted.
        2. When a TLD is burned, its details along with all the subdomains are deleted

    */

    function _resetTokenTransfer (uint256 _id) internal {

        require(checkDomainExists(getDomainNameFromId(_id)), "Domain doesnt exists");
        delete domains[_id].DOMAINDATA;

    }

    function _resetTokenBurn (uint256 _id) internal {

        require(checkDomainExists(getDomainNameFromId(_id)), "Domain doesnt exists");

        if(domains[_id].ISTOPLEVELDOMAIN)
        {
            if(domains[_id].SUBDOMAINS.length()>0)
            {
                for (uint i = 0; i < domains[_id].SUBDOMAINS.length(); i++) {                              
                    burn(domains[_id].SUBDOMAINS.at(i));
                }     
            }

            delete domainNameToIds[getDomainNameFromId(_id)];
            delete domains[_id];
        }

        else
        {
            delete domainNameToIds[getDomainNameFromId(_id)];
            delete domains[_id];
        }
    }

    function burn (uint256 _id) public {
        _burn(_id);
        _resetTokenBurn(_id);
    }

    function safeTransferFrom (address from, address to, uint256 tokenId, bytes memory data) public override {
        _safeTransfer(from, to, tokenId, data);
        _resetTokenTransfer(tokenId);
    }

    function safeTransferFrom (address from, address to, uint256 tokenId) public override {
        _safeTransfer(from, to, tokenId, "");
        _resetTokenTransfer(tokenId);
    }

    function transferFrom (address from, address to, uint256 tokenId) public override {
        _transfer(from, to, tokenId);
        _resetTokenTransfer(tokenId);
    }


}
