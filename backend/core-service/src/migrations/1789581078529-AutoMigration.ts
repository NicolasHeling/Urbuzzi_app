import { MigrationInterface, QueryRunner } from "typeorm";

export class AutoMigration1789581078529 implements MigrationInterface {
    name = 'AutoMigration1789581078529'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "proposals" ADD "rejectionReason" text`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "proposals" DROP COLUMN "rejectionReason"`);
    }

}
