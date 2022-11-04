// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IERC20 {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Artist {

/*
An artist is managed by a smart contract. 
The artist can upload the art work by providing a description and setting up a base price. 
Anyone can bid on that art work. 
The artist can then sell the art work to any of the bid of interest.
*/    
    
    // Store the art work details
    struct ArtWork{
        uint id;
        string name;
        string url;
        string description;
        uint basePrice;
        bool isSold;
        address soldTo;
    }
    // Store the bid details
    struct Bid{
        uint artWorkId;
        address bidder;
        uint amount;
        bool isComplete;
    }

    modifier onlyArtist() {
        require(artist == msg.sender,"Only Artist!");
        _;
    }

    address public artist;
    string public nameOfArtist;
    string public aboutTheArtist;
    uint countOfArtWorks;
    uint countOfBids;
    
    // Address of Alfajores test net cUSD
    address internal cUSD = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    // To keep track of art work uploaded by the artist
    uint id = 0;
    
    ArtWork [] public artWorks; 
    Bid [] public bids;


    constructor(string memory _nameOfArtist, string memory _aboutTheArtist) {
        artist = msg.sender;
        nameOfArtist = _nameOfArtist;
        aboutTheArtist = _aboutTheArtist;
    }

    // This function allows the artist to upload the art work
    function uploadArtWork( string memory _name,
                            string memory _url,
                            string memory _description,
                            uint _basePrice
                          ) 
                            public onlyArtist {
                                ArtWork memory newArtWork = ArtWork({
                                    id:id,
                                    name:_name,
                                    url:_url,
                                    description:_description,
                                    basePrice:_basePrice,
                                    isSold:false,
                                    soldTo:address(0)
                                });
                                // add the new art work to the list of art works
                                artWorks.push(newArtWork);
                                id += 1; 
                                countOfArtWorks +=1;
                            }
    
    // This function allows the public to bid on a particular art work
    function bid(uint _artWorkId,uint _amount) public {
        require(artWorks[_artWorkId].id == _artWorkId,"Wrong id");
        require(artWorks[_artWorkId].isSold == false,"Sold out!");
        require(_amount >= artWorks[_artWorkId].basePrice,"Make sure that you atleat match the base price"); 
        
        Bid memory newBid = Bid({
            artWorkId:_artWorkId,
            bidder:msg.sender,
            amount:_amount,
            isComplete:false
        });
        // add the new bid to the list of bids
        bids.push(newBid);
        countOfBids += 1;
    }

    // This function allows the artist to sell the art work for a particular bid
    function sell(uint _bidID) public onlyArtist {
        require(bids[_bidID].isComplete == false,"Sold already"); 
        require(artWorks[bids[_bidID].artWorkId].isSold == false,"Sold already");
        
        // Transfer the funds to the Artist from the account of bidder
        require(
            IERC20(cUSD).transferFrom(
                bids[_bidID].bidder,
                msg.sender,
                bids[_bidID].amount
            ),"Failed"
        );
        
        // Update the mapping so that anyone can see to whom this art work was sold to
        artWorks[bids[_bidID].artWorkId].soldTo = bids[_bidID].bidder;
        // indicate that bid is complete
        bids[_bidID].isComplete = true;
        // set the status of art work to sold
        artWorks[bids[_bidID].artWorkId].isSold = true;
    }

    // Get the total number of art works and bids
    function getCount() public view returns(uint,uint){
        return(
            countOfArtWorks,
            countOfBids
        );
    }
}
