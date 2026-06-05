-- ============================================================
--  EJERCICIOS DE PRACTICA - TechMex
--  Usa esto junto con la guia de estudio
--  Cada ejercicio tiene su solucion abajo (intenta resolverlo
--  solo ANTES de ver la solucion!)
-- ============================================================

SET search_path TO techmex;


-- ============================================================
-- BLOQUE 1: SELECT, WHERE, ORDER BY (Lecciones 2 y 3 de la guia)
-- ============================================================

-- EJERCICIO 1.1
-- Muestra el nombre, ciudad y segmento de todos los clientes PREMIUM
-- (intenta resolverlo antes de ver la solucion)

-- SOLUCION 1.1:
SELECT nombre, ciudad, segmento
FROM clientes
WHERE segmento = 'PREMIUM'
ORDER BY nombre;


-- EJERCICIO 1.2
-- Muestra los 5 productos mas caros (nombre y precio)

-- SOLUCION 1.2:
SELECT nombre, precio
FROM productos
WHERE activo = TRUE
ORDER BY precio DESC
LIMIT 5;


-- EJERCICIO 1.3
-- Muestra los pedidos del 2024 que NO esten cancelados

-- SOLUCION 1.3:
SELECT pedido_id, cliente_id, fecha, estado
FROM pedidos
WHERE fecha >= '2024-01-01'
  AND estado <> 'CANCELADO'
ORDER BY fecha;


-- EJERCICIO 1.4
-- Clientes de CDMX o Monterrey que esten activos

-- SOLUCION 1.4:
SELECT nombre, ciudad, email
FROM clientes
WHERE ciudad IN ('CDMX', 'Monterrey')
  AND activo = TRUE
ORDER BY ciudad, nombre;


-- ============================================================
-- BLOQUE 2: GROUP BY y HAVING (Leccion 4)
-- ============================================================

-- EJERCICIO 2.1
-- Cuantos clientes hay por segmento?

-- SOLUCION 2.1:
SELECT
    segmento,
    COUNT(*) AS total_clientes
FROM clientes
GROUP BY segmento
ORDER BY total_clientes DESC;


-- EJERCICIO 2.2
-- Cuantos pedidos tiene cada estado? (ENTREGADO, PENDIENTE, etc.)

-- SOLUCION 2.2:
SELECT
    estado,
    COUNT(*) AS cantidad
FROM pedidos
GROUP BY estado
ORDER BY cantidad DESC;


-- EJERCICIO 2.3
-- Ciudades con MAS de 3 clientes activos

-- SOLUCION 2.3:
SELECT
    ciudad,
    COUNT(*) AS total
FROM clientes
WHERE activo = TRUE
GROUP BY ciudad
HAVING COUNT(*) > 3
ORDER BY total DESC;


-- EJERCICIO 2.4
-- Empleados del departamento de Ventas con salario promedio por puesto

-- SOLUCION 2.4:
SELECT
    puesto,
    COUNT(*)          AS num_empleados,
    AVG(salario)      AS salario_promedio,
    MIN(salario)      AS salario_minimo,
    MAX(salario)      AS salario_maximo
FROM empleados
WHERE departamento = 'Ventas'
GROUP BY puesto
ORDER BY salario_promedio DESC;


-- ============================================================
-- BLOQUE 3: INNER JOIN (Leccion 5)
-- ============================================================

-- EJERCICIO 3.1
-- Muestra cada pedido con el NOMBRE del cliente (no solo el ID)
-- Columnas: pedido_id, nombre_cliente, fecha, estado

-- SOLUCION 3.1:
SELECT
    p.pedido_id,
    c.nombre    AS nombre_cliente,
    p.fecha,
    p.estado
FROM pedidos AS p
INNER JOIN clientes AS c ON p.cliente_id = c.cliente_id
ORDER BY p.fecha DESC;


-- EJERCICIO 3.2
-- Detalle de pedidos: pedido_id, cliente, nombre del producto, cantidad, precio

-- SOLUCION 3.2:
SELECT
    p.pedido_id,
    c.nombre        AS cliente,
    pr.nombre       AS producto,
    dp.cantidad,
    dp.precio_unit,
    dp.cantidad * dp.precio_unit AS subtotal
