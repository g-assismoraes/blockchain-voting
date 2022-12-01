// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


contract Votacao {

    bool votacaoAberta;

    struct Votante {
        bool podeVotar;
        bool jaVotou;
        uint voto;
    }

    struct Proposta {
        bytes32 descricao;
        uint contagemVotos;
    }

    address public presidenteVotacao;

    mapping(address => Votante) public votantes;

    Proposta[] public propostas;

    constructor(bytes32[] memory nomesPropostas) {
        votacaoAberta = true;
        presidenteVotacao = msg.sender;
        for (uint i = 0; i < nomesPropostas.length; i++) {
            propostas.push(Proposta({
                descricao: nomesPropostas[i],
                contagemVotos: 0
            }));
        }
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
    

    function votar(uint proposta) external {
        require(votacaoAberta, "Votacao fechada.");
        Votante storage sender = votantes[msg.sender];
        require(sender.podeVotar, "Nao tem poder de voto");
        require(!sender.jaVotou, "Ja votou");
        sender.jaVotou = true;
        sender.voto = proposta;
        propostas[proposta].contagemVotos += 1;
    }
    
    function consultaResultado() external view
            returns (bytes32 resultado)
    {   
        uint propostaLiderando = 0;
        uint contagem = 0;
        for (uint p = 0; p < propostas.length; p++) {
            if (propostas[p].contagemVotos > contagem) {
                contagem = propostas[p].contagemVotos;
                propostaLiderando = p;
            }
        }
        resultado = propostas[propostaLiderando].descricao;
    }
}