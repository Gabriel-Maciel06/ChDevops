import os
from fpdf import FPDF

class EntregaPDF(FPDF):
    def header(self):
        self.set_font('Arial', 'B', 14)
        self.cell(0, 10, 'FIAP - DevOps Tools & Cloud Computing', 0, 1, 'C')
        self.set_font('Arial', 'I', 11)
        self.cell(0, 6, 'Entrega Oficial - 3ª Sprint (Challenge 2026)', 0, 1, 'C')
        self.ln(10)

def gerar_pdf():
    pdf = EntregaPDF()
    pdf.add_page()
    pdf.set_font('Arial', '', 11)
    
    # 1. Identificação dos Integrantes
    pdf.set_font('Arial', 'B', 12)
    pdf.cell(0, 8, 'Integrantes do Grupo:', 0, 1)
    pdf.set_font('Arial', '', 11)
    integrantes = [
        "- Vitoria Rodrigues Martins - RM565160",
        "- Augusto Bonomo Junior - RM565155",
        "- Thomas Fontes - RM562254",
        "- Gabriel Maciel - RM562795",
        "- Matheus Pereira Molina - RM563399"
    ]
    for i in integrantes:
        pdf.cell(0, 7, i, 0, 1)
        
    pdf.ln(8)
    
    # 2. Links de Entrega Obrigatórios
    pdf.set_font('Arial', 'B', 12)
    pdf.cell(0, 8, 'Links de Entrega:', 0, 1)
    pdf.set_font('Arial', '', 11)
    
    pdf.cell(0, 7, 'Link do Repositorio no GitHub:', 0, 1)
    pdf.set_font('Arial', 'U', 11)
    pdf.cell(0, 7, 'https://github.com/Gabriel-Maciel06/ChDevops', 0, 1)
    
    pdf.ln(4)
    pdf.set_font('Arial', '', 11)
    pdf.cell(0, 7, 'Link do Video Demonstrativo no YouTube:', 0, 1)
    pdf.set_font('Arial', 'U', 11)
    pdf.cell(0, 7, 'https://youtu.be/SEU_VIDEO_AQUI', 0, 1)
    
    # Salvar
    saida = 'Entrega_DevOps_Sprint3_FIAP.pdf'
    pdf.output(saida, 'F')
    print(f"PDF gerado com sucesso: {saida}")

if __name__ == '__main__':
    gerar_pdf()
