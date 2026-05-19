package com.clyvo.api.service;

import com.clyvo.api.model.Pet;
import com.clyvo.api.repository.PetRepository;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;

import java.time.LocalDate;
import java.time.Period;

@Service
@RequiredArgsConstructor
public class PetService {

    private final PetRepository repository;

    @Cacheable("petInsights")
    public String calcularInsightIA(Pet pet) {
        int idade = Period.between(pet.getDataNascimento(), LocalDate.now()).getYears();
        String raca = pet.getRaca().getNome();

        // Lógica Preditiva Dinâmica
        String propensao = pet.getRaca().getPropensaoDoenca();
        String cuidados = pet.getRaca().getCuidadosEspeciais();
        
        if (idade > 7 && propensao != null && !propensao.isEmpty()) {
            return "Alerta de Idade: Risco de " + propensao + ". Recomendamos exames preventivos.";
        } else if (cuidados != null && !cuidados.isEmpty()) {
            return "Cuidado Específico da Raça (" + raca + "): " + cuidados;
        }
        
        return "Saúde estável. Continue com o plano de longevidade.";
    }
}
