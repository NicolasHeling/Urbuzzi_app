import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { v4 as uuidv4 } from 'uuid';
import * as path from 'path';

@Injectable()
export class StorageService {
  private readonly s3Client: S3Client;
  private readonly bucketName = process.env.S3_BUCKET_NAME || 'urbuzzi-bucket';

  constructor() {
    this.s3Client = new S3Client({
      region: process.env.S3_REGION || 'auto', // 'auto' para Cloudflare R2
      endpoint: process.env.S3_ENDPOINT, // URL do Cloudflare R2 ou AWS
      credentials: {
        accessKeyId: process.env.S3_ACCESS_KEY || '',
        secretAccessKey: process.env.S3_SECRET_KEY || '',
      },
    });
  }

  async uploadFile(file: Express.Multer.File): Promise<string> {
    const fileExtension = path.extname(file.originalname);
    const fileName = `${uuidv4()}${fileExtension}`;

    try {
      await this.s3Client.send(
        new PutObjectCommand({
          Bucket: this.bucketName,
          Key: fileName,
          Body: file.buffer,
          ContentType: file.mimetype,
          // ACL: 'public-read', // Descomente se o bucket permitir ACL público
        }),
      );

      // Retorna a URL pública (ajuste conforme seu domínio público do S3/R2)
      const publicUrl = process.env.S3_PUBLIC_URL || `https://${this.bucketName}.s3.amazonaws.com`;
      return `${publicUrl}/${fileName}`;
    } catch (error) {
      console.error('Erro no upload:', error);
      throw new InternalServerErrorException('Falha ao fazer upload do arquivo');
    }
  }
}
