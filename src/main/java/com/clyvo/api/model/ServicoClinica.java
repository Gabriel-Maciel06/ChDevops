package com.clyvo.api.model;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "T_SERVICO_CLINICA")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ServicoClinica {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "id_clinica")
    private Clinica clinica;
    
    @ManyToOne
    @JoinColumn(name = "id_tipo_catalogo")
    private TipoEventoCatalogo tipoEventoCatalogo;
    
    private Boolean disponivel;
}
