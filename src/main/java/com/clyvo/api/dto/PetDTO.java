package com.clyvo.api.dto;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import java.time.LocalDate;
@Data
public class PetDTO {
    @NotBlank(message = "O nome é obrigatório")
    private String nome;
    private LocalDate dataNascimento;
    private Double peso;
    private Long racaId;
    private String tutorCpf;
}
