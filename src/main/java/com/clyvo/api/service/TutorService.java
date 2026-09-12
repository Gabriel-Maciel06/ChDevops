package com.clyvo.api.service;

import com.clyvo.api.dto.TutorDTO;
import com.clyvo.api.exception.RecursoNaoEncontradoException;
import com.clyvo.api.model.Tutor;
import com.clyvo.api.repository.TutorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class TutorService {

    private final TutorRepository tutorRepository;

    @Transactional
    public TutorDTO salvar(TutorDTO dto) {
        Tutor tutor = new Tutor();
        tutor.setCpf(dto.getCpf());
        tutor.setNome(dto.getNome());
        tutor.setEmail(dto.getEmail());
        tutor.setTelefone(dto.getTelefone());
        tutor.setQuantidadePets(dto.getQuantidadePets());
        return mapToDTO(tutorRepository.save(tutor));
    }

    @Transactional(readOnly = true)
    public Page<TutorDTO> listarTodos(Pageable pageable) {
        return tutorRepository.findAll(pageable).map(this::mapToDTO);
    }

    @Transactional(readOnly = true)
    public TutorDTO buscarPorCpf(String cpf) {
        return tutorRepository.findById(cpf)
                .map(this::mapToDTO)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Tutor não encontrado com CPF: " + cpf));
    }

    @Transactional
    public TutorDTO atualizar(String cpf, TutorDTO dto) {
        Tutor tutor = tutorRepository.findById(cpf)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Tutor não encontrado com CPF: " + cpf));
        tutor.setNome(dto.getNome());
        tutor.setEmail(dto.getEmail());
        tutor.setTelefone(dto.getTelefone());
        tutor.setQuantidadePets(dto.getQuantidadePets());
        return mapToDTO(tutorRepository.save(tutor));
    }

    /** Exclui o tutor. Pets vinculados são removidos em cascata pelo banco (FK fk_pet_tutor ON DELETE CASCADE). */
    @Transactional
    public void deletar(String cpf) {
        if (!tutorRepository.existsById(cpf)) {
            throw new RecursoNaoEncontradoException("Tutor não encontrado com CPF: " + cpf);
        }
        tutorRepository.deleteById(cpf);
    }

    private TutorDTO mapToDTO(Tutor tutor) {
        TutorDTO dto = new TutorDTO();
        dto.setCpf(tutor.getCpf());
        dto.setNome(tutor.getNome());
        dto.setEmail(tutor.getEmail());
        dto.setTelefone(tutor.getTelefone());
        dto.setQuantidadePets(tutor.getQuantidadePets());
        return dto;
    }
}
