import sys
from fpdf import FPDF
import os

class PDF(FPDF):
    def header(self):
        self.set_font('Arial', 'B', 15)
        self.cell(0, 10, 'FIAP - Faculdade de Informatica e Administracao Paulista', 0, 1, 'C')
        self.ln(10)

def create_java_pdf(filepath):
    pdf = PDF()
    pdf.add_page()
    pdf.set_font('Arial', '', 12)
    
    content = [
        "Disciplina: Java Advanced",
        "Projeto: Clyvo Vet - API Preditiva de Longevidade Pet",
        "Sprint: 1o Challenge",
        "",
        "Integrantes do Grupo:",
        "- Vitoria Rodrigues Martins - RM565160",
        "- Augusto Bonomo Junior - RM565155",
        "- Thomas Fontes - RM562254",
        "- Gabriel Maciel - RM562795",
        "- Matheus Pereira Molina - RM563399",
        "",
        "--------------------------------------------------",
        "",
        "1. Repositorio Oficial do Codigo-Fonte",
        "O codigo-fonte da aplicacao encontra-se no link abaixo:",
        "Link do GitHub: https://github.com/Gabriel-Maciel06/CHJava",
        "",
        "2. Evidencias de Teste (CRUD e Persistencia)",
        "(COLE AQUI OS PRINTS DO POSTMAN MOSTRANDO OS TESTES DO CRUD)",
    ]
    
    for line in content:
        pdf.cell(0, 10, line, 0, 1)
        
    pdf.output(filepath, 'F')

def create_devops_pdf(filepath):
    pdf = PDF()
    pdf.add_page()
    pdf.set_font('Arial', '', 12)
    
    content = [
        "Disciplina: DevOps Tools & Cloud Computing",
        "Projeto: Clyvo Vet - Infraestrutura e Conteinerizacao Azure",
        "Sprint: 1o Challenge",
        "",
        "Integrantes do Grupo:",
        "- Vitoria Rodrigues Martins - RM565160",
        "- Augusto Bonomo Junior - RM565155",
        "- Thomas Fontes - RM562254",
        "- Gabriel Maciel - RM562795",
        "- Matheus Pereira Molina - RM563399",
        "",
        "Indice:",
        "1. Links do Projeto e Apresentacao",
        "2. Desenho da Arquitetura",
        "3. Evidencia de Remocao de Recursos na Nuvem",
        "",
        "--------------------------------------------------",
        "",
        "1. Links do Projeto e Apresentacao",
        "Link do GitHub (Infra/IaC): https://github.com/Gabriel-Maciel06/ChDevops",
        "Link do Video (YouTube): [COLE O LINK DO SEU VIDEO AQUI]",
        "",
        "2. Desenho da Arquitetura Macro",
        "(COLE AQUI O PRINT DO DIAGRAMA DA ARQUITETURA DO README)",
        "",
        "3. Evidencia de Remocao de Recursos na Nuvem",
        "(COLE AQUI O PRINT DA TELA MOSTRANDO A EXCLUSAO DA VM NA AZURE)",
    ]
    
    for line in content:
        pdf.cell(0, 10, line, 0, 1)
        
    pdf.output(filepath, 'F')

if __name__ == '__main__':
    desktop_path = os.path.expanduser('~/Desktop/CHALLANGE')
    create_java_pdf(os.path.join(desktop_path, 'Entrega_JavaAdvanced_Sprint1.pdf'))
    create_devops_pdf(os.path.join(desktop_path, 'Entrega_DevOps_Sprint1.pdf'))
    print("PDFs criados com sucesso na pasta CHALLANGE.")
