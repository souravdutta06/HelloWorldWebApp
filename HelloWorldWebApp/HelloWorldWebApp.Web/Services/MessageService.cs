namespace HelloWorldWebApp.Web.Services;

public class MessageService : IMessageService
{
    public string GetMessage()
    {
        return "Hello World from Sourav Dutta!";
    }
}
