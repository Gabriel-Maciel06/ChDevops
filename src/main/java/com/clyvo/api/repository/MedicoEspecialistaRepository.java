package com.clyvo.api.repository;
import com.clyvo.api.model.MedicoEspecialista;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
@Repository
public interface MedicoEspecialistaRepository extends JpaRepository<MedicoEspecialista, Long> {}
