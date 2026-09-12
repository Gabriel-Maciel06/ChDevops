package com.clyvo.api.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

/**
 * Tabela CORE 1: T_TUTOR - responsável legal pelos pets monitorados.
 * Mapeamento alinhado ao DDL oficial (script_bd.sql).
 */
@Entity
@Table(name = "T_TUTOR")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Tutor {

    @Id
    @Column(name = "cpf", length = 14)
    private String cpf; // PK conforme solicitado

    @NotBlank
    @Column(name = "nome", nullable = false, length = 100)
    private String nome;

    @Column(name = "telefone", length = 20)
    private String telefone;

    @Email
    @Column(name = "email", length = 100)
    private String email;

    @Column(name = "qtd_pets")
    private Integer quantidadePets;
}
