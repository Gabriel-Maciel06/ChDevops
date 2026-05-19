package com.clyvo.api.model;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
@Entity
@Table(name = "T_HISTORICO_CLINICO")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class HistoricoClinico {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @OneToOne @JoinColumn(name = "id_evento")
    private Evento evento;
    private LocalDate dataEvento;
    private LocalDate dataVencimento;
    private String status;
    @Lob
    private String observacoesIa;
}
