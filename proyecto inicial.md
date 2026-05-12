Aquí está el análisis completo de las entidades necesarias para PChop:Las entidades se agrupan en **6 dominios principales**:
<img width="1348" height="476" alt="image" src="https://github.com/user-attachments/assets/094cf82c-5a3d-4401-ab18-11a663338b3e" />

---

**Clientes y autenticación**
- `CLIENTE` — datos personales, estado de cuenta, historial
- `DIRECCION` — múltiples direcciones por cliente (envío y facturación)

**Catálogo de productos**
- `PRODUCTO` — núcleo del catálogo con SKU, precios, oferta
- `CATEGORIA` — árbol jerárquico (ej: Electrónicos → Computadoras → Laptops)
- `MARCA` — Apple, Samsung, Logitech, etc.
- `IMAGEN_PRODUCTO` — múltiples imágenes ordenadas por producto
- `ESPECIFICACION` — atributos técnicos clave-valor (RAM, pantalla, conectividad)

**Inventario y proveedores**
- `INVENTARIO` — stock actual, mínimo y ubicación en almacén
- `PROVEEDOR` — quién suministra cada producto

**Carrito y pedidos**
- `CARRITO` + `DETALLE_CARRITO` — sesión de compra persistente
- `PEDIDO` + `DETALLE_PEDIDO` — historial de órdenes confirmadas
- `CUPON` — descuentos por código, con control de usos y vencimiento

**Pagos y logística**
- `PAGO` — método, monto, estado (pagado, reembolsado, pendiente)
- `ENVIO` — número de guía, transportista, estado de entrega

**Postventa**
- `RESENA` — calificación y comentario por producto, vinculada al cliente

---

¿Quieres que profundice en algún dominio? Por ejemplo puedo diseñar el esquema completo con tipos de datos, índices recomendados, o las reglas de negocio (constraints) para alguna de estas entidades.

Las entidades con sus atributos y tipo, en forma de tabla para cada uno de las entidades

## Tablas

<img width="791" height="504" alt="image" src="https://github.com/user-attachments/assets/32078503-6362-424f-b72a-e5ff888719af" />

<img width="753" height="713" alt="image" src="https://github.com/user-attachments/assets/56e5ecbf-2a23-4b3f-bfaf-03690e41753e" />

<img width="739" height="703" alt="image" src="https://github.com/user-attachments/assets/2182c0e3-7f5c-4efd-9b85-2832293d84bd" />

<img width="745" height="343" alt="image" src="https://github.com/user-attachments/assets/f9bf88a9-fe78-4cb0-b0dc-8d24627e3965" />

<img width="734" height="544" alt="image" src="https://github.com/user-attachments/assets/3677115e-1329-4b52-9ffb-62c388430755" />

<img width="373" height="408" alt="image" src="https://github.com/user-attachments/assets/79f6bcdd-dd71-407c-97b6-6fbed40bfc82" />

<img width="741" height="474" alt="image" src="https://github.com/user-attachments/assets/7c10e5af-02f7-4d30-a116-f2b110fbe76a" />

<img width="450" height="384" alt="image" src="https://github.com/user-attachments/assets/2fad5c63-f13b-429a-a700-697be4659a00" />

