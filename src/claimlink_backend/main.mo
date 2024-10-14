import ExtTokenClass "../extv2/ext_v2/v2";
import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import TrieMap "mo:base/TrieMap";
import Result "mo:base/Result";
import List "mo:base/List";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Error "mo:base/Error";
import Nat32 "mo:base/Nat32";
import Hash "mo:base/Hash";
import Timer "mo:base/Timer";
import Nat64 "mo:base/Nat64";
import Bool "mo:base/Bool";
import Float "mo:base/Float";
import Buffer "mo:base/Buffer";
import Blob "mo:base/Blob";
import Option "mo:base/Option";
import AID "../extv2/motoko/util/AccountIdentifier";
import ExtCore "../extv2/motoko/ext/Core";
import ExtCommon "../extv2/motoko/ext/Common";

actor Main {

    type AccountIdentifier = ExtCore.AccountIdentifier;
    type SubAccount = ExtCore.SubAccount;
    type TokenIndex  = ExtCore.TokenIndex;
    type TokenIdentifier  = ExtCore.TokenIdentifier;
    type CommonError = ExtCore.CommonError;
    type MetadataLegacy = ExtCommon.Metadata;

    type MetadataValue = (Text , {
        #text : Text;
        #blob : Blob;
        #nat : Nat;
        #nat8: Nat8;
    });
    type MetadataContainer = {
        #data : [MetadataValue];
        #blob : Blob;
        #json : Text;
    };
    type Metadata = {
        #fungible : {
            name : Text;
            symbol : Text;
            decimals : Nat8;
            metadata : ?MetadataContainer;
        };
        #nonfungible : {
            name : Text;
            description : Text;
            asset : Text;
            thumbnail : Text;
            metadata : ?MetadataContainer;
        };
    };
    type TransferRequest = ExtCore.TransferRequest;
    type TransferResponse = ExtCore.TransferResponse;
    type AccountBalanceArgs = { account : AccountIdentifier };
    type BinaryAccountBalanceArgs = { account : Blob };
    public type Account = { owner : Principal; subaccount : ?Blob };

    public type TimeStamp = { timestamp_nanos : Nat64 };
    public type Tokens = { e8s : Nat64 };
    // public type TransferArgs = {
    //     to : AccountIdentifier;
    //     fee : Tokens;
    //     memo : Nat64;
    //     from_subaccount : ?AccountIdentifier;
    //     created_at_time : ?TimeStamp;
    //     amount : Tokens;
    // };
    // type TransferArgs = {
    //     amount : Tokens;
    //     toPrincipal : Principal;
    //     toSubaccount : ?IcpLedger.SubAccount;
    // };
    public type TransferFromArgs = {
        to : Account;
        fee : ?Nat;
        spender_subaccount : ?Blob;
        from : Account;
        memo : ?Blob;
        created_at_time : ?Nat64;
        amount : Nat;
    };
    type ICPTs = { e8s : Nat64 };
    type SendArgs = {
        memo : Nat64;
        amount : ICPTs;
        fee : ICPTs;
        from_subaccount : ?SubAccount;
        to : AccountIdentifier;
        created_at_time : ?Time.Time;
    };
    type Deposit = {
        tokenId : TokenIndex;
        sender : Principal;
        collectionCanister : Principal;
        timestamp : Time.Time;
        claimPattern : Text;
        status :Text;
    };
    type User = ExtCore.User;
    type Campaign = {
        id : Text;
        title : Text;
        tokenType : Text;
        collection : Principal;
        claimPattern : Text;
        tokenIds : [TokenIndex];
        walletOption : Text;
        displayWallets : [Text];
        expirationDate : Time.Time;
        createdBy : Principal;
        createdAt : Time.Time;
        depositIndices : [Nat32];
    };
    type QRSet = {
        id: Text;
        title: Text;
        quantity: Nat;
        campaignId: Text;
        createdAt: Time.Time;
        creator: Principal;
    };
    type Dispenser = {
        id : Text;
        title : Text;
        startDate : Time.Time;
        createdAt: Time.Time;
        duration : Int;
        createdBy: Principal;
        campaignId : Text;
        whitelist : [Principal]
    };
    type Link = {
        tokenId : TokenIndex;
        collection : Principal;
        linkKey : Nat32;
        claimPattern : Text;
        createdBy : AccountIdentifier
    };
    public type TransferError_1 = {
        #TxTooOld : { allowed_window_nanos : Nat64 };
        #BadFee : { expected_fee : Tokens };
        #TxDuplicate : { duplicate_of : Nat64 };
        #TxCreatedInFuture;
        #InsufficientFunds : { balance : Tokens };
    };
    public type Result_6 = { #Ok : Nat64; #Err : TransferError_1 };
    public type Result_3 = { #Ok : Nat; #Err : TransferFromError };
    public type TransferFromError = {
        #GenericError : { message : Text; error_code : Nat };
        #TemporarilyUnavailable;
        #InsufficientAllowance : { allowance : Nat };
        #BadBurn : { min_burn_amount : Nat };
        #Duplicate : { duplicate_of : Nat };
        #BadFee : { expected_fee : Nat };
        #CreatedInFuture : { ledger_time : Nat64 };
        #TooOld;
        #InsufficientFunds : { balance : Nat };
    };
    public type DetailValue = {
        #True;
        #False;
        #U64 : Nat;
        #I64 : Int;
        #Float : Float;
        #Text : Text;
        #Principal : Principal;
        #Slice : [Nat8];
        #Vec : [DetailValue];
    };
    public type AddCanisterInput = {
        name: Text;
        description: Text;
        thumbnail: Text;
        frontend: ?Text;
        principal_id: Principal;
        details: [(Text, DetailValue)];
    };
    public type OperationError = {
        #NotAuthorized;
        #BadParameters;
        #NonExistentItem;
        #Unknown : Text;
    };
    public type CanisterMetadata = {
        name: Text;
        description: Text;
        thumbnail: Text;
        frontend: ?Text;
        principal_id: Principal;
        submitter: Principal;
        last_updated_by: Principal;
        last_updated_at: Time.Time;
        details: [(Text, DetailValue)];
    };



    // Maps user and the collection canisterIds they create
    private stable var allCollections : [Principal] = [];
    private var usersCollectionMap = TrieMap.TrieMap<Principal, [(Time.Time,Principal)]>(Principal.equal, Principal.hash);
    private stable var stableuserCollectionMap : [(Principal,[(Time.Time,Principal)])] = [];
    // Map to store created Links
    private var userLinks =  TrieMap.TrieMap<Principal, [Link]>(Principal.equal, Principal.hash);
    private stable var stableUserLinks : [(Principal,[Link])] = [];
    stable var claimCount : Nat = 0;
    stable var linksCount : Nat = 0;
    stable var userClaimCount : Nat = 0;
    stable var userLinksCount : Nat = 0;
    // Daily Stats
    stable var dailyLinksCreatedCount: Nat = 0;
    stable var dailyLinksClaimedCount: Nat = 0;
    stable var dailyUserLinksCreatedCount: Nat = 0;
    stable var dailyUserLinksClaimedCount: Nat = 0;
    private var dailyUserLinksCreatedMap = TrieMap.TrieMap<Principal, Nat>(Principal.equal, Principal.hash);
    private var dailyUserLinksClaimedMap = TrieMap.TrieMap<Principal, Nat>(Principal.equal, Principal.hash);


    private var claimedTokensMap = TrieMap.TrieMap<Principal, [(Principal, Nat)]>(Principal.equal, Principal.hash);

    //  Maps related to Campaigns
    private var campaigns = TrieMap.TrieMap<Text, Campaign>(Text.equal, Text.hash);
    private stable var stableCampaigns : [(Text,Campaign)] = [];
    private var campaignLinks = TrieMap.TrieMap<Text, [Nat32]>(Text.equal, Text.hash);
    private stable var stableCampaignLinks : [(Text, [Nat32])] = [];
    private var userCampaignsMap = TrieMap.TrieMap<Principal, [Campaign]>(Principal.equal, Principal.hash);
    private stable var stableUserCampaignsMap : [(Principal, [Campaign])] = [];
    // Maps related to dispensers
    private var dispensers = TrieMap.TrieMap<Text, Dispenser>(Text.equal, Text.hash);
    private stable var stableDispensers : [(Text,Dispenser)] = [];
    private var userDispensersMap = TrieMap.TrieMap<Principal, [Dispenser]>(Principal.equal, Principal.hash);
    private stable var stableUserDispensersMap : [(Principal, [Dispenser])] = [];
    private var userClaimedDispensers = TrieMap.TrieMap<Principal,[Text]>(Principal.equal, Principal.hash);
    private stable var stableuserClaimedDispensers : [(Principal,[Text])] = [];
    // Maps related to QR set
    private var qrSetMap = TrieMap.TrieMap<Text, QRSet>(Text.equal, Text.hash);
    private stable var stableQrSetMap : [(Text,QRSet)] = [];
    private var userQRSetMap = TrieMap.TrieMap<Principal, [QRSet]>(Principal.equal, Principal.hash);
    private stable var stableUserQrSetMap : [(Principal, [QRSet])] = [];
    // Map that stores QRsets and dispenser created on a Campaign
    private stable var qdcMap : [(Text,(Text,Text))] = [];
    // Token data Store
    func nat32Hash(value: Nat32) : Hash.Hash {
        let natValue = Nat32.toNat(value);
        return Hash.hash(natValue);
    };
    func natHash(value: Nat) : Hash.Hash {
        return Hash.hash(value);
    };
    private var tokensDataToBeMinted = TrieMap.TrieMap<Principal,[(Nat32,Metadata)]>(Principal.equal,Principal.hash);
    private stable var stableTokensDataToBeMinted : [(Principal,[(Nat32,Metadata)])] = [];
    private var nextTokenIndex : Nat32 = 0;
    // Campaign Timer
    private var campaignTimers = TrieMap.TrieMap<Text, Timer.TimerId>(Text.equal, Text.hash);
    private stable var stableCampaignTimers : [(Text, Timer.TimerId)] = [];
    // Dispenser Timer
    private var dispenserTimers = TrieMap.TrieMap<Text, Timer.TimerId>(Text.equal, Text.hash);
    private stable var stableDispenserTimers : [(Text, Timer.TimerId)] = [];

    // Stores details about the tokens coming into this vault
    private var depositItemsMap = TrieMap.TrieMap<Nat32, Deposit>(Nat32.equal,nat32Hash);
    private stable var stableDepositMap : [(Nat32, Deposit)] = [];

    // let LedgerCanister = actor "ryjl3-tyaaa-aaaaa-aaaba-cai" : actor {
    //     // account_balance : shared query BinaryAccountBalanceArgs -> async Tokens;
    //     // transfer : shared TransferArgs -> async Result_6;
    //     // send_dfx : shared SendArgs -> async Nat64;
    //     // account_balance_dfx : shared query AccountBalanceArgs -> async Tokens;
    //     icrc2_transfer_from : shared TransferFromArgs -> async Result_3;

    // };

    let RegistryCanister = actor "bd3sg-teaaa-aaaaa-qaaba-cai" : actor {
        add_canister: (caller: Principal, metadata: AddCanisterInput, trusted_source: ?Principal) -> async Result.Result<(), OperationError>;
    };



    // public shared ({ caller = user }) func transferICP(
    //     amount: Nat, 
    //     fee: ?Nat, 
    //     spenderSubaccount: ?Blob,
    //     memo: ?Blob,
    //     createdAtTime: ?Nat64
    // ) : async Text {
        
    //     let fromAccount: Account = {
    //         owner = user;
    //         subaccount = null; 
    //     };

    //     let toAccount: Account = {
    //         owner = Principal.fromActor(Main);
    //         subaccount = null; 
    //     };

    //     let transferArgs: TransferFromArgs = {
    //         to = toAccount;
    //         fee = fee; 
    //         spender_subaccount = spenderSubaccount; 
    //         from = fromAccount;
    //         memo = memo; 
    //         created_at_time = createdAtTime; 
    //         amount = amount; 
    //     };

    //     let transferResult: Result_3 = await LedgerCanister.icrc2_transfer_from(transferArgs);

    //     switch (transferResult) {
    //         case (#Ok(nat)) {
    //             return "Transfer successful: " # Nat.toText(nat);
    //         };
    //         case (#Err(error)) {
    //             return handleTransferError(error);
    //         };
    //     };
    // };

    // func handleTransferError(error: TransferFromError) : Text {
    //     switch (error) {
    //         case (#GenericError(record)) {
    //             return "Generic error: " # record.message # " (code: " # Nat.toText(record.error_code) # ")";
    //         };
    //         case (#InsufficientAllowance(record)) {
    //             return "Insufficient allowance: " # Nat.toText(record.allowance);
    //         };
    //         case (#BadBurn(record)) {
    //             return "Bad burn amount, minimum required: " # Nat.toText(record.min_burn_amount);
    //         };
    //         case (#Duplicate(record)) {
    //             return "Duplicate transaction of: " # Nat.toText(record.duplicate_of);
    //         };
    //         case (#BadFee(record)) {
    //             return "Bad fee, expected fee: " # Nat.toText(record.expected_fee);
    //         };
    //         case (#CreatedInFuture(record)) {
    //             return "Transaction created in the future. Ledger time: " # Nat.toText(Nat64.toNat(record.ledger_time));
    //         };
    //         case (#TooOld) {
    //             return "Transaction is too old.";
    //         };
    //         case (#InsufficientFunds(record)) {
    //             return "Insufficient funds. Available balance: " # Nat.toText(record.balance);
    //         };
    //         case (#TemporarilyUnavailable) {
    //             return "The system is temporarily unavailable. Please try again later.";
    //         };
    //     }
    // };





    // public shared ({caller = user}) func transfer(args : TransferArgs) : async Result.Result<IcpLedger.BlockIndex, Text> {

    //     let fromAccount = Principal.toLedgerAccount(user, null);
    //     let balanceResult = await IcpLedger.account_balance({account = fromAccount});

    //     // Print debug information
    //     Debug.print(
    //         "Transferring "
    //         # debug_show (args.amount)
    //         # " tokens to principal "
    //         # debug_show (args.toPrincipal)
    //         # " from account "
    //         # debug_show (fromAccount)
    //         # " caller principal "
    //         # debug_show (user)
    //         # " balance "
    //         # debug_show (balanceResult)
    //     );

    //     // Check if the balance is sufficient
    //     // switch balanceResult.e8s {
    //     //     case (balance) {
    //     //         if (balance < args.amount.e8s + 10_000) { // +10_000 for the transaction fee
    //     //             return #err("Insufficient funds: balance = " # debug_show(balance));
    //     //         };
    //     //     };
    //     // };
        
    //     // Prepare transfer arguments
    //     let transferArgs : IcpLedger.TransferArgs = {
    //         memo = 0;
    //         amount = args.amount;
    //         fee = { e8s = 10_000 };
    //         from_subaccount = null;  // Specify the subaccount (optional, null means default subaccount)
    //         to = Principal.toLedgerAccount(args.toPrincipal, args.toSubaccount);  // Convert to principal's ledger account
    //         created_at_time = null;  // Optional: Set to null to use the current time
    //     };

    //     // Attempt the transfer
    //     try {
    //         let transferResult = await IcpLedger.transfer(transferArgs);

    //         // Check if the transfer was successful
    //         switch (transferResult) {
    //             case (#Err(transferError)) {
    //                 return #err("Couldn't transfer funds:\n" # debug_show(transferError));
    //             };
    //             case (#Ok(blockIndex)) { 
    //                 return #ok(blockIndex);
    //             };
    //         };
    //     } catch (error : Error) {
    //         // Handle any other errors that may occur during the transfer
    //         return #err("Reject message: " # Error.message(error));
    //     };
    // };


    public shared query func getDepositItem(key : Nat32) : async ?Deposit {
        return depositItemsMap.get(key); 
    };

    public shared query func getAlldepositItemsMap() : async [(Nat32, Deposit)] {
        var result : [(Nat32, Deposit)] = [];
        for ((key, value) in depositItemsMap.entries()) {
            result := Array.append([(key, value)], result);
        };
        return result;
    };


    system func preupgrade() {
        stableuserCollectionMap := Iter.toArray(usersCollectionMap.entries());
        stableCampaigns := Iter.toArray(campaigns.entries());
        stableCampaignLinks := Iter.toArray(campaignLinks.entries());
        stableUserLinks := Iter.toArray(userLinks.entries());
        stableUserCampaignsMap := Iter.toArray(userCampaignsMap.entries());
        stableDispensers := Iter.toArray(dispensers.entries());
        stableuserClaimedDispensers := Iter.toArray(userClaimedDispensers.entries());
        stableUserDispensersMap := Iter.toArray(userDispensersMap.entries());
        stableQrSetMap := Iter.toArray(qrSetMap.entries());
        stableUserQrSetMap := Iter.toArray(userQRSetMap.entries());
        stableTokensDataToBeMinted := Iter.toArray(tokensDataToBeMinted.entries());
        stableCampaignTimers := Iter.toArray(campaignTimers.entries());
        stableDispenserTimers := Iter.toArray(dispenserTimers.entries());
        stableDepositMap := Iter.toArray(depositItemsMap.entries());

    };

    // Postupgrade function to restore the data from stable variables
    system func postupgrade() {
        usersCollectionMap := TrieMap.fromEntries(stableuserCollectionMap.vals(), Principal.equal, Principal.hash);
        campaigns := TrieMap.fromEntries(stableCampaigns.vals(), Text.equal, Text.hash);
        campaignLinks := TrieMap.fromEntries(stableCampaignLinks.vals(), Text.equal, Text.hash);
        userLinks := TrieMap.fromEntries(stableUserLinks.vals(), Principal.equal, Principal.hash);
        userCampaignsMap := TrieMap.fromEntries(stableUserCampaignsMap.vals(), Principal.equal, Principal.hash);
        dispensers := TrieMap.fromEntries(stableDispensers.vals(), Text.equal, Text.hash);
        userDispensersMap := TrieMap.fromEntries(stableUserDispensersMap.vals(), Principal.equal, Principal.hash);
        userClaimedDispensers := TrieMap.fromEntries(stableuserClaimedDispensers.vals(), Principal.equal, Principal.hash);
        qrSetMap := TrieMap.fromEntries(stableQrSetMap.vals(), Text.equal, Text.hash);
        userQRSetMap := TrieMap.fromEntries(stableUserQrSetMap.vals(), Principal.equal, Principal.hash);
        tokensDataToBeMinted := TrieMap.fromEntries(stableTokensDataToBeMinted.vals(), Principal.equal, Principal.hash);
        campaignTimers := TrieMap.fromEntries(stableCampaignTimers.vals(), Text.equal, Text.hash);
        dispenserTimers := TrieMap.fromEntries(stableDispenserTimers.vals(), Text.equal, Text.hash);
        depositItemsMap := TrieMap.fromEntries(stableDepositMap.vals(), Nat32.equal, nat32Hash);
    };


    func generateKey(caller: AccountIdentifier, timestamp: Time.Time, _tokenId: TokenIndex): Hash.Hash {
        let callerNat32 = AID.hash(caller);
        let timestampNat32 = Int.hash(timestamp);
        let tokenIdNat32 = _tokenId;
        let callerNat = Nat32.toNat(callerNat32);
        let timestampNat = Nat32.toNat(timestampNat32);
        let tokenIdNat = Nat32.toNat(tokenIdNat32);
        let largeModulus = 2 ** 128;
        let combinedNat = ((callerNat + timestampNat + tokenIdNat) % largeModulus);
        return Hash.hash(combinedNat);  // Hash expects Nat32, so convert back

    };

    type DashboardStats = {
        totalLinks: Nat;
        claimedLinks: Nat;
        userLinksCount : Nat;
        userClaimCount : Nat;
        linksCoundToday : Nat;
        claimsCountToday : Nat;
        userLinksCoundToday : Nat;
        userClaimsCountToday : Nat;
        campaigns: ?[Campaign];
        qrSets: ?[QRSet];
        dispensers: ?[Dispenser];
    };

    func incrementUserLinksCreated(user: Principal) {
        let currentCount = switch (dailyUserLinksCreatedMap.get(user)) {
            case null { 0 };
            case (?count) { count };
        };
        dailyUserLinksCreatedMap.put(user, currentCount + 1);
    };

    func incrementUserLinksClaimed(user: Principal) {
        let currentCount = switch (dailyUserLinksClaimedMap.get(user)) {
            case null { 0 };
            case (?count) { count };
        };
        dailyUserLinksClaimedMap.put(user, currentCount + 1);
    };



    // Function to reset daily stats at midnight
    func resetDailyStats(): async () {
        dailyLinksCreatedCount := 0;
        dailyLinksClaimedCount := 0;
        dailyUserLinksCreatedMap := TrieMap.TrieMap<Principal, Nat>(Principal.equal, Principal.hash);
        dailyUserLinksClaimedMap := TrieMap.TrieMap<Principal, Nat>(Principal.equal, Principal.hash);
        // Schedule the next reset at midnight
        await setMidnightTimer();
    };

    // Function to set a timer for midnight to reset stats
    func setMidnightTimer<system>() : async () {
        let now = Time.now();
        let secondsUntilMidnight = getSecondsUntilMidnight(now);
        let nanosecondsUntilMidnight = secondsUntilMidnight * 1_000_000_000;
        // Schedule a timer to trigger resetDailyStats at the next midnight
        let id = Timer.setTimer<system>(#nanoseconds nanosecondsUntilMidnight, func () : async () {
            await resetDailyStats();
        });
    };

    // Function to calculate how many seconds until midnight
    func getSecondsUntilMidnight(currentTime: Time.Time): Nat {
        let secondsInDay: Nat = 24 * 60 * 60;
        let currentTimeOfDay = Nat64.toNat(Nat64.fromIntWrap(currentTime % secondsInDay));
        return secondsInDay - currentTimeOfDay;
    };

    public shared func initStatTimer()  : async () {
        await setMidnightTimer()
    };

    public shared ({caller = user}) func dashboardDetails() : async DashboardStats {

        let campaigns = userCampaignsMap.get(user);
        let qrSets = userQRSetMap.get(user);
        let dispensers = userDispensersMap.get(user);
        let userSpecificLinksCount = switch (userLinks.get(user)) {
            case (null) { 0 };
            case (?userLinksList) { userLinksList.size() };
        };

        let userSpecificClaimsCount = switch (claimedTokensMap.get(user)) {
            case (null) { 0 };
            case (?userClaimsList) {
                Array.foldLeft(userClaimsList, 0, func(acc : Nat, item : (Principal, Nat)) : Nat {
                    acc + item.1;
                });
            };
        };
        let userLinksCreatedToday = switch (dailyUserLinksCreatedMap.get(user)) {
            case null { 0 };
            case (?count) { count };
        };

        let userLinksClaimedToday = switch (dailyUserLinksClaimedMap.get(user)) {
            case null { 0 };
            case (?count) { count };
        };
      
        return {
            totalLinks = linksCount;
            claimedLinks = claimCount;
            userLinksCount = userSpecificLinksCount;
            userClaimCount = userSpecificClaimsCount;
            linksCoundToday = dailyLinksCreatedCount;
            claimsCountToday = dailyLinksClaimedCount;
            userLinksCoundToday = userLinksCreatedToday;
            userClaimsCountToday = userLinksClaimedToday;
            campaigns = campaigns;
            qrSets = qrSets;
            dispensers = dispensers;
        };
    };


    // func knowAdmin(caller : Principal) : async Bool{
    //     let extToken = await ExtTokenClass.EXTNFT(caller);
    //     extToken._isAdmin(caller);
    // };

    public shared ({caller = user }) func addCollectionToUserMap (collection_id : Principal) : async Text {
        // if (Principal.isAnonymous(user)) {
        //     throw Error.reject("Anonymous principals are not allowed.");
        // };
        let userCollections = usersCollectionMap.get(user);
        let currentTime = Time.now();
        switch (userCollections) {
            case null {
                // No collections exist, create a new list with the current collection
                let newCollections: [(Time.Time, Principal)] = [(currentTime, collection_id)];
                usersCollectionMap.put(user, newCollections);
                return "Collection added";
            };
            case (?collections) {
                // Check if the collection already exists
                let collectionExists = List.some<(Time.Time, Principal)>(
                    List.fromArray(collections),
                    func x { x.1 == collection_id }
                );
                if (collectionExists) {
                    return "Collection already added";
                } else {
                    // Add the new collection with a timestamp
                    let updatedCollections = List.push<(Time.Time, Principal)>((currentTime, collection_id), List.fromArray(collections));
                    usersCollectionMap.put(user, List.toArray(updatedCollections));
                    return "Collection added";
                };
            };
        };
     }; 

    public shared ({caller = user}) func removeCollectionFromUserMap (collection_id : Principal) : async Text {
        // if (Principal.isAnonymous(user)) {
        //     throw Error.reject("Anonymous principals are not allowed.");
        // };
        let userCollections = usersCollectionMap.get(user);
        switch (userCollections) {
            case null {
                return "There are no collections added yet!";
            };
            case (?collections) {
                // Filter out the collection to remove
                let updatedCollections = List.filter<(Time.Time, Principal)>(
                    List.fromArray(collections),
                    func x { x.1 != collection_id }
                );
                if (List.isNil(updatedCollections)) {
                    usersCollectionMap.delete(user);
                } else {
                    usersCollectionMap.put(user, List.toArray(updatedCollections));
                };
                return "Collection removed";
            };
        };
    };

    // Collection creation
    public shared ({ caller = user }) func createExtCollection(_title : Text, _symbol : Text, _metadata : Text) : async (Principal, Principal) {
        // if (Principal.isAnonymous(user)) {
        //     throw Error.reject("Anonymous principals are not allowed.");
        // };
        Cycles.add<system>(500_000_000_000);
        let extToken = await ExtTokenClass.EXTNFT(Principal.fromActor(Main));
        let extCollectionCanisterId = await extToken.getCanisterId();
        let collectionCanisterActor = actor (Principal.toText(extCollectionCanisterId)) : actor {
            ext_setCollectionMetadata : (
                name : Text,
                symbol : Text,
                metadata : Text
            ) -> async ();
            setMinter : ( minter : Principal)-> async();
            ext_admin : () -> async Principal
        };
        await collectionCanisterActor.setMinter(user);
        await collectionCanisterActor.ext_setCollectionMetadata(_title, _symbol, _metadata);
        // Updating the userCollectionMap 
        let collections = usersCollectionMap.get(user);
        let buffer = Buffer.fromArray<Principal>(allCollections);
        buffer.add(extCollectionCanisterId);
        allCollections := Buffer.toArray(buffer);
        let canisterMetadata: CanisterMetadata = {
            name = _title;
            description = _symbol;  // Assuming metadata holds the description
            thumbnail = _metadata;            // Set a thumbnail if you have one
            frontend = null;          // Set frontend if applicable
            principal_id = extCollectionCanisterId;
            submitter = user;          // The user creating the collection
            last_updated_by = user;
            last_updated_at = Time.now();
            details = [];              // You can add more details if needed
        };

        let addResult = await RegistryCanister.add_canister(user, canisterMetadata, null);
        switch (addResult) {
            case (#ok(())) {
                switch(collections){
                    case null {
                        let updatedCollections = [(Time.now(), extCollectionCanisterId)];
                        usersCollectionMap.put(user,updatedCollections);
                        return (user, extCollectionCanisterId);
                    };
                    case (?collections){
                        let updatedObj = Array.append(collections, [(Time.now(), extCollectionCanisterId)]);
                        usersCollectionMap.put(user, updatedObj);
                        return (user, extCollectionCanisterId);
                    };
                };
            };
            case (#err(errType)) {
                // Handle different error types
                let errorMessage: Text = switch (errType) {
                    case (#BadParameters) { "Bad parameters provided." };
                    case (#NonExistentItem) { "The specified item does not exist." };
                    case (#NotAuthorized) { "Not authorized to perform this action." };
                    case (#Unknown(error)) { "Unknown error occurred: " # error };
                };
                throw Error.reject("Failed to add canister to registry: " # errorMessage);
            };
        };
        


    };

    // Collection creation
    // public shared ({ caller = user }) func createExtCollection(_title : Text, _symbol : Text, _metadata : Text) : async (Principal, Principal) {
    //     // if (Principal.isAnonymous(user)) {
    //     //     throw Error.reject("Anonymous principals are not allowed.");
    //     // };
    //     let collectionCreationFee : Nat64 = 100_000_000; // Example: 1 ICP = 100_000_000 e8s
    //     let userAccount : AccountIdentifier = AID.fromPrincipal(user,null);
    //     let platformAccount : AccountIdentifier = AID.fromPrincipal(user,null);
    //     let balanceResult = await LedgerCanister.account_balance_dfx({ account = userAccount });
    //     if (balanceResult.e8s < collectionCreationFee) {
    //         throw Error.reject("Insufficient balance to create collection. Please ensure you have enough ICP.");
    //     };
    //     let transferRequest: TransferArgs = {
    //         to = platformAccount;
    //         amount = { e8s = collectionCreationFee };
    //         fee = { e8s = 10_000 };
    //         memo = 0;
    //         from_subaccount = null;
    //         created_at_time = null; 
    //     };
    //     let transferResponse = await LedgerCanister.transfer(transferRequest);
    //     switch (transferResponse) {
    //         case (#Ok(nat)) {
    //             // Step 3: If transfer succeeds, proceed with collection creation
    //             Cycles.add<system>(500_000_000_000);
    //             let extToken = await ExtTokenClass.EXTNFT(Principal.fromActor(Main));
    //             let extCollectionCanisterId = await extToken.getCanisterId();
    //             let collectionCanisterActor = actor (Principal.toText(extCollectionCanisterId)) : actor {
    //                 ext_setCollectionMetadata : (name: Text, symbol: Text, metadata: Text) -> async ();
    //                 setMinter: (minter: Principal) -> async ();
    //                 ext_admin: () -> async Principal;
    //             };

    //             // Set the user as the minter and set metadata for the collection
    //             await collectionCanisterActor.setMinter(user);
    //             await collectionCanisterActor.ext_setCollectionMetadata(_title, _symbol, _metadata);

    //             // Step 4: Update userCollectionMap and return the result
    //             let collections = usersCollectionMap.get(user);
    //             let buffer = Buffer.fromArray<Principal>(allCollections);
    //             buffer.add(extCollectionCanisterId);
    //             allCollections := Buffer.toArray(buffer);
    //             switch (collections) {
    //                 case null {
    //                     let updatedCollections = [(Time.now(), extCollectionCanisterId)];
    //                     usersCollectionMap.put(user, updatedCollections);
    //                     return (user, extCollectionCanisterId);
    //                 };
    //                 case (?collections) {
    //                     let updatedObj = List.push((Time.now(), extCollectionCanisterId), List.fromArray(collections));
    //                     usersCollectionMap.put(user, List.toArray(updatedObj));
    //                     return (user, extCollectionCanisterId);
    //                 };
    //             };
    //         };
    //         case (#Err(error)) {
    //         // Handle transfer errors
            
    //         };
    //     };
    //     // let extToken = await ExtTokenClass.EXTNFT(Principal.fromActor(Main));
    //     // let extCollectionCanisterId = await extToken.getCanisterId();
    //     // let collectionCanisterActor = actor (Principal.toText(extCollectionCanisterId)) : actor {
    //     //     ext_setCollectionMetadata : (
    //     //         name : Text,
    //     //         symbol : Text,
    //     //         metadata : Text
    //     //     ) -> async ();
    //     //     setMinter : ( minter : Principal)-> async();
    //     //     ext_admin : () -> async Principal
    //     // };
    //     // await collectionCanisterActor.setMinter(user);
    //     // await collectionCanisterActor.ext_setCollectionMetadata(_title, _symbol, _metadata);
    //     // // Updating the userCollectionMap 
    //     // let collections = usersCollectionMap.get(user);
    //     // let buffer = Buffer.fromArray<Principal>(allCollections);
    //     // buffer.add(extCollectionCanisterId);
    //     // allCollections := Buffer.toArray(buffer);
    //     // switch(collections){
    //     //     case null {
    //     //         let updatedCollections = [(Time.now(), extCollectionCanisterId)];
    //     //         usersCollectionMap.put(user,updatedCollections);
    //     //         return (user, extCollectionCanisterId);
    //     //     };
    //     //     case (?collections){
    //     //         let updatedObj = List.push((Time.now(), extCollectionCanisterId),List.fromArray(collections));
    //     //         usersCollectionMap.put(user,List.toArray(updatedObj));
    //     //         return (user, extCollectionCanisterId);
    //     //     };
    //     // };


    // };

    // Getting Collection Metadata 
    public shared ({caller = user}) func getUserCollectionDetails() : async ?[(Time.Time, Principal, Text, Text, Text)] {
        let collections = usersCollectionMap.get(user);
        
        switch (collections) {
            case (null) {
                return null;
            };
            case (?collections) {
                var result : List.List<(Time.Time, Principal, Text, Text, Text)> = List.nil();
                
                for ((timestamp, collectionCanisterId) in collections.vals()) {
                    let collectionCanister = actor (Principal.toText(collectionCanisterId)) : actor {
                        getCollectionDetails: () -> async (Text, Text, Text);
                    };

                    let details = await collectionCanister.getCollectionDetails();
                    result := List.push((timestamp, collectionCanisterId, details.0, details.1, details.2), result);
                };

                let finalResult = List.toArray(List.reverse(result));
                return ?finalResult;
            };
        };
    };


    public shared ({caller = user}) func getUserCollectionDetailsPaginate(
        page: Nat, 
        pageSize: Nat
    ) : async {
        data: [(Time.Time, Principal, Text, Text, Text)];
        current_page: Nat;
        total_pages: Nat
    } {
        let collections = usersCollectionMap.get(user);

        switch (collections) {
            case (null) {
                return {
                    data = [];
                    current_page = 0;
                    total_pages = 0
                };
            };
            case (?collections) {
                let totalCollections = collections.size();
                let totalPages = if (totalCollections % pageSize == 0) {
                    totalCollections / pageSize;
                } else {
                    (totalCollections / pageSize) + 1;
                };

                let startIndex = page * pageSize;
                if (startIndex >= totalCollections) {
                    return {
                        data = []; 
                        current_page = page + 1;
                        total_pages = totalPages
                    };
                };
                let endIndex = Nat.min(totalCollections, startIndex + pageSize);

                var resultList : List.List<(Time.Time, Principal, Text, Text, Text)> = List.nil();
                var currentIndex: Nat = 0;
                for ((timestamp, collectionCanisterId) in collections.vals()) {
                    if (currentIndex >= startIndex and currentIndex < endIndex) {
                        let collectionCanister = actor (Principal.toText(collectionCanisterId)) : actor {
                            getCollectionDetails: () -> async (Text, Text, Text);
                        };
                        let details = await collectionCanister.getCollectionDetails();
                        resultList := List.push((timestamp, collectionCanisterId, details.0, details.1, details.2), resultList);
                    };
                    currentIndex += 1;
                };

            let res = List.toArray(List.reverse(resultList));

                return {
                    data = res;
                    current_page = page + 1;
                    total_pages = totalPages
                };
            };
        };
    };



    // Getting Collections that user own(only gets canisterIds of respective collections)
    public shared query ({caller = user}) func getUserCollections() : async ?[(Time.Time,Principal)] {
        return usersCollectionMap.get(user);
    };
    
    // Getting all the collections ever created(only gets the canisterIds)
    public shared query func getAllCollections() : async [(Principal, [(Time.Time, Principal)])] {
        var result : [(Principal, [(Time.Time, Principal)])] = [];
        for ((key, value) in usersCollectionMap.entries()) {
            result := Array.append([(key, value)], result);
        };
        return result;
    };

    
    // Minting  a NFT pass the collection canisterId in which you want to mint and the required details to add, this enables minting multiple tokens
    public shared ({caller = user}) func mintExtNonFungible(
        _collectionCanisterId : Principal,
        name : Text,
        desc : Text,
        asset : Text,
        thumb : Text,
        metadata : ?MetadataContainer,
        amount : Nat

    ) : async [TokenIndex] {

        // if (Principal.isAnonymous(user)) {
        //     throw Error.reject("Anonymous principals are not allowed.");
        // };
        
        let collectionCanisterActor = actor (Principal.toText(_collectionCanisterId)) : actor{
            ext_mint : (
                request : [(AccountIdentifier, Metadata)]
            ) -> async [TokenIndex]
        };
        let metadataNonFungible : Metadata = #nonfungible{
            name = name;
            description = desc;
            asset = asset;
            thumbnail = thumb;
            metadata = metadata;
        };

        let receiver = AID.fromPrincipal(user,null);
        var request : [(AccountIdentifier,Metadata)] = [];
        var i : Nat = 0;
        while (i < amount) {
            request := Array.append(request , [(receiver,metadataNonFungible)]);
            i := i + 1;
        }; 
        let extMint = await collectionCanisterActor.ext_mint(request);
        extMint
    };
    
    // Minting  a Fungible token pass the collection canisterId in which you want to mint and the required details to add, this enables minting multiple tokens
    public shared ({caller = user}) func mintExtFungible(
        _collectionCanisterId : Principal,
        name : Text,
        symbol : Text,
        decimals : Nat8,
        metadata: ?MetadataContainer,
        amount : Nat

    ) : async [TokenIndex] {

        if (Principal.isAnonymous(user)) {
            // You can either return an error or throw an exception.
            throw Error.reject("Anonymous principals are not allowed.");
        };
        
        let collectionCanisterActor = actor (Principal.toText(_collectionCanisterId)) : actor{
            ext_mint : (
                request : [(AccountIdentifier, Metadata)]
            ) -> async [TokenIndex]
        };
        let metadataFungible : Metadata = #fungible{
            name = name;
            symbol = symbol;
            decimals = decimals;
            metadata = metadata;
        };

        let receiver = AID.fromPrincipal(user,null);
        var request : [(AccountIdentifier,Metadata)] = [];
        var i : Nat = 0;
        while (i < amount) {
            request := Array.append(request , [(receiver,metadataFungible)]);
            i := i + 1;
        }; 
        let extMint = await collectionCanisterActor.ext_mint(request);
        extMint
    };

    // Stores the data of token now but mints it later at the time of claiming, gives you details to be added in Link
    public shared ({caller = user}) func storeTokendetails(
        _collectionCanisterId : Principal,
        name : Text,
        desc : Text,
        asset : Text,
        thumb : Text,
        metadata : ?MetadataContainer,
        amount : Nat
    ) : async [Nat32] {
        // if (Principal.isAnonymous(user)) {
        //     throw Error.reject("Anonymous principals are not allowed.");
        // };
        let metadataNonFungible : Metadata = #nonfungible{
            name = name;
            description = desc;
            asset = asset;
            thumbnail = thumb;
            metadata = metadata;
        };

        var i = 0;
        var nextTokenIds : [Nat32] = [];
        while (i < amount) {
            try {
                let currentTokens = switch(tokensDataToBeMinted.get(_collectionCanisterId)) {
                    case (?existingTokens) existingTokens;
                    case null [];
                };
                let updatedTokens = Array.append(currentTokens, [(nextTokenIndex, metadataNonFungible)]);
                tokensDataToBeMinted.put(_collectionCanisterId, updatedTokens);
                
                nextTokenIds := Array.append(nextTokenIds, [nextTokenIndex]);
                nextTokenIndex := nextTokenIndex + 1;
                i := i + 1;

            } catch (e) {
                throw Error.reject("Error occurred while storing token details");
            }
        };

        return nextTokenIds;
    };

    public shared func getStoredTokens(
        _collectionCanisterId : Principal    
    ) : async ?[(Nat32, Metadata)] {
        tokensDataToBeMinted.get(_collectionCanisterId)
    };

    public shared func getStoredTokensPaginate(
        _collectionCanisterId: Principal, 
        page: Nat, 
        pageSize: Nat
    ) : async { 
        data: [(Nat32, Metadata)]; 
        current_page: Nat; 
        total_pages: Nat 
    } {

        switch (tokensDataToBeMinted.get(_collectionCanisterId)) {
            case (?tokensArray) {
                let totalItems = tokensArray.size();
                let totalPages = if (totalItems % pageSize == 0) {
                    totalItems / pageSize
                } else {
                    (totalItems / pageSize) + 1
                };

                let startIndex = page * pageSize;
                if (startIndex >= totalItems) {
                    return { data = []; current_page = page + 1; total_pages = totalPages };
                };
                let endIndex = Nat.min(totalItems, startIndex + pageSize);
                var resultTokens: List.List<(Nat32, Metadata)> = List.nil();
                var currentIndex: Nat = 0;
                for (token in tokensArray.vals()) {
                    if (currentIndex >= startIndex and currentIndex < endIndex) {
                        resultTokens := List.push(token, resultTokens);
                    };
                    currentIndex += 1;
                };

                let resultArray = List.toArray(List.reverse(resultTokens));

                return {
                    data = resultArray;
                    current_page = page + 1;
                    total_pages = totalPages;
                };
            };
            case null {
                return { data = []; current_page = 0; total_pages = 0 };
            };
        }
    };




    
    
    // Get Fungible token details for specific collection
    public shared ({ caller = user }) func getFungibleTokens(
        _collectionCanisterId : Principal
    ) : async [(TokenIndex, AccountIdentifier, Metadata)] {
        let collectionCanisterActor = actor (Principal.toText(_collectionCanisterId)) : actor{
            getAllFungibleTokenData : () -> async [(TokenIndex, AccountIdentifier, Metadata)]
        };
        let userAID = AID.fromPrincipal(user,null);
        let allTokens = await collectionCanisterActor.getAllFungibleTokenData();
        let userTokens : [(TokenIndex, AccountIdentifier, Metadata)] = Array.filter(
            allTokens,
            func (tokenData: (TokenIndex, AccountIdentifier, Metadata)) : Bool {
                let (tokenIndex, owner, metadata) = tokenData;
                owner == userAID
            }
        );
        return userTokens;
    };

    // Get NFT details for specific collection
    public shared ({ caller = user }) func getNonFungibleTokens(
        _collectionCanisterId: Principal,
    ) : async [(TokenIndex, AccountIdentifier, Metadata)] {
        let collectionCanisterActor = actor (Principal.toText(_collectionCanisterId)) : actor{
            getAllNonFungibleTokenData : () -> async [(TokenIndex, AccountIdentifier, Metadata)]
        };

        let allTokens = await collectionCanisterActor.getAllNonFungibleTokenData();
        let userAID = AID.fromPrincipal(user,null);

        // Filter tokens by owner
        let userTokens : [(TokenIndex, AccountIdentifier, Metadata)] = Array.filter(
            allTokens,
            func (tokenData: (TokenIndex, AccountIdentifier, Metadata)) : Bool {
                let (tokenIndex, owner, metadata) = tokenData;
                owner == userAID
            }
        );
        return userTokens;
    };

    // Get NFT details for specific collection
    public shared ({ caller = user }) func getNonFungibleTokensPaginate(
        _collectionCanisterId: Principal,
        page: Nat,
        pageSize: Nat
    ) : async {
        data: [(TokenIndex, AccountIdentifier, Metadata)];
        current_page: Nat;
        total_pages: Nat
    } {
        let collectionCanisterActor = actor (Principal.toText(_collectionCanisterId)) : actor {
            getAllNonFungibleTokenData: () -> async [(TokenIndex, AccountIdentifier, Metadata)];
        };

        let allTokens = await collectionCanisterActor.getAllNonFungibleTokenData();
        let userAID = AID.fromPrincipal(user, null);
        // Filter tokens by owner
        let userTokens : [(TokenIndex, AccountIdentifier, Metadata)] = Array.filter(
            allTokens,
            func (tokenData: (TokenIndex, AccountIdentifier, Metadata)) : Bool {
                let (tokenIndex, owner, metadata) = tokenData;
                owner == userAID
            }
        );
        let totalItems = userTokens.size();
        let totalPages = if (totalItems % pageSize == 0) {
            totalItems / pageSize
        } else {
            (totalItems / pageSize) + 1
        };

        let startIndex = page * pageSize;
        if (startIndex >= totalItems) {
            return {
                data = [];
                current_page = page + 1;
                total_pages = totalPages
            };
        };
        let endIndex = Nat.min(totalItems, startIndex + pageSize);

        var paginatedTokens: List.List<(TokenIndex, AccountIdentifier, Metadata)> = List.nil();
        var currentIndex: Nat = 0;
        for (token in userTokens.vals()) {
            if (currentIndex >= startIndex and currentIndex < endIndex) {
                paginatedTokens := List.push(token, paginatedTokens);
            };
            currentIndex += 1;
        };

        let paginatedTokensArray = List.toArray(List.reverse(paginatedTokens));

        return {
            data = paginatedTokensArray;
            current_page = page + 1;
            total_pages = totalPages
        };
    };





    public shared ({ caller = user }) func getUserTokensFromAllCollections() : async [(Principal, Text, Nat)] {
        var resultArray = Buffer.Buffer<(Principal, Text, Nat)>(0);

        let userClaims : ?[(Principal, Nat)] = claimedTokensMap.get(user);

        switch (userClaims) {
            case null {
                return [];
            };
            case (?claimedCollectionData) {
                for ((collectionCanisterId, tokenCount) in claimedCollectionData.vals()) {
                    let collectionCanisterActor = actor (Principal.toText(collectionCanisterId)) : actor {
                        getCollectionDetails : () -> async (Text, Text, Text);
                    };
                    let collectionDetailsResult = await collectionCanisterActor.getCollectionDetails();
                    let collectionTitle = collectionDetailsResult.0;
                    resultArray.add((collectionCanisterId, collectionTitle, tokenCount));
                };
            };
        };

        return Buffer.toArray(resultArray);
    };



    // public shared ({ caller = user }) func getUserTokensFromAllCollections() : async [(Principal, Text, Nat)] {
    //     var resultArray = Buffer.Buffer<(Principal, Text, Nat)>(0);

    //     let userAID = AID.fromPrincipal(user, null);
    //     let userCollections = usersCollectionMap.get(user);

    //     for (collectionCanisterId in allCollections.vals()) {
    //         var presentInUserCollections = false;

    //         switch (userCollections) {
    //             case (?collections) {
    //                 // Use Array.find to check if collectionCanisterId exists in collections
    //                 presentInUserCollections := Option.isSome(Array.find(collections, func((_ : Time.Time, principal : Principal)) : Bool { 
    //                     principal == collectionCanisterId 
    //                 }));
    //             };
    //             case null { 
    //                 presentInUserCollections := false;
    //             };
    //         };

    //         // Skip processing if the collection is already in userCollections
    //         if (not presentInUserCollections) {
    //             let collectionCanisterActor = actor (Principal.toText(collectionCanisterId)) : actor {
    //                 tokens : (aid : AccountIdentifier) -> async Result.Result<[TokenIndex], CommonError>;
    //                 getCollectionDetails : () -> async (Text, Text, Text); 
    //             };

    //             // Retrieve collection details
    //             let collectionDetails = await collectionCanisterActor.getCollectionDetails();
    //             let collectionTitle = collectionDetails.0;

    //             // Get tokens of the user in the collection
    //             let tokensResult = await collectionCanisterActor.tokens(userAID);

    //             // Process the token result
    //             switch (tokensResult) {
    //                 case (#ok(tokenIds)) {
    //                     let tokenCount = tokenIds.size();
    //                     if (tokenCount > 0) {
    //                         resultArray.add((collectionCanisterId, collectionTitle, tokenCount));
    //                     };
    //                 };
    //                 case (#err(_)) {
    //                     // Ignore errors for collections where token retrieval fails
    //                 };
    //             };
    //         };
    //     };

    //     return Buffer.toArray(resultArray);
    // };


    func principalToUser(principal: Principal) : User {
        #principal(principal)
    };

    // Token will be transfered to this Vault and gives you req details to construct a link out of it, which you can share
    public shared ({caller = user}) func createLink(
        _collectionCanisterId: Principal,
        _from: Principal,
        _tokenId: TokenIndex
    ) : async Nat32 {

        // if (Principal.isAnonymous(user)) {
        //     throw Error.reject("Anonymous principals are not allowed.");
        // };
        // Check if the link (tokenId) already exists in userLinks for this user
        let existingLinks = userLinks.get(_from);

        switch (existingLinks) {
            case null {
                // No links exist, continue to the next step
            };
            case (?links) {
                // Convert the existing array to a List
                let linksList = List.fromArray(links);

                // Check if the tokenId already exists
                let tokenExists = List.some<Link>(
                    linksList,
                    func(link) { link.tokenId == _tokenId and link.claimPattern == "transfer" and link.collection == _collectionCanisterId }
                );

                if (tokenExists) {
                    throw Error.reject("Error: Token ID already exists in user links.");
                };
            };
        };

        // Prepare the new deposit and link objects
        let userAID = AID.fromPrincipal(_from, null);
        let key = generateKey(userAID, Time.now(), _tokenId);
        let newDeposit: Deposit = {
            tokenId = _tokenId;
            sender = _from;
            collectionCanister = _collectionCanisterId;
            timestamp = Time.now();
            claimPattern = "transfer";
            status = "created";
        };
        let newLink: Link = {
            tokenId = _tokenId;
            collection = _collectionCanisterId;
            claimPattern = "transfer";
            createdBy = userAID;
            linkKey = key;
        };

        // Update the userLinks TrieMap with the new link
        switch (existingLinks) {
            case null {
                // No links exist
                userLinks.put(_from, [newLink]);
            };
            case (?links) {
                // Convert the existing array to a List
                let linksList = List.fromArray(links);

                // Add the new link to the list
                let updatedLinksList = List.push(newLink, linksList);

                // Update the user's links in the TrieMap
                userLinks.put(_from, List.toArray(updatedLinksList));
            };
        };

        // Store the new deposit in the depositItemsMap
        depositItemsMap.put(key, newDeposit);
        linksCount := linksCount + 1;
        dailyLinksCreatedCount := dailyLinksCreatedCount + 1;
        incrementUserLinksCreated(user);
        // Return the key for tracking purposes (no token transfer here)
        return key;
    };


    public shared ({caller = user}) func createLinkForNonMinted(
        _collectionCanisterId : Principal,
        _from : Principal,
        _tokenId : Nat32
    ) : async Nat32 {

        // if (Principal.isAnonymous(user)) {
        //     throw Error.reject("Anonymous principals are not allowed.");
        // };

        let existingLinks = userLinks.get(_from);

        switch (existingLinks) {
            case null {
                // No links exist, continue to the next step
            };
            case (?links) {
                // Convert the existing array to a List
                let linksList = List.fromArray(links);

                // Check if the tokenId already exists
                let tokenExists = List.some<Link>(
                    linksList,
                    func(link) { link.tokenId == _tokenId and link.claimPattern == "mint" }
                );

                if (tokenExists) {
                    throw Error.reject("Error: Token ID already exists in user links.");
                };
            };
        };
        // Check if the tokenId exists in the tokensDataToBeMinted for the given collection
        switch (tokensDataToBeMinted.get(_collectionCanisterId)) {
            case (?tokensList) {
                var matchingToken: ?(Nat32, Metadata) = null;

                for (token in tokensList.vals()) {
                    if (token.0 == _tokenId) {
                        matchingToken := ?token;
                    }
                };
                let userAID = AID.fromPrincipal(_from,null); 

                switch (matchingToken) {
                    case (?(_, metadata)) {
                        // Create a deposit entry for the non-minted token
                        let key = generateKey(userAID, Time.now(), _tokenId);
                        let newDeposit: Deposit = {
                            tokenId = _tokenId;
                            sender = _from;
                            collectionCanister = _collectionCanisterId;
                            timestamp = Time.now();
                            claimPattern = "mint";
                            status = "created";
                        };
                        let newLink: Link = {
                            tokenId = _tokenId;
                            collection = _collectionCanisterId;
                            claimPattern = "mint";
                            createdBy = userAID;
                            linkKey = key;
                        };

                        // Update the userLinks TrieMap with the new link
                        switch (existingLinks) {
                            case null {
                                // No links exist
                                userLinks.put(_from, [newLink]);
                            };
                            case (?links) {
                                // Convert the existing array to a List
                                let linksList = List.fromArray(links);

                                // Add the new link to the list
                                let updatedLinksList = List.push(newLink, linksList);

                                // Update the user's links in the TrieMap
                                userLinks.put(_from, List.toArray(updatedLinksList));
                            };
                        };
                        depositItemsMap.put(key,newDeposit);
                        linksCount := linksCount + 1;
                        dailyLinksCreatedCount := dailyLinksCreatedCount + 1;
                        incrementUserLinksCreated(user);
                        key;
                    };
                    case null {
                        throw Error.reject("Token ID does not match any stored metadata");
                        return 0;
                    };
                };
            };
            case null {
                throw Error.reject("No stored tokens found for the given collection canister");
                return 0;
            };
        };
    };

    public shared ({caller = user}) func claim(
        _collectionCanisterId: Principal,
        _depositKey: Nat32
    ) : async Result.Result<Int, Text> {
        // if (Principal.isAnonymous(user)) {
        //     throw Error.reject("Anonymous principals are not allowed.");
        // };
        await claimToken(user, _collectionCanisterId, _depositKey)
    };

    func claimToken(
        user : Principal,
        _collectionCanisterId: Principal,
        _depositKey: Nat32
    ) : async Result.Result<Int, Text> {
        
        let depositItemOpt = depositItemsMap.get(_depositKey);

        switch (depositItemOpt) {
            case null {
                throw Error.reject("Deposit Key not found, might be claimed already..!");
                return #err("Deposit Key not found, might be claimed already..!");
            };
            case (?depositItem) {
                let claimResult = switch (depositItem.claimPattern) {
                    case ("transfer") {
                        await claimLink(user, _collectionCanisterId, depositItem, _depositKey);
                    };
                    case ("mint") {
                        await mintAtClaim(user, _collectionCanisterId, depositItem, _depositKey);
                    };
                    case _ {
                        throw Error.reject("Invalid claim pattern: " # depositItem.claimPattern);
                        return #err("Invalid claim pattern");
                    };
                };

                switch (claimResult) {
                    case (#ok(claimRes)) {
                        // Retrieve existing claims for the user
                        let userClaims : ?[(Principal, Nat)] = claimedTokensMap.get(user);
                        
                        let updatedClaims : [(Principal, Nat)] = switch (userClaims) {
                            case null {
                                // No existing claims, initialize with a new entry
                                [(_collectionCanisterId, 1)];
                            };
                            case (?(existingClaims)) {
                                // Convert to List for easier manipulation
                                let claimsList = List.fromArray(existingClaims);

                                // Check if the collection canister ID is already in the list
                                var found = false;
                                var updatedList = List.map<(Principal, Nat), (Principal, Nat)>(claimsList, func (claim : (Principal, Nat)) : (Principal, Nat) {
                                    if (claim.0 == _collectionCanisterId) {
                                        found := true;
                                        // Increment the token count for this collection
                                        (claim.0, claim.1 + 1);
                                    } else {
                                        claim;
                                    }
                                });

                                // If not found, add a new entry for this collection
                                if (not found) {
                                    updatedList := List.push<(Principal, Nat)>((_collectionCanisterId, 1), updatedList);
                                };

                                // Convert back to array for storing in the TrieMap
                                List.toArray(updatedList);
                            };
                        };

                        // Update the claimed tokens map with the new or updated list
                        claimedTokensMap.put(user, updatedClaims);
                        return #ok(claimRes);
                    };
                    case (#err e) {
                        return #err(e);
                    };
                };
            };
        };
    };


        


    // Token will be transfered to user who claims through the shared link
    func claimLink(
        user: Principal,
        _collectionCanisterId: Principal,
        _depositItem: Deposit,
        _depositKey: Nat32
    ) : async Result.Result<Int, Text> {

        // if (Principal.isAnonymous(user)) {
        //     throw Error.reject("Anonymous principals are not allowed.");
        // };

        let collectionCanisterActor = actor (Principal.toText(_collectionCanisterId)) : actor {
            ext_transfer: (
                request: TransferRequest
            ) -> async TransferResponse;
        };

        let depositObj: Deposit = _depositItem;

        if (_collectionCanisterId != depositObj.collectionCanister) {
            return #err("Collection canister ID mismatch");
        };

        let userFrom: User = principalToUser(depositObj.sender);  // Sender is the original owner
        let userTo: User = principalToUser(user);                 // Claimer is the caller

        let tokenIdentifier = ExtCore.TokenIdentifier.fromPrincipal(_collectionCanisterId, depositObj.tokenId);
        
        let transferRequest: TransferRequest = {
            from = userFrom;
            to = userTo;
            token = tokenIdentifier;
            amount = 1;
            memo = "";
            notify = false;
            subaccount = null;
        };

        let response = await collectionCanisterActor.ext_transfer(transferRequest);

        switch (response) {
            case (#ok(balance)) {
                depositItemsMap.delete(_depositKey);

                let existingLinksOpt = userLinks.get(depositObj.sender);
                switch (existingLinksOpt) {
                    case (?links) {
                        let updatedLinks = Array.filter(links, func(link: Link): Bool {
                            link.tokenId != depositObj.tokenId or link.claimPattern != depositObj.claimPattern;
                        });
                        userLinks.put(depositObj.sender, updatedLinks);
                    };
                    case null {
                        return #err("No links found for user");
                    };
                };

                for (campaignId in campaignLinks.keys()) {
                    let linkIndicesOpt = campaignLinks.get(campaignId);
                    switch (linkIndicesOpt) {
                        case (?linkIndices) {
                            let newLinks = Array.filter<Nat32>(linkIndices, func(key: Nat32): Bool {
                                return key != _depositKey;
                            });
                            campaignLinks.put(campaignId, newLinks);
                            let campaignOpt = campaigns.get(campaignId);
                            switch (campaignOpt) {
                                case (?campaign) {
                                    // Update depositIndices in the campaign object
                                    let updatedDepositIndices = Array.filter<Nat32>(campaign.depositIndices, func(index: Nat32): Bool {
                                        return index != _depositKey;
                                    });
                                    let updatedCampaign : Campaign = {
                                            id = campaign.id;
                                            title = campaign.title;
                                            tokenType = campaign.tokenType;
                                            collection = campaign.collection;
                                            claimPattern = campaign.claimPattern;
                                            tokenIds = campaign.tokenIds;
                                            walletOption = campaign.walletOption;
                                            displayWallets = campaign.displayWallets;
                                            expirationDate = campaign.expirationDate;
                                            createdBy = campaign.createdBy;
                                            createdAt = campaign.createdAt;
                                            depositIndices = updatedDepositIndices;
                                        };

                                    campaigns.put(campaignId, updatedCampaign);

                                    // If no remaining links, delete the campaign
                                    if (newLinks.size() == 0) {
                                        await deleteCampaign(campaignId);
                                    };
                                };
                                case null { /* Handle if campaign not found */ };
                            };
                        };
                        case null {
                            return #err("No link created during campaign creation");
                        };
                    };
                };

                claimCount := claimCount + 1;
                dailyLinksClaimedCount := dailyLinksClaimedCount + 1;
                incrementUserLinksClaimed(user);
                return #ok(0); // Successful claim
            };

            case (#err(err)) {
                switch (err) {
                    case (#CannotNotify(accountId)) {
                        return #err("Cannot notify account " # accountId);
                    };
                    case (#InsufficientBalance) {
                        return #err("Insufficient balance");
                    };
                    case (#InvalidToken(tokenId)) {
                        return #err("Invalid token " # tokenId);
                    };
                    case (#Other(text)) {
                        return #err("Error: " # text);
                    };
                    case (#Rejected) {
                        return #err("Transfer rejected");
                    };
                    case (#Unauthorized(accountId)) {
                        return #err("Unauthorized account " # accountId);
                    };
                };
            };
        };
    };


    func mintAtClaim(
        user : Principal,
        _collectionCanisterId : Principal,
        _depositItem : Deposit,
        _depositKey : Nat32
    ) : async Result.Result<Int, Text> {

        // if (Principal.isAnonymous(user)) {
        //     throw Error.reject("Anonymous principals are not allowed.");
        // };
        let collectionCanisterActor = actor (Principal.toText(_collectionCanisterId)) : actor{
            ext_mint : (
                request : [(AccountIdentifier, Metadata)]
            ) -> async [TokenIndex]
        };

        if (_collectionCanisterId != _depositItem.collectionCanister) {
            throw Error.reject("Collection canister ID mismatch");
            return #err("Collection canister ID mismatch");
        };

        let tokensListOpt = tokensDataToBeMinted.get(_collectionCanisterId);
        switch (tokensListOpt) {
            case (?tokensList) {
                var foundToken: ?(Nat32, Metadata) = null;
                var remainingTokens: [(Nat32, Metadata)] = [];

                for (token in tokensList.vals()) {
                    if (token.0 == _depositItem.tokenId) {
                        foundToken := ?token;
                    } else {
                        remainingTokens := Array.append(remainingTokens, [token]);
                    };
                };

                switch (foundToken) {
                    case (?(_, metadata)) {
                        let receiver = AID.fromPrincipal(user, null);
                        let request: [(AccountIdentifier, Metadata)] = [(receiver, metadata)]; 

                        let response = await collectionCanisterActor.ext_mint(request);

                        depositItemsMap.delete(_depositKey);
                        if (Array.size(remainingTokens) > 0) {
                            tokensDataToBeMinted.put(_collectionCanisterId, remainingTokens);
                        } else {
                            tokensDataToBeMinted.delete(_collectionCanisterId);
                        };

                        let existingLinksOpt = userLinks.get(_depositItem.sender);
                        switch (existingLinksOpt) {
                            case (?links) {
                                let updatedLinks = Array.filter(links, func(link: Link): Bool {
                                    link.tokenId != _depositItem.tokenId or link.claimPattern != _depositItem.claimPattern;
                                });
                                userLinks.put(_depositItem.sender, updatedLinks);
                            };
                            case null {
                                throw Error.reject("No links found for user");
                                return #err("No links found for user");
                            };
                        };

                        for (campaignId in campaignLinks.keys()) {
                        let linkIndicesOpt = campaignLinks.get(campaignId);
                        switch (linkIndicesOpt) {
                            case (?linkIndices) {
                                let newLinks = Array.filter<Nat32>(linkIndices, func(key: Nat32): Bool {
                                    return key != _depositKey;
                                });
                                campaignLinks.put(campaignId, newLinks);
                                if(newLinks.size()==0){
                                    await deleteCampaign(campaignId);
                                }
                            };
                            case null {
                                return #err("No link created during campaign creation");
                            };
                        };
                    };


                        claimCount := claimCount + 1;
                        dailyLinksClaimedCount := dailyLinksClaimedCount + 1;
                        incrementUserLinksClaimed(user);
                        return #ok(0); // Successful mint
                    };
                    case null {
                        throw Error.reject("Token ID does not match any in the deposit object");
                        return #err("Token ID does not match any in the deposit object");
                    };
                };
            };
            case null {
                throw Error.reject("No metadata found for the given token");
                return #err("No metadata found for the given token");
            };
        };
    };


    // Campaign creation
    public shared ({caller = user}) func createCampaign (
        title: Text,
        tokenType: Text,
        collection : Principal,
        claimPattern: Text,
        tokenIds: [TokenIndex],
        walletOption: Text,
        displayWallets : [Text],
        expirationDate: Time.Time,
    ) : async (Text,[Nat32]) {

        // if (Principal.isAnonymous(user)) {
        //     throw Error.reject("Anonymous principals are not allowed.");
        // };
        let campaignId = generateCampaignId(user);
        var linkResponses: [Nat32] = [];

        for (tokenId in tokenIds.vals()) {
            var linkKeys : Nat32 = 0;
            if(claimPattern == "transfer"){
                linkKeys := await createLink(collection, user, tokenId);
            } else if (claimPattern == "mint") {
                linkKeys := await createLinkForNonMinted(collection, user, tokenId);
            } else {
                throw Error.reject("Invalid claimPattern: " # claimPattern);
            };

            if (linkKeys == 0) {
                // If createLink or createLinksForNonMinted fails, throw an error and abort campaign creation
                throw Error.reject("Failed to create campaign: " # claimPattern # " failed for tokenId " # Nat32.toText(tokenId));
            };

            linkResponses := Array.append(linkResponses, [linkKeys]);
            campaignLinks.put(campaignId, linkResponses);
        };

        let campaign : Campaign = {
            id = campaignId;
            title = title;
            tokenType = tokenType;
            collection = collection;
            claimPattern = claimPattern;
            tokenIds = tokenIds;
            walletOption = walletOption;
            displayWallets = displayWallets;
            expirationDate = expirationDate;
            createdBy = user;
            createdAt = Time.now();
            depositIndices = linkResponses;
        };
        campaigns.put(campaignId, campaign);

        let userCampaigns = userCampaignsMap.get(user);
        switch (userCampaigns) {
            case null {
                userCampaignsMap.put(user, [campaign]);
            };
            case (?userCampaigns) {
                userCampaignsMap.put(user, Array.append(userCampaigns, [campaign]));
            };
        };

        switch (?expirationDate) {
            case (?exp) await scheduleCampaignDeletion(campaignId, exp);
            case null Debug.print("Invalid expiration date format");
        };

        return (campaignId, linkResponses);
    };

    func scheduleCampaignDeletion(campaignId : Text, expiration: Time.Time) : async () {
        let now = Time.now();
        let duration = if (expiration > now) expiration - now else now - expiration;
        let natDuration = Nat64.toNat(Nat64.fromIntWrap(duration));
        if (duration > 0) {
            let id = Timer.setTimer<system>(#nanoseconds natDuration, func () : async () {
                await deleteCampaign(campaignId);
            });
            campaignTimers.put(campaignId, id);
        };
    };

    // internal function to take care of link expiration
    func deleteCampaign(campaignId: Text) : async () {
        // Retrieve QRSetId and DispenserId from qdcMap
        var qrSetId : Text = "";
        var dispenserId : Text = "";
        
        var qdcList = List.fromArray(qdcMap);
        var updatedQdcList = List.filter<(Text, (Text, Text))>(qdcList, func(entry) : Bool {
            if (entry.0 == campaignId) {
                qrSetId := entry.1.0;
                dispenserId := entry.1.1;
                false
            } else {
                true
            }
        });
        qdcMap := List.toArray(updatedQdcList);

        // Remove QRSet if it exists
        if (qrSetId != "") {
            qrSetMap.delete(qrSetId);
        };

        // Remove Dispenser if it exists
        if (dispenserId != "") {
            dispensers.delete(dispenserId);
        };
        // Delete links related to the campaign
        campaignLinks.delete(campaignId);

        // Delete the campaign itself
        campaigns.delete(campaignId);

        // Cancel the scheduled timer if it exists
        switch (campaignTimers.get(campaignId)) {
            case (?timerId) {
                Timer.cancelTimer(timerId);
                campaignTimers.delete(campaignId);
            };
            case null {};
        };

        // Remove the campaign from the user's campaign map
        for ((user, userCampaigns) in userCampaignsMap.entries()) {
            let updatedCampaigns = Array.filter<Campaign>(userCampaigns ,func (campaign) : Bool {
                campaign.id != campaignId
            });
            if (updatedCampaigns.size() == 0) {
                userCampaignsMap.delete(user);
            } else {
                userCampaignsMap.put(user, updatedCampaigns);
            };
        };

        // Remove related QR sets from user's QR set map
        for ((user, userQRSets) in userQRSetMap.entries()) {
            let updatedQRSets = Array.filter<QRSet>(userQRSets ,func (qrSet) : Bool {
                qrSet.campaignId != campaignId
            });
            if (updatedQRSets.size() == 0) {
                userQRSetMap.delete(user);
            } else {
                userQRSetMap.put(user, updatedQRSets);
            };
        };

        // Remove related dispensers from user's dispenser map
        for ((user, userDispensers) in userDispensersMap.entries()) {
            let updatedDispensers = Array.filter<Dispenser>(
                userDispensers,
                func(dispenser) : Bool {
                    dispenser.campaignId != campaignId;
                },
            );
            if (updatedDispensers.size() == 0) {
                userDispensersMap.delete(user);
            } else {
                userDispensersMap.put(user, updatedDispensers);
            };
        };
    };


    // Get details of a specific Campaign
    public shared query func getCampaignDetails(campaignId : Text) : async ?Campaign {
        campaigns.get(campaignId);
    };
    // Get Links created inside a Campaign
    public shared query func getCampaignLinks(campaignId : Text) : async ?[Nat32] {
        campaignLinks.get(campaignId);
    };
    // Get all campaigns created by a user
    public shared query ({ caller = user }) func getUserCampaigns() : async ?[Campaign] {
        userCampaignsMap.get(user);
    };

    // Generation of unique campaign ID
    private func generateCampaignId(user : Principal) : Text {
        // Using user ID (Principal) and current timestamp to generate a unique campaign ID
        let timestamp = Time.now();
        let userId = Principal.toText(user);
        "Campaign-" # userId # "_" # Int.toText(timestamp)
    };

    // QR Set Creation
    public shared ({ caller = user }) func createQRSet(
        title : Text,
        quantity : Nat,
        campaignId : Text
    ) : async Text {

        // if (Principal.isAnonymous(user)) {
        //     throw Error.reject("Anonymous principals are not allowed.");
        // };

        let qrSetId = generateQRSetId(user);

        let newQRSet : QRSet = {
            id = qrSetId;
            title = title;
            quantity = quantity;
            campaignId = campaignId;
            createdAt = Time.now();
            creator = user;
        };

        // Update qdcMap with the QRSet and DispenserId
        var qdcList = List.fromArray(qdcMap);

        // Find the entry for the given campaignId
        var qdcEntry = List.find(qdcList, func(entry : (Text, (Text, Text))) : Bool {
            return entry.0 == campaignId;
        });

        switch (qdcEntry) {
            case null {
                // If no entry exists for the campaignId, create a new entry with QRSetId
                qdcList := List.push((campaignId, (qrSetId, "")), qdcList );
            };
            case (?existingEntry) {
                // If a QRSetId already exists for the campaign, throw an error
                if (existingEntry.1.0 != "") {
                    // Throw an error or handle it appropriately
                    throw Error.reject("QRSet already exists for this campaignId.");
                } else {
                    // Otherwise, update the existing entry by adding the new QRSetId
                    qdcList := List.filter(qdcList, func(entry : (Text, (Text, Text))) : Bool {
                        return entry.0 != campaignId;
                });
                    qdcList := List.push((campaignId, (qrSetId, existingEntry.1.1)), qdcList);
                }
            };
        };

        // Convert the list back to an array
        qdcMap := List.toArray(qdcList);


        qrSetMap.put(qrSetId, newQRSet);

        let userQRSets = userQRSetMap.get(user);
        switch (userQRSets) {
            case (null) {
                userQRSetMap.put(user, [newQRSet]);
            };
            case (?userQRSets) {
                userQRSetMap.put(user, Array.append(userQRSets, [newQRSet]));
            };
        };

        qrSetId
    };

    private func generateQRSetId(user : Principal) : Text {
        // Using user ID (Principal) and current timestamp to generate a unique campaign ID
        let timestamp = Time.now();
        let userId = Principal.toText(user);
        "QR-" #userId # "_" # Int.toText(timestamp)
    };

    // Get details of a specific QR set
    public shared query func getQRSetById(qrSetId : Text) : async ?QRSet {
        qrSetMap.get(qrSetId)
    };

    // Get all QR sets created by a user
    public shared query ({ caller = user }) func getUserQRSets() : async ?[QRSet] {
        userQRSetMap.get(user)
    };

    // public shared({caller = user}) func deleteQRSet(qrSetId: Text) : async Int {
    //     // Check if the QRSet exists
    //     switch (qrSetMap.get(qrSetId)) {
    //         case (?qrSet) {
    //             // QRSet exists, proceed with deletion
    //             qrSetMap.remove(qrSetId);
                
    //             // Remove QRSet from userQRSetMap
    //             let userQRSetEntries = userQRSetMap.get(user);
    //             switch (userQRSetEntries) {
    //                 case (?qrSets) {
    //                     let updatedQRSetEntries = List.filter<QRSet>(fun(qrSet) { qrSet.id != qrSetId }, List.fromArray(userQRSets));
    //                     userQRSetMap.put(user, List.toArray(updatedQRSetEntries));
    //                 };
    //                 case null {
    //                     // No QR sets found for the user
    //                 };
    //             };
                
    //             return 0; // Indicate success
    //         };
    //         case null {
    //             // QRSet does not exist
    //             return -1; // Indicate failure
    //         };
    //     }
    // };

    public shared ({ caller = user }) func createDispenser (
        _title : Text,
        _startDate : Time.Time,
        _duration : Int,
        _campaignId : Text,
        _whitelist : [Principal]
    ) : async Text {

        // if (Principal.isAnonymous(user)) {
        //     throw Error.reject("Anonymous principals are not allowed.");
        // };
        let dispenserId = generateDispenserId(user);

        let dispenser : Dispenser = {
            id = dispenserId;
            title = _title;
            startDate = _startDate;
            createdAt = Time.now();
            createdBy = user;
            duration = _duration;
            campaignId = _campaignId;
            whitelist = _whitelist;
        };

        // Update qdcMap with the QRSet and DispenserId
        var qdcList = List.fromArray(qdcMap);

        // Find the entry for the given campaignId
        var qdcEntry = List.find(qdcList, func(entry : (Text, (Text, Text))) : Bool {
            return entry.0 == _campaignId;
        });

        switch (qdcEntry) {
            case null {
                // If no entry exists for the campaignId, create a new entry with DispenserId
                qdcList := List.push((_campaignId, ("", dispenserId)), qdcList );
            };
            case (?existingEntry) {
                // If a DispenserId already exists for the campaign, throw an error
                if (existingEntry.1.1 != "") {
                    // Throw an error or handle it appropriately
                    throw Error.reject("Dispenser already exists for this campaignId.");
                } else {
                    // Otherwise, update the existing entry by adding the new DispenserId
                    qdcList := List.filter(qdcList, func(entry : (Text, (Text, Text))) : Bool {
                        return entry.0 != _campaignId;
                });
                    qdcList := List.push((_campaignId, (existingEntry.1.0, dispenserId)), qdcList);
                }
            };
        };

        // Convert the list back to an array
        qdcMap := List.toArray(qdcList);



        dispensers.put(dispenserId, dispenser);

        await scheduleDispenserDeletion(dispenserId, _startDate, _duration);


        let userDispensers = userDispensersMap.get(user);
        switch (userDispensers) {
            case null {
                userDispensersMap.put(user, [dispenser]);
            };
            case (?userDispensers) {
                userDispensersMap.put(user, Array.append(userDispensers, [dispenser]));
            };
        };
        return dispenserId;
    };

   public shared ({ caller = user }) func dispenserClaim(
        _dispenserId: Text
    ): async Result.Result<Int, Text> {

        // if (Principal.isAnonymous(user)) {
        //     throw Error.reject("Anonymous principals are not allowed.");
        // };
        let dispenserOpt = dispensers.get(_dispenserId);

        switch (dispenserOpt) {
            case null {
                return #err("Dispenser not found");
            };
            case (?dispenser) {
                // Check if user is in the whitelist
                if(dispenser.whitelist.size() > 0){
                    let userInWhitelist = Array.find(dispenser.whitelist, func(p: Principal): Bool { p == user });
                    switch (?userInWhitelist) {
                        case null {
                            return #err("User not whitelisted");
                        };
                        case (?_) {

                        };
                    };
                };
                        // User is whitelisted, proceed with the rest of the claim logic
                        let campaignOpt = campaigns.get(dispenser.campaignId);

                        switch (campaignOpt) {
                            case null {
                                return #err("Campaign not found");
                            };
                            case (?campaign) {
                                let remainingClaimsOpt = campaignLinks.get(dispenser.campaignId);

                                switch (remainingClaimsOpt) {
                                    case null {
                                        return #err("No claims found for this campaign");
                                    };
                                    case (?remainingClaims) {
                                        if (remainingClaims.size() == 0) {
                                            return #err("No more tokens to claim");
                                        };

                                        // Check if user has already claimed a token from this dispenser
                                        let userClaims = userClaimedDispensers.get(user);
                                        switch (userClaims) {
                                            case null {
                                                // No previous claims, proceed with claim
                                            };
                                            case (?claims) {
                                                let alreadyClaimed = Array.find(claims, func(claimedId: Text): Bool {
                                                    claimedId == dispenser.id
                                                });
                                                if (alreadyClaimed != null) {
                                                    return #err("User has already claimed a token from this dispenser");
                                                };
                                            };
                                        };

                                        // Claim the token (assuming claimToken returns a Result)
                                        let claimResult = await claimToken(user, campaign.collection, remainingClaims[0]);
                                        switch (claimResult) {
                                            case (#ok(result)) {
                                                // Update user claims
                                                let updatedClaims = switch (userClaims) {
                                                    case null { List.push<Text>(dispenser.id, List.nil<Text>()) }; // Start new List
                                                    case (?existingClaimsArray) {
                                                        let existingClaims = List.fromArray(existingClaimsArray); // Convert to List
                                                        List.push<Text>(dispenser.id, existingClaims); // Add to existing List
                                                    };
                                                };
                                                let updatedClaimsArray = List.toArray(updatedClaims);
                                                userClaimedDispensers.put(user, updatedClaimsArray);
                                                return #ok(result);  // Return the claimed token ID
                                            };
                                            case (#err(err)) {
                                                return #err(err);  // Return any error from claimToken
                                            };
                                        };
                                    };
                                };
                            };
                        };
            };
        };
    };



    // Function to schedule dispenser deletion based on start time and duration
    func scheduleDispenserDeletion(dispenserId : Text, startTime : Time.Time, duration : Int) : async () {
        let now = Time.now();
        
        // Calculate the expiration time
        let expirationTime = (startTime) + (duration * 60_000_000_000);  // duration is in minutes, converting to nanoseconds
        let timeRemaining = if (expirationTime > now) expirationTime - now else now - expirationTime;
        let natDuration = Nat64.toNat(Nat64.fromIntWrap(timeRemaining));
        
        if (timeRemaining > 0) {
            let id = Timer.setTimer<system>(#nanoseconds natDuration, func () : async () {
                await deleteDispenser(dispenserId);
            });
            dispenserTimers.put(dispenserId, id);
        };
    };

    func deleteDispenser(dispenserId: Text) : async  () {

        // Delete the dispenser itself
        dispensers.delete(dispenserId);

        // Cancel the scheduled timer if it exists
        switch (dispenserTimers.get(dispenserId)) {
            case (?timerId) {
                Timer.cancelTimer(timerId);
                dispenserTimers.delete(dispenserId);
            };
            case null {};
        };

        // Remove the dispenser from the user's dispenser map
        for ((user, userDispensers) in userDispensersMap.entries()) {
            let updatedDispensers = Array.filter<Dispenser>(
                userDispensers,
                func(dispenser) : Bool {
                    dispenser.id != dispenserId;
                },
            );
            if (updatedDispensers.size() == 0) {
                userDispensersMap.delete(user);
            } else {
                userDispensersMap.put(user, updatedDispensers);
            };
        };
    };









    // Get details of a specific Dispenser
    public shared query func getDispenserDetails(dispenserId : Text) : async ?Dispenser {
        dispensers.get(dispenserId);
    };

    // Get all dispensers created by a user
    public shared query ({ caller = user }) func getUserDispensers() : async ?[Dispenser] {
        userDispensersMap.get(user);
    };

    // Generation of unique dispenser ID
    private func generateDispenserId(user : Principal) : Text {
        // Using user ID (Principal) and current timestamp to generate a unique dispenser ID
        let timestamp = Time.now();
        let userId = Principal.toText(user);
        "Dispenser-" # userId # "_" # Int.toText(timestamp)
    };


    // Function to get campaign IDs where QRSet is available
    public query func getCampaignsWithQRSet() : async [Text] {

        let qdcList = List.fromArray(qdcMap);

        // Filter campaigns where the QRSet is present (non-empty)
        let qrSetCampaigns = List.filter(qdcList, func(entry : (Text, (Text, Text))) : Bool {
            let (campaignId, (qrSet, _)) = entry;
            return qrSet != "";  
        });

        // Extract only the campaign IDs and return them as an array
        return List.toArray(List.map(qrSetCampaigns, func(entry : (Text, (Text, Text))) : Text {
            let (campaignId, _) = entry;
            return campaignId;
        }));
    };

    // Function to get campaign IDs where Dispenser is available
    public query func getCampaignsWithDispenser() : async [Text] {

        let qdcList = List.fromArray(qdcMap);

        // Filter campaigns where the Dispenser is present (non-empty)
        let dispenserCampaigns = List.filter(qdcList, func(entry : (Text, (Text, Text))) : Bool {
            let (campaignId, (_, dispenser)) = entry;
            return dispenser != "";
        });

        // Extract only the campaign IDs and return them as an array
        return List.toArray(List.map(dispenserCampaigns, func(entry : (Text, (Text, Text))) : Text {
            let (campaignId, _) = entry;
            return campaignId;
        }));
    };

}