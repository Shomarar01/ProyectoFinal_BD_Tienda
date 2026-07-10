USE tienda_electronica;

-- ==============================================================================
-- FASE 3: CONSULTAS SQL (QUERIES)
-- ==============================================================================

-- 1. Listar productos disponibles por categoria, ordenados por precio
-- O sea, solo queremos ver los que tienen stock mayor a 0, y usamos JOIN para traer el nombre de la categoría y no solo el número.
SELECT p.nombre AS producto, c.nombre AS categoria, p.precio, p.stock 
FROM productos p
JOIN categorias c ON p.id_categoria = c.id_categoria
WHERE p.stock > 0
ORDER BY p.precio ASC;

-- 2. Mostrar clientes con pedidos pendientes y total de compras
-- Juntamos clientes y pedidos. Contamos cuántos pedidos pendientes tiene cada uno usando COUNT.
SELECT c.nombre AS cliente, c.correo, COUNT(pe.id_pedido) AS total_pedidos_pendientes
FROM clientes c
JOIN pedidos pe ON c.id_cliente = pe.id_cliente
WHERE pe.estado = 'pendiente'
GROUP BY c.id_cliente;

-- 3. Reporte de los 5 productos con mejor calificacion promedio en resenas
-- Sacamos el promedio de calificación usando AVG, agrupamos por producto para que no se repitan, y los ordenamos de mayor a menor limitando a los top 5.
SELECT p.nombre AS producto, AVG(r.calificacion) AS promedio_calificacion
FROM productos p
JOIN resenas r ON p.id_producto = r.id_producto
GROUP BY p.id_producto
ORDER BY promedio_calificacion DESC
LIMIT 5;

-- ==============================================================================
-- FASE 3: PROCEDIMIENTOS ALMACENADOS (STORED PROCEDURES)
-- ==============================================================================
-- Cambiamos el delimitador para que MySQL no se confunda con los puntos y comas internos.
DELIMITER //

-- 1. Registrar un nuevo pedido (Verificando limite de 5 pendientes y stock)
-- Aquí revisamos si el cliente ya debe mucho (5 pendientes). Si sí, marcamos error. Si hay stock, creamos el pedido.
CREATE PROCEDURE sp_registrar_pedido(
    IN p_id_cliente INT, 
    IN p_id_producto INT, 
    IN p_cantidad INT, 
    IN p_precio DECIMAL(10,2)
)
BEGIN
    DECLARE v_pendientes INT;
    DECLARE v_stock INT;
    DECLARE v_nuevo_id_pedido INT;
    
    -- Contamos cuántos pedidos pendientes tiene este cliente
    SELECT COUNT(*) INTO v_pendientes FROM pedidos WHERE id_cliente = p_id_cliente AND estado = 'pendiente';
    -- Revisamos cuánto stock tiene el producto
    SELECT stock INTO v_stock FROM productos WHERE id_producto = p_id_producto;
    
    IF v_pendientes >= 5 THEN
        -- Como aprendimos en clase, usamos SIGNAL SQLSTATE para lanzar nuestro propio error si no cumple la regla.
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El cliente ya tiene 5 pedidos pendientes máximos.';
    ELSEIF v_stock < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No hay suficiente stock para este producto.';
    ELSE
        -- Si pasa las validaciones, creamos el pedido con la fecha de hoy (CURDATE)
        INSERT INTO pedidos (fecha_pedido, estado, id_cliente) VALUES (CURDATE(), 'pendiente', p_id_cliente);
        -- Obtenemos el ID del pedido que se acaba de crear solita
        SET v_nuevo_id_pedido = LAST_INSERT_ID();
        -- Insertamos el detalle del pedido
        INSERT INTO detalles_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES (v_nuevo_id_pedido, p_id_producto, p_cantidad, p_precio);
    END IF;
END //

