-- ============================================================
--  BASE DE DATOS DE PRACTICA: Tienda en Linea "TechMex"
--  Para usar con DBeaver + PostgreSQL
--  Cubre: SELECT, WHERE, JOIN, GROUP BY, CTEs, Window Functions
-- ============================================================
-- INSTRUCCIONES:
--   1. Abre DBeaver
--   2. Conectate a tu PostgreSQL
--   3. Abre un nuevo SQL Script (Ctrl+])
--   4. Pega TODO este archivo
--   5. Selecciona todo (Ctrl+A) y ejecuta (Alt+X o el boton de Play)
-- ============================================================


-- ------------------------------------------------------------
-- 0. CREAR Y USAR UN SCHEMA LIMPIO
-- ------------------------------------------------------------
DROP SCHEMA IF EXISTS techmex CASCADE;
CREATE SCHEMA techmex;
SET search_path TO techmex;


-- ============================================================
-- TABLAS
-- ============================================================

-- ------------------------------------------------------------
-- 1. REGIONES (tabla de referencia pequeña)
-- ------------------------------------------------------------
CREATE TABLE regiones (
    region_id   SERIAL PRIMARY KEY,
    nombre      VARCHAR(60)  NOT NULL,
    pais        VARCHAR(60)  NOT NULL DEFAULT 'Mexico'
);

-- ------------------------------------------------------------
-- 2. CATEGORIAS de productos
-- ------------------------------------------------------------
CREATE TABLE categorias (
    categoria_id  SERIAL PRIMARY KEY,
    nombre        VARCHAR(80)  NOT NULL,
    descripcion   TEXT
);

-- ------------------------------------------------------------
-- 3. CLIENTES
-- ------------------------------------------------------------
CREATE TABLE clientes (
    cliente_id    SERIAL PRIMARY KEY,
    nombre        VARCHAR(120) NOT NULL,
    email         VARCHAR(150) NOT NULL,
    telefono      VARCHAR(20),
    ciudad        VARCHAR(80),
    region_id     INTEGER REFERENCES regiones(region_id),
    segmento      VARCHAR(30)  CHECK (segmento IN ('PREMIUM','REGULAR','NUEVO')),
    activo        BOOLEAN      NOT NULL DEFAULT TRUE,
    fecha_registro DATE         NOT NULL
);

-- ------------------------------------------------------------
-- 4. EMPLEADOS (con auto-referencia para el manager)
-- ------------------------------------------------------------
CREATE TABLE empleados (
    empleado_id   SERIAL PRIMARY KEY,
    nombre        VARCHAR(120) NOT NULL,
    puesto        VARCHAR(80),
    departamento  VARCHAR(60),
    salario       NUMERIC(10,2),
    manager_id    INTEGER REFERENCES empleados(empleado_id),  -- SELF JOIN
    fecha_ingreso DATE
);

-- ------------------------------------------------------------
-- 5. PRODUCTOS
-- ------------------------------------------------------------
CREATE TABLE productos (
    producto_id   SERIAL PRIMARY KEY,
    nombre        VARCHAR(150) NOT NULL,
    categoria_id  INTEGER REFERENCES categorias(categoria_id),
    precio        NUMERIC(10,2) NOT NULL,
    costo         NUMERIC(10,2),
    stock         INTEGER       NOT NULL DEFAULT 0,
    activo        BOOLEAN       NOT NULL DEFAULT TRUE
);

-- ------------------------------------------------------------
-- 6. PEDIDOS
-- ------------------------------------------------------------
CREATE TABLE pedidos (
    pedido_id     SERIAL PRIMARY KEY,
    cliente_id    INTEGER REFERENCES clientes(cliente_id),
    empleado_id   INTEGER REFERENCES empleados(empleado_id),  -- vendedor
    fecha         DATE          NOT NULL,
    estado        VARCHAR(30)   CHECK (estado IN ('ENTREGADO','PENDIENTE','ENVIADO','CANCELADO')),
    ciudad_envio  VARCHAR(80),
    notas         TEXT
);

