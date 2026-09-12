package com.clyvo.api.service;

import com.clyvo.api.dto.PetDTO;
import com.clyvo.api.exception.RecursoNaoEncontradoException;
import com.clyvo.api.model.Pet;
import com.clyvo.api.model.Raca;
import com.clyvo.api.model.Tutor;
import com.clyvo.api.repository.PetRepository;
import com.clyvo.api.repository.RacaRepository;
import com.clyvo.api.repository.TutorRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;

import java.time.LocalDate;
import java.time.Period;

@Service
@RequiredArgsConstructor
public class PetService {

    private final PetRepository repository;
    private final TutorRepository tutorRepository;
    private final RacaRepository racaRepository;

    /** Motor preditivo simplificado: cruza idade cronológica com a predisposição genética da raça. */
    public String calcularInsightIA(Pet pet) {
        int idade = Period.between(pet.getDataNascimento(), LocalDate.now()).getYears();
        String raca = (pet.getRaca() != null) ? pet.getRaca().getNome() : "Desconhecida";
        String propensao = (pet.getRaca() != null) ? pet.getRaca().getPropensaoDoenca() : null;
        String cuidados = (pet.getRaca() != null) ? pet.getRaca().getCuidadosEspeciais() : null;
        
        if (idade > 7 && propensao != null && !propensao.isEmpty()) {
            return "Alerta de Idade (" + idade + " anos): Risco de " + propensao + ". Recomendamos exames preventivos.";
        } else if (cuidados != null && !cuidados.isEmpty()) {
            return "Cuidado Específico da Raça (" + raca + "): " + cuidados;
        }
        return "Saúde estável. Continue com o plano de longevidade.";
    }

    @Transactional(readOnly = true)
    public Page<PetDTO> listarTodos(Pageable pageable) {
        return repository.findAll(pageable).map(this::mapToDTO);
    }

    @Transactional(readOnly = true)
    public PetDTO buscarPorId(Long id) {
        Pet pet = repository.findById(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Pet não encontrado com id " + id));
        PetDTO dto = mapToDTO(pet);
        // Se ainda não houver parecer persistido, gera o insight preditivo em tempo real
        if (dto.getStatusLongevidade() == null || dto.getStatusLongevidade().isBlank()) {
            dto.setStatusLongevidade(calcularInsightIA(pet));
        }
        return dto;
    }

    @Transactional
    public PetDTO salvar(PetDTO dto) {
        Pet pet = new Pet();
        aplicarDados(pet, dto);
        return mapToDTO(repository.save(pet));
    }

    @Transactional
    public PetDTO atualizar(Long id, PetDTO dto) {
        Pet pet = repository.findById(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Pet não encontrado com id " + id));
        aplicarDados(pet, dto);
        return mapToDTO(repository.save(pet));
    }

    @Transactional
    public void deletar(Long id) {
        if (!repository.existsById(id)) {
            throw new RecursoNaoEncontradoException("Pet não encontrado com id " + id);
        }
        repository.deleteById(id);
    }

    private void aplicarDados(Pet pet, PetDTO dto) {
        pet.setNome(dto.getNome());
        pet.setDataNascimento(dto.getDataNascimento());
        pet.setPeso(dto.getPeso());
        pet.setStatusLongevidade(dto.getStatusLongevidade());

        Tutor tutor = tutorRepository.findById(dto.getTutorCpf())
                .orElseThrow(() -> new RecursoNaoEncontradoException("Tutor não encontrado com o CPF informado: " + dto.getTutorCpf()));
        pet.setTutor(tutor);

        if (dto.getRacaId() != null) {
            Raca raca = racaRepository.findById(dto.getRacaId())
                    .orElseThrow(() -> new RecursoNaoEncontradoException("Raça não encontrada com id " + dto.getRacaId()));
            pet.setRaca(raca);
        } else {
            pet.setRaca(null);
        }
    }

    private PetDTO mapToDTO(Pet pet) {
        PetDTO dto = new PetDTO();
        dto.setId(pet.getId());
        dto.setNome(pet.getNome());
        dto.setDataNascimento(pet.getDataNascimento());
        dto.setPeso(pet.getPeso());
        dto.setStatusLongevidade(pet.getStatusLongevidade());
        if (pet.getTutor() != null) {
            dto.setTutorCpf(pet.getTutor().getCpf());
        }
        if (pet.getRaca() != null) {
            dto.setRacaId(pet.getRaca().getId());
            dto.setRacaNome(pet.getRaca().getNome());
        }
        return dto;
    }
}
