package com.clyvo.api.service;

import com.clyvo.api.dto.TutorDTO;
import com.clyvo.api.model.Tutor;
import com.clyvo.api.repository.TutorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class TutorService {

    private final TutorRepository tutorRepository;

    public TutorDTO salvar(TutorDTO dto) {
        Tutor tutor = new Tutor();
        tutor.setCpf(dto.getCpf());
        tutor.setNome(dto.getNome());
        tutor.setEmail(dto.getEmail());
        tutor.setTelefone(dto.getTelefone());
        tutor.setQuantidadePets(dto.getQuantidadePets());
        
        Tutor salvo = tutorRepository.save(tutor);
        return mapToDTO(salvo);
    }

    public Page<TutorDTO> listarTodos(Pageable pageable) {
        return tutorRepository.findAll(pageable).map(this::mapToDTO);
    }

    public TutorDTO buscarPorCpf(String cpf) {
        return tutorRepository.findById(cpf)
                .map(this::mapToDTO)
                .orElseThrow(() -> new RuntimeException("Tutor não encontrado com CPF: " + cpf));
    }

    public TutorDTO atualizar(String cpf, TutorDTO dto) {
        Tutor tutor = tutorRepository.findById(cpf)
                .orElseThrow(() -> new RuntimeException("Tutor não encontrado com CPF: " + cpf));
                
        tutor.setNome(dto.getNome());
        tutor.setEmail(dto.getEmail());
        tutor.setTelefone(dto.getTelefone());
        tutor.setQuantidadePets(dto.getQuantidadePets());
        
        Tutor salvo = tutorRepository.save(tutor);
        return mapToDTO(salvo);
    }

    public void deletar(String cpf) {
        if (!tutorRepository.existsById(cpf)) {
            throw new RuntimeException("Tutor não encontrado com CPF: " + cpf);
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
