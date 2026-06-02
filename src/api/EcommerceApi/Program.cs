using Azure.Identity;
using Microsoft.EntityFrameworkCore;
using Scalar.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

// Connect to Key Vault
var keyVaultUri = new Uri($"https://{builder.Configuration["KeyVaultName"]}.vault.azure.net/");
builder.Configuration.AddAzureKeyVault(keyVaultUri, new DefaultAzureCredential());

builder.Services.AddControllers();
builder.Services.AddOpenApi();

// Register the Cosmos DB client as a singleton service.
builder.Services.AddSingleton(sp => {
    var config = sp.GetRequiredService<IConfiguration>();
    return new Microsoft.Azure.Cosmos.CosmosClient(config["CosmosConnectionString"]);
});

builder.Services.AddDbContext<EcommerceApi.Data.OrdersDbContext>(options =>
    options.UseSqlServer(builder.Configuration["SqlConnectionString"]));

builder.Services.AddApplicationInsightsTelemetry(options =>
    options.ConnectionString = builder.Configuration["AppInsightsConnectionString"]);

var app = builder.Build();

app.MapOpenApi();
app.MapScalarApiReference();
app.MapGet("/", () => Results.Redirect("/scalar/v1"));

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.Run();
