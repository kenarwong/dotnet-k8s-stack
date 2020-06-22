import { Component, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';

import { EnvService } from '../service/env.service';

@Component({
  selector: 'app-api-info',
  templateUrl: './api-info.component.html'
})
export class ApiInfoComponent {
  public apiInfo: ApiInfo;

  constructor(
    http: HttpClient,
    private env: EnvService
  ) {
    http.get<ApiInfo>(env.apiUrl + 'info').subscribe(result => {
      this.apiInfo = result;
    }, error => console.error(error));
  }
}

interface ApiInfo {
  apiEnvironment: string;
  hostname: string;
}
