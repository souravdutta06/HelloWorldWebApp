using HelloWorldWebApp.Web.Services;
using Microsoft.AspNetCore.Mvc;

public class HomeController : Controller
{
    private readonly IMessageService _messageService;

    public HomeController(IMessageService messageService)
    {
        _messageService = messageService;
    }

    public IActionResult Index()
    {
        var message = _messageService.GetMessage();
        ViewData["Message"] = message;
        return View();
    }
}
