-- Mocks de Lotes
INSERT INTO lots (id, block, number, area, price, status, "createdAt", "updatedAt") VALUES
('11111111-1111-1111-1111-111111111111', 'A', '1', 360.50, 120000.00, 'Disponível', NOW(), NOW()),
('22222222-2222-2222-2222-222222222222', 'A', '2', 365.00, 122000.00, 'Reservado', NOW(), NOW()),
('33333333-3333-3333-3333-333333333333', 'B', '10', 400.00, 150000.00, 'Vendido', NOW(), NOW()),
('44444444-4444-4444-4444-444444444444', 'C', '5', 300.00, 95000.00, 'Disponível', NOW(), NOW());

-- Mocks de Propostas (Relacionados aos lotes acima)
INSERT INTO proposals (id, "customerName", "customerDocument", status, "offeredPrice", lot_id, "createdAt", "updatedAt") VALUES
('55555555-5555-5555-5555-555555555555', 'João Silva', '123.456.789-00', 'Nova', 115000.00, '11111111-1111-1111-1111-111111111111', NOW(), NOW()),
('66666666-6666-6666-6666-666666666666', 'Maria Oliveira', '987.654.321-99', 'Em Análise', 122000.00, '22222222-2222-2222-2222-222222222222', NOW(), NOW()),
('77777777-7777-7777-7777-777777777777', 'Empresa XYZ LTDA', '00.111.222/0001-33', 'Aprovada', 150000.00, '33333333-3333-3333-3333-333333333333', NOW(), NOW()),
('88888888-8888-8888-8888-888888888888', 'Carlos Santos', '456.789.123-11', 'Rejeitada', 80000.00, '44444444-4444-4444-4444-444444444444', NOW(), NOW());
