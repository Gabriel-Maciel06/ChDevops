package com.clyvo.api.model;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
@Entity
@Table(name = "T_TRATAMENTO")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Tratamento {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne @JoinColumn(name = "id_pet")
    private Pet pet;
    private String nomeMedicamento;
    private String frequencia;
    private LocalDate dataInicio;
    private LocalDate dataFinal;
}
