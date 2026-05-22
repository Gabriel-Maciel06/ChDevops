package com.clyvo.api.service;

import com.clyvo.api.dto.PetDTO;
import com.clyvo.api.exception.RecursoNaoEncontradoException;
import com.clyvo.api.model.Pet;
import com.clyvo.api.model.Tutor;
import com.clyvo.api.repository.PetRepository;
import com.clyvo.api.repository.TutorRepository;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;

import java.time.LocalDate;
import java.time.Period;

@Service
@RequiredArgsConstructor
public class PetService {

    private final PetRepository repository;
    private final TutorRepository tutorRepository;

    @Cacheable("petInsights")
    public String calcularInsightIA(Pet pet) {
        int idade = Period.between(pet.getDataNascimento(), LocalDate.now()).getYears();
        String raca = (pet.getRaca() != null) ? pet.getRaca().getNome() : "Desconhecida";

        // Lógica Preditiva Dinâmica
        String propensao = (pet.getRaca() != null) ? pet.getRaca().getPropensaoDoenca() : null;
        String cuidados = (pet.getRaca() != null) ? pet.getRaca().getCuidadosEspeciais() : null;
        
        if (idade > 7 && propensao != null && !propensao.isEmpty()) {
            return "Alerta de Idade: Risco de " + propensao + ". Recomendamos exames preventivos.";
        } else if (cuidados != null && !cuidados.isEmpty()) {
            return "Cuidado Específico da Raça (" + raca + "): " + cuidados;
        }
        
        return "Saúde estável. Continue com o plano de longevidade.";
    }

    public Page<PetDTO> listarTodos(Pageable pageable) {
        return repository.findAll(pageable).map(this::mapToDTO);
    }

    public PetDTO buscarPorId(Long id) {
        Pet pet = repository.findById(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Pet não encontrado com id " + id));
        
        PetDTO dto = mapToDTO(pet);
        // Garantindo que a IA rode e povoe o status
        dto.setStatusLongevidade(calcularInsightIA(pet));
        return dto;
    }

    public PetDTO salvar(PetDTO dto) {
        Pet pet = new Pet();
        pet.setNome(dto.getNome());
        pet.setDataNascimento(dto.getDataNascimento());
        pet.setPeso(dto.getPeso());
        
        Tutor tutor = tutorRepository.findById(dto.getTutorCpf())
                .orElseThrow(() -> new RecursoNaoEncontradoException("Tutor não encontrado com o CPF informado: " + dto.getTutorCpf()));
        pet.setTutor(tutor);
        
        Pet salvo = repository.save(pet);
        return mapToDTO(salvo);
    }

    public PetDTO atualizar(Long id, PetDTO dto) {
        Pet pet = repository.findById(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Pet não encontrado com id " + id));
        
        pet.setNome(dto.getNome());
        pet.setDataNascimento(dto.getDataNascimento());
        pet.setPeso(dto.getPeso());
        
        // Atualiza tutor se mudou
        if (!pet.getTutor().getCpf().equals(dto.getTutorCpf())) {
            Tutor tutor = tutorRepository.findById(dto.getTutorCpf())
                    .orElseThrow(() -> new RecursoNaoEncontradoException("Tutor não encontrado com CPF: " + dto.getTutorCpf()));
            pet.setTutor(tutor);
        }
        
        Pet salvo = repository.save(pet);
        return mapToDTO(salvo);
    }

    public void deletar(Long id) {
        if (!repository.existsById(id)) {
            throw new RecursoNaoEncontradoException("Pet não encontrado com id " + id);
        }
        repository.deleteById(id);
    }

    private PetDTO mapToDTO(Pet pet) {
        PetDTO dto = new PetDTO();
        dto.setId(pet.getId());
        dto.setNome(pet.getNome());
        dto.setDataNascimento(pet.getDataNascimento());
        dto.setPeso(pet.getPeso());
        if (pet.getTutor() != null) {
            dto.setTutorCpf(pet.getTutor().getCpf());
        }
        return dto;
    }
}
