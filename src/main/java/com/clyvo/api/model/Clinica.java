package com.clyvo.api.model;
import jakarta.persistence.*;
import lombok.*;
@Entity
@Table(name = "T_CLINICA")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Clinica {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String nomeCnpj;
    private String telefone;
    private Double latitude;
    private Double longitude;
    private String bairro;
    private String cidade;
    private String estado;
    @Column(name = "atendimento_24h")
    private Boolean atendimento24h;
}
