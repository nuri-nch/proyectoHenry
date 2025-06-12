
SHOW INDEX FROM sales;
SHOW INDEX FROM products;
SHOW INDEX FROM employees;

-- ¿Cuáles fueron los 5 productos más vendidos (por cantidad total), y cuál fue el vendedor que más unidades vendió de cada uno? Una vez obtenga los resultados, en el análisis responde: ¿Hay algún vendedor que aparece más de una vez como el que más vendió un producto? ¿Algunos de estos vendedores representan más del 10% de la ventas de este producto?

  
  WITH top_products AS (
  SELECT productid, SUM(quantity) AS total_units
  FROM sales
  GROUP BY productid
  ORDER BY total_units DESC
  LIMIT 5
),
product_customers AS (
  SELECT productid, COUNT(DISTINCT customerid) AS unique_customers
  FROM sales
  WHERE productid IN (SELECT productid FROM top_products)
  GROUP BY productid
),
total_customers AS (
  SELECT COUNT(DISTINCT customerid) AS total FROM sales
)
SELECT tp.productid, tp.total_units, pc.unique_customers,
       ROUND(pc.unique_customers * 100.0 / tc.total, 2) AS customer_percentage
FROM top_products tp
JOIN product_customers pc ON tp.productid = pc.productid
CROSS JOIN total_customers tc
ORDER BY customer_percentage DESC;

-- RESPUESTA: los 5 productos mas vendidos (con el vendedor que mas los vendio) fueron: Yoghurt Tubes por Daphne King, Longos - Chiken Wings por Jean Vang, Thyme - Lemon: Fresh por Devon Brewer, Onion Powder por Devon Brewer y Cream Of Tartar por Sonya Dickson. El vendedor Devon Brewer aparecio como mejor vendedor de 2 productos (Thyme - Lemon: Fresh y Onion Powder). ninguno representa mas del 10% de la venta de ese producto.

-- ---------

-- Entre los 5 productos más vendidos, ¿cuántos clientes únicos compraron cada uno y qué proporción representa sobre el total de clientes? Analiza si ese porcentaje sugiere que el producto fue ampliamente adoptado entre los clientes o si, por el contrario, fue comprado por un grupo reducido que generó un volumen alto de ventas. Compara los porcentajes entre productos e identifica si alguno de ellos depende más de un segmento específico de clientes
WITH top_5_products AS (
    SELECT 
        productid,
        SUM(quantity) AS total_quantity
    FROM sales
    GROUP BY productid
    ORDER BY total_quantity DESC
    LIMIT 5
),
unique_customers_per_product AS (
    SELECT 
        s.productid,
        COUNT(DISTINCT s.customerid) AS unique_customers
    FROM sales s
    JOIN top_5_products t5 ON s.productid = t5.productid
    GROUP BY s.productid
),
total_customers AS (
    SELECT COUNT(DISTINCT customerid) AS total_customers
    FROM sales
)
SELECT 
    u.productid,
    p.productname,
    u.unique_customers,
    t.total_customers,
    ROUND(100.0 * u.unique_customers / t.total_customers, 2) AS porcentaje_clientes
FROM unique_customers_per_product u
JOIN total_customers t ON 1=1
JOIN products p ON u.productid = p.productid
ORDER BY porcentaje_clientes DESC;

-- RESPUESTA: Los 5 productos más vendidos fueron adoptados por aproximadamente el 14% del total de clientes, sin grandes diferencias entre ellos. Esto indica que su popularidad es generalizada entre la clientela y no depende de un grupo reducido de consumidores. El volumen de ventas no provino de pocos clientes haciendo compras grandes, sino de una base relativamente amplia de compradores.

-- -- -- -- 

-- ¿A qué categorías pertenecen los 5 productos más vendidos y qué proporción representan dentro del total de unidades vendidas de su categoría? Utiliza funciones de ventana para comparar la relevancia de cada producto dentro de su propia categoría.

WITH ventas_por_producto AS (
    SELECT 
        s.productid,
        SUM(s.quantity) AS total_unidades
    FROM sales s
    GROUP BY s.productid
),
ventas_con_categoria AS (
    SELECT 
        vpp.productid,
        p.categoryid,
        c.categoryname,
        vpp.total_unidades
    FROM ventas_por_producto vpp
    JOIN products p ON vpp.productid = p.productid
    JOIN categories c ON p.categoryid = c.categoryid
),
top_5_productos AS (
    SELECT *
    FROM ventas_con_categoria
    ORDER BY total_unidades DESC
    LIMIT 5
), 
ventas_categoria_total AS (
    SELECT 
        categoryid,
        SUM(total_unidades) AS total_categoria
    FROM ventas_con_categoria
    GROUP BY categoryid
)
SELECT 
    t5.productid,
    t5.total_unidades,
    t5.categoryname,
    ROUND(100.0 * t5.total_unidades / vct.total_categoria, 2) AS porcentaje_en_categoria
FROM top_5_productos t5
JOIN ventas_categoria_total vct ON t5.categoryid = vct.categoryid
ORDER BY porcentaje_en_categoria DESC;


-- RESPUESTA: los 5 productos pertenecen a las categorias Poultry(2,17%), Seafood(2,85%), Snails(2,77%), Beverages(2,68%), Meat(2,04%), 
 
