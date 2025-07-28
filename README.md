# Monokera Event Sync

Sistema de sincronización de eventos entre microservicios usando RabbitMQ y Redis.

## 🏗️ Diagrama de Arquitectura

![Arquitectura](docs/arquitectura.png)

```

## 🚀 Quick Start

### Prerrequisitos
- Docker y Docker Compose
- Ruby 3.3.8 (para desarrollo local)

### 1. Clonar el repositorio
```bash
git clone <repository-url>
cd monokera-event-sync
```

### 2. Iniciar todos los servicios
```bash
docker-compose up -d
```

### 3. Verificar que todo esté funcionando
```bash
# Verificar servicios
docker-compose ps

# Ver logs
docker-compose logs -f
```

## 📡 Endpoints Disponibles

### Order Service (Puerto 3001)
- `POST /orders` - Crear una nueva orden
- `GET /orders?customer_id=X` - Obtener órdenes por cliente
- `GET /up` - Health check
- `GET /api-docs` - Documentación de API

### Customer Service (Puerto 3002)
- `GET /customers` - Listar todos los clientes
- `GET /customers/:id` - Obtener cliente específico
- `PUT /customers/:id` - Actualizar cliente
- `GET /up` - Health check
- `GET /api-docs` - Documentación de API

### RabbitMQ Management (Puerto 15672)
- Usuario: `guest`
- Contraseña: `guest`

## 🔧 Configuración

### Variables de Entorno
```bash
# Order Service
DATABASE_HOST=postgres_order
DATABASE_USER=postgres
DATABASE_PASSWORD=password
DATABASE_NAME=orders_development
DATABASE_PORT=5432
RABBITMQ_URL=amqp://guest:guest@rabbitmq:5672
REDIS_URL=redis://redis:6379/0
CUSTOMER_SERVICE_URL=http://customer_service:3000

# Customer Service
DATABASE_HOST=postgres_customer
DATABASE_USER=postgres
DATABASE_PASSWORD=password
DATABASE_NAME=customers_development
DATABASE_PORT=5432
RABBITMQ_URL=amqp://guest:guest@rabbitmq:5672
REDIS_URL=redis://redis:6379/0
```

## 📝 Uso de la API

### 1. Crear un cliente
```bash
curl -X PUT http://localhost:3002/customers/1 \
  -H "Content-Type: application/json" \
  -d '{
    "customer": {
      "name": "Juan Pérez",
      "address": "Calle 123, Ciudad"
    }
  }'
```

### 2. Crear una orden
```bash
curl -X POST http://localhost:3001/orders \
  -H "Content-Type: application/json" \
  -d '{
    "order": {
      "customer_id": 1,
      "product_name": "Laptop",
      "quantity": 1,
      "price": 999.99,
      "status": "pending"
    }
  }'
```

### 3. Verificar el contador de órdenes
```bash
curl http://localhost:3002/customers/1
```

## 🧪 Testing

### Ejecutar tests
```bash
# Order Service
docker-compose exec order_service bundle exec rspec

# Customer Service
docker-compose exec customer_web bundle exec rspec
```

### Cobertura de código
Los reportes de cobertura se generan en `coverage/index.html` después de ejecutar los tests.

## 🔍 Monitoreo

### Health Checks
- Order Service: `http://localhost:3001/up`
- Customer Service: `http://localhost:3002/up`

### RabbitMQ Management
- URL: `http://localhost:15672`
- Usuario: `guest`
- Contraseña: `guest`

### Logs
```bash
# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f order_service
docker-compose logs -f customer_web
docker-compose logs -f customer_workers
```

## 🛠️ Desarrollo

### Estructura del Proyecto
```
monokera-event-sync/
├── docker-compose.yml          # Configuración de servicios
├── services/
│   ├── order_service/          # Servicio de órdenes
│   │   ├── app/
│   │   │   ├── controllers/    # Controladores REST
│   │   │   ├── models/         # Modelos de datos
│   │   │   └── services/       # Lógica de negocio
│   │   └── spec/               # Tests
│   └── customer_service/       # Servicio de clientes
│       ├── app/
│       │   ├── controllers/    # Controladores REST
│       │   ├── models/         # Modelos de datos
│       │   ├── workers/        # Workers de Sneakers
│       │   └── services/       # Lógica de negocio
│       └── spec/               # Tests
```

### Flujo de Eventos
1. **Order Service** recibe una petición para crear una orden
2. Valida que el cliente existe usando caché de Redis
3. Crea la orden en la base de datos
4. Publica un evento `order_created` en RabbitMQ
5. **Customer Service** recibe el evento via Sneakers worker
6. Actualiza el contador de órdenes del cliente
7. Invalida el caché del cliente en Redis

## 🚨 Troubleshooting

### Problemas Comunes

#### 1. Error de conexión a base de datos
```bash
# Verificar que PostgreSQL esté corriendo
docker-compose ps postgres_order postgres_customer

# Recrear las bases de datos
docker-compose down -v
docker-compose up -d
```

#### 2. Error de conexión a RabbitMQ
```bash
# Verificar que RabbitMQ esté corriendo
docker-compose ps rabbitmq

# Ver logs de RabbitMQ
docker-compose logs rabbitmq
```

#### 3. Workers no procesan eventos
```bash
# Verificar que el worker esté corriendo
docker-compose ps customer_workers

# Ver logs del worker
docker-compose logs customer_workers
```

## 📊 Métricas y Performance

### Monitoreo de Colas
- RabbitMQ Management UI: `http://localhost:15672`
- Verificar cola `order_events_queue` para eventos pendientes

### Caché de Redis
- Los clientes se cachean por 1 semana (604800 segundos)
- Se invalida automáticamente al actualizar un cliente
