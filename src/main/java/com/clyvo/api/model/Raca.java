package com.clyvo.api.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "T_RACA")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Raca {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String nome;

    private String propensaoDoenca; // Ex: Displasia, Problemas Respiratórios

    private Integer expectativaVida; // Em anos

    private String cuidadosEspeciais;
}
