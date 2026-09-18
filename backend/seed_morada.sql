DO $$ 
DECLARE
    block_index INT;
    lot_index INT;
    block_name TEXT;
    lot_number TEXT;
    v_area NUMERIC;
    v_price NUMERIC;
    v_total INT := 0;
BEGIN
    DELETE FROM lots WHERE "landName" = 'Loteamento Morada do Sol';

    FOR block_index IN 1..15 LOOP
        block_name := 'Q' || LPAD(block_index::TEXT, 2, '0');
        
        FOR lot_index IN 1..13 LOOP
            IF block_index > 12 AND lot_index > 12 THEN
                CONTINUE;
            END IF;
            
            lot_number := LPAD(lot_index::TEXT, 2, '0');
            v_area := 300 + (random() * 100);
            v_price := v_area * 500;
            
            INSERT INTO lots (id, block, number, area, price, status, "landName", "createdAt", "updatedAt")
            VALUES (
                gen_random_uuid(),
                block_name,
                lot_number,
                ROUND(v_area, 2),
                ROUND(v_price, 2),
                'Disponível',
                'Loteamento Morada do Sol',
                NOW(),
                NOW()
            );
            
            v_total := v_total + 1;
        END LOOP;
    END LOOP;
    RAISE NOTICE 'Inseridos % lotes', v_total;
END $$;