-- -------

-- ¿Cuáles son los 10 productos con mayor cantidad de unidades vendidas en todo el catálogo y cuál es su posición dentro de su propia categoría? Utiliza funciones de ventana para identificar el ranking de cada producto en su categoría. Luego, analiza si estos productos son también los líderes dentro de sus categorías o si compiten estrechamente con otros productos de alto rendimiento. ¿Qué observas sobre la concentración de ventas dentro de algunas categorías?

WITH total_sales_per_product AS (
    SELECT 
        s.productid,
        SUM(s.quantity) AS total_quantity
    FROM sales s
    GROUP BY s.productid
),
top_10_products AS (
    SELECT
        tsp.productid,
        tsp.total_quantity,
        p.productname,
        p.categoryid
    FROM total_sales_per_product tsp
    JOIN products p ON tsp.productid = p.productid
    ORDER BY tsp.total_quantity DESC
    LIMIT 10
),
-- Calculamos ranking solo para los productos de esas categorías de los top 10
categories_of_interest AS (
    SELECT DISTINCT categoryid FROM top_10_products
),
ranked_products_in_category AS (
    SELECT
        p.productid,
        p.productname,
        p.categoryid,
        tsp.total_quantity,
        RANK() OVER (PARTITION BY p.categoryid ORDER BY tsp.total_quantity DESC) AS category_rank
    FROM products p
    JOIN total_sales_per_product tsp ON p.productid = tsp.productid
    WHERE p.categoryid IN (SELECT categoryid FROM categories_of_interest)
)
SELECT
    t.productid,
    t.productname,
    t.total_quantity,
    r.category_rank,
    c.categoryname
FROM top_10_products t
JOIN ranked_products_in_category r ON t.productid = r.productid
JOIN categories c ON t.categoryid = c.categoryid
ORDER BY t.total_quantity DESC;

-- RESPUESTA:  De los 10 productos más vendidos del catálogo, 7 son líderes en su categoría, es decir, tienen la mayor cantidad de unidades vendidas dentro de su grupo.
-- Los otros 3 productos ocupan posiciones secundarias dentro de su categoría , lo que sugiere que compiten estrechamente con otros productos de alto rendimiento.

-- --------------------------------------------------------------------------------------------------------------

-- SEGUNDO AVANCE 

CREATE TABLE IF NOT EXISTS monitoring_sales_threshold (
    id INT AUTO_INCREMENT PRIMARY KEY,
    productid INT NOT NULL,
    productname VARCHAR(255) NOT NULL,
    total_quantity INT NOT NULL,
    exceeded_date DATETIME NOT NULL
);

-- -- 

CREATE TRIGGER trg_after_insert_sale
AFTER INSERT ON sales
FOR EACH ROW
BEGIN
    -- Calcula la cantidad total vendida del producto nuevo
    SET @total_qty = (SELECT SUM(quantity) FROM sales WHERE productid = NEW.productid);

    -- Obtiene el nombre del producto
    SET @product_name = (SELECT productname FROM products WHERE productid = NEW.productid);

    -- Verifica si ya se registró la superación del umbral
    SET @already_recorded = (SELECT COUNT(*) FROM monitoring_sales_threshold WHERE productid = NEW.productid);

    IF @total_qty > 204000 AND @already_recorded = 0 THEN
        INSERT INTO monitoring_sales_threshold(productid, productname, total_quantity, exceeded_date)
        VALUES (NEW.productid, @product_name, @total_qty, NOW());
    END IF;
END;

-- --

SHOW TRIGGERS LIKE 'sales';  -- reviso que se creo el Trigger

-- --

INSERT INTO sales (salesid, productid, quantity, salespersonid, customerid, salesdate) -- agrego productos para ver
VALUES (NULL, 161, 1000, 5, 10, NOW());

-- --

SELECT * FROM monitoring_sales_threshold 

-- --

-- DROP TRIGGER IF EXISTS trg_after_insert_sale; ()

-- -- 

-- Registra una venta correspondiente al vendedor con ID 9, al cliente con ID 84, del producto con ID 103, por una cantidad de 1.876 unidades y un valor de 1200 unidades.

-- Consulta la tabla de monitoreo, toma captura de los resultados y realiza un análisis breve de lo ocurrido.

INSERT INTO sales (salesid, productid, quantity, totalprice, salespersonid, customerid, salesdate)
VALUES (NULL, 103, 1876, 1200, 9, 84, NOW());

-- Selecciona dos consultas del avance 1 y crea los índices que consideres más adecuados para optimizar su ejecución.
-- Prueba con índices individuales y compuestos, según la lógica de cada consulta. Luego, vuelve a ejecutar ambas consultas y compara los tiempos de ejecución antes y después de aplicar los índices. Finalmente, describe brevemente el impacto que tuvieron los índices en el rendimiento y en qué tipo de columnas resultan más efectivos para este tipo de operaciones.

CREATE INDEX idx_sales_productid ON sales(productid);

CREATE INDEX idx_sales_customerid ON sales(customerid);

CREATE INDEX idx_sales_product_customer ON sales(productid, customerid);























