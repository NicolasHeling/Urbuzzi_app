import { MigrationInterface, QueryRunner } from "typeorm";

export class AddPerformanceIndexes1789000000000 implements MigrationInterface {
    name = 'AddPerformanceIndexes1789000000000'

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Indexes serão criados pela migration 1790000000000-CreateMissingTables
        // que garante que as tabelas existem antes de indexá-las.
        // Esta migration é mantida como no-op para não quebrar o histórico.
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // no-op
    }
}
