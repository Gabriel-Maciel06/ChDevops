package com.clyvo.api.repository;
import com.clyvo.api.model.HistoricoClinico;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
@Repository
public interface HistoricoClinicoRepository extends JpaRepository<HistoricoClinico, Long> {}
