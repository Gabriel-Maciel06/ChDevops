package com.clyvo.api.model;
import jakarta.persistence.*;
import lombok.*;
@Entity
@Table(name = "T_MEDICO_ESPECIALISTA")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MedicoEspecialista {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String nome;
    private String especialidade;
}
