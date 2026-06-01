using Azure.Storage.Blobs;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace functions
{
    public class ProcessOrder
    {
        private readonly ILogger<ProcessOrder> _logger;

        public ProcessOrder(ILogger<ProcessOrder> logger)
        {
            _logger = logger;
        }

        [Function("ProcessOrder")]
        public async Task Run(
            [ServiceBusTrigger("orders-queue", Connection = "ServiceBusConnectionString")]
            string messageBody)
        {
            _logger.LogInformation("Processing order: {Message}", messageBody);

            // Deserialize the order
            var order = System.Text.Json.JsonSerializer.Deserialize<OrderMessage>(messageBody);
            if (order is null)
            {
                _logger.LogWarning("Received null or invalid order message: {Message}", messageBody);
                return;
            }
            
            // Generate a simple invoice text
            var invoice = $"""
                INVOICE
                Order ID: {order.Id}
                Customer: {order.CustomerId}
                Product: {order.ProductName}
                Quantity: {order.Quantity}
                Total: {order.TotalPrice:C}
                Date: {DateTime.UtcNow}
                """;

            // Upload invoice to Blob Storage
            var blobConnectionString = Environment.GetEnvironmentVariable("BlobStorageConnectionString");
            if (string.IsNullOrWhiteSpace(blobConnectionString))
            {
                _logger.LogError("BlobStorageConnectionString is not configured. Cannot upload invoice for order {OrderId}.", order.Id);
                return;
            }

            var blobServiceClient = new BlobServiceClient(blobConnectionString);
            var containerClient = blobServiceClient.GetBlobContainerClient("invoices");
            await containerClient.CreateIfNotExistsAsync();

            var blobClient = containerClient.GetBlobClient($"invoice-{order.Id}.txt");
            using var stream = new MemoryStream(
                System.Text.Encoding.UTF8.GetBytes(invoice));
            await blobClient.UploadAsync(stream, overwrite: true);

            _logger.LogInformation("Invoice generated for order {OrderId}", order.Id);
        }
    }

    public record OrderMessage(int Id, string CustomerId, string ProductName,
        int Quantity, decimal TotalPrice);
}

