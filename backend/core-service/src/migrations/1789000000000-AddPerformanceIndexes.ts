import { MigrationInterface, QueryRunner } from "typeorm";

export class AddPerformanceIndexes1789000000000 implements MigrationInterface {
    name = 'AddPerformanceIndexes1789000000000'

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Proposals - index on lot_id
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_proposals_lotId" ON "proposals" ("lot_id") `);
        
        // Visit Schedule - index on customerName and lot_id
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_visits_customerName" ON "visit_schedules" ("customerName") `);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_visits_lotId" ON "visit_schedules" ("lot_id") `);
        
        // Tasks - index on userId
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_tasks_userId" ON "tasks" ("userId") `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP INDEX IF EXISTS "IDX_tasks_userId"`);
        await queryRunner.query(`DROP INDEX IF EXISTS "IDX_visits_lotId"`);
        await queryRunner.query(`DROP INDEX IF EXISTS "IDX_visits_customerName"`);
        await queryRunner.query(`DROP INDEX IF EXISTS "IDX_proposals_lotId"`);
    }
}
