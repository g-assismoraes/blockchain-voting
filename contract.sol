// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Votacao {

    bool public votacaoAberta;
    uint public PEC_id;

    struct Votante {
        bool podeVotar;
        bool jaVotou;
        uint voto;
    }

    struct TipoVoto {
        bytes32 descricao;
        uint id;
        uint contagemVotos;
    }

    address public presidenteVotacao;

    mapping(address => Votante) public votantes;

    TipoVoto[] public votos;

    constructor(uint id) {
        votacaoAberta = true;
        PEC_id = id;
        presidenteVotacao = msg.sender;
        votantes[presidenteVotacao].podeVotar = true;
        votos.push(TipoVoto({descricao: "Favoravel",contagemVotos: 0, id:1}));
        votos.push(TipoVoto({descricao: "Contrario",contagemVotos: 0, id:2}));
        votos.push(TipoVoto({descricao: "Abstencao",contagemVotos: 0, id:3}));
        
    }

    function concedePoderDeVoto(address votante) external {
        require(
            votacaoAberta,
            "Votacao fechada."
        );
        require(
            msg.sender == presidenteVotacao,
            "Somente o presidente da votacao possui essa prerrogativa."
        );
        require(
            !votantes[votante].jaVotou,
            "Nao eh possivel votar mais de uma vez."
        );
        require(votantes[votante].podeVotar == false);
        votantes[votante].podeVotar = true;

    }

    function votar(uint tipoVoto) external { //0 favoravel; 1 contrario; 2 abstencao
        require(votacaoAberta, "Votacao fechada.");
        Votante storage sender = votantes[msg.sender];
        require(sender.podeVotar, "Nao tem poder de voto.");
        require(!sender.jaVotou, "Ja votou.");
        sender.jaVotou = true;
        sender.voto = tipoVoto;
        votos[tipoVoto].contagemVotos += 1;
    }

    function encerraVotacao() external {
        require(
            votacaoAberta,
            "Votacao ja fechada fechada."
        );
        require(
            msg.sender == presidenteVotacao,
            "Somente o presidente da votacao possui essa prerrogativa."
        );
        votacaoAberta = false;
        }
    
    
    function consultaResultado() external view
            returns (uint numFavoravel, uint numContrario, uint numAbstencao)
    {   
        numFavoravel = votos[0].contagemVotos;
        numContrario = votos[1].contagemVotos;
        numAbstencao = votos[2].contagemVotos;
    }
}