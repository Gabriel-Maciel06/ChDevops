package com.clyvo.api.controller;
import com.clyvo.api.model.MedicoEspecialista;
import com.clyvo.api.repository.MedicoEspecialistaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import java.net.URI;
@RestController
@RequiredArgsConstructor @RequestMapping("/api/especialistas")
public class MedicoEspecialistaController {
    private final MedicoEspecialistaRepository repository;
    @GetMapping public ResponseEntity<Page<MedicoEspecialista>> listar(Pageable p) { return ResponseEntity.ok(repository.findAll(p)); }
    @PostMapping public ResponseEntity<MedicoEspecialista> salvar(@RequestBody MedicoEspecialista m) { return ResponseEntity.ok(repository.save(m)); }
    
    @PutMapping("/{id}")
    public ResponseEntity<MedicoEspecialista> atualizar(@PathVariable Long id, @RequestBody MedicoEspecialista m) {
        if(!repository.existsById(id)) return ResponseEntity.notFound().build();
        m.setId(id);
        return ResponseEntity.ok(repository.save(m));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        if(!repository.existsById(id)) return ResponseEntity.notFound().build();
        repository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
