
CREATE DATABASE IF NOT EXISTS tienda_electronica;
USE tienda_electronica;

-- Categorias
CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE, -- Nombre único
    descripcion TEXT
);

-- Clientes
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE, -- Correo único
    telefono VARCHAR(20),
    direccion VARCHAR(255)
);

-- Productos
CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL CHECK (stock >= 0), -- Stock no negativo
    id_categoria INT,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

-- Pedidos
CREATE TABLE pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    fecha_pedido DATE NOT NULL,
    estado ENUM('pendiente', 'enviado', 'entregado') DEFAULT 'pendiente',
    id_cliente INT,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- Detalles_pedido
CREATE TABLE detalles_pedido (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT,
    id_producto INT,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- Resenas
CREATE TABLE resenas (
    id_resena INT AUTO_INCREMENT PRIMARY KEY,
    calificacion INT NOT NULL CHECK (calificacion BETWEEN 1 AND 5),
    comentario TEXT,
    fecha DATE NOT NULL,
    id_producto INT,
    id_cliente INT,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- Optimizar la búsqueda de productos por nombre
CREATE INDEX idx_producto_nombre ON productos(nombre);

-- Optimizar la búsqueda de productos por su categoría
CREATE INDEX idx_producto_categoria ON productos(id_categoria);

-- Optimizar la búsqueda del historial de pedidos de un cliente específico
CREATE INDEX idx_pedido_cliente ON pedidos(id_cliente);