﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace api.Model
{
    [Table("Currency", Schema = "Sales")]
    public partial class Currency
    {
        public Currency()
        {
            CountryRegionCurrency = new HashSet<CountryRegionCurrency>();
            CurrencyRateFromCurrencyCodeNavigation = new HashSet<CurrencyRate>();
            CurrencyRateToCurrencyCodeNavigation = new HashSet<CurrencyRate>();
        }

        [Key]
        [StringLength(3)]
        public string CurrencyCode { get; set; }
        [Required]
        [StringLength(50)]
        public string Name { get; set; }
        [Column(TypeName = "datetime")]
        public DateTime ModifiedDate { get; set; }

        [InverseProperty("CurrencyCodeNavigation")]
        public virtual ICollection<CountryRegionCurrency> CountryRegionCurrency { get; set; }
        [InverseProperty(nameof(CurrencyRate.FromCurrencyCodeNavigation))]
        public virtual ICollection<CurrencyRate> CurrencyRateFromCurrencyCodeNavigation { get; set; }
        [InverseProperty(nameof(CurrencyRate.ToCurrencyCodeNavigation))]
        public virtual ICollection<CurrencyRate> CurrencyRateToCurrencyCodeNavigation { get; set; }
    }
}