FROM detalle_pedido AS dp
JOIN pedidos        AS p  ON dp.pedido_id   = p.pedido_id
JOIN clientes       AS c  ON p.cliente_id   = c.cliente_id
JOIN productos      AS pr ON dp.producto_id = pr.producto_id
ORDER BY p.pedido_id;


-- EJERCICIO 3.3
-- Total gastado por cada cliente (nombre + suma de sus pedidos)
-- Solo pedidos ENTREGADOS

-- SOLUCION 3.3:
SELECT
    c.nombre,
    c.segmento,
    COUNT(DISTINCT p.pedido_id)                    AS num_pedidos,
    SUM(dp.cantidad * dp.precio_unit)              AS total_gastado
FROM clientes       AS c
JOIN pedidos        AS p  ON c.cliente_id   = p.cliente_id
JOIN detalle_pedido AS dp ON p.pedido_id    = dp.pedido_id
WHERE p.estado = 'ENTREGADO'
GROUP BY c.cliente_id, c.nombre, c.segmento
ORDER BY total_gastado DESC;


-- EJERCICIO 3.4 (SELF JOIN)
-- Muestra cada empleado con el nombre de su jefe directo

-- SOLUCION 3.4:
SELECT
    e.nombre        AS empleado,
    e.puesto,
    m.nombre        AS jefe_directo
FROM empleados AS e
LEFT JOIN empleados AS m ON e.manager_id = m.empleado_id
ORDER BY m.nombre NULLS FIRST, e.nombre;


-- ============================================================
-- BLOQUE 4: LEFT JOIN y huerfanos (Leccion 6 - LO MAS IMPORTANTE)
-- ============================================================

-- EJERCICIO 4.1
-- Muestra TODOS los clientes con cuantos pedidos tienen
-- Los que no tienen pedidos deben mostrar 0 (no desaparecer)

-- SOLUCION 4.1:
SELECT
    c.cliente_id,
    c.nombre,
    c.segmento,
    c.ciudad,
    COUNT(p.pedido_id)           AS num_pedidos,
    COALESCE(SUM(
        dp.cantidad * dp.precio_unit
    ), 0)                        AS total_gastado
FROM clientes       AS c
LEFT JOIN pedidos        AS p  ON c.cliente_id  = p.cliente_id
LEFT JOIN detalle_pedido AS dp ON p.pedido_id   = dp.pedido_id
GROUP BY c.cliente_id, c.nombre, c.segmento, c.ciudad
ORDER BY total_gastado DESC;


-- EJERCICIO 4.2
-- Clientes que NUNCA han hecho un pedido
-- (esto es exactamente lo que preguntan en entrevistas!)

-- SOLUCION 4.2:
SELECT
    c.cliente_id,
    c.nombre,
    c.email,
    c.ciudad,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN pedidos AS p ON c.cliente_id = p.cliente_id
WHERE p.pedido_id IS NULL   -- <-- la clave: NULL = no tiene pareja
ORDER BY c.fecha_registro;


-- EJERCICIO 4.3
-- Productos que NUNCA han sido vendidos
-- (mismo patron, diferente tabla)

-- SOLUCION 4.3:
SELECT
    pr.producto_id,
    pr.nombre,
    pr.precio,
    pr.stock
FROM productos AS pr
LEFT JOIN detalle_pedido AS dp ON pr.producto_id = dp.producto_id
WHERE dp.detalle_id IS NULL
  AND pr.activo = TRUE;


-- EJERCICIO 4.4 (VALIDACION CRUZADA - tema central de tu entrevista)
-- Detecta pedidos que tienen cliente_id que NO existe en la tabla clientes
-- (simula la validacion entre dos bases de datos)
-- Para esto necesitamos insertar un pedido "huerfano" primero:

-- Primero agrega un pedido con cliente_id invalido:
-- INSERT INTO pedidos (cliente_id, empleado_id, fecha, estado, ciudad_envio)
-- VALUES (9999, 4, '2024-06-01', 'PENDIENTE', 'CDMX');

-- Luego ejecuta la validacion:
SELECT
    p.pedido_id,
    p.cliente_id     AS cliente_id_en_pedido,
    p.fecha,
    'CLIENTE NO EXISTE' AS tipo_error
FROM pedidos AS p
LEFT JOIN clientes AS c ON p.cliente_id = c.cliente_id
WHERE c.cliente_id IS NULL;

