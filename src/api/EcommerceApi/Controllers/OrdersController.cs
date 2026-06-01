using EcommerceApi.Data;
using EcommerceApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EcommerceApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly OrdersDbContext _db;
    private readonly IConfiguration _configuration;

    public OrdersController(OrdersDbContext db, IConfiguration configuration)
    {
        _db = db;
        _configuration = configuration;
    }

    // GET api/orders
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var orders = await _db.Orders.ToListAsync();
        return Ok(orders);
    }

    // GET api/orders/{id}
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var order = await _db.Orders.FindAsync(id);
        if (order == null) return NotFound();
        return Ok(order);
    }

    // POST api/orders
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] Order order)
    {
        _db.Orders.Add(order);
        await _db.SaveChangesAsync();
        
        // Publish event to Service Bus
        var connectionString = _configuration["ServiceBusConnectionString"];
        await using var client = new Azure.Messaging.ServiceBus.ServiceBusClient(connectionString);
        var sender = client.CreateSender("orders-queue");
        var messageBody = System.Text.Json.JsonSerializer.Serialize(order);
        var message = new Azure.Messaging.ServiceBus.ServiceBusMessage(messageBody);
        await sender.SendMessageAsync(message);

        return CreatedAtAction(nameof(GetById), new { id = order.Id }, order);

    }
}