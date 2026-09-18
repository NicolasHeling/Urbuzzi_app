-- ============================================================================
-- Seed: Loteamento Morada do Sol
-- Gera lotes com a distribuicao EXATA que o MapData estatico do Flutter espera.
--
-- Distribuicao por quadra (casar com urbuzzi_app/lib/features/home/presentation/map_data.dart):
--   Q01=16, Q02=14, Q03=12, Q04=10, Q05=16, Q06=14, Q07=12, Q08=10,
--   Q09=14, Q10=14, Q11=12, Q12=8,  Q13=14, Q14=14, Q15=12    Total: 192 lotes
-- ============================================================================

DO $$
DECLARE
    block_counts INT[] := ARRAY[16, 14, 12, 10, 16, 14, 12, 10, 14, 14, 12, 8, 14, 14, 12];
    block_index INT;
    lot_index INT;
    block_name TEXT;
    lot_number TEXT;
    lot_count INT;
    v_area NUMERIC;
    v_price NUMERIC;
    v_total INT := 0;
    v_status TEXT;
    v_rand NUMERIC;
    v_project_id UUID;
BEGIN
    -- 1. Garantir que o projeto "Loteamento Morada do Sol" existe
    SELECT id INTO v_project_id FROM projects WHERE name = 'Loteamento Morada do Sol';
    IF v_project_id IS NULL THEN
        v_project_id := gen_random_uuid();
        INSERT INTO projects (id, name, description, address, "createdAt", "updatedAt")
        VALUES (
            v_project_id,
            'Loteamento Morada do Sol',
            'Loteamento residencial com 15 quadras e 192 lotes em área nobre.',
            'Rodovia PR-182, Km 5 - Toledo/PR',
            NOW(),
            NOW()
        );
        RAISE NOTICE '[Seed] Projeto "Loteamento Morada do Sol" criado (id=%).',  v_project_id;
    ELSE
        RAISE NOTICE '[Seed] Projeto "Loteamento Morada do Sol" já existe (id=%).', v_project_id;
    END IF;

    -- 2. Limpar lotes antigos deste loteamento
    DELETE FROM lots WHERE "landName" = 'Loteamento Morada do Sol';

    -- 3. Inserir lotes com distribuicao exata por quadra
    FOR block_index IN 1..15 LOOP
        block_name := LPAD(block_index::TEXT, 2, '0');
        lot_count  := block_counts[block_index];

        FOR lot_index IN 1..lot_count LOOP
            lot_number := LPAD(lot_index::TEXT, 2, '0');

            -- Área entre 250m2 e 480m2 (variacao por posicao)
            v_area := 280 + (30 * (block_index % 4)) + (10 * (lot_index % 5));

            -- Preço por m2 entre R$450 e R$600 dependendo da quadra
            v_price := v_area * (480 + (block_index * 8));

            -- Distribuicao realista de status:
            v_rand := random();
            IF v_rand < 0.55 THEN
                v_status := 'Disponível';
            ELSIF v_rand < 0.70 THEN
                v_status := 'Reservado';
            ELSIF v_rand < 0.82 THEN
                v_status := 'Vendido';
            ELSIF v_rand < 0.90 THEN
                v_status := 'Em aprovação';
            ELSIF v_rand < 0.96 THEN
                v_status := 'Bloqueado';
            ELSE
                v_status := 'Cancelado';
            END IF;

            INSERT INTO lots (id, block, number, area, price, status, "landName", "createdAt", "updatedAt")
            VALUES (
                gen_random_uuid(),
                block_name,
                lot_number,
                ROUND(v_area, 2),
                ROUND(v_price, 2),
                v_status,
                'Loteamento Morada do Sol',
                NOW(),
                NOW()
            );

            v_total := v_total + 1;
        END LOOP;
    END LOOP;

    RAISE NOTICE '[Seed] Inseridos % lotes para "Loteamento Morada do Sol" com distribuicao exata do MapData.', v_total;
END $$;
