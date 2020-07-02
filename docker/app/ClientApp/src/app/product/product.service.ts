import { Observable } from 'rxjs';
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { EnvService } from '../service/env.service';

import { Product } from '../model/product';

@Injectable({
    providedIn: 'root',
})
export class ProductService {

    constructor(
        private http: HttpClient,
        private env: EnvService
    ) {  }

    /**
     * Get Product
     * product/{id}
     */
    public get(id: number): Observable<Product> {
        return this.http.get<Product>(`${this.env.apiUrl}product/${id}`);
    }

    /**
     * List Products
     * product/ 
     */
    public list(): Observable<Product[]> {
        return this.http.get<Product[]>(`${this.env.apiUrl}product/`);
    }
}