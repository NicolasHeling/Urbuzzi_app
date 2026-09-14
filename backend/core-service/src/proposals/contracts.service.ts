import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Proposal } from './proposal.entity';
import * as PDFDocument from 'pdfkit';

@Injectable()
export class ContractsService {
  constructor(
    @InjectRepository(Proposal)
    private readonly proposalRepository: Repository<Proposal>,
  ) {}

  async generateContract(proposalId: string): Promise<PDFKit.PDFDocument> {
    const proposal = await this.proposalRepository.findOne({
      where: { id: proposalId },
      relations: ['lot'],
    });

    if (!proposal) {
      throw new NotFoundException('Proposal not found');
    }

    const doc = new PDFDocument();
    
    doc.fontSize(20).text('Contrato de Compra e Venda', { align: 'center' });
    doc.moveDown();
    
    doc.fontSize(12).text(`Proposta ID: ${proposal.id}`);
    doc.text(`Cliente: ${proposal.customerName}`);
    doc.text(`Documento: ${proposal.customerDocument || 'N/A'}`);
    
    if (proposal.lot) {
      doc.text(`Lote ID: ${proposal.lot.id}`);
      doc.text(`Lote Bloco: ${proposal.lot.block || 'N/A'}, Lote Número: ${proposal.lot.number || 'N/A'}`);
    } else {
      doc.text(`Lote: N/A`);
    }
    
    doc.text(`Valor Oferecido: R$ ${proposal.offeredPrice}`);
    doc.text(`Data: ${new Date().toLocaleDateString()}`);
    
    doc.end();
    
    return doc;
  }
}