-- ------------------------------------------------------------
-- 7. DETALLE DE PEDIDO (tabla puente)
-- ------------------------------------------------------------
CREATE TABLE detalle_pedido (
    detalle_id    SERIAL PRIMARY KEY,
    pedido_id     INTEGER REFERENCES pedidos(pedido_id),
    producto_id   INTEGER REFERENCES productos(producto_id),
    cantidad      INTEGER        NOT NULL CHECK (cantidad > 0),
    precio_unit   NUMERIC(10,2)  NOT NULL,
    descuento_pct NUMERIC(5,2)   DEFAULT 0
);

-- ------------------------------------------------------------
-- 8. TABLA CON CLIENTES "FANTASMA" para practicar huerfanos
--    (simula registros sin cliente valido en pedidos)
-- ------------------------------------------------------------
CREATE TABLE clientes_externos (
    ext_id        SERIAL PRIMARY KEY,
    nombre        VARCHAR(120),
    plataforma    VARCHAR(60)    -- 'Amazon', 'MercadoLibre', etc.
);


-- ============================================================
-- DATOS
-- ============================================================

-- REGIONES
INSERT INTO regiones (nombre, pais) VALUES
('CDMX',            'Mexico'),
('Guadalajara',     'Mexico'),
('Monterrey',       'Mexico'),
('Puebla',          'Mexico'),
('Cancun',          'Mexico'),
('Tijuana',         'Mexico'),
('Merida',          'Mexico');

-- CATEGORIAS
INSERT INTO categorias (nombre, descripcion) VALUES
('Laptops',         'Computadoras portatiles de todas las marcas'),
('Accesorios',      'Teclados, mouses, hubs y perifericos'),
('Monitores',       'Pantallas de 24 a 32 pulgadas'),
('Audio',           'Audifonos, bocinas y micrófonos'),
('Almacenamiento',  'Discos duros SSD y USB');

-- Truco para SERIAL con valores especificos:
TRUNCATE empleados RESTART IDENTITY CASCADE;
INSERT INTO empleados (nombre, puesto, departamento, salario, manager_id, fecha_ingreso) VALUES
('Carlos Mendoza',    'Director General',      'Direccion',   95000, NULL,       '2018-01-10'),
('Sofia Reyes',       'Gerente de Ventas',     'Ventas',      62000, 1,          '2019-03-15'),
('Luis Herrera',      'Gerente de Logistica',  'Logistica',   58000, 1,          '2019-06-01'),
('Ana Garcia',        'Vendedor Senior',       'Ventas',      42000, 2,          '2020-02-20'),
('Pedro Castillo',    'Vendedor Senior',       'Ventas',      40000, 2,          '2020-05-10'),
('Maria Torres',      'Vendedor Junior',       'Ventas',      28000, 4,          '2021-09-01'),
('Diego Morales',     'Vendedor Junior',       'Ventas',      27000, 4,          '2021-11-15'),
('Elena Fuentes',     'Operador Logistica',    'Logistica',   25000, 3,          '2022-01-10'),
('Roberto Cruz',      'Operador Logistica',    'Logistica',   24000, 3,          '2022-03-20');

