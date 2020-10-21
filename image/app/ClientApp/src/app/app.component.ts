import { Component } from '@angular/core';

import { EnvService } from './service/env.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'app';
  public appEnvironment: string;
  
  constructor(
    private env: EnvService
  ) {
    this.appEnvironment = env.appEnvironment;
  }
}
