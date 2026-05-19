package com.clyvo.api.model;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "T_TIPO_EVENTO_CATALOGO")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class TipoEventoCatalogo {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String descricao;
    private String categoria;
}
