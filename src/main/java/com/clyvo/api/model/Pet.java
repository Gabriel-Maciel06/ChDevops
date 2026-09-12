package com.clyvo.api.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDate;

/**
 * Tabela CORE 2: T_PET - paciente monitorado, vinculado a um tutor (N:1).
 * Mapeamento alinhado ao DDL oficial (script_bd.sql), incluindo o
 * ON DELETE CASCADE da FK fk_pet_tutor.
 */
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
    @Column(name = "nome", nullable = false, length = 100)
    private String nome;

    @NotNull
    @Column(name = "data_nascimento", nullable = false)
    private LocalDate dataNascimento;

    @Column(name = "peso")
    private Double peso;

    @ManyToOne
    @JoinColumn(name = "raca_id", foreignKey = @ForeignKey(name = "fk_pet_raca"))
    private Raca raca;

    @ManyToOne(optional = false)
    @JoinColumn(name = "tutor_cpf", nullable = false, foreignKey = @ForeignKey(name = "fk_pet_tutor"))
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Tutor tutor;

    // Parecer preditivo de longevidade (persistido)
    @Column(name = "status_longevidade", length = 500)
    private String statusLongevidade;
}
