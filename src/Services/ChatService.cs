using System.Text;
using System.Text.Json;
using Azure.Identity;
using ZavaStorefront.Models;

namespace ZavaStorefront.Services
{
    public interface IChatService
    {
        Task<ChatResponse> SendMessageAsync(string message);
    }

    public class ChatService : IChatService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;
        private readonly ILogger<ChatService> _logger;
        private readonly DefaultAzureCredential _credential;

        public ChatService(HttpClient httpClient, IConfiguration configuration, ILogger<ChatService> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _logger = logger;
            
            // Specify the tenant ID to use the correct Azure AD tenant
            var tenantId = configuration["AzureAI:TenantId"] 
                ?? Environment.GetEnvironmentVariable("AZURE_TENANT_ID");
            
            var options = new DefaultAzureCredentialOptions();
            if (!string.IsNullOrEmpty(tenantId))
            {
                options.TenantId = tenantId;
            }
            // Prefer Azure CLI credential for local development
            options.ExcludeVisualStudioCredential = true;
            options.ExcludeVisualStudioCodeCredential = true;
            
            _credential = new DefaultAzureCredential(options);
        }

        public async Task<ChatResponse> SendMessageAsync(string message)
        {
            try
            {
                var endpoint = _configuration["AzureAI:Endpoint"] 
                    ?? Environment.GetEnvironmentVariable("AZURE_AI_FOUNDRY_ENDPOINT");
                var deploymentName = _configuration["AzureAI:DeploymentName"] ?? "gpt-4o";

                if (string.IsNullOrEmpty(endpoint))
                {
                    _logger.LogWarning("Azure AI endpoint not configured");
                    return new ChatResponse
                    {
                        Success = false,
                        ErrorMessage = "Chat service is not configured. Please configure Azure AI settings."
                    };
                }

                var requestBody = new
                {
                    messages = new[]
                    {
                        new { role = "system", content = "You are a helpful assistant for Zava Storefront, an e-commerce platform. Help customers with questions about products, pricing, and general inquiries. Keep responses concise and helpful." },
                        new { role = "user", content = message }
                    },
                    max_tokens = 800,
                    temperature = 0.7
                };

                var json = JsonSerializer.Serialize(requestBody);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                // Get Azure AD token for Azure OpenAI
                var tokenResult = await _credential.GetTokenAsync(
                    new Azure.Core.TokenRequestContext(new[] { "https://cognitiveservices.azure.com/.default" }));

                _httpClient.DefaultRequestHeaders.Clear();
                _httpClient.DefaultRequestHeaders.Authorization = 
                    new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", tokenResult.Token);

                var requestUrl = $"{endpoint.TrimEnd('/')}/openai/deployments/{deploymentName}/chat/completions?api-version=2024-02-15-preview";
                
                _logger.LogInformation("Sending request to Azure AI: {Url}", requestUrl);
                
                var response = await _httpClient.PostAsync(requestUrl, content);

                if (response.IsSuccessStatusCode)
                {
                    var responseContent = await response.Content.ReadAsStringAsync();
                    var jsonDoc = JsonDocument.Parse(responseContent);
                    
                    var assistantMessage = jsonDoc.RootElement
                        .GetProperty("choices")[0]
                        .GetProperty("message")
                        .GetProperty("content")
                        .GetString();

                    _logger.LogInformation("Received successful response from Azure AI");
                    
                    return new ChatResponse
                    {
                        Success = true,
                        Response = assistantMessage ?? "No response received."
                    };
                }
                else
                {
                    var errorContent = await response.Content.ReadAsStringAsync();
                    _logger.LogError("Azure AI request failed: {StatusCode} - {Error}", response.StatusCode, errorContent);
                    
                    return new ChatResponse
                    {
                        Success = false,
                        ErrorMessage = $"Failed to get response from AI service. Status: {response.StatusCode}"
                    };
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calling Azure AI service");
                return new ChatResponse
                {
                    Success = false,
                    ErrorMessage = "An error occurred while processing your request."
                };
            }
        }
    }
}
