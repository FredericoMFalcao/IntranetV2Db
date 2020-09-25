DROP PROCEDURE IF EXISTS FF_NovaFatura;

DELIMITER //

-- Descrição: transforma um ficheiro no disco numa fatura de fornecedor por classificar
--
--        será chamada pelo sistema quando:
--         (1) recebe um email com anexo PDF
--         (2) ficheiro Dropbox
--

CREATE PROCEDURE FF_NovaFatura (IN NumSerie TEXT, IN FileId TEXT )
 BEGIN
 
  -- 0. Verificar validade dos argumentos
  IF NumSerie NOT REGEXP '^FT(An|Lx)[0-9]{2}#[0-9]{3,4}\.pdf$'
   THEN signal sqlstate '20000' set message_text = 'NumSerie com formato inválido';
  END IF;
   
  -- 1. Começar Transacao
  START TRANSACTION;
  
  -- 1. Inserir em Documentos 
  INSERT INTO Documentos (NumSerie, Tipo, Estado, FileId) 
  VALUES (NumSerie, 'FaturaFornecedor', 'PorClassificarFornecedor', FileId);
  
  -- 10. Salvar
  COMMIT;
 END;
//

DELIMITER ;