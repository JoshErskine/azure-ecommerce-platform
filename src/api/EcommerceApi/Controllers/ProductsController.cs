using EcommerceApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Cosmos;

namespace EcommerceApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly CosmosClient _cosmosClient;
    private const string DatabaseName = "EcommerceDb";
    private const string ContainerName = "Products";

    public ProductsController(CosmosClient cosmosClient)
    {
        _cosmosClient = cosmosClient;
    }

    // GET api/products
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var container = _cosmosClient.GetContainer(DatabaseName, ContainerName);
        var query = container.GetItemQueryIterator<Product>("SELECT * FROM c");
        var results = new List<Product>();
        while (query.HasMoreResults)
        {
            var response = await query.ReadNextAsync();
            results.AddRange(response);
        }
        return Ok(results);
    }

    // GET api/products/{id}?category={category}
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(string id, [FromQuery] string category)
    {
        var container = _cosmosClient.GetContainer(DatabaseName, ContainerName);
        var response = await container.ReadItemAsync<Product>(id, new PartitionKey(category));
        return Ok(response.Resource);
    }

    // POST api/products
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] Product product)
    {
        var container = _cosmosClient.GetContainer(DatabaseName, ContainerName);
        var response = await container.CreateItemAsync(product, new PartitionKey(product.Category));
        return CreatedAtAction(nameof(GetById),
            new { id = product.Id, category = product.Category },
            response.Resource);
    }

    // DELETE api/products/{id}?category={category}
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id, [FromQuery] string category)
    {
        var container = _cosmosClient.GetContainer(DatabaseName, ContainerName);
        await container.DeleteItemAsync<Product>(id, new PartitionKey(category));
        return NoContent();
    }
}