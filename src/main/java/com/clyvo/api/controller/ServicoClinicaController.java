package com.clyvo.api.controller;

import com.clyvo.api.model.ServicoClinica;
import com.clyvo.api.repository.ServicoClinicaRepository;
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
@RequestMapping("/api/servicos-clinica")
public class ServicoClinicaController {

    private final ServicoClinicaRepository repository;

    @GetMapping
    public ResponseEntity<Page<ServicoClinica>> listar(Pageable p) {
        return ResponseEntity.ok(repository.findAll(p));
    }

    @PostMapping
    public ResponseEntity<ServicoClinica> salvar(@RequestBody ServicoClinica servico) {
        return ResponseEntity.status(201).body(repository.save(servico));
    }
}
