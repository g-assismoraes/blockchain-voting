// SPDX-License-Identifier: GPL-3.0
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

    function consedePoderDeVoto(address votante) external {
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
    

    function votar(uint proposta) external { //1 favoravel; 2 contrario; abstencao
        require(votacaoAberta, "Votacao fechada.");
        Votante storage sender = votantes[msg.sender];
        require(sender.podeVotar, "Nao tem poder de voto.");
        require(!sender.jaVotou, "Ja votou.");
        sender.jaVotou = true;
        sender.voto = proposta;
        votos[proposta].contagemVotos += 1;
    }
    
    function consultaResultado() external view
            returns (uint resultado)
    {   
        resultado = 0;
        uint contagem = 0;
        for (uint p = 0; p < votos.length; p++) { //se tiver empate → aprovacao tem prioridade negacao e por ultimo abstencao
            if (votos[p].contagemVotos > contagem) {
                contagem = votos[p].contagemVotos;
                resultado = p;
            }
        }
    }
}