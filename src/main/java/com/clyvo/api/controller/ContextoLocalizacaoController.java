package com.clyvo.api.controller;

import com.clyvo.api.model.ContextoLocalizacao;
import com.clyvo.api.repository.ContextoLocalizacaoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import java.net.URI;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/contexto-localizacao")
public class ContextoLocalizacaoController {

    private final ContextoLocalizacaoRepository repository;

    @PostMapping
    public ResponseEntity<ContextoLocalizacao> registrarLocalizacao(@RequestBody ContextoLocalizacao localizacao) {
        return ResponseEntity.status(201).body(repository.save(localizacao));
    }
}
