import { Component } from '@angular/core';

import { EnvService } from '../service/env.service';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
})
export class HomeComponent {
  public appEnvironment: string;
  public hostname: string;
  
  constructor(
    private env: EnvService
  ) {
    this.appEnvironment = env.appEnvironment;
    this.hostname = env.hostname;
  }

}
