DROP PROCEDURE IF EXISTS FF_ClassificarFornecedor;

DELIMITER //

CREATE PROCEDURE FF_ClassificarFornecedor (
IN NumSerie                 TEXT,
IN NumFatura                TEXT,
IN Projecto                 TEXT,
IN DataFatura               DATE,
IN DataRecebida             DATE,
IN PeriodoFacturacao        TEXT,
-- e.g. {"Inicio": "2011-11-25", "Fim": "2011-11-25"}
IN DataValFactura           TEXT,
IN FornecedorCodigo         TEXT,
IN Valor                    TEXT,
-- e.g. {"Bens": {"ValorBase": 0.00, "Iva": 0.00}, "Servicos": {"ValorBase":0.00,"Iva":0.00}}
IN Moeda                    TEXT,
IN Descricao                TEXT
)
 BEGIN
 
  -- 0. Verificar validade dos argumentos
  IF NumSerie NOT IN (SELECT NumSerie FROM Documentos WHERE Estado = 'PorClassificarFornecedor')
   THEN signal sqlstate '20000' set message_text = 'Fatura inexistente ou indisponível para esta ação';
  END IF;
   
  -- 1. Começar Transacao
  START TRANSACTION;
  
  -- 2. Alterar dados
  -- 2.1 Inserir Lançamento Fornecedor
  INSERT INTO Lancamentos (Conta, CoefRateio, Mes, DocNumSerie)
  VALUES (FornecedorCodigo, 1, DataFatura, NumSerie);
  
  -- 2.2 Inserir Lançamento Custos Gerais
  INSERT INTO Lancamentos (Conta, CoefRateio, Mes, DocNumSerie)
  VALUES ("CG01", -1, DataFatura, NumSerie);
  
  -- 2.3 Acrescentar dados a documento
  UPDATE Documentos
   SET
    Estado = 'PorClassificarAnalitica',
    Extra = JSON_SET(Extra, 
        '$.NumFatura', NumFatura,
        '$.Projeto', Projeto,
        '$.DataFactura', DataFatura,
        '$.DataRecebida', DataRecebida,
        '$.PeriodoFacturacao', PeriodoFacturacao,
        '$.DataValFactura', DataValFactura,
        '$.FornecedorCodigo', FornecedorCodigo,
        '$.Valor', Valor,
        '$.Moeda', Moeda,
        '$.Descricao', Descricao
  ) 
  WHERE NumSerie = NumSerie;
  
  -- 10. Salvar
  COMMIT;
 END;
//

DELIMITER ;