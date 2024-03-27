SELECT
T1."BcdCode" "Barcode",
T0."FrgnName" "Nombre de artículo",
T2."CardFName" "Proveedor",
T0."ItemCode" "Código de artículo",
T3."Price" "Precio",
T4."ItmsGrpNam" "Grupo de artículo",
"En Stock",
"Cambios",
CASE WHEN T0."U_TM_MDEC" = 'N' THEN 'No' else 'Si' END "Maneja Decimales",
CASE WHEN T0."VatGourpSa" = 'V0' THEN '0%'  WHEN T0."VatGourpSa" = 'V1' THEN '7%'  WHEN T0."VatGourpSa" = 'V2' THEN '10%' END "ITBMS",
T1."BcdCode" "Barcode", 
T0."LastPurPrc" "CostoCompra",
T0."AvgPrice" "CostoProm",
T0."U_Porcentaje_Utilidad" "%U. Control",

CASE WHEN T0."QryGroup5" = 'Y' THEN 'Si' ELSE '' END "Artículo con formas de venta",

CASE WHEN T0."QryGroup5" = 'Y' AND T0."QryGroup6" = 'Y' THEN 'Si'
        WHEN T0."QryGroup5" = 'Y' AND T0."QryGroup6" = 'N' THEN 'No' END "Venta por unidad",

CASE WHEN T0."QryGroup5" = 'Y' AND T0."QryGroup7" = 'Y' THEN 'Si'
        WHEN T0."QryGroup5" = 'Y' AND T0."QryGroup7" = 'N' THEN 'No' END  "Venta por bolsa/caja",

T0."U_Medida",
T0."U_Unidad_Medida",
T0."U_Ubicacion_en_almacen"


FROM
SBO_MANA.OITM T0  INNER JOIN SBO_MANA.OBCD T1 ON T0."ItemCode" = T1."ItemCode"
LEFT JOIN SBO_MANA.OCRD T2 ON T0."CardCode" = T2."CardCode"
INNER JOIN SBO_MANA.ITM1 T3 ON T0."ItemCode" = T3."ItemCode" AND T3."PriceList" = 1
INNER JOIN SBO_MANA.OITB T4 ON T0."ItmsGrpCod" = T4."ItmsGrpCod"

LEFT JOIN
(
	SELECT "ItemCode", "OnHand" as "Cambios"
	FROM SBO_MANA.OITW WHERE "WhsCode" = '02' AND "OnHand" <> 0 GROUP BY "ItemCode", "WhsCode", "OnHand"
) R
ON T1."ItemCode" = R."ItemCode"

LEFT JOIN
(
	SELECT "ItemCode", "OnHand" as "En Stock"
	FROM SBO_MANA.OITW WHERE "WhsCode" = '01' AND "OnHand" <> 0 GROUP BY "ItemCode", "WhsCode", "OnHand"
) U
ON T1."ItemCode" = U."ItemCode"

WHERE 
T0."frozenFor" = 'N'


ORDER BY 1