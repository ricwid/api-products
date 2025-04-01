using api_products;

var products = new List<Product>
{
    new Product(1, "House Insurance", 10.99m),
    new Product(2, "Car Insurance", 20.49m),
    new Product(3, "Life Insurance", 15.00m)
};

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

var app = builder.Build();

app.MapOpenApi();
app.UseHttpsRedirection();

// 1. Get All Products
app.MapGet("/products", () => Results.Ok(products))
    .WithName("GetAllProducts")
    .WithTags("Products");

// 2. Get Product by ID
app.MapGet("/products/{id}", (int id) =>
    {
        var product = products.FirstOrDefault(p => p.Id == id);
        return product is not null ? Results.Ok(product) : Results.NotFound();
    })
    .WithName("GetProductById")
    .WithTags("Products");

// 3. Create Product
app.MapPost("/products", (Product newProduct) =>
    {
        products.Add(newProduct);
        return Results.Created($"/products/{newProduct.Id}", newProduct);
    })
    .WithName("CreateProduct")
    .WithTags("Products");

// 4. Update Product
app.MapPut("/products/{id}", (int id, Product updatedProduct) =>
    {
        var product = products.FirstOrDefault(p => p.Id == id);
        if (product is null) return Results.NotFound();

        // Update the product fields
        product = updatedProduct with { Id = id };

        // Update the in-memory list (to mimic database persistence)
        var index = products.FindIndex(p => p.Id == id);
        products[index] = product;

        return Results.NoContent();
    })
    .WithName("UpdateProduct")
    .WithTags("Products");

app.MapGet("/ping", () => Results.Ok("pong"))
    .WithName("Ping")
    .WithTags("Products");

app.Run();

