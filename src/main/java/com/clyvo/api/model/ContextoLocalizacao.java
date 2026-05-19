package com.clyvo.api.model;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "T_CONTEXTO_LOCALIZACAO")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ContextoLocalizacao {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "cpf_tutor")
    private Tutor tutor;
    
    private Double latitudeAtual;
    private Double longitudeAtual;
    private LocalDateTime dataHoraCaptura;
    private String cidadeDetectada;
}
