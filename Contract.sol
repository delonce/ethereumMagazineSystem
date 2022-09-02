// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Magazines {
    address owner;

    mapping(address => structBank) public bank;
    mapping(address => structMagazine) public magazines;
    mapping(address => structPostav) public postavs;
    mapping(address => structAdmin) public admins;
    mapping(address => structSeller) public sellers;
    mapping(address => structBuyer) public buyers;
    address[] allAdmins;

    structUserRequests[] adminRequests;
    structBookOfComplaints[] public complaintsBook;
    structBookOfReply[] public repliesBook;

    struct structMagazine {
        bool status;
        uint balance;
        string state;
    }

    struct structBookOfComplaints {
        address magazineAddr;
        address author;
        string text;
        uint rate;
        uint likes;
        uint dislikes;
    }

    struct structBookOfReply {
        uint commNum;
        string text;
    }

    struct structBank {
        uint cash;
    }

    struct structPostav {
        string login;
        uint balance;
    }

    struct structAdmin {
        bool status;
        string login;
        string fio;
        uint balance;
    }

    struct structSeller {
        bool status;
        string login;
        string fio;
        string state;
        address magazine;
        uint balance;
    }

    struct structBuyer {
        bool status;
        string login;
        string fio;
        uint balance;
    }

    struct structUserRequests {
        address addr;
        uint typeOperation;
        address magazineAddr;
    }

    constructor() {
        owner = msg.sender;
        bank[owner] = structBank(10000);
        magazines[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = structMagazine(true, 1000, "Kazan");  // 1
        magazines[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = structMagazine(true, 900, "Kaluga");  // 2
        magazines[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB] = structMagazine(true, 1050, "Moscow");  // 3
        magazines[0x617F2E2fD72FD9D5503197092aC168c91465E7f2] = structMagazine(true, 700, "Ryazan");  // 4
        magazines[0x17F6AD8Ef982297579C203069C1DbfFE4348c372] = structMagazine(true, 2000, "Samara");  // 5
        magazines[0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678] = structMagazine(true, 2300, "StPet");  // 6
        magazines[0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7] = structMagazine(true, 0, "Taganrog");  // 7
        magazines[0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C] = structMagazine(true, 780, "Tomsk");  // 8
        magazines[0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC] = structMagazine(true, 1500, "Habarovsk");  // 9
        postavs[0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c] = structPostav("goldfish", 100);

        // seller

        sellers[0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C] = structSeller(
            true,
            "semen", 
            "Semenov Semen Semenovich",
            magazines[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2].state,
            0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
            70
        );

        // admin

        allAdmins.push(0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB);
        admins[0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB] = structAdmin(
            true,
            "ivan",
            "Ivanov Ivan Ivanovich",
            50
        );

        buyers[0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB] = structBuyer(
            true,
            admins[0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB].login,
            admins[0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB].fio,
            admins[0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB].balance
        );

        sellers[0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB].status = true;

        // buyer

        buyers[0x583031D1113aD414F02576BD6afaBfb302140225] = structBuyer(
            true,
            "petr",
            "Petrov Petr Petrovich",
            80
        );
    }

    function getMoneyForMagazine() public {
        require(magazines[msg.sender].status == true, "You are not an magazine!");
        magazines[msg.sender].balance += 1000;
        bank[owner].cash -= 1000;
    }

    function getAllRequests() public view returns(structUserRequests[] memory) {
        require(admins[msg.sender].status == true, "You are not an admin!");
        return adminRequests;
    }

    function makeNewSeller(address userAddress, address magazineAddr) public {
        require(admins[msg.sender].status == true, "You are not an admin!");

        buyers[userAddress].status = false;
        sellers[userAddress].status = true;
        sellers[userAddress].login = buyers[userAddress].login;
        sellers[userAddress].fio = buyers[userAddress].fio;
        sellers[userAddress].state = magazines[magazineAddr].state;
        sellers[userAddress].magazine = magazineAddr;
        sellers[userAddress].balance = buyers[userAddress].balance;
    }

    function makeNewBuyer(address userAddress) public {
        require(admins[msg.sender].status == true, "You are not an admin!");
        
        sellers[userAddress].status = false;
        buyers[userAddress].status = true;

        buyers[userAddress].login = sellers[userAddress].login;
        buyers[userAddress].fio = sellers[userAddress].fio;
        buyers[userAddress].balance = sellers[userAddress].balance;
    }

    function makeNewAdmin(address userAddress, uint currentStatus) public {
        require(admins[msg.sender].status == true, "You are not an admin!");
        
        if (currentStatus == 0) {
            admins[userAddress].status = true;

            admins[userAddress].login = buyers[userAddress].login;
            admins[userAddress].balance = buyers[userAddress].balance;
            allAdmins.push(userAddress);

            sellers[userAddress].status = true;

        } else if (currentStatus == 1) {
            sellers[userAddress].status = false;
            admins[userAddress].status = true;

            admins[userAddress].login = sellers[userAddress].login;
            admins[userAddress].balance = sellers[userAddress].balance;
            allAdmins.push(userAddress);

            buyers[userAddress].status = true;
            buyers[userAddress].login = admins[userAddress].login;
            buyers[userAddress].fio = admins[userAddress].fio;
            buyers[userAddress].balance =  admins[userAddress].balance;
        }

    }

    function createNewMagazine(address magazineAddress, string memory magazineState) public {
        require(admins[msg.sender].status == true, "You are not an admin!");

        magazines[magazineAddress].status = true;
        magazines[magazineAddress].state = magazineState;
    }

    function deleteMagazine(address magazineAddress) public {
        require(admins[msg.sender].status == true, "You are not an admin!");

        magazines[magazineAddress].status = false;
    }

    function requestMakeSeller(address magazineAddr) public {
        require(buyers[msg.sender].status == true, "You are not an buyer!");
        adminRequests.push(structUserRequests(msg.sender, 1, magazineAddr));
    }

    function requestMakeBuyer() public {
        require(sellers[msg.sender].status == true, "You are not an seller!");
        adminRequests.push(structUserRequests(msg.sender, 0, msg.sender));
    }

    function requestMakeAdmin() public {
        require(sellers[msg.sender].status == true || buyers[msg.sender].status == true, "You are not an seller!");
        adminRequests.push(structUserRequests(msg.sender, 2, msg.sender));
    }

    function makeComment(string memory text, address magazineAddr, uint rate) public {
        require(buyers[msg.sender].status == true, "You are not an buyer");
        require(magazines[magazineAddr].status == true, "Wrong address of magazine");
        require(rate >= 0 && rate <= 10, "Rate may be 0 < rate < 10");

        if (sellers[msg.sender].status == true) {
            rate = 0;
        }

        complaintsBook.push(structBookOfComplaints(
            magazineAddr,
            msg.sender,
            text,
            rate,
            0,
            0
        ));
    }

    function makeReplyOfComment(string memory text, uint numOfComment) public {
        require(buyers[msg.sender].status == true || complaintsBook[numOfComment].magazineAddr == sellers[msg.sender].magazine);
        repliesBook.push(
            structBookOfReply(
                numOfComment,
                text
            )
        );
    }

    function LikeOrDislike(uint numOfComment, bool typeValue) public {
        require(buyers[msg.sender].status == true, "You are not an buyer");

        if (typeValue == true) {
            complaintsBook[numOfComment].likes += 1;
        } else {
            complaintsBook[numOfComment].dislikes += 1;
        }
    }

    function goRegister(string memory login, string memory fio) public {
        buyers[msg.sender] = structBuyer(
            true,
            login,
            fio,
            0
        );
    }
}


