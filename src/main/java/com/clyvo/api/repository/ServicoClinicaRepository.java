package com.clyvo.api.repository;
import com.clyvo.api.model.ServicoClinica;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ServicoClinicaRepository extends JpaRepository<ServicoClinica, Long> {
    
    // Consulta para encontrar clínicas que oferecem um serviço específico
    @Query("SELECT sc FROM ServicoClinica sc WHERE sc.tipoEventoCatalogo.id = :idTipo AND sc.disponivel = true")
    List<ServicoClinica> findClinicasByTipoServico(@Param("idTipo") Long idTipo);
}
