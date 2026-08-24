import { MigrationInterface, QueryRunner } from "typeorm";

export class AddLotMeasurements1787614139776 implements MigrationInterface {
    name = 'AddLotMeasurements1787614139776'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "lots" ADD "registration" character varying`);
        await queryRunner.query(`ALTER TABLE "lots" ADD "frontMeasure" numeric(10,2)`);
        await queryRunner.query(`ALTER TABLE "lots" ADD "backMeasure" numeric(10,2)`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "lots" DROP COLUMN "backMeasure"`);
        await queryRunner.query(`ALTER TABLE "lots" DROP COLUMN "frontMeasure"`);
        await queryRunner.query(`ALTER TABLE "lots" DROP COLUMN "registration"`);
    }

}
