import { MigrationInterface, QueryRunner, Table } from "typeorm";

export class CreateCommissionsTable1789000000001 implements MigrationInterface {
    name = 'CreateCommissionsTable1789000000001'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.createTable(new Table({
            name: "commissions",
            columns: [
                {
                    name: "id",
                    type: "uuid",
                    isPrimary: true,
                    isGenerated: true,
                    generationStrategy: "uuid"
                },
                {
                    name: "brokerId",
                    type: "varchar"
                },
                {
                    name: "proposalId",
                    type: "uuid"
                },
                {
                    name: "saleValue",
                    type: "decimal",
                    precision: 12,
                    scale: 2
                },
                {
                    name: "commissionValue",
                    type: "decimal",
                    precision: 12,
                    scale: 2
                },
                {
                    name: "status",
                    type: "varchar",
                    default: "'PENDING'"
                },
                {
                    name: "createdAt",
                    type: "timestamp",
                    default: "now()"
                },
                {
                    name: "updatedAt",
                    type: "timestamp",
                    default: "now()"
                }
            ]
        }), true);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.dropTable("commissions");
    }
}
