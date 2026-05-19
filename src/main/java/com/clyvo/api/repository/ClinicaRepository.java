package com.clyvo.api.repository;
import com.clyvo.api.model.Clinica;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
@Repository
public interface ClinicaRepository extends JpaRepository<Clinica, Long> {}
