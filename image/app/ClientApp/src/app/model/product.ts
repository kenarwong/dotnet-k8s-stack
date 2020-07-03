export class Product {
    public productId: number;
    public name: string;
    public productNumber: number;
    public makeFlag: boolean;
    public finishedGoodsFlag: boolean;
    public Color: string;
    public safetyStockLevel: number;
    public reorderPoint: number;
    public standardCost: number;
    public listPrice: number;
    public size: number;
    public sizeUnitMeasureCode: number;
    public weightUnitMeasureCode: string;
    public weight: number;
    public daysToManufacture: number;
    public productLine: string;
    public class: string;
    public style: string;
    public productSubcategoryId: number;
    public productModelId: number;
    public sellStartDate: Date;
    public sellEndDate: Date;
    public discontinuedDate: Date;
    public rowguid: string;
    public modifiedDate: Date;

    // public virtual ProductModel ProductModel { get; set; }
    // public virtual ProductSubcategory ProductSubcategory { get; set; }
    // public virtual UnitMeasure SizeUnitMeasureCodeNavigation { get; set; }
    // public virtual UnitMeasure WeightUnitMeasureCodeNavigation { get; set; }
    // public virtual ICollection<BillOfMaterials> BillOfMaterialsComponent { get; set; }
    // public virtual ICollection<BillOfMaterials> BillOfMaterialsProductAssembly { get; set; }
    // public virtual ICollection<ProductCostHistory> ProductCostHistory { get; set; }
    // public virtual ICollection<ProductInventory> ProductInventory { get; set; }
    // public virtual ICollection<ProductListPriceHistory> ProductListPriceHistory { get; set; }
    // public virtual ICollection<ProductProductPhoto> ProductProductPhoto { get; set; }
    // public virtual ICollection<ProductReview> ProductReview { get; set; }
    // public virtual ICollection<ProductVendor> ProductVendor { get; set; }
    // public virtual ICollection<PurchaseOrderDetail> PurchaseOrderDetail { get; set; }
    // public virtual ICollection<ShoppingCartItem> ShoppingCartItem { get; set; }
    // public virtual ICollection<SpecialOfferProduct> SpecialOfferProduct { get; set; }
    // public virtual ICollection<TransactionHistory> TransactionHistory { get; set; }
    // public virtual ICollection<WorkOrder> WorkOrder { get; set; }

    constructor(
    ) {  }
}