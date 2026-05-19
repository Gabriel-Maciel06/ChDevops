package com.clyvo.api.service;

import com.clyvo.api.model.Clinica;
import com.clyvo.api.model.ContextoLocalizacao;
import com.clyvo.api.model.ServicoClinica;
import com.clyvo.api.repository.ContextoLocalizacaoRepository;
import com.clyvo.api.repository.ServicoClinicaRepository;
import com.clyvo.api.exception.RecursoNaoEncontradoException;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MatchPreditivoService {

    private final ContextoLocalizacaoRepository localizacaoRepository;
    private final ServicoClinicaRepository servicoClinicaRepository;

    public List<Clinica> buscarClinicasProximasParaServico(String cpfTutor, Long idTipoServico) {
        // 1. Busca a última localização do tutor
        ContextoLocalizacao localizacao = localizacaoRepository.findTopByTutorCpfOrderByDataHoraCapturaDesc(cpfTutor)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Localização do tutor não encontrada."));

        // 2. Busca os serviços disponíveis para o tipo solicitado
        List<ServicoClinica> servicos = servicoClinicaRepository.findClinicasByTipoServico(idTipoServico);

        // 3. Filtra clínicas na mesma cidade/região da última localização detectada.
        return servicos.stream()
                .map(ServicoClinica::getClinica)
                .filter(clinica -> clinica.getCidade() != null && clinica.getCidade().equalsIgnoreCase(localizacao.getCidadeDetectada()))
                .collect(Collectors.toList());
    }
}
