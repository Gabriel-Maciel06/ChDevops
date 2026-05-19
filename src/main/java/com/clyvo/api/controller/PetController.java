package com.clyvo.api.controller;

import com.clyvo.api.exception.RecursoNaoEncontradoException;
import com.clyvo.api.model.Pet;
import com.clyvo.api.repository.PetRepository;
import com.clyvo.api.service.PetService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.server.mvc.WebMvcLinkBuilder;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import java.net.URI;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

import com.clyvo.api.dto.PetDTO;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/pets")
@RequiredArgsConstructor
public class PetController {

    private final PetRepository repository;
    private final PetService service;

    @GetMapping
    public ResponseEntity<Page<Pet>> listar(@PageableDefault(size = 5) Pageable paginacao) {
        return ResponseEntity.ok(repository.findAll(paginacao));
    }

    @PostMapping
    public ResponseEntity<Pet> salvar(@RequestBody @Valid PetDTO dto) {
        Pet pet = Pet.builder()
                .nome(dto.getNome())
                .dataNascimento(dto.getDataNascimento())
                .peso(dto.getPeso())
                .build();
        
        Pet salvo = repository.save(pet);
        URI uri = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(salvo.getId())
                .toUri();
                
        return ResponseEntity.created(uri).body(salvo);
    }

    @GetMapping("/{id}")
    public EntityModel<Pet> buscarPorId(@PathVariable Long id) {
        Pet pet = repository.findById(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Pet não encontrado"));

        pet.setStatusLongevidade(service.calcularInsightIA(pet));

        return EntityModel.of(pet,
                linkTo(methodOn(PetController.class).buscarPorId(id)).withSelfRel(),
                linkTo(methodOn(PetController.class).listar(null)).withRel("lista-pets"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Pet> atualizar(@PathVariable Long id, @RequestBody @Valid PetDTO dto) {
        Pet pet = repository.findById(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Pet não encontrado"));
        
        pet.setNome(dto.getNome());
        pet.setDataNascimento(dto.getDataNascimento());
        pet.setPeso(dto.getPeso());
        
        return ResponseEntity.ok(repository.save(pet));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        repository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
