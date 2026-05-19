package com.clyvo.api.repository;
import com.clyvo.api.model.TipoEventoCatalogo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TipoEventoCatalogoRepository extends JpaRepository<TipoEventoCatalogo, Long> {}
