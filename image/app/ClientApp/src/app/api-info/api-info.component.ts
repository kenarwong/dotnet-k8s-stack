import { Component, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';

import { EnvService } from '../service/env.service';
import { ApiInfo } from '../model/apiInfo';

@Component({
  selector: 'app-api-info',
  templateUrl: './api-info.component.html'
})
export class ApiInfoComponent {
  public apiInfo: ApiInfo;
  public apiInfoUrl: string;

  constructor(
    http: HttpClient,
    private env: EnvService
  ) {
    this.apiInfoUrl = env.apiUrl + 'info';
    http.get<ApiInfo>(env.apiUrl + 'info').subscribe(result => {
      this.apiInfo = result;
    }, error => console.error(error));
  }
}
