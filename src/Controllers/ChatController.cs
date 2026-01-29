using Microsoft.AspNetCore.Mvc;
using ZavaStorefront.Models;
using ZavaStorefront.Services;

namespace ZavaStorefront.Controllers
{
    public class ChatController : Controller
    {
        private readonly IChatService _chatService;
        private readonly ILogger<ChatController> _logger;

        public ChatController(IChatService chatService, ILogger<ChatController> logger)
        {
            _chatService = chatService;
            _logger = logger;
        }

        public IActionResult Index()
        {
            _logger.LogInformation("Chat page accessed");
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> SendMessage([FromBody] ChatRequest request)
        {
            if (string.IsNullOrWhiteSpace(request?.Message))
            {
                return BadRequest(new ChatResponse
                {
                    Success = false,
                    ErrorMessage = "Message cannot be empty."
                });
            }

            _logger.LogInformation("Received chat message: {MessageLength} characters", request.Message.Length);
            
            var response = await _chatService.SendMessageAsync(request.Message);
            
            return Json(response);
        }
    }
}