-- 2. Registrar reseña (Verificando que el cliente sí haya comprado el producto)
-- O sea, cruzamos detalles de pedido y pedidos para asegurar que el producto pasó por las manos del cliente.
CREATE PROCEDURE sp_registrar_resena(
    IN p_calificacion INT, 
    IN p_comentario TEXT, 
    IN p_id_producto INT, 
    IN p_id_cliente INT
)
BEGIN
    DECLARE v_compro INT;
    
    -- Verificamos si existe alguna compra de ese producto hecha por ese cliente
    SELECT COUNT(*) INTO v_compro 
    FROM detalles_pedido dp
    JOIN pedidos p ON dp.id_pedido = p.id_pedido
    WHERE p.id_cliente = p_id_cliente AND dp.id_producto = p_id_producto;
    
    IF v_compro = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Solo puedes reseñar productos que hayas comprado.';
    ELSE
        INSERT INTO resenas (calificacion, comentario, fecha, id_producto, id_cliente) 
        VALUES (p_calificacion, p_comentario, CURDATE(), p_id_producto, p_id_cliente);
    END IF;
END //

-- 3. Actualizar el stock de un producto después de un pedido
-- Simplemente le restamos la cantidad que el cliente compró al stock actual.
CREATE PROCEDURE sp_actualizar_stock(
    IN p_id_producto INT, 
    IN p_cantidad_comprada INT
)
BEGIN
    UPDATE productos 
    SET stock = stock - p_cantidad_comprada 
    WHERE id_producto = p_id_producto;
END //

-- 4. Cambiar el estado de un pedido (ej. de pendiente a enviado)
CREATE PROCEDURE sp_cambiar_estado_pedido(
    IN p_id_pedido INT, 
    IN p_nuevo_estado VARCHAR(20)
)
BEGIN
    UPDATE pedidos 
    SET estado = p_nuevo_estado 
    WHERE id_pedido = p_id_pedido;
END //

-- 5. Eliminar reseña de un producto específico, actualizando el promedio
-- En bases relacionales, los promedios se calculan al momento. Al borrar la reseña, el promedio general se ajusta solito.
CREATE PROCEDURE sp_eliminar_resena(
    IN p_id_resena INT
)
BEGIN
    DECLARE v_id_producto INT;
    -- Guardamos el ID del producto antes de borrar la reseña para luego mostrar el nuevo promedio
    SELECT id_producto INTO v_id_producto FROM resenas WHERE id_resena = p_id_resena;
    
    DELETE FROM resenas WHERE id_resena = p_id_resena;
    
    -- Mostramos cómo quedó el promedio después de borrarla
    SELECT p.nombre, AVG(r.calificacion) AS nuevo_promedio
    FROM productos p
    LEFT JOIN resenas r ON p.id_producto = r.id_producto
    WHERE p.id_producto = v_id_producto
    GROUP BY p.id_producto;
END //

-- 6. Agregar un nuevo producto, verificando que no exista duplicado
-- Validamos que no metan un producto con el mismo nombre en la misma categoría.
CREATE PROCEDURE sp_agregar_producto(
    IN p_nombre VARCHAR(150), 
    IN p_descripcion TEXT, 
    IN p_precio DECIMAL(10,2), 
    IN p_stock INT, 
    IN p_id_categoria INT
)
BEGIN
    DECLARE v_existe INT;
    
    SELECT COUNT(*) INTO v_existe FROM productos 
    WHERE nombre = p_nombre AND id_categoria = p_id_categoria;
    
    IF v_existe > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Ya existe un producto con ese nombre en esta categoría.';
    ELSE
        INSERT INTO productos (nombre, descripcion, precio, stock, id_categoria) 
        VALUES (p_nombre, p_descripcion, p_precio, p_stock, p_id_categoria);
    END IF;
END //

-- 7. Actualizar la información de un cliente (ej. dirección o teléfono)
CREATE PROCEDURE sp_actualizar_cliente(
    IN p_id_cliente INT, 
    IN p_nueva_direccion VARCHAR(255), 
    IN p_nuevo_telefono VARCHAR(20)
)
BEGIN
    UPDATE clientes 
    SET direccion = p_nueva_direccion, telefono = p_nuevo_telefono 
    WHERE id_cliente = p_id_cliente;
END //

-- 8. Generar un reporte de productos con stock bajo (menos de 5 unidades)
CREATE PROCEDURE sp_reporte_stock_bajo()
BEGIN
    SELECT nombre, stock, precio 
    FROM productos 
    WHERE stock < 5
    ORDER BY stock ASC;
END //

DELIMITER ;