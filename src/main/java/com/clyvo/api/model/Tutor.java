package com.clyvo.api.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Entity
@Table(name = "T_TUTOR")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Tutor {

    @Id
    private String cpf; // PK conforme solicitado

    @NotBlank
    private String nome;

    private String telefone;

    @Email
    private String email;

    private Integer quantidadePets;
}
