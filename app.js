// ########################################
// ########## SETUP

// Express
const express = require('express');
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

//dotENV
require('dotenv').config();

const PORT = process.env.PORT;

// Database
const db = require('./database/db-connector');

// Handlebars
const { engine } = require('express-handlebars'); // Import express-handlebars engine
app.engine('.hbs', engine({ extname: '.hbs' })); // Create instance of handlebars
app.set('view engine', '.hbs'); // Use handlebars engine for *.hbs files.

// ########################################
// ########## ROUTE HANDLERS

// READ ROUTES
app.get('/', async function (req, res) {
    try {
        res.render('home'); // Render the home.hbs file
    } catch (error) {
        console.error('Error rendering page:', error);
        // Send a generic error message to the browser
        res.status(500).send('An error occurred while rendering the page.');
    }
});

app.get('/products', async function (req, res) {
    try {
        query1 = "SELECT productID AS 'ID', productName AS 'Name', productPrice AS 'Price', \
            productStock AS 'Stock', Categories.categoryName AS 'Category' FROM Products \
            LEFT JOIN Categories ON Products.categoryID = Categories.categoryID;";
        query2 = 'SELECT * FROM Categories;';
        const [products] = await db.query(query1);
        const [categories] = await db.query(query2);
        res.render('products', { products: products, categories: categories });
    }
    catch (error) {
        console.error('Error executing query:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database query.'
        );
    }
});

app.get('/restockorders', async function (req, res) {
    try {
        query1 = 'SELECT orderID, DATE_FORMAT(orderDate, "%m-%d-%Y") AS orderDate, totalCost, CASE WHEN isDelivered = 1 THEN "Yes" ELSE "No" END AS isDelivered, \
            Suppliers.supplierName as "Supplier", CONCAT(Employees.fName, " ", Employees.lName) as "Employee" FROM RestockOrders \
            LEFT JOIN Suppliers ON RestockOrders.supplierID = Suppliers.supplierID \
            LEFT JOIN Employees ON RestockOrders.employeeID = Employees.employeeID;';
        const [restockOrders] = await db.query(query1);
        res.render('restockOrders', { restockOrders: restockOrders });
    }
    catch (error) {
        console.error('Error executing query:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database query.'
        );
    }
});

app.get('/productrestockdetails', async function (req, res) {
    try {
        query1 = 'SELECT detailsID, orderID, Products.productName as "Product", \
            quantityOrdered, singlePrice, totalPrice FROM ProductRestockDetails \
            LEFT JOIN Products ON ProductRestockDetails.productID = Products.productID;';
        const [details] = await db.query(query1);
        res.render('productRestockDetails', { details: details });
    }
    catch (error) {
        console.error('Error executing query:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database query.'
        );
    }
});

app.get('/employees', async function (req, res) {
    try {
        query1 = 'SELECT employeeID, fName, lName, email, phone FROM Employees;';
        const [employees] = await db.query(query1);
        res.render('employees', { employees: employees });
    }
    catch (error) {
        console.error('Error executing query:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database query.'
        );
    }
});

app.get('/suppliers', async function (req, res) {
    try {
        query1 = 'SELECT supplierID, supplierName, phone, \
            email, address, state, zip, country, city \
            FROM Suppliers;';
        const [suppliers] = await db.query(query1);
        res.render('suppliers', { suppliers: suppliers });
    }
    catch (error) {
        console.error('Error executing query:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database query.'
        );
    }
});

app.get('/categories', async function (req, res) {
    try {
        query1 = 'SELECT categoryID , categoryName FROM Categories;';
        const [categories] = await db.query(query1);
        res.render('categories', { categories: categories });
    }
    catch (error) {
        console.error('Error executing query:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database query.'
        );
    }
});

app.get('/productssuppliers', async function (req, res) {
    try {
        query1 = 'SELECT Products_Suppliers.proSupID, Products.productName, Suppliers.supplierName \
            FROM Products_Suppliers \
            LEFT JOIN Products ON Products_Suppliers.productID = Products.productID \
            LEFT JOIN Suppliers ON Products_Suppliers.supplierID = Suppliers.supplierID;';
        query2 = 'SELECT * FROM Products;';
        query3 = 'SELECT * FROM Suppliers;';
        const [suppliers] = await db.query(query3);
        const [products] = await db.query(query2);
        const [productSuppliers] = await db.query(query1);
        res.render('productssuppliers', { productSuppliers: productSuppliers, suppliers: suppliers, products: products });
    }
    catch (error) {
        console.error('Error executing query:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database query.'
        );
    }
});

app.post('/products/create', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;

        if (isNaN(parseInt(data.create_product_stock)))
            data.create_product_stock = null;

        // Create and execute our queries
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_CreateProduct(?, ?, ?, ?, @new_id);`;

        // Store ID of last inserted row
        const [[[rows]]] = await db.query(query1, [
            data.create_product_name,
            data.create_product_price,
            data.create_product_stock,
            data.create_category,
        ]);

        console.log(`CREATE product. ID: ${rows.new_id} ` +
            `Name: ${data.create_product_name}`
        );

        // Redirect the user to the updated webpage
        res.redirect('/products');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.post('/reset', async function (req, res) {
    try {
        const query1 = `CALL sp_ResetDatabase;`;

        await db.query(query1);

        console.log('Database reset to initial state.');

        res.redirect(req.get('referer') || '/');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

// ########################################
// ########## LISTENER

app.listen(PORT, function () {
    console.log(
        'Express started on http://localhost:' +
            PORT +
            '; press Ctrl-C to terminate.'
    );
});