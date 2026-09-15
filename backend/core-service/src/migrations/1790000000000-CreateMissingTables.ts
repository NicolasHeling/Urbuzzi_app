import { MigrationInterface, QueryRunner } from "typeorm";

export class CreateMissingTables1790000000000 implements MigrationInterface {
    name = 'CreateMissingTables1790000000000'

    public async up(queryRunner: QueryRunner): Promise<void> {
        // ─── 1. Novas tabelas ──────────────────────────────────────────────

        // Projects
        await queryRunner.query(`
            CREATE TABLE IF NOT EXISTS "projects" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "name" character varying NOT NULL,
                "description" character varying,
                "svgMap" character varying,
                "address" character varying,
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_projects" PRIMARY KEY ("id")
            )
        `);

        // Kanban Columns
        await queryRunner.query(`
            CREATE TABLE IF NOT EXISTS "kanban_columns" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "name" character varying NOT NULL,
                "order" integer NOT NULL DEFAULT 0,
                "color" character varying NOT NULL DEFAULT '#C2650A',
                "projectId" character varying,
                "isFinal" boolean NOT NULL DEFAULT false,
                "isCancellation" boolean NOT NULL DEFAULT false,
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_kanban_columns" PRIMARY KEY ("id")
            )
        `);

        // Pipeline Stages
        await queryRunner.query(`
            CREATE TABLE IF NOT EXISTS "pipeline_stages" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "name" character varying NOT NULL,
                "order" integer NOT NULL DEFAULT 0,
                "color" character varying NOT NULL DEFAULT '#C2650A',
                "projectId" character varying,
                "isActive" boolean NOT NULL DEFAULT true,
                "isFinal" boolean NOT NULL DEFAULT false,
                "isCancellation" boolean NOT NULL DEFAULT false,
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_pipeline_stages" PRIMARY KEY ("id")
            )
        `);

        // Tasks
        await queryRunner.query(`
            CREATE TABLE IF NOT EXISTS "tasks" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "title" character varying NOT NULL,
                "date" date NOT NULL,
                "time" time NOT NULL,
                "status" character varying NOT NULL DEFAULT 'Pendente',
                "clientId" character varying NOT NULL,
                "userId" character varying,
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_tasks" PRIMARY KEY ("id")
            )
        `);

        // Visit Schedules
        await queryRunner.query(`
            CREATE TABLE IF NOT EXISTS "visit_schedules" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "customerName" character varying NOT NULL,
                "date" TIMESTAMP NOT NULL,
                "responsibleUserName" character varying,
                "lot_id" uuid,
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_visit_schedules" PRIMARY KEY ("id")
            )
        `);

        // Proposal History
        await queryRunner.query(`
            CREATE TABLE IF NOT EXISTS "proposal_history" (
                "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
                "proposal_id" uuid NOT NULL,
                "oldColumnId" character varying,
                "oldColumnName" character varying,
                "newColumnId" character varying,
                "newColumnName" character varying,
                "responsibleUserName" character varying,
                "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_proposal_history" PRIMARY KEY ("id")
            )
        `);

        // ─── 2. Colunas faltando em tabelas existentes ─────────────────────

        // lots.projectId
        await queryRunner.query(`
            ALTER TABLE "lots" ADD COLUMN IF NOT EXISTS "projectId" character varying
        `);

        // lots.documents
        await queryRunner.query(`
            ALTER TABLE "lots" ADD COLUMN IF NOT EXISTS "documents" jsonb
        `);

        // proposals.projectId
        await queryRunner.query(`
            ALTER TABLE "proposals" ADD COLUMN IF NOT EXISTS "projectId" character varying
        `);

        // proposals.kanban_column_id
        await queryRunner.query(`
            ALTER TABLE "proposals" ADD COLUMN IF NOT EXISTS "kanban_column_id" uuid
        `);

        // ─── 3. Foreign Keys ───────────────────────────────────────────────

        // visit_schedules -> lots
        await queryRunner.query(`
            ALTER TABLE "visit_schedules" 
            ADD CONSTRAINT "FK_visit_schedules_lot" 
            FOREIGN KEY ("lot_id") REFERENCES "lots"("id") ON DELETE SET NULL
        `);

        // proposal_history -> proposals
        await queryRunner.query(`
            ALTER TABLE "proposal_history" 
            ADD CONSTRAINT "FK_proposal_history_proposal" 
            FOREIGN KEY ("proposal_id") REFERENCES "proposals"("id") ON DELETE CASCADE
        `);

        // proposals -> kanban_columns
        await queryRunner.query(`
            ALTER TABLE "proposals" 
            ADD CONSTRAINT "FK_proposals_kanban_column" 
            FOREIGN KEY ("kanban_column_id") REFERENCES "kanban_columns"("id") ON DELETE SET NULL
        `);

        // ─── 4. Indexes ───────────────────────────────────────────────────

        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_tasks_date_time" ON "tasks" ("date", "time")`);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_tasks_clientId" ON "tasks" ("clientId")`);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_tasks_status" ON "tasks" ("status")`);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_tasks_userId" ON "tasks" ("userId")`);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_visits_date" ON "visit_schedules" ("date")`);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_visits_customerName" ON "visit_schedules" ("customerName")`);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_visits_lotId" ON "visit_schedules" ("lot_id")`);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_lots_status" ON "lots" ("status")`);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_lots_projectId" ON "lots" ("projectId")`);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_lots_block_number" ON "lots" ("block", "number")`);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_proposals_status" ON "proposals" ("status")`);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_proposals_createdAt" ON "proposals" ("createdAt")`);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_proposals_projectId" ON "proposals" ("projectId")`);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_proposals_slaDeadline" ON "proposals" ("slaDeadline")`);
        await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_proposals_lotId" ON "proposals" ("lot_id")`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Drop FKs
        await queryRunner.query(`ALTER TABLE "proposals" DROP CONSTRAINT IF EXISTS "FK_proposals_kanban_column"`);
        await queryRunner.query(`ALTER TABLE "proposal_history" DROP CONSTRAINT IF EXISTS "FK_proposal_history_proposal"`);
        await queryRunner.query(`ALTER TABLE "visit_schedules" DROP CONSTRAINT IF EXISTS "FK_visit_schedules_lot"`);

        // Drop added columns
        await queryRunner.query(`ALTER TABLE "proposals" DROP COLUMN IF EXISTS "kanban_column_id"`);
        await queryRunner.query(`ALTER TABLE "proposals" DROP COLUMN IF EXISTS "projectId"`);
        await queryRunner.query(`ALTER TABLE "lots" DROP COLUMN IF EXISTS "documents"`);
        await queryRunner.query(`ALTER TABLE "lots" DROP COLUMN IF EXISTS "projectId"`);

        // Drop tables
        await queryRunner.query(`DROP TABLE IF EXISTS "proposal_history"`);
        await queryRunner.query(`DROP TABLE IF EXISTS "visit_schedules"`);
        await queryRunner.query(`DROP TABLE IF EXISTS "tasks"`);
        await queryRunner.query(`DROP TABLE IF EXISTS "pipeline_stages"`);
        await queryRunner.query(`DROP TABLE IF EXISTS "kanban_columns"`);
        await queryRunner.query(`DROP TABLE IF EXISTS "projects"`);
    }
}
