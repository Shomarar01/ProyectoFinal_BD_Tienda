USE tienda_electronica;

-- Categorías (3)
INSERT INTO categorias (nombre, descripcion) VALUES
('Teléfonos', 'Smartphones y accesorios celulares'),
('Laptops', 'Computadoras portátiles para uso personal y profesional'),
('Accesorios', 'Cables, audífonos, fundas y periféricos');

-- Clientes (15)
INSERT INTO clientes (nombre, correo, telefono, direccion) VALUES
('Pablo Hernandez', 'pablo@email.com', '5551234', 'Calle 1'),
('Jhovanny Pérez', 'jhovanny@email.com', '5551235', 'Calle 2'),
('Zury Bautista', 'zury@email.com', '5551236', 'Calle 3'),
('Juan Ruiz', 'juan@email.com', '5551237', 'Calle 4'),
('Angel Duenas', 'angel@email.com', '5551238', 'Calle 5'),
('Hugo Soto', 'hugo@email.com', '5551239', 'Calle 6'),
('Sara Rivera', 'sara@email.com', '5551240', 'Calle 7'),
('Paco Luna', 'paco@email.com', '5551241', 'Calle 8'),
('Cecilia Hernández', 'cecilia@email.com', '5551242', 'Calle 9'),
('Raúl Mora', 'raul@email.com', '5551243', 'Calle 10'),
('Nolan Rivera', 'nolan@email.com', '5551244', 'Calle 11'),
('Omar Navarrete', 'omar@email.com', '5551245', 'Calle 12'),
('Lupita Gonzalez', 'lupita@email.com', '5551246', 'Calle 13'),
('José Ruz', 'jose@email.com', '5551247', 'Calle 14'),
('Rogelio Navarrete', 'rogelio@email.com', '5551248', 'Calle 15');

-- Productos (30)(10 teléfonos, 10 laptops, 10 accesorios)
INSERT INTO productos (nombre, descripcion, precio, stock, id_categoria) VALUES
('iPhone 13', 'Teléfono Apple', 15000, 20, 1), ('Galaxy S21', 'Teléfono Samsung', 12000, 15, 1),
('Pixel 6', 'Teléfono Google', 10000, 10, 1), ('Xiaomi Mi 11', 'Teléfono Xiaomi', 8000, 25, 1),
('Moto G100', 'Teléfono Motorola', 7500, 30, 1), ('OnePlus 9', 'Teléfono OnePlus', 11000, 5, 1),
('iPhone 14', 'Teléfono Apple', 18000, 10, 1), ('Galaxy S22', 'Teléfono Samsung', 14000, 12, 1),
('Poco X3', 'Teléfono Poco', 5000, 40, 1), ('Huawei P40', 'Teléfono Huawei', 9000, 8, 1),
('MacBook Air', 'Laptop Apple', 20000, 10, 2), ('Dell XPS 13', 'Laptop Dell', 25000, 5, 2),
('ThinkPad X1', 'Laptop Lenovo', 22000, 7, 2), ('HP Envy', 'Laptop HP', 18000, 12, 2),
('Asus ZenBook', 'Laptop Asus', 17000, 9, 2), ('Acer Swift', 'Laptop Acer', 15000, 15, 2),
('MacBook Pro', 'Laptop Apple', 30000, 3, 2), ('Razer Blade', 'Laptop Razer', 35000, 2, 2),
('MSI Stealth', 'Laptop MSI', 28000, 4, 2), ('Lenovo Legion', 'Laptop Gaming Lenovo', 24000, 6, 2),
('AirPods Pro', 'Audífonos Apple', 5000, 50, 3), ('Galaxy Buds', 'Audífonos Samsung', 3000, 40, 3),
('Sony WH-1000XM4', 'Audífonos Sony', 6000, 15, 3), ('Cable USB-C', 'Cable 2 metros', 200, 100, 3),
('Cargador Rápido', 'Cargador 20W', 400, 80, 3), ('Funda iPhone 13', 'Funda silicona', 300, 60, 3),
('Mica de Cristal', 'Protector de pantalla', 150, 120, 3), ('PowerBank 10000mAh', 'Batería externa', 800, 30, 3),
('Mouse Inalámbrico', 'Mouse Bluetooth', 500, 45, 3), ('Teclado Mecánico', 'Teclado USB', 1200, 20, 3);

-- Pedidos (20)
INSERT INTO pedidos (fecha_pedido, estado, id_cliente) VALUES
('2023-10-01', 'entregado', 1), ('2023-10-02', 'entregado', 2), ('2023-10-03', 'entregado', 3),
('2023-10-04', 'enviado', 4), ('2023-10-05', 'pendiente', 5), ('2023-10-06', 'entregado', 6),
('2023-10-07', 'enviado', 7), ('2023-10-08', 'pendiente', 8), ('2023-10-09', 'entregado', 9),
('2023-10-10', 'enviado', 10), ('2023-10-11', 'pendiente', 11), ('2023-10-12', 'entregado', 12),
('2023-10-13', 'enviado', 13), ('2023-10-14', 'pendiente', 14), ('2023-10-15', 'entregado', 15),
('2023-10-16', 'enviado', 1), ('2023-10-17', 'pendiente', 2), ('2023-10-18', 'entregado', 3),
('2023-10-19', 'enviado', 4), ('2023-10-20', 'pendiente', 5);

-- Detalles de Pedido (25)
INSERT INTO detalles_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 1, 15000), (1, 21, 1, 5000), (2, 11, 1, 20000), (3, 2, 1, 12000), (3, 22, 1, 3000),
(4, 12, 1, 25000), (5, 3, 2, 10000), (6, 23, 1, 6000), (7, 13, 1, 22000), (8, 4, 1, 8000),
(9, 24, 3, 200), (10, 14, 1, 18000), (11, 5, 1, 7500), (12, 25, 2, 400), (13, 15, 1, 17000),
(14, 6, 1, 11000), (15, 26, 1, 300), (16, 16, 1, 15000), (17, 7, 1, 18000), (18, 27, 2, 150),
(19, 17, 1, 30000), (20, 8, 1, 14000), (20, 28, 1, 800), (15, 29, 1, 500), (1, 30, 1, 1200);

-- Reseñas (10) (Asumiendo que los clientes compraron el producto según los detalles)
INSERT INTO resenas (calificacion, comentario, fecha, id_producto, id_cliente) VALUES
(5, 'Excelente teléfono, muy rápido.', '2023-10-10', 1, 1),
(4, 'Buena laptop, pero la batería dura poco.', '2023-10-11', 11, 2),
(5, 'Me encantó la cámara del S21.', '2023-10-12', 2, 3),
(3, 'Los audífonos están bien, un poco caros.', '2023-10-13', 21, 1),
(5, 'Muy potente para programar.', '2023-10-14', 12, 4),
(4, 'Buen diseño de audífonos.', '2023-10-15', 22, 3),
(5, 'Carga súper rápido.', '2023-10-16', 25, 12),
(2, 'La funda se rayó muy rápido.', '2023-10-17', 26, 15),
(5, 'El mejor mouse que he tenido.', '2023-10-18', 29, 15),
(4, 'Buen teclado, aunque algo ruidoso.', '2023-10-19', 30, 1);