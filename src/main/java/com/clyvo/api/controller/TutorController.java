package com.clyvo.api.controller;

import com.clyvo.api.dto.TutorDTO;
import com.clyvo.api.model.Pet;
import com.clyvo.api.repository.PetRepository;
import com.clyvo.api.service.TutorService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/api/tutores")
@RequiredArgsConstructor
public class TutorController {

    private final TutorService tutorService;
    private final PetRepository petRepository;

    @GetMapping
    public ResponseEntity<Page<TutorDTO>> listarTodos(Pageable pageable) {
        return ResponseEntity.ok(tutorService.listarTodos(pageable));
    }

    @GetMapping("/{cpf}")
    public ResponseEntity<TutorDTO> buscarPerfil(@PathVariable String cpf) {
        return ResponseEntity.ok(tutorService.buscarPorCpf(cpf));
    }

    @GetMapping("/{cpf}/pets")
    public ResponseEntity<List<Pet>> listarPetsDoTutor(@PathVariable String cpf) {
        List<Pet> pets = petRepository.findByTutorCpf(cpf);
        return ResponseEntity.ok(pets);
    }

    @PostMapping
    public ResponseEntity<TutorDTO> salvar(@Valid @RequestBody TutorDTO dto) {
        TutorDTO salvo = tutorService.salvar(dto);
        URI uri = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{cpf}")
                .buildAndExpand(salvo.getCpf())
                .toUri();
        return ResponseEntity.created(uri).body(salvo);
    }

    @PutMapping("/{cpf}")
    public ResponseEntity<TutorDTO> atualizar(@PathVariable String cpf, @Valid @RequestBody TutorDTO dto) {
        return ResponseEntity.ok(tutorService.atualizar(cpf, dto));
    }

    @DeleteMapping("/{cpf}")
    public ResponseEntity<Void> deletar(@PathVariable String cpf) {
        tutorService.deletar(cpf);
        return ResponseEntity.noContent().build();
    }
}
