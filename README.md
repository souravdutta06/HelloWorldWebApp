# HelloWorldWebApp

A modern ASP.NET Core MVC web application built with .NET 8, featuring:

- ✅ MVC Architecture  
- ✅ Bootstrap 5 (Dark Mode UI)  
- ✅ Dependency Injection  
- ✅ Unit Testing with xUnit  
- ✅ Docker-Ready

## 🔧 Tech Stack

| Layer              | Technology          |
|-------------------|---------------------|
| Backend Framework | ASP.NET Core MVC (.NET 8) |
| UI Styling        | Bootstrap 5 (via CDN) |
| Testing           | xUnit (.NET Test SDK) |
| Dependency Injection | Built-in .NET DI |
| Project Type      | Web + Unit Test Solution |

## 🏗️ Project Structure

```
HelloWorldWebApp/
├── HelloWorldWebApp.Web/      # ASP.NET Core MVC App
│   ├── Controllers/           # HomeController using DI
│   ├── Services/              # IMessageService + MessageService
│   └── Views/                 # Razor Views with Bootstrap (Dark)
├── HelloWorldWebApp.Tests/    # xUnit test project
├── HelloWorldWebApp.sln       # Solution file
└── .gitignore
```

## 🚀 How to Run

```bash
git clone https://github.com/yourusername/HelloWorldWebApp.git
cd HelloWorldWebApp

# Run the web app
cd HelloWorldWebApp.Web
dotnet run
```

Then open `https://localhost:5001` or `http://localhost:5000`.

## 🧪 How to Run Unit Tests

```bash
cd HelloWorldWebApp.Tests
dotnet test
```

## 🐳 Docker

### Build Image

```bash
docker build -t helloworld-webapp -f HelloWorldWebApp.Web/Dockerfile .
```

### Run Container

```bash
docker run -d -p 8080:80 --name webapp-container helloworld-webapp
```

Then visit: [http://localhost:8080](http://localhost:8080)

## 👤 Author

**Sourav Dutta**

## 📜 License

This project is open-source and available under the MIT License.