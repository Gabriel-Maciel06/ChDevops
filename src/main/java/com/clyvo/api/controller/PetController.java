package com.clyvo.api.controller;

import com.clyvo.api.dto.PetDTO;
import com.clyvo.api.service.PetService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.hateoas.EntityModel;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

@RestController
@RequestMapping("/api/pets")
@RequiredArgsConstructor
public class PetController {

    private final PetService service;

    @GetMapping
    public ResponseEntity<Page<PetDTO>> listar(@PageableDefault(size = 5) Pageable paginacao) {
        return ResponseEntity.ok(service.listarTodos(paginacao));
    }

    @PostMapping
    public ResponseEntity<PetDTO> salvar(@RequestBody @Valid PetDTO dto) {
        PetDTO salvo = service.salvar(dto);
        URI uri = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(salvo.getId())
                .toUri();
                
        return ResponseEntity.created(uri).body(salvo);
    }

    @GetMapping("/{id}")
    public EntityModel<PetDTO> buscarPorId(@PathVariable Long id) {
        PetDTO dto = service.buscarPorId(id);

        return EntityModel.of(dto,
                linkTo(methodOn(PetController.class).buscarPorId(id)).withSelfRel(),
                linkTo(methodOn(PetController.class).listar(null)).withRel("lista-pets"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<PetDTO> atualizar(@PathVariable Long id, @RequestBody @Valid PetDTO dto) {
        return ResponseEntity.ok(service.atualizar(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        service.deletar(id);
        return ResponseEntity.noContent().build();
    }
}
