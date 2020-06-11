﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace api.Model
{
    [Table("PurchaseOrderDetail", Schema = "Purchasing")]
    public partial class PurchaseOrderDetail
    {
        [Key]
        [Column("PurchaseOrderID")]
        public int PurchaseOrderId { get; set; }
        [Key]
        [Column("PurchaseOrderDetailID")]
        public int PurchaseOrderDetailId { get; set; }
        [Column(TypeName = "datetime")]
        public DateTime DueDate { get; set; }
        public short OrderQty { get; set; }
        [Column("ProductID")]
        public int ProductId { get; set; }
        [Column(TypeName = "money")]
        public decimal UnitPrice { get; set; }
        [Column(TypeName = "money")]
        public decimal LineTotal { get; set; }
        [Column(TypeName = "decimal(8, 2)")]
        public decimal ReceivedQty { get; set; }
        [Column(TypeName = "decimal(8, 2)")]
        public decimal RejectedQty { get; set; }
        [Column(TypeName = "decimal(9, 2)")]
        public decimal StockedQty { get; set; }
        [Column(TypeName = "datetime")]
        public DateTime ModifiedDate { get; set; }

        [ForeignKey(nameof(ProductId))]
        [InverseProperty("PurchaseOrderDetail")]
        public virtual Product Product { get; set; }
        [ForeignKey(nameof(PurchaseOrderId))]
        [InverseProperty(nameof(PurchaseOrderHeader.PurchaseOrderDetail))]
        public virtual PurchaseOrderHeader PurchaseOrder { get; set; }
    }
}
