package com.clyvo.api.repository;
import com.clyvo.api.model.ContextoLocalizacao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ContextoLocalizacaoRepository extends JpaRepository<ContextoLocalizacao, Long> {
    
    // Pega a última localização do tutor
    Optional<ContextoLocalizacao> findTopByTutorCpfOrderByDataHoraCapturaDesc(String cpf);
}
