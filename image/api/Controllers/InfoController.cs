using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using api.Model;

namespace api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class InfoController : ControllerBase
    {
        // GET: api/Info
        [HttpGet]
        public Info GetInfo()
        {
            return new Info {
                ApiEnvironment = Environment.GetEnvironmentVariable("APP_ENVIRONMENT"),
                Hostname = Environment.GetEnvironmentVariable("HOSTNAME")
            };
        }
    }
}