-- CLIENTES (30 clientes: algunos con muchos pedidos, uno sin pedidos para LEFT JOIN)
INSERT INTO clientes (nombre, email, telefono, ciudad, region_id, segmento, activo, fecha_registro) VALUES
('Maria Garcia',        'maria.garcia@email.com',      '5551001001', 'CDMX',         1, 'PREMIUM',  TRUE,  '2022-01-15'),
('Juan Lopez',          'juan.lopez@email.com',        '3311002002', 'Guadalajara',  2, 'REGULAR',  TRUE,  '2022-02-20'),
('Ana Torres',          'ana.torres@email.com',        '8181003003', 'Monterrey',    3, 'PREMIUM',  TRUE,  '2022-03-10'),
('Pedro Ruiz',          'pedro.ruiz@email.com',        '2221004004', 'Puebla',       4, 'NUEVO',    TRUE,  '2022-04-05'),
('Luisa Mendez',        'luisa.mendez@email.com',      '9981005005', 'Cancun',       5, 'REGULAR',  TRUE,  '2022-05-12'),
('Carlos Jimenez',      'carlos.jimenez@email.com',    '6641006006', 'Tijuana',      6, 'PREMIUM',  TRUE,  '2022-06-18'),
('Sofia Vargas',        'sofia.vargas@email.com',      '9991007007', 'Merida',       7, 'REGULAR',  TRUE,  '2022-07-22'),
('Diego Morales',       'diego.morales@email.com',     '5551008008', 'CDMX',         1, 'NUEVO',    TRUE,  '2022-08-30'),
('Elena Castro',        'elena.castro@email.com',      '3311009009', 'Guadalajara',  2, 'PREMIUM',  TRUE,  '2022-09-14'),
('Roberto Reyes',       'roberto.reyes@email.com',     '8181010010', 'Monterrey',    3, 'REGULAR',  FALSE, '2022-10-01'),
('Patricia Flores',     'patricia.flores@email.com',   '2221011011', 'Puebla',       4, 'PREMIUM',  TRUE,  '2022-11-08'),
('Miguel Ramirez',      'miguel.ramirez@email.com',    '5551012012', 'CDMX',         1, 'REGULAR',  TRUE,  '2022-12-20'),
('Laura Herrera',       'laura.herrera@email.com',     '3311013013', 'Guadalajara',  2, 'NUEVO',    TRUE,  '2023-01-05'),
('Fernando Cruz',       'fernando.cruz@email.com',     '8181014014', 'Monterrey',    3, 'PREMIUM',  TRUE,  '2023-02-14'),
('Isabel Ortega',       'isabel.ortega@email.com',     '2221015015', 'Puebla',       4, 'REGULAR',  TRUE,  '2023-03-22'),
('Alejandro Munoz',     'alejandro.munoz@email.com',   '9981016016', 'Cancun',       5, 'NUEVO',    TRUE,  '2023-04-10'),
('Valentina Soto',      'valentina.soto@email.com',    '6641017017', 'Tijuana',      6, 'PREMIUM',  TRUE,  '2023-05-18'),
('Santiago Perez',      'santiago.perez@email.com',    '9991018018', 'Merida',       7, 'REGULAR',  FALSE, '2023-06-25'),
('Camila Rojas',        'camila.rojas@email.com',      '5551019019', 'CDMX',         1, 'NUEVO',    TRUE,  '2023-07-03'),
('Andres Vega',         'andres.vega@email.com',       '3311020020', 'Guadalajara',  2, 'PREMIUM',  TRUE,  '2023-08-11'),
('Natalia Rios',        'natalia.rios@email.com',      '8181021021', 'Monterrey',    3, 'REGULAR',  TRUE,  '2023-09-19'),
('Emilio Salinas',      'emilio.salinas@email.com',    '2221022022', 'Puebla',       4, 'NUEVO',    TRUE,  '2023-10-27'),
('Daniela Campos',      'daniela.campos@email.com',    '9981023023', 'Cancun',       5, 'PREMIUM',  TRUE,  '2023-11-04'),
('Hector Luna',         'hector.luna@email.com',       '6641024024', 'Tijuana',      6, 'REGULAR',  TRUE,  '2023-12-12'),
('Adriana Nunez',       'adriana.nunez@email.com',     '9991025025', 'Merida',       7, 'NUEVO',    TRUE,  '2024-01-20'),
('Pablo Guerrero',      'pablo.guerrero@email.com',    '5551026026', 'CDMX',         1, 'PREMIUM',  TRUE,  '2024-02-28'),
('Gabriela Medina',     'gabriela.medina@email.com',   '3311027027', 'Guadalajara',  2, 'REGULAR',  TRUE,  '2024-03-08'),
('Ricardo Espinoza',    'ricardo.espinoza@email.com',  '8181028028', 'Monterrey',    3, 'NUEVO',    TRUE,  '2024-04-16'),
-- Este cliente NO tendra pedidos -- perfecto para practicar LEFT JOIN
('Beatriz Alvarado',    'beatriz.alvarado@email.com',  '2221029029', 'Puebla',       4, 'NUEVO',    TRUE,  '2024-05-01'),
-- Este tampoco -- practicar huerfanos
('Jorge Sandoval',      'jorge.sandoval@email.com',    '9981030030', 'Cancun',       5, 'NUEVO',    TRUE,  '2024-06-10');

