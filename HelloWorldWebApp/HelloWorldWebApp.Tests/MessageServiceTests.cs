using HelloWorldWebApp.Web.Services;
using Xunit;

namespace HelloWorldWebApp.Tests;

public class MessageServiceTests
{
    [Fact]
    public void GetMessage_ReturnsHelloWorld()
    {
        // Arrange
        var service = new MessageService();

        // Act
        var message = service.GetMessage();

        // Assert
        Assert.Equal("Hello World from Sourav Dutta!", message);
    }
}
