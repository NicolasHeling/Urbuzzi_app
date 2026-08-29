import { MigrationInterface, QueryRunner } from "typeorm";

export class AddWhatsappNumberToLots1788234000000 implements MigrationInterface {
    name = 'AddWhatsappNumberToLots1788234000000'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "lots" ADD "whatsappNumber" character varying`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "lots" DROP COLUMN "whatsappNumber"`);
    }

}
