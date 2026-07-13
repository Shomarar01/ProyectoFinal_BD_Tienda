USE tienda_electronica;

-- consultas sql

-- 1. Listar productos disponibles por categoría, ordenados por precio.
-- solo queremos ver los que tienen stock mayor a 0, usamos un JOIN para poder cruzar la tabla de productos con la de categorias,
-- ya que si no lo hacemos, el sistema solo nos mostraria el numero del id_categoria y el usuario no sabria a que categoria pertenece
-- el producto;al final ordenamos con ORDER BY para que salgan los precios mas baratos primero.
SELECT p.nombre AS producto, c.nombre AS categoria, p.precio, p.stock
FROM productos p
JOIN categorias c ON p.id_categoria = c.id_categoria
WHERE p.stock > 0
ORDER BY p.precio ASC;


-- 2. Mostrar clientes con pedidos pendientes y total de compras.
-- aqui juntamos las tablas de clientes y pedidos con un JOIN para saber de quien es cada orden, usamos la funcion count
-- para contar exactamente cuantos registros pendientes tiene cada persona y agrupamos con GROUP BY por el id del cliente 
-- para que el conteo no se mezcle y se haga de forma individual para cada uno de ellos.
SELECT c.nombre AS cliente, c.correo, COUNT(pe.id_pedido) AS total_pedidos_pendientes
FROM clientes c
JOIN pedidos pe ON c.id_cliente = pe.id_cliente
WHERE pe.estado = 'pendiente'
GROUP BY c.id_cliente;


-- 3. Reporte de los 5 productos con mejor calificación promedio en reseñas.
-- usamos la funcion AVG para calcular de forma automatica el promedio real de las estrellas de cada producto y agrupamos 
-- por el id del producto para que el sistema calcule el promedio por separado para cada prodcuto, luego los ordenamos de mayor a menor 
-- calificacion con DESC y usamos LIMIT 5 para que solo nos muestre el top de los mejores en la tienda
SELECT p.nombre AS producto, AVG(r.calificacion) AS promedio_calificacion
FROM productos p
JOIN resenas r ON p.id_producto = r.id_producto
GROUP BY p.id_producto
ORDER BY promedio_calificacion DESC
LIMIT 5;
