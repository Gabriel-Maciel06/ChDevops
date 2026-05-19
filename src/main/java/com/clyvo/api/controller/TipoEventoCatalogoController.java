package com.clyvo.api.controller;

import com.clyvo.api.model.TipoEventoCatalogo;
import com.clyvo.api.repository.TipoEventoCatalogoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import java.net.URI;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/tipos-evento")
public class TipoEventoCatalogoController {

    private final TipoEventoCatalogoRepository repository;

    @GetMapping
    public ResponseEntity<Page<TipoEventoCatalogo>> listar(Pageable p) {
        return ResponseEntity.ok(repository.findAll(p));
    }

    @PostMapping
    public ResponseEntity<TipoEventoCatalogo> salvar(@RequestBody TipoEventoCatalogo tipo) {
        return ResponseEntity.status(201).body(repository.save(tipo));
    }
}