-- Si no hay huerfanos, el resultado estara vacio (eso es BUENO)


-- ============================================================
-- BLOQUE 5: UNION, INTERSECT, EXCEPT (Leccion 6 avanzado)
-- ============================================================

-- EJERCICIO 5.1
-- Combina: emails de clientes internos + nombres de clientes externos
-- (UNION ALL para ver todos, con columna que indica el origen)

-- SOLUCION 5.1:
SELECT nombre, 'INTERNO'       AS origen FROM clientes
UNION ALL
SELECT nombre, 'EXTERNO'       AS origen FROM clientes_externos
ORDER BY nombre;


-- EJERCICIO 5.2
-- Clientes que compraron en 2023 Y TAMBIEN en 2024 (INTERSECT)

-- SOLUCION 5.2:
SELECT DISTINCT cliente_id FROM pedidos WHERE EXTRACT(YEAR FROM fecha) = 2023
INTERSECT
SELECT DISTINCT cliente_id FROM pedidos WHERE EXTRACT(YEAR FROM fecha) = 2024;


-- EJERCICIO 5.3
-- Clientes que compraron en 2023 pero NO en 2024 (EXCEPT)

-- SOLUCION 5.3:
SELECT DISTINCT cliente_id FROM pedidos WHERE EXTRACT(YEAR FROM fecha) = 2023
EXCEPT
SELECT DISTINCT cliente_id FROM pedidos WHERE EXTRACT(YEAR FROM fecha) = 2024;


-- ============================================================
-- BLOQUE 6: CTEs con WITH (Leccion 7)
-- ============================================================

-- EJERCICIO 6.1
-- Usando CTE: clientes con total gastado mayor a $20,000
-- (no subconsultas anidadas!)

-- SOLUCION 6.1:
WITH gastos AS (
    SELECT
        p.cliente_id,
        SUM(dp.cantidad * dp.precio_unit * (1 - dp.descuento_pct/100.0)) AS total
    FROM pedidos        AS p
    JOIN detalle_pedido AS dp ON p.pedido_id = dp.pedido_id
    WHERE p.estado = 'ENTREGADO'
    GROUP BY p.cliente_id
)
SELECT
    c.nombre,
    c.segmento,
    c.ciudad,
    ROUND(g.total, 2) AS total_gastado
FROM gastos AS g
JOIN clientes AS c ON g.cliente_id = c.cliente_id
WHERE g.total > 20000
ORDER BY g.total DESC;


-- EJERCICIO 6.2
-- CTE multiple: reporte de ventas por empleado con categoria del rendimiento

-- SOLUCION 6.2:
WITH ventas_por_empleado AS (
    SELECT
        p.empleado_id,
        COUNT(DISTINCT p.pedido_id)                                      AS pedidos_cerrados,
        SUM(dp.cantidad * dp.precio_unit * (1 - dp.descuento_pct/100.0)) AS monto_vendido
    FROM pedidos        AS p
    JOIN detalle_pedido AS dp ON p.pedido_id = dp.pedido_id
    WHERE p.estado = 'ENTREGADO'
    GROUP BY p.empleado_id
)
SELECT
    e.nombre            AS vendedor,
    e.puesto,
    v.pedidos_cerrados,
    ROUND(v.monto_vendido, 2) AS monto_vendido,
    CASE
        WHEN v.monto_vendido > 100000 THEN 'TOP PERFORMER'
        WHEN v.monto_vendido > 50000  THEN 'BUEN RENDIMIENTO'
        ELSE                               'EN DESARROLLO'
    END                 AS categoria
FROM ventas_por_empleado AS v
JOIN empleados AS e ON v.empleado_id = e.empleado_id
ORDER BY v.monto_vendido DESC;


-- ============================================================
-- BLOQUE 7: Window Functions (Leccion 8)
-- ============================================================

-- EJERCICIO 7.1
-- Numera los pedidos de cada cliente del mas reciente al mas antiguo

-- SOLUCION 7.1:
SELECT
    c.nombre,
    p.pedido_id,
    p.fecha,
    p.estado,
    ROW_NUMBER() OVER (
        PARTITION BY p.cliente_id
        ORDER BY p.fecha DESC
    ) AS num_pedido_del_cliente
