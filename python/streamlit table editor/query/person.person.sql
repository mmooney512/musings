SELECT			PersonType
			  , NameStyle
			  , Title
			  , FirstName
			  , MiddleName
			  , LastName
			  , Suffix
FROM			person.person
ORDER BY		BusinessEntityID
OFFSET		? ROWS FETCH NEXT ? ROWS ONLY
;