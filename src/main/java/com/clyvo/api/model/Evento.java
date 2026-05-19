package com.clyvo.api.model;
import jakarta.persistence.*;
import lombok.*;
@Entity
@Table(name = "T_EVENTO")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Evento {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String tipo;
    @ManyToOne @JoinColumn(name = "id_pet")
    private Pet pet;
    @ManyToOne @JoinColumn(name = "id_tutor")
    private Tutor tutor;
    @ManyToOne @JoinColumn(name = "id_medico_especialista")
    private MedicoEspecialista medico;
    @ManyToOne @JoinColumn(name = "id_clinica")
    private Clinica clinica;
}
