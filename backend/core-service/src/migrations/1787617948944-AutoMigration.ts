import { MigrationInterface, QueryRunner } from "typeorm";

export class AutoMigration1787617948944 implements MigrationInterface {
    name = 'AutoMigration1787617948944'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "lots" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "block" character varying NOT NULL, "number" character varying NOT NULL, "area" numeric(10,2) NOT NULL, "price" numeric(12,2) NOT NULL, "status" character varying NOT NULL DEFAULT 'Disponível', "registration" character varying, "frontMeasure" numeric(10,2), "backMeasure" numeric(10,2), "svgCoordinates" character varying, "landName" character varying, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_2bb990a4015865cb1daa1d22fd9" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "proposals" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "customerName" character varying NOT NULL, "customerDocument" character varying NOT NULL, "status" character varying NOT NULL DEFAULT 'Nova', "offeredPrice" numeric(12,2), "responsibleUserName" character varying, "slaDeadline" TIMESTAMP, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), "lot_id" uuid, CONSTRAINT "PK_db524c8db8e126a38a2f16d8cac" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "audits" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "action" character varying NOT NULL, "entityName" character varying NOT NULL, "entityId" character varying NOT NULL, "userId" character varying, "details" jsonb, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_b2d7a2089999197dc7024820f28" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "clients" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "name" character varying NOT NULL, "cpfOrCnpj" character varying NOT NULL, "email" character varying NOT NULL, "phone" character varying NOT NULL, "address" character varying, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "UQ_4553aff90abae45ca93b7f3bab3" UNIQUE ("cpfOrCnpj"), CONSTRAINT "UQ_b48860677afe62cd96e12659482" UNIQUE ("email"), CONSTRAINT "PK_f1ab7cf3a5714dbc6bb4e1c28a4" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "reservations" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "expiresAt" TIMESTAMP NOT NULL, "status" character varying NOT NULL DEFAULT 'PENDING', "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), "clientId" uuid, "lotId" uuid, CONSTRAINT "PK_da95cef71b617ac35dc5bcda243" PRIMARY KEY ("id"))`);
        await queryRunner.query(`ALTER TABLE "proposals" ADD CONSTRAINT "FK_4454d34c991e4bc9f7ab09e6c23" FOREIGN KEY ("lot_id") REFERENCES "lots"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "reservations" ADD CONSTRAINT "FK_e31637a1b37f007468858cd3855" FOREIGN KEY ("clientId") REFERENCES "clients"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "reservations" ADD CONSTRAINT "FK_0cfbef9ed754bca0ad8ac948c09" FOREIGN KEY ("lotId") REFERENCES "lots"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "reservations" DROP CONSTRAINT "FK_0cfbef9ed754bca0ad8ac948c09"`);
        await queryRunner.query(`ALTER TABLE "reservations" DROP CONSTRAINT "FK_e31637a1b37f007468858cd3855"`);
        await queryRunner.query(`ALTER TABLE "proposals" DROP CONSTRAINT "FK_4454d34c991e4bc9f7ab09e6c23"`);
        await queryRunner.query(`DROP TABLE "reservations"`);
        await queryRunner.query(`DROP TABLE "clients"`);
        await queryRunner.query(`DROP TABLE "audits"`);
        await queryRunner.query(`DROP TABLE "proposals"`);
        await queryRunner.query(`DROP TABLE "lots"`);
    }

}