-- PRODUCTOS
INSERT INTO productos (nombre, categoria_id, precio, costo, stock, activo) VALUES
('Laptop Dell XPS 13',         1, 22999.00, 16000.00, 15,  TRUE),
('Laptop HP Pavilion 15',      1, 14999.00, 10000.00, 20,  TRUE),
('Laptop Lenovo IdeaPad',      1, 11500.00,  8000.00, 25,  TRUE),
('Laptop MacBook Air M2',      1, 32999.00, 24000.00,  8,  TRUE),
('Laptop Asus VivoBook',       1, 12800.00,  8800.00, 18,  TRUE),
('Mouse Logitech MX Master',   2,  1299.00,   700.00, 60,  TRUE),
('Mouse Inalambrico HP',       2,   399.00,   200.00, 80,  TRUE),
('Teclado Mecanico Corsair',   2,  1899.00,  1100.00, 40,  TRUE),
('Teclado Membrana Genius',    2,   349.00,   180.00, 70,  TRUE),
('Hub USB-C 7 Puertos',        2,   899.00,   500.00, 35,  TRUE),
('Monitor LG 27" 4K',          3,  8999.00,  6000.00, 10,  TRUE),
('Monitor Dell 24" Full HD',   3,  5499.00,  3500.00, 14,  TRUE),
('Monitor Samsung 32" Curvo',  3, 11500.00,  7800.00,  6,  TRUE),
('Audifonos Sony WH-1000XM5',  4,  5999.00,  3800.00, 22,  TRUE),
('Audifonos JBL Tune 770NC',   4,  2499.00,  1500.00, 30,  TRUE),
('Bocina Bose SoundLink',      4,  3299.00,  2000.00, 18,  TRUE),
('Microfono Blue Yeti',        4,  2899.00,  1800.00, 12,  TRUE),
('SSD Samsung 1TB',            5,  1699.00,  1000.00, 45,  TRUE),
('SSD Kingston 500GB',         5,   899.00,   500.00, 55,  TRUE),
('USB Kingston 128GB',         5,   299.00,   140.00, 90,  TRUE),
-- Producto descontinuado (activo=FALSE) para practicar filtros
('Laptop Acer Viejo Modelo',   1,  6500.00,  4000.00,  0,  FALSE);

