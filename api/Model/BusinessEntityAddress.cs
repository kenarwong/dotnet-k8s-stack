﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace api.Model
{
    [Table("BusinessEntityAddress", Schema = "Person")]
    public partial class BusinessEntityAddress
    {
        [Key]
        [Column("BusinessEntityID")]
        public int BusinessEntityId { get; set; }
        [Key]
        [Column("AddressID")]
        public int AddressId { get; set; }
        [Key]
        [Column("AddressTypeID")]
        public int AddressTypeId { get; set; }
        [Column("rowguid")]
        public Guid Rowguid { get; set; }
        [Column(TypeName = "datetime")]
        public DateTime ModifiedDate { get; set; }

        [ForeignKey(nameof(AddressId))]
        [InverseProperty("BusinessEntityAddress")]
        public virtual Address Address { get; set; }
        [ForeignKey(nameof(AddressTypeId))]
        [InverseProperty("BusinessEntityAddress")]
        public virtual AddressType AddressType { get; set; }
        [ForeignKey(nameof(BusinessEntityId))]
        [InverseProperty("BusinessEntityAddress")]
        public virtual BusinessEntity BusinessEntity { get; set; }
    }
}
