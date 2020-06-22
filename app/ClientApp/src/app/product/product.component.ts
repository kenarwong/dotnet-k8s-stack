import { Component, Inject } from '@angular/core';

import { Product } from '../model/product';
import { ProductService } from './product.service';

@Component({
  selector: 'app-product',
  templateUrl: './product.component.html'
})
export class ProductComponent {
  public product: Product;
  private productNumber: number;

  public products: Product[];

  constructor(
    private productService: ProductService
  ) {
    this.productService
      .list()
      .subscribe(
        result => {
          this.products = result;
        },
        error => console.error(error)
      );
  }

  // /**
  //  * Get product and assign to property
  //  * getProduct(id)
  //  */
  // public getProduct(id: number) {
  //   if (id) {
  //     this.productService
  //       .get(id)
  //       .subscribe(
  //         result => {
  //           this.product = result;
  //         },
  //         error => console.error(error)
  //       );
  //   }
  // }
}