-- PEDIDOS (50 pedidos entre 2023 y 2024)
INSERT INTO pedidos (cliente_id, empleado_id, fecha, estado, ciudad_envio) VALUES
-- Maria Garcia (cliente 1) - cliente premium con muchos pedidos
( 1, 4, '2023-01-15', 'ENTREGADO', 'CDMX'),
( 1, 4, '2023-04-22', 'ENTREGADO', 'CDMX'),
( 1, 5, '2023-08-10', 'ENTREGADO', 'CDMX'),
( 1, 4, '2024-01-20', 'ENTREGADO', 'CDMX'),
( 1, 4, '2024-05-05', 'PENDIENTE', 'CDMX'),
-- Juan Lopez (cliente 2)
( 2, 5, '2023-02-10', 'ENTREGADO', 'Guadalajara'),
( 2, 6, '2023-09-18', 'ENTREGADO', 'Guadalajara'),
( 2, 5, '2024-03-07', 'ENVIADO',   'Guadalajara'),
-- Ana Torres (cliente 3)
( 3, 4, '2023-03-05', 'ENTREGADO', 'Monterrey'),
( 3, 4, '2023-11-12', 'ENTREGADO', 'Monterrey'),
( 3, 5, '2024-02-28', 'ENTREGADO', 'Monterrey'),
-- Pedro Ruiz (cliente 4)
( 4, 7, '2023-04-20', 'ENTREGADO', 'Puebla'),
( 4, 7, '2024-04-14', 'CANCELADO', 'Puebla'),
-- Luisa Mendez (cliente 5)
( 5, 6, '2023-05-30', 'ENTREGADO', 'Cancun'),
-- Carlos Jimenez (cliente 6) - PREMIUM
( 6, 4, '2023-02-28', 'ENTREGADO', 'Tijuana'),
( 6, 4, '2023-06-15', 'ENTREGADO', 'Tijuana'),
( 6, 5, '2023-12-01', 'ENTREGADO', 'Tijuana'),
( 6, 4, '2024-03-20', 'ENVIADO',   'Tijuana'),
-- Sofia Vargas (cliente 7)
( 7, 6, '2023-07-10', 'ENTREGADO', 'Merida'),
( 7, 7, '2024-01-08', 'ENTREGADO', 'Merida'),
-- Diego Morales (cliente 8)
( 8, 7, '2023-08-22', 'ENTREGADO', 'CDMX'),
-- Elena Castro (cliente 9) - PREMIUM
( 9, 5, '2023-03-18', 'ENTREGADO', 'Guadalajara'),
( 9, 5, '2023-09-05', 'ENTREGADO', 'Guadalajara'),
( 9, 4, '2024-04-01', 'PENDIENTE', 'Guadalajara'),
-- Roberto Reyes (cliente 10) - inactivo pero con historial
(10, 6, '2023-01-30', 'ENTREGADO', 'Monterrey'),
-- Patricia Flores (cliente 11)
(11, 4, '2023-06-12', 'ENTREGADO', 'Puebla'),
(11, 5, '2023-12-20', 'ENTREGADO', 'Puebla'),
-- Miguel Ramirez (cliente 12)
(12, 7, '2023-07-25', 'ENTREGADO', 'CDMX'),
(12, 6, '2024-02-10', 'CANCELADO', 'CDMX'),
-- Laura Herrera (cliente 13) - NUEVO
(13, 7, '2024-01-15', 'ENTREGADO', 'Guadalajara'),
-- Fernando Cruz (cliente 14) - PREMIUM
(14, 4, '2023-04-08', 'ENTREGADO', 'Monterrey'),
(14, 4, '2023-10-14', 'ENTREGADO', 'Monterrey'),
(14, 5, '2024-05-10', 'ENVIADO',   'Monterrey'),
-- Isabel Ortega (cliente 15)
(15, 6, '2023-08-05', 'ENTREGADO', 'Puebla'),
-- Alejandro Munoz (cliente 16)
(16, 7, '2023-09-28', 'ENTREGADO', 'Cancun'),
-- Valentina Soto (cliente 17) - PREMIUM
(17, 4, '2023-05-22', 'ENTREGADO', 'Tijuana'),
(17, 5, '2023-11-30', 'ENTREGADO', 'Tijuana'),
(17, 4, '2024-04-18', 'PENDIENTE', 'Tijuana'),
-- Santiago Perez (cliente 18) - inactivo
(18, 6, '2023-02-14', 'ENTREGADO', 'Merida'),
-- Camila Rojas (cliente 19)
(19, 7, '2023-10-07', 'ENTREGADO', 'CDMX'),
(19, 7, '2024-03-15', 'ENVIADO',   'CDMX'),
-- Andres Vega (cliente 20) - PREMIUM
(20, 4, '2023-06-30', 'ENTREGADO', 'Guadalajara'),
(20, 5, '2024-01-25', 'ENTREGADO', 'Guadalajara'),
-- Natalia Rios (cliente 21)
(21, 6, '2023-11-18', 'ENTREGADO', 'Monterrey'),
-- Emilio Salinas (cliente 22)
(22, 7, '2023-12-08', 'ENTREGADO', 'Puebla'),
-- Daniela Campos (cliente 23)
(23, 5, '2024-02-20', 'ENTREGADO', 'Cancun'),
-- Hector Luna (cliente 24)
(24, 6, '2024-03-02', 'ENTREGADO', 'Tijuana'),
-- Adriana Nunez (cliente 25)
(25, 7, '2024-04-25', 'PENDIENTE', 'Merida'),
-- Pablo Guerrero (cliente 26)
(26, 4, '2024-05-01', 'ENVIADO',   'CDMX');
-- OJO: clientes 27-30 NO tienen pedidos --> perfectos para LEFT JOIN

