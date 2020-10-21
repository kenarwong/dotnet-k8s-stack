import { Component } from '@angular/core';

import { EnvService } from '../service/env.service';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
})
export class HomeComponent {
  public hostname: string;
  public githubUrl: string;
  
  constructor(
    private env: EnvService
  ) {
    this.hostname = env.hostname;
    this.githubUrl = env.githubUrl;
  }

}
