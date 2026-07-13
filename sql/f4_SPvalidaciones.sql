-- Intento de resenaa sin compra previa
CALL sp_registrar_resena(5, 'Me gusto mucho', 1, 2);

-- Intento de compra sin stock suficiente
CALL sp_registrar_pedido(2, 1, 1000, 15000.00);

-- Intento de agregar producto duplicado
CALL sp_agregar_producto('iPhone 13', 'Tel\'efono de prueba', 15000.00, 10, 1);

-- Actualizacion del inventario de productos
CALL sp_actualizar_stock(3, 3);

-- Cambio en el estado de un pedido}
CALL sp_cambiar_estado_pedido(4, 'pendiente');

-- Eliminacion de una resena y calculo del promedio
CALL sp_eliminar_resena(3);

-- Actualizacion de los datos de contacto de un cliente
CALL sp_actualizar_cliente(3, 'Avenida Principal 555', '555-4789');

-- Generacion del reporte automatizado de stock bajo
CALL sp_reporte_stock_bajo();