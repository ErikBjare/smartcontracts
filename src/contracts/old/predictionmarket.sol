// A simple binary prediction market

pragma solidity ^0.4.0;

contract PredictionMarket {
    enum Outcome { Yes, No, Invalid }

    struct Prediction {
        address payoutAddress;
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

    function PredictionMarket(string _question) payable {
        require(msg.value >= 0);

        oracle = msg.sender;
        pot = msg.value;
        question = _question;

        yesPot = pot/2;
        noPot  = pot - yesPot;

        predictions.length = 2;
        predictions[0] = Prediction(msg.sender, yesPot, Outcome.Yes);
        predictions[1] = Prediction(msg.sender, noPot, Outcome.No);
    }

    modifier onlyBy(address _account) {
        require(msg.sender == _account);
        _;
    }

    function predict(bool _option) payable {
        if(msg.value <= 0 || finalized) return;

        pot += msg.value;
        if(_option) {
            yesPot += msg.value;
        } else {
            noPot += msg.value;
        }

        predictions.length += 1;
        predictions[predictions.length-1] = Prediction(msg.sender, msg.value, _option ? Outcome.Yes : Outcome.No);
    }

    function finalize(bool _option) onlyBy(oracle) {
        if(finalized) return;

        outcome = _option ? Outcome.Yes : Outcome.No;
        finalized = true;
    }

    function getPot() constant returns (uint _pot) {
        _pot = pot;
    }

    function price() constant returns (uint _yesPrice, uint _noPrice) {
        _yesPrice = (1 ether * pot) / yesPot;
        _noPrice = (1 ether * pot) / noPot;
    }

    function payout() {
        if(!finalized || payedout) return;

        uint256 _outcomePot;
        if(outcome == Outcome.Yes) {
            _outcomePot = yesPot;
        } else if(outcome == Outcome.No) {
            _outcomePot = noPot;
        } else {
            _outcomePot = pot;
        }

        uint256 _valuePerShare = pot / _outcomePot;
        for(uint i=0; i<predictions.length; i++) {
            Prediction storage _pred = predictions[i];
            if(outcome == Outcome.Invalid || _pred.option == outcome) {
                uint256 _payout = _pred.shares * _valuePerShare;
                _pred.payoutAddress.transfer(_payout);
            }
        }

        payedout = true;
    }
}
