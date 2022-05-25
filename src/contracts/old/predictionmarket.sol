// A simple binary prediction market

pragma solidity ^0.8.4;

contract PredictionMarket {
    enum Outcome { Yes, No, Invalid }

    struct Prediction {
        address payable payoutAddress;
        uint shares;
        Outcome option;
    }

    address oracle;
    string question;
    uint pot;

    uint yesPot;
    uint noPot;

    bool finalized = false;
    Outcome outcome = Outcome.Invalid;
    bool payedout = false;

    Prediction[] predictions;

    constructor(string memory _question) payable {
        require(msg.value >= 0, "Must be created with an initial deposit");

        oracle = msg.sender;
        pot = msg.value;
        question = _question;

        yesPot = pot/2;
        noPot  = pot - yesPot;

        predictions.push(Prediction(payable(msg.sender), yesPot, Outcome.Yes));
        predictions.push(Prediction(payable(msg.sender), noPot, Outcome.No));
    }

    modifier onlyBy(address _account) {
        require(msg.sender == _account, "Access denied");
        _;
    }

    function predict(bool _option) public payable {
        if(msg.value <= 0 || finalized) return;

        pot += msg.value;
        if(_option) {
            yesPot += msg.value;
        } else {
            noPot += msg.value;
        }

        predictions.push(Prediction(payable(msg.sender), msg.value, _option ? Outcome.Yes : Outcome.No));
    }

    function finalize(bool _option) public onlyBy(oracle) {
        if(finalized) return;

        outcome = _option ? Outcome.Yes : Outcome.No;
        finalized = true;
    }

    function getPot() public view returns (uint _pot) {
        _pot = pot;
    }

    function price() public view returns (uint _yesPrice, uint _noPrice) {
        _yesPrice = (1 ether * pot) / yesPot;
        _noPrice = (1 ether * pot) / noPot;
    }

    function payout() public {
        if(!finalized || payedout) return;

        uint256 _outcomePot;
        if(outcome == Outcome.Yes) {
            _outcomePot = yesPot;
        } else if(outcome == Outcome.No) {
            _outcomePot = noPot;
        } else {
            _outcomePot = pot;
        }

        payedout = true;

        uint256 _valuePerShare = pot / _outcomePot;
        for(uint i=0; i<predictions.length; i++) {
            Prediction storage _pred = predictions[i];
            if(outcome == Outcome.Invalid || _pred.option == outcome) {
                uint256 _payout = _pred.shares * _valuePerShare;
                _pred.payoutAddress.transfer(_payout);
            }
        }
    }
}