-- DETALLE DE PEDIDO (cada pedido tiene 1 o 2 productos)
INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unit, descuento_pct) VALUES
-- Pedido 1 (Maria, laptop + mouse)
(1,  1, 1, 22999.00, 0),
(1,  6, 1,  1299.00, 5),
-- Pedido 2 (Maria, teclado + hub)
(2,  8, 1,  1899.00, 0),
(2, 10, 1,   899.00, 0),
-- Pedido 3 (Maria, monitor)
(3, 12, 1,  5499.00, 10),
-- Pedido 4 (Maria, laptop)
(4,  4, 1, 32999.00, 0),
-- Pedido 5 (Maria, audifonos + SSD)
(5, 14, 1,  5999.00, 0),
(5, 18, 1,  1699.00, 5),
-- Pedido 6 (Juan, laptop)
(6,  2, 1, 14999.00, 0),
-- Pedido 7 (Juan, accesorios)
(7,  7, 1,   399.00, 0),
(7,  9, 1,   349.00, 0),
-- Pedido 8 (Juan, SSD)
(8, 19, 2,   899.00, 0),
-- Pedido 9 (Ana, monitor grande)
(9, 13, 1, 11500.00, 0),
-- Pedido 10 (Ana, audifonos)
(10, 14, 1, 5999.00, 5),
-- Pedido 11 (Ana, laptop)
(11,  3, 1, 11500.00, 0),
-- Pedido 12 (Pedro, accesorios baratos)
(12,  9, 1,   349.00, 0),
(12, 20, 2,   299.00, 0),
-- Pedido 13 (Pedro, cancelado)
(13,  7, 1,   399.00, 0),
-- Pedido 14 (Luisa, bocina)
(14, 16, 1,  3299.00, 0),
-- Pedido 15 (Carlos, laptop premium)
(15,  1, 1, 22999.00, 0),
-- Pedido 16 (Carlos, monitor + mouse)
(16, 11, 1,  8999.00, 10),
(16,  6, 1,  1299.00,  5),
-- Pedido 17 (Carlos, laptop mac)
(17,  4, 1, 32999.00,  5),
-- Pedido 18 (Carlos, enviado)
(18, 14, 1,  5999.00,  0),
-- Pedido 19 (Sofia, teclado)
(19,  8, 1,  1899.00,  0),
-- Pedido 20 (Sofia, laptop)
(20,  3, 1, 11500.00,  0),
-- Pedido 21 (Diego, accesorio)
(21, 10, 1,   899.00,  0),
-- Pedido 22 (Elena, laptop)
(22,  5, 1, 12800.00,  0),
-- Pedido 23 (Elena, monitor)
(23, 12, 1,  5499.00,  0),
-- Pedido 24 (Elena, pendiente)
(24,  1, 1, 22999.00,  0),
-- Pedido 25 (Roberto inactivo)
(25,  6, 1,  1299.00,  0),
-- Pedido 26 (Patricia, audifonos)
(26, 15, 1,  2499.00,  0),
-- Pedido 27 (Patricia, laptop)
(27,  2, 1, 14999.00,  0),
-- Pedido 28 (Miguel, SSD)
(28, 18, 1,  1699.00,  0),
-- Pedido 29 (Miguel, cancelado)
(29,  7, 2,   399.00,  0),
-- Pedido 30 (Laura)
(30,  9, 1,   349.00,  0),
(30, 20, 3,   299.00,  0),
-- Pedido 31 (Fernando, laptop)
(31,  1, 1, 22999.00,  0),
-- Pedido 32 (Fernando, monitor)
(32, 13, 1, 11500.00,  5),
-- Pedido 33 (Fernando, enviado)
(33,  4, 1, 32999.00,  0),
-- Pedido 34 (Isabel)
(34,  8, 1,  1899.00,  0),
-- Pedido 35 (Alejandro)
(35, 16, 1,  3299.00,  0),
-- Pedido 36 (Valentina, laptop)
(36,  4, 1, 32999.00,  0),
-- Pedido 37 (Valentina, monitor)
(37, 11, 1,  8999.00,  0),
-- Pedido 38 (Valentina, pendiente)
(38, 14, 1,  5999.00,  0),
-- Pedido 39 (Santiago)
(39, 17, 1,  2899.00,  0),
-- Pedido 40 (Camila)
(40,  3, 1, 11500.00,  0),
-- Pedido 41 (Camila, enviado)
(41,  8, 1,  1899.00,  0),
-- Pedido 42 (Andres, laptop)
(42,  1, 1, 22999.00,  5),
-- Pedido 43 (Andres)
(43,  6, 1,  1299.00,  0),
-- Pedido 44 (Natalia)
(44, 15, 1,  2499.00,  0),
-- Pedido 45 (Emilio)
(45, 19, 2,   899.00,  0),
-- Pedido 46 (Daniela)
(46, 16, 1,  3299.00,  0),
-- Pedido 47 (Hector)
(47, 18, 1,  1699.00,  0),
(47, 20, 2,   299.00,  0),
-- Pedido 48 (Adriana, pendiente)
(48, 15, 1,  2499.00,  0),
-- Pedido 49 (Pablo)
(49,  2, 1, 14999.00,  0);

