SELECT * FROM [10.1.30.39].CORPORERM_VITAE.DBO.PPESSOA
WHERE CODIGO IN (SELECT CODPESSOA FROM [10.1.30.39].CORPORERM_VITAE.DBO.VCANDIDATOS 
WHERE DTULTALTWEB > (GETDATE() - 2) AND DTULTALTWEB < (GETDATE() - 1))

SELECT * FROM [10.1.30.39].CORPORERM_VITAE.DBO.VCANDIDATOS
WHERE CODPESSOA IN (SELECT CODPESSOA FROM [10.1.30.39].CORPORERM_VITAE.DBO.VCANDIDATOS 
WHERE DTULTALTWEB > (GETDATE() - 2) AND DTULTALTWEB < (GETDATE() - 1))

SELECT * FROM [10.1.30.39].CORPORERM_VITAE.DBO.VUSUARIOCURRICULO WHERE NOME = 'Andr� Germano Valentim da Silva'
SELECT * FROM VUSUARIOCURRICULO WHERE NOME = 'Andr� Germano Valentim da Silva'

SELECT * FROM [10.1.30.39].CORPORERM_VITAE.DBO.VCANDIDATOS WHERE CODPESSOA = '32063'
SELECT * FROM VCANDIDATOS WHERE CODPESSOA = '18984'

SELECT * FROM [10.1.30.39].CORPORERM_VITAE.DBO.PPESSOA WHERE CODIGO = '32063'
SELECT * FROM PPESSOA WHERE CODIGO = '18984'

SELECT * FROM [10.1.30.39].CORPORERM_VITAE.DBO.VHABILIDADESPESSOAIS WHERE CODPESSOA = '32063'
SELECT * FROM VHABILIDADESPESSOAIS WHERE CODPESSOA = '18984'

SELECT * FROM [10.1.30.39].CORPORERM_VITAE.DBO.VEXPPROF WHERE CODPESSOA = '32063'
SELECT * FROM VEXPPROF WHERE CODPESSOA = '18984'

SELECT * FROM [10.1.30.39].CORPORERM_VITAE.DBO.VDETEXPPROF WHERE CODPESSOA = '32063'
SELECT * FROM VDETEXPPROF WHERE CODPESSOA = '18984'

SELECT * FROM [10.1.30.39].CORPORERM_VITAE.DBO.VFORMACAOACAD WHERE CODPESSOA = '32063'
SELECT * FROM VFORMACAOACAD WHERE CODPESSOA = '18984'

SELECT * FROM [10.1.30.39].CORPORERM_VITAE.DBO.VFORMACAOADIC WHERE CODPESSOA = '32063'
SELECT * FROM VFORMACAOADIC WHERE CODPESSOA = '18984'