FROM pedidos AS p
JOIN clientes AS c ON p.cliente_id = c.cliente_id
ORDER BY c.nombre, p.fecha DESC;


-- EJERCICIO 7.2
-- El pedido MAS RECIENTE de cada cliente (solo 1 por cliente)

-- SOLUCION 7.2:
WITH pedidos_numerados AS (
    SELECT
        p.*,
        c.nombre AS nombre_cliente,
        ROW_NUMBER() OVER (
            PARTITION BY p.cliente_id
            ORDER BY p.fecha DESC
        ) AS rn
    FROM pedidos AS p
    JOIN clientes AS c ON p.cliente_id = c.cliente_id
)
SELECT nombre_cliente, pedido_id, fecha, estado
FROM pedidos_numerados
WHERE rn = 1
ORDER BY fecha DESC;


-- EJERCICIO 7.3
-- Ranking de clientes por total gastado (con RANK y DENSE_RANK)
-- Observa la diferencia cuando hay empates

-- SOLUCION 7.3:
WITH totales AS (
    SELECT
        p.cliente_id,
        SUM(dp.cantidad * dp.precio_unit) AS total
    FROM pedidos        AS p
    JOIN detalle_pedido AS dp ON p.pedido_id = dp.pedido_id
    WHERE p.estado = 'ENTREGADO'
    GROUP BY p.cliente_id
)
SELECT
    c.nombre,
    ROUND(t.total, 2)                           AS total_gastado,
    RANK()       OVER (ORDER BY t.total DESC)   AS rank_con_salto,
    DENSE_RANK() OVER (ORDER BY t.total DESC)   AS rank_sin_salto
FROM totales AS t
JOIN clientes AS c ON t.cliente_id = c.cliente_id
ORDER BY t.total DESC;


-- EJERCICIO 7.4
-- Para cada empleado, muestra su salario y la diferencia con el promedio de su departamento

-- SOLUCION 7.4:
SELECT
    nombre,
    departamento,
    salario,
    ROUND(AVG(salario) OVER (PARTITION BY departamento), 2) AS promedio_depto,
    salario - ROUND(AVG(salario) OVER (PARTITION BY departamento), 2) AS diferencia
FROM empleados
ORDER BY departamento, salario DESC;


-- ============================================================
-- BLOQUE 8: CONSULTA FINAL INTEGRADORA
-- (Combina todo lo aprendido en una sola query)
-- ============================================================

-- RETO FINAL:
-- Reporte ejecutivo: top 3 clientes por region con su total de compras en 2024,
-- incluyendo cuantos pedidos hicieron y el ticket promedio.
-- Solo pedidos ENTREGADOS o ENVIADOS.

WITH compras_2024 AS (
    SELECT
        p.cliente_id,
        COUNT(DISTINCT p.pedido_id)                                      AS num_pedidos,
        SUM(dp.cantidad * dp.precio_unit * (1 - dp.descuento_pct/100.0)) AS total_compras
    FROM pedidos        AS p
    JOIN detalle_pedido AS dp ON p.pedido_id = dp.pedido_id
    WHERE EXTRACT(YEAR FROM p.fecha) = 2024
      AND p.estado IN ('ENTREGADO', 'ENVIADO')
    GROUP BY p.cliente_id
),
clientes_con_compras AS (
    SELECT
        c.nombre,
        c.segmento,
        r.nombre            AS region,
        cc.num_pedidos,
        cc.total_compras,
        ROUND(cc.total_compras / cc.num_pedidos, 2) AS ticket_promedio,
        ROW_NUMBER() OVER (
            PARTITION BY r.nombre
            ORDER BY cc.total_compras DESC
        ) AS posicion_en_region
    FROM compras_2024 AS cc
    JOIN clientes     AS c ON cc.cliente_id = c.cliente_id
    JOIN regiones     AS r ON c.region_id   = r.region_id
)
SELECT
    posicion_en_region AS posicion,
    region,
    nombre          AS cliente,
    segmento,
    num_pedidos,
    ROUND(total_compras, 2) AS total_compras,
    ticket_promedio
FROM clientes_con_compras
WHERE posicion_en_region <= 3
ORDER BY region, posicion_en_region;

-- ============================================================
-- FIN DE EJERCICIOS
-- Si llegaste hasta aqui, estas listo para la entrevista!
-- ============================================================