-- CLIENTES EXTERNOS (para el ejercicio de INTERSECT/EXCEPT)
INSERT INTO clientes_externos (nombre, plataforma) VALUES
('Maria Garcia',    'MercadoLibre'),
('Juan Lopez',      'Amazon'),
('Nuevo Cliente X', 'Amazon'),
('Ana Torres',      'MercadoLibre'),
('Cliente Externo', 'Shopify');


-- ============================================================
-- VISTAS UTILES (opcionales, pero practicas)
-- ============================================================

-- Vista que ya trae el monto total de cada pedido calculado
CREATE VIEW v_pedidos_con_total AS
SELECT
    p.pedido_id,
    p.cliente_id,
    p.empleado_id,
    p.fecha,
    p.estado,
    p.ciudad_envio,
    SUM(dp.cantidad * dp.precio_unit * (1 - dp.descuento_pct / 100.0)) AS monto_total
FROM pedidos p
JOIN detalle_pedido dp ON p.pedido_id = dp.pedido_id
GROUP BY p.pedido_id, p.cliente_id, p.empleado_id, p.fecha, p.estado, p.ciudad_envio;


-- ============================================================
-- CONFIRMACION
-- ============================================================
SELECT '✅ Base de datos TechMex creada correctamente!' AS resultado;

SELECT
    'regiones'        AS tabla, COUNT(*) AS filas FROM techmex.regiones       UNION ALL
SELECT 'categorias',            COUNT(*) FROM techmex.categorias    UNION ALL
SELECT 'clientes',              COUNT(*) FROM techmex.clientes       UNION ALL
SELECT 'empleados',             COUNT(*) FROM techmex.empleados      UNION ALL
SELECT 'productos',             COUNT(*) FROM techmex.productos      UNION ALL
SELECT 'pedidos',               COUNT(*) FROM techmex.pedidos        UNION ALL
SELECT 'detalle_pedido',        COUNT(*) FROM techmex.detalle_pedido UNION ALL
SELECT 'clientes_externos',     COUNT(*) FROM techmex.clientes_externos;
