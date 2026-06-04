using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace functions;

public class DeadLetterMonitor
{
    private readonly ILogger<DeadLetterMonitor> _logger;

    public DeadLetterMonitor(ILogger<DeadLetterMonitor> logger)
    {
        _logger = logger;
    }

    [Function("DeadLetterMonitor")]
    public void Run(
        [ServiceBusTrigger(
            "orders-queue/$deadletterqueue",
            Connection = "ServiceBusConnectionString")]
        string messageBody,
        FunctionContext context)
    {
        // Log it so it appears in Application Insights.
        _logger.LogError(
            "Dead-lettered message detected: {Message}", messageBody);
    }
}