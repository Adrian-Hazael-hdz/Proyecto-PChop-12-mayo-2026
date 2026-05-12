-- ============================================================
--  PChop - Script de creación de base de datos
--  Motor: MySQL 8.x / MariaDB 10.6+
--  Generado: 2026
-- ============================================================

CREATE DATABASE IF NOT EXISTS bdpchop
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE bdpchop;

SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- DOMINIO 1: Clientes y autenticación
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS CLIENTE (
    cliente_id        INT            NOT NULL AUTO_INCREMENT,
    nombre            VARCHAR(80)    NOT NULL,
    apellido          VARCHAR(80)    NOT NULL,
    email             VARCHAR(150)   NOT NULL,
    password_hash     VARCHAR(255)   NOT NULL,
    telefono          VARCHAR(20)    NULL,
    estado            ENUM('activo','inactivo','bloqueado') NOT NULL DEFAULT 'activo',
    fecha_registro    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_login      DATETIME       NULL,

    CONSTRAINT pk_cliente       PRIMARY KEY (cliente_id),
    CONSTRAINT uq_cliente_email UNIQUE (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS DIRECCION (
    direccion_id      INT            NOT NULL AUTO_INCREMENT,
    cliente_id        INT            NOT NULL,
    alias             VARCHAR(50)    NULL,
    calle             VARCHAR(200)   NOT NULL,
    ciudad            VARCHAR(100)   NOT NULL,
    estado_provincia  VARCHAR(100)   NOT NULL,
    codigo_postal     VARCHAR(10)    NOT NULL,
    pais              CHAR(2)        NOT NULL COMMENT 'ISO 3166-1 alpha-2',
    tipo              ENUM('envio','facturacion','ambas') NOT NULL DEFAULT 'envio',
    es_predeterminada BOOLEAN        NOT NULL DEFAULT FALSE,

    CONSTRAINT pk_direccion     PRIMARY KEY (direccion_id),
    CONSTRAINT fk_dir_cliente   FOREIGN KEY (cliente_id)
        REFERENCES CLIENTE(cliente_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ------------------------------------------------------------
-- DOMINIO 2: Catálogo de productos
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS CATEGORIA (
    categoria_id       INT           NOT NULL AUTO_INCREMENT,
    nombre             VARCHAR(100)  NOT NULL,
    slug               VARCHAR(120)  NOT NULL,
    categoria_padre_id INT           NULL COMMENT 'FK recursiva para árbol jerárquico',
    descripcion        VARCHAR(300)  NULL,
    activo             BOOLEAN       NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_categoria        PRIMARY KEY (categoria_id),
    CONSTRAINT uq_categoria_slug   UNIQUE (slug),
    CONSTRAINT fk_cat_padre        FOREIGN KEY (categoria_padre_id)
        REFERENCES CATEGORIA(categoria_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS MARCA (
    marca_id    INT           NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(100)  NOT NULL,
    slug        VARCHAR(120)  NOT NULL,
    logo_url    VARCHAR(500)  NULL,
    pais_origen CHAR(2)       NULL COMMENT 'ISO 3166-1 alpha-2',
    activo      BOOLEAN       NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_marca       PRIMARY KEY (marca_id),
    CONSTRAINT uq_marca_nombre UNIQUE (nombre),
    CONSTRAINT uq_marca_slug   UNIQUE (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS PROVEEDOR (
    proveedor_id    INT           NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(150)  NOT NULL,
    rfc_nit         VARCHAR(30)   NULL COMMENT 'Identificador fiscal',
    contacto_nombre VARCHAR(100)  NULL,
    contacto_email  VARCHAR(150)  NULL,
    telefono        VARCHAR(20)   NULL,
    pais            CHAR(2)       NULL COMMENT 'ISO 3166-1 alpha-2',
    activo          BOOLEAN       NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_proveedor PRIMARY KEY (proveedor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS PRODUCTO (
    producto_id         INT             NOT NULL AUTO_INCREMENT,
    sku                 VARCHAR(50)     NOT NULL,
    nombre              VARCHAR(200)    NOT NULL,
    descripcion         TEXT            NULL,
    precio_regular      DECIMAL(10,2)   NOT NULL CHECK (precio_regular >= 0),
    precio_oferta       DECIMAL(10,2)   NULL      CHECK (precio_oferta >= 0),
    categoria_id        INT             NOT NULL,
    marca_id            INT             NOT NULL,
    proveedor_id        INT             NOT NULL,
    activo              BOOLEAN         NOT NULL DEFAULT TRUE,
    fecha_creacion      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_producto          PRIMARY KEY (producto_id),
    CONSTRAINT uq_producto_sku      UNIQUE (sku),
    CONSTRAINT fk_prod_categoria    FOREIGN KEY (categoria_id)
        REFERENCES CATEGORIA(categoria_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prod_marca        FOREIGN KEY (marca_id)
        REFERENCES MARCA(marca_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prod_proveedor    FOREIGN KEY (proveedor_id)
        REFERENCES PROVEEDOR(proveedor_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS IMAGEN_PRODUCTO (
    imagen_id   INT           NOT NULL AUTO_INCREMENT,
    producto_id INT           NOT NULL,
    url         VARCHAR(500)  NOT NULL,
    alt_text    VARCHAR(200)  NULL      COMMENT 'Texto alternativo para accesibilidad',
    orden       TINYINT       NOT NULL DEFAULT 0 COMMENT 'Posición en la galería',
    es_principal BOOLEAN      NOT NULL DEFAULT FALSE,

    CONSTRAINT pk_imagen_producto   PRIMARY KEY (imagen_id),
    CONSTRAINT fk_img_producto      FOREIGN KEY (producto_id)
        REFERENCES PRODUCTO(producto_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS ESPECIFICACION (
    especificacion_id INT           NOT NULL AUTO_INCREMENT,
    producto_id       INT           NOT NULL,
    clave             VARCHAR(100)  NOT NULL COMMENT 'Ej: RAM, Pantalla, Conectividad',
    valor             VARCHAR(300)  NOT NULL COMMENT 'Ej: 16 GB, 15.6", Wi-Fi 6',
    unidad            VARCHAR(20)   NULL      COMMENT 'Ej: GB, kg, pulgadas',
    orden             TINYINT       NOT NULL DEFAULT 0 COMMENT 'Posición en ficha técnica',

    CONSTRAINT pk_especificacion    PRIMARY KEY (especificacion_id),
    CONSTRAINT fk_espec_producto    FOREIGN KEY (producto_id)
        REFERENCES PRODUCTO(producto_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ------------------------------------------------------------
-- DOMINIO 3: Inventario
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS INVENTARIO (
    inventario_id       INT          NOT NULL AUTO_INCREMENT,
    producto_id         INT          NOT NULL,
    stock_actual        INT          NOT NULL DEFAULT 0 CHECK (stock_actual >= 0),
    stock_minimo        INT          NOT NULL DEFAULT 5  COMMENT 'Umbral de alerta de reposición',
    ubicacion_almacen   VARCHAR(50)  NULL      COMMENT 'Ej: A-12, Pasillo-3',
    fecha_actualizacion DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_inventario        PRIMARY KEY (inventario_id),
    CONSTRAINT uq_inventario_prod   UNIQUE (producto_id),
    CONSTRAINT fk_inv_producto      FOREIGN KEY (producto_id)
        REFERENCES PRODUCTO(producto_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ------------------------------------------------------------
-- DOMINIO 4: Carrito y pedidos
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS CUPON (
    cupon_id          INT           NOT NULL AUTO_INCREMENT,
    codigo            VARCHAR(30)   NOT NULL,
    tipo_descuento    ENUM('porcentaje','monto_fijo') NOT NULL,
    valor             DECIMAL(10,2) NOT NULL CHECK (valor > 0),
    minimo_compra     DECIMAL(10,2) NULL      COMMENT 'Monto mínimo para aplicar el cupón',
    usos_maximos      INT           NULL      COMMENT 'NULL = ilimitado',
    usos_actuales     INT           NOT NULL DEFAULT 0,
    fecha_inicio      DATE          NOT NULL,
    fecha_vencimiento DATE          NULL,
    activo            BOOLEAN       NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_cupon       PRIMARY KEY (cupon_id),
    CONSTRAINT uq_cupon_code  UNIQUE (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS CARRITO (
    carrito_id    INT           NOT NULL AUTO_INCREMENT,
    cliente_id    INT           NULL      COMMENT 'NULL cuando es comprador invitado',
    sesion_token  VARCHAR(255)  NULL      COMMENT 'Token para carritos de invitados',
    cupon_id      INT           NULL,
    creado_en     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                                ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_carrito       PRIMARY KEY (carrito_id),
    CONSTRAINT fk_car_cliente   FOREIGN KEY (cliente_id)
        REFERENCES CLIENTE(cliente_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_car_cupon     FOREIGN KEY (cupon_id)
        REFERENCES CUPON(cupon_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS DETALLE_CARRITO (
    detalle_id      INT           NOT NULL AUTO_INCREMENT,
    carrito_id      INT           NOT NULL,
    producto_id     INT           NOT NULL,
    cantidad        SMALLINT      NOT NULL CHECK (cantidad >= 1),
    precio_unitario DECIMAL(10,2) NOT NULL COMMENT 'Snapshot del precio al agregar al carrito',

    CONSTRAINT pk_detalle_carrito   PRIMARY KEY (detalle_id),
    CONSTRAINT uq_car_producto      UNIQUE (carrito_id, producto_id),
    CONSTRAINT fk_dcar_carrito      FOREIGN KEY (carrito_id)
        REFERENCES CARRITO(carrito_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_dcar_producto     FOREIGN KEY (producto_id)
        REFERENCES PRODUCTO(producto_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS PEDIDO (
    pedido_id          INT           NOT NULL AUTO_INCREMENT,
    cliente_id         INT           NOT NULL,
    numero_orden       VARCHAR(30)   NOT NULL COMMENT 'Ej: PCH-20260001',
    estado             ENUM('pendiente','pagado','enviado','entregado','cancelado')
                                     NOT NULL DEFAULT 'pendiente',
    subtotal           DECIMAL(10,2) NOT NULL,
    descuento          DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    impuesto           DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total              DECIMAL(10,2) NOT NULL,
    cupon_id           INT           NULL,
    direccion_envio_id INT           NOT NULL,
    creado_en          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_pedido            PRIMARY KEY (pedido_id),
    CONSTRAINT uq_pedido_numero     UNIQUE (numero_orden),
    CONSTRAINT fk_ped_cliente       FOREIGN KEY (cliente_id)
        REFERENCES CLIENTE(cliente_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ped_cupon         FOREIGN KEY (cupon_id)
        REFERENCES CUPON(cupon_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_ped_direccion     FOREIGN KEY (direccion_envio_id)
        REFERENCES DIRECCION(direccion_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS DETALLE_PEDIDO (
    detalle_id      INT           NOT NULL AUTO_INCREMENT,
    pedido_id       INT           NOT NULL,
    producto_id     INT           NOT NULL,
    cantidad        SMALLINT      NOT NULL CHECK (cantidad >= 1),
    precio_unitario DECIMAL(10,2) NOT NULL COMMENT 'Snapshot histórico del precio',
    subtotal_linea  DECIMAL(10,2) NOT NULL COMMENT 'cantidad × precio_unitario',

    CONSTRAINT pk_detalle_pedido    PRIMARY KEY (detalle_id),
    CONSTRAINT fk_dped_pedido       FOREIGN KEY (pedido_id)
        REFERENCES PEDIDO(pedido_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_dped_producto     FOREIGN KEY (producto_id)
        REFERENCES PRODUCTO(producto_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ------------------------------------------------------------
-- DOMINIO 5: Pagos y logística
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS PAGO (
    pago_id             INT           NOT NULL AUTO_INCREMENT,
    pedido_id           INT           NOT NULL,
    metodo              ENUM('tarjeta','paypal','transferencia','oxxo','otro')
                                      NOT NULL,
    monto               DECIMAL(10,2) NOT NULL CHECK (monto > 0),
    moneda              CHAR(3)       NOT NULL DEFAULT 'MXN' COMMENT 'ISO 4217',
    estado              ENUM('pendiente','pagado','fallido','reembolsado')
                                      NOT NULL DEFAULT 'pendiente',
    referencia_externa  VARCHAR(200)  NULL      COMMENT 'ID del gateway de pago',
    fecha_pago          DATETIME      NULL,

    CONSTRAINT pk_pago          PRIMARY KEY (pago_id),
    CONSTRAINT fk_pago_pedido   FOREIGN KEY (pedido_id)
        REFERENCES PEDIDO(pedido_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS ENVIO (
    envio_id        INT           NOT NULL AUTO_INCREMENT,
    pedido_id       INT           NOT NULL,
    transportista   VARCHAR(80)   NOT NULL COMMENT 'Ej: FedEx, DHL, Estafeta',
    numero_guia     VARCHAR(100)  NULL,
    estado          ENUM('preparando','en_camino','entregado','devuelto')
                                  NOT NULL DEFAULT 'preparando',
    costo_envio     DECIMAL(8,2)  NOT NULL DEFAULT 0.00,
    fecha_estimada  DATE          NULL,
    fecha_entrega   DATETIME      NULL      COMMENT 'Fecha real de entrega',
    url_rastreo     VARCHAR(500)  NULL,

    CONSTRAINT pk_envio         PRIMARY KEY (envio_id),
    CONSTRAINT fk_envio_pedido  FOREIGN KEY (pedido_id)
        REFERENCES PEDIDO(pedido_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ------------------------------------------------------------
-- DOMINIO 6: Postventa
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS RESENA (
    resena_id    INT       NOT NULL AUTO_INCREMENT,
    producto_id  INT       NOT NULL,
    cliente_id   INT       NOT NULL,
    pedido_id    INT       NOT NULL COMMENT 'Verifica que el cliente haya comprado el producto',
    calificacion TINYINT   NOT NULL CHECK (calificacion BETWEEN 1 AND 5),
    titulo       VARCHAR(150) NULL,
    comentario   TEXT      NULL,
    aprobada     BOOLEAN   NOT NULL DEFAULT FALSE COMMENT 'Pendiente de moderación',
    creada_en    DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_resena            PRIMARY KEY (resena_id),
    CONSTRAINT uq_resena_unica      UNIQUE (producto_id, cliente_id, pedido_id),
    CONSTRAINT fk_res_producto      FOREIGN KEY (producto_id)
        REFERENCES PRODUCTO(producto_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_res_cliente       FOREIGN KEY (cliente_id)
        REFERENCES CLIENTE(cliente_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_res_pedido        FOREIGN KEY (pedido_id)
        REFERENCES PEDIDO(pedido_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- ÍNDICES RECOMENDADOS
-- ============================================================

-- CLIENTE
CREATE INDEX idx_cliente_estado        ON CLIENTE(estado);

-- PRODUCTO
CREATE INDEX idx_producto_categoria    ON PRODUCTO(categoria_id);
CREATE INDEX idx_producto_marca        ON PRODUCTO(marca_id);
CREATE INDEX idx_producto_proveedor    ON PRODUCTO(proveedor_id);
CREATE INDEX idx_producto_activo       ON PRODUCTO(activo);
CREATE INDEX idx_producto_precio       ON PRODUCTO(precio_regular);

-- INVENTARIO
CREATE INDEX idx_inv_stock_actual      ON INVENTARIO(stock_actual);

-- CARRITO
CREATE INDEX idx_carrito_cliente       ON CARRITO(cliente_id);
CREATE INDEX idx_carrito_token         ON CARRITO(sesion_token);

-- DETALLE_CARRITO
CREATE INDEX idx_dcar_producto         ON DETALLE_CARRITO(producto_id);

-- PEDIDO
CREATE INDEX idx_pedido_cliente        ON PEDIDO(cliente_id);
CREATE INDEX idx_pedido_estado         ON PEDIDO(estado);
CREATE INDEX idx_pedido_creado         ON PEDIDO(creado_en);

-- DETALLE_PEDIDO
CREATE INDEX idx_dped_producto         ON DETALLE_PEDIDO(producto_id);

-- PAGO
CREATE INDEX idx_pago_estado           ON PAGO(estado);
CREATE INDEX idx_pago_referencia       ON PAGO(referencia_externa);

-- ENVIO
CREATE INDEX idx_envio_estado          ON ENVIO(estado);
CREATE INDEX idx_envio_guia            ON ENVIO(numero_guia);

-- RESENA
CREATE INDEX idx_res_producto          ON RESENA(producto_id);
CREATE INDEX idx_res_calificacion      ON RESENA(calificacion);
CREATE INDEX idx_res_aprobada          ON RESENA(aprobada);


SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- FIN DEL SCRIPT  bdpchop.sql
-- ============================================================
