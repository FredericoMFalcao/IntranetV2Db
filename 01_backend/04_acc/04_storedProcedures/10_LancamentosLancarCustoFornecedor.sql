DROP PROCEDURE IF EXISTS <?=tableNameWithModule()?>;

DELIMITER //

CREATE PROCEDURE <?=tableNameWithModule()?> (
  IN in_NumSerie                    TEXT,
  IN in_ClassificacaoAnalitica      TEXT
  -- e.g. [{"CentroResultados": "CR0101", "Analitica": "AN0202", "Colaborador": "COabc", "Valor": 1000}, {...}]
)
  BEGIN
    DECLARE v_PeriodoFaturacao TEXT;
    DECLARE v_ValorFatura DECIMAL(18,2);
    DECLARE v_Retencao FLOAT;
    DECLARE i INT;
    SET v_PeriodoFaturacao = JSON_EXTRACT((SELECT Extra FROM <?=tableNameWithModule("Documentos","DOC")?> WHERE NumSerie = in_NumSerie), '$.PeriodoFaturacao');
    SET v_ValorFatura = FF_ValorTotal((SELECT Extra FROM <?=tableNameWithModule("Documentos","DOC")?> WHERE NumSerie = in_NumSerie));
    SET v_Retencao = FF_Retencao(in_NumSerie);
    SET i = 0;
    
           
    -- 1. Inserir lançamentos na conta do fornecedor
    CALL <?=tableNameWithModule("CriarLancamento")?> (
      JSON_VALUE((SELECT Extra FROM <?=tableNameWithModule("Documentos","DOC")?> WHERE NumSerie = in_NumSerie), '$.FornecedorCodigo'),
      1 - (v_Retencao / v_ValorFatura),
      v_PeriodoFaturacao,
      in_NumSerie
    );
    
    
    -- 2. Inserir lançamentos na conta de impostos
    CALL <?=tableNameWithModule("CriarLancamento")?> (
      'IM01',
      v_Retencao / v_ValorFatura,
      v_PeriodoFaturacao,
      in_NumSerie
    );
    
    
    -- 3. Inserir lançamentos em custos específicos
    WHILE i != JSON_LENGTH(in_ClassificacaoAnalitica) DO

      CALL <?=tableNameWithModule("CriarLancamento")?> (
        CONCAT_WS(":",
          JSON_VALUE(JSON_EXTRACT(in_ClassificacaoAnalitica, CONCAT("$[", i, "]")), '$.CentroResultados'),
          JSON_VALUE(JSON_EXTRACT(in_ClassificacaoAnalitica, CONCAT("$[", i, "]")), '$.Analitica'),
          JSON_VALUE(JSON_EXTRACT(in_ClassificacaoAnalitica, CONCAT("$[", i, "]")), '$.Colaborador')
        ),
        JSON_VALUE(JSON_EXTRACT(in_ClassificacaoAnalitica, CONCAT("$[", i, "]")), '$.Valor') / v_ValorFatura * -1,
        v_PeriodoFaturacao,
        in_NumSerie
      );

      SET i = i + 1;

    END WHILE;
  
  END;
    
//

DELIMITER ;
