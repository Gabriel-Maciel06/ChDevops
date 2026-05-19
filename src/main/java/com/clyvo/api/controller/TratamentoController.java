package com.clyvo.api.controller;
import com.clyvo.api.model.Tratamento;
import com.clyvo.api.repository.TratamentoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import java.net.URI;
@RestController
@RequiredArgsConstructor @RequestMapping("/api/tratamentos")
public class TratamentoController {
    private final TratamentoRepository repository;
    @PostMapping public ResponseEntity<Tratamento> salvar(@RequestBody Tratamento t) { return ResponseEntity.ok(repository.save(t)); }
    
    @PutMapping("/{id}")
    public ResponseEntity<Tratamento> atualizar(@PathVariable Long id, @RequestBody Tratamento t) {
        if(!repository.existsById(id)) return ResponseEntity.notFound().build();
        t.setId(id);
        return ResponseEntity.ok(repository.save(t));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        if(!repository.existsById(id)) return ResponseEntity.notFound().build();
        repository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
