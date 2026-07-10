-- Procedimientos almacenados

-- Cambiamos el delimitador temporalmente a dos diagonales para que mysql entienda que todo el procedimiento es un solo bloque de codigo y no se detenga cuando encuentre los puntos y comas internos de los inserts o updates.
DELIMITER //

-- 1. Registrar un nuevo pedido, verificando el límite de 5 pedidos pendientes y stock suficiente.
-- este procedimiento sirve para automatizar las compras porque primero declaramos variables locales para guardar de forma temporal los datos que vamos a consultar de las tablas, luego usamos SELECT COUNT y SELECT STOCK INTO para meter los resultados dentro de nuestras variables y poder hacer las validaciones del negocio con un IF, si el cliente ya debe 5 pedidos o si no hay stock, usamos signal SQLSTATE '45000' para detener todo por completo y lanzar un error personalizado, evitando que la base de datos se rompa o registre datos falsos;  si todo esta bien, se inserta el pedido y usamos LAST_INSERT_ID para agarrar el id que se acaba de generar en automatico y meterlo directo en detalles_pedido
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

    -- contamos cuantos pedidos pendientes tiene este cliente y lo guardamos en la variable
    SELECT COUNT(*) INTO v_pendientes FROM pedidos WHERE id_cliente = p_id_cliente AND estado = 'pendiente';

    -- revisamos cuanto stock tiene el producto actual y lo guardamos en la variable
    SELECT stock INTO v_stock FROM productos WHERE id_producto = p_id_producto;

    IF v_pendientes >= 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El cliente ya tiene 5 pedidos pendientes máximos.';
    ELSEIF v_stock < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No hay suficiente stock para este producto.';
    ELSE
        -- si pasa los filtros guardamos el pedido usando CURDATE para poner la fecha del dia de hoy en automatico
        INSERT INTO pedidos (fecha_pedido, estado, id_cliente) VALUES (CURDATE(), 'pendiente', p_id_cliente);

        -- guardamos el id generado para no perder la relacion con su detalle
        SET v_nuevo_id_pedido = LAST_INSERT_ID();

        -- insertamos el producto en la tabla puente de detalles_pedido
        INSERT INTO detalles_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES (v_nuevo_id_pedido, p_id_producto, p_cantidad, p_precio);
    END IF;
END //


-- 2. Registrar una reseña, verificando que el cliente haya comprado el producto.
-- este procedimiento protege la integridad de las opiniones de la tienda, hacemos un SELECT COUNT cruzando detalles_pedido y pedidos con un JOIN para verificar si existe al menos un registro donde este cliente haya pagado por este producto, si el conteo da cero significa que nunca lo compro, por lo que usamos SIGNAL SQLSTATE para arrojar un error y bloquear la insercion de la resena
CREATE PROCEDURE sp_registrar_resena(
    IN p_calificacion INT,
    IN p_comentario TEXT,
    IN p_id_producto INT,
    IN p_id_cliente INT
)
BEGIN
    DECLARE v_compro INT;

    -- buscamos si hay registros que demuestren que el cliente si compro el producto
    SELECT COUNT(*) INTO v_compro
    FROM detalles_pedido dp
    JOIN pedidos p ON dp.id_pedido = p.id_pedido
    WHERE p.id_cliente = p_id_cliente AND dp.id_producto = p_id_producto;

    IF v_compro = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Solo puedes hacer reseñas de productos que hayas comprado.';
    ELSE
        INSERT INTO resenas (calificacion, comentario, fecha, id_producto, id_cliente)
        VALUES (p_calificacion, p_comentario, CURDATE(), p_id_producto, p_id_cliente);
    END IF;
END //


-- 3. Actualizar el stock de un producto después de un pedido
-- este procedimiento sirve para manteer actualizado el inventario, lo que hacemos es un UPDATE directo a la tabla de productos usando su llave primaria y le restamos al stock original la cantidad exacta de piezas que el cliente se va a llevar en su compra
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
-- sirve para la logica de logistica de la tienda, usamos un update para modificar el texto del estado de la orden (pendiente, enviado, entregado) guiandonos  por el id_pedido para no alterar las compras de otros clientes
CREATE PROCEDURE sp_cambiar_estado_pedido(
    IN p_id_pedido INT,
    IN p_nuevo_estado VARCHAR(20)
)
BEGIN
    UPDATE pedidos
    SET estado = p_nuevo_estado
    WHERE id_pedido = p_id_pedido;
END //


-- 5. Eliminar reseña de un producto específico, actualizando el promedio de calificaciones
-- aqui primero buscamos cual es el id del producto al que pertenece la resena que queremos borrar y lo respaldamos en una variable local, ya que si la borramos primero perderiamos ese dato; despues de aplicar el delete, hacemos un select combinado con AVG para mostrarle de inmediato al administrador como se recalculo el promedio general de estrellas de ese producto de manera automatica
CREATE PROCEDURE sp_eliminar_resena(
    IN p_id_resena INT
)
BEGIN
    DECLARE v_id_producto INT;

    -- respaldamos el id del producto en nuestra variable antes de borrar el registro
    SELECT id_producto INTO v_id_producto FROM resenas WHERE id_resena = p_id_resena;

    -- borramos la resena de la tabla
    DELETE FROM resenas WHERE id_resena = p_id_resena;

    -- calculamos y mostramos el nuevo promedio real en pantalla
    SELECT p.nombre, AVG(r.calificacion) AS nuevo_promedio
    FROM productos p
    LEFT JOIN resenas r ON p.id_producto = r.id_producto
    WHERE p.id_producto = v_id_producto
    GROUP BY p.id_producto;
END //


-- 6. Agregar un nuevo producto, verificando que no exista un duplicado (mismo nombre y categoría).
-- para evitar errores de captura donde metan dos veces la misma laptop o celular, hacemos un select count buscando si ya hay un registro con exactamente el mismo nombre dentro de la misma categoria, si el sistema encuentra que ya existe, frena la operacion con un signal y le avisa al usuario
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
-- este procedimiento sirve para que el usuario pueda cambiar sus datos de contacto en su perfil, aplicamos un UPDATE directo sobre la tabla clientes y usamos el id_cliente en el WHERE para  que se modifiquen los datos de la persona correcta
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
-- es una consulta de control para el administrador de la tienda, hace un SELECT filtrando con un WHERE para extraer unicamente los productos que tengan menos de 5 piezas en el inventario, ordenandolos de menor a mayor stock para saber que urge resurtir primero.
CREATE PROCEDURE sp_reporte_stock_bajo()
BEGIN
    SELECT nombre, stock, precio
    FROM productos
    WHERE stock < 5
    ORDER BY stock ASC;
END //

-- regresamos el delimitador al punto y coma que se usa de forma normal en sql
DELIMITER ;