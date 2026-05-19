package com.clyvo.api.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "T_PET")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Pet {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    private String nome;

    @NotNull
    private LocalDate dataNascimento;

    private Double peso;

    @ManyToOne
    @JoinColumn(name = "raca_id")
    private Raca raca;

    @ManyToOne
    @JoinColumn(name = "tutor_cpf")
    private Tutor tutor;

    // Campo calculado ou persistido para a IA
    private String statusLongevidade; 
}
