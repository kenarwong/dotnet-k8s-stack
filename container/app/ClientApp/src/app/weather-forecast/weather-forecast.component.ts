import { Component, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';

import { EnvService } from '../service/env.service';

@Component({
  selector: 'app-weather-forecast',
  templateUrl: './weather-forecast.component.html'
})
export class WeatherForecastComponent {
  public forecasts: WeatherForecast[];

  constructor(
    http: HttpClient,
    private env: EnvService
  ) {
    http.get<WeatherForecast[]>(env.apiUrl + 'weatherforecast').subscribe(result => {
      this.forecasts = result;
    }, error => console.error(error));
  }
}

interface WeatherForecast {
  date: string;
  temperatureC: number;
  temperatureF: number;
  summary: string;
}
