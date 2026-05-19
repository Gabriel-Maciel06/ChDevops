package com.clyvo.api.repository;
import com.clyvo.api.model.Tratamento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
@Repository
public interface TratamentoRepository extends JpaRepository<Tratamento, Long> {}
