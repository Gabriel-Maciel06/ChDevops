package com.clyvo.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import lombok.Data;
import java.time.LocalDate;

@Data
public class PetDTO {
    
    private Long id;

    @NotBlank(message = "O nome do pet é obrigatório")
    private String nome;

    @NotNull(message = "A data de nascimento é obrigatória")
    @PastOrPresent(message = "A data de nascimento não pode estar no futuro")
    private LocalDate dataNascimento;

    @NotNull(message = "O peso é obrigatório")
    private Double peso;

    @NotBlank(message = "O CPF do tutor é obrigatório")
    private String tutorCpf;

    private String statusLongevidade;
}
