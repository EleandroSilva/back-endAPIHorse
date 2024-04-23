{*******************************************************}
{                    API PDV - JSON                     }
{                      Be More Web                      }
{          In�cio do projeto 08/04/2024 22:46           }
{                 www.bemoreweb.com.br                  }
{                     (17)98169-5336                    }
{                        2003/2024                      }
{         Analista desenvolvedor (Eleandro Silva)       }
{*******************************************************}
unit Model.DAO.Imp.Estado;

interface

uses
  System.SysUtils,
  Data.DB,

  FireDAC.Comp.Client,

  Uteis.Tratar.Mensagens,

  Model.DAO.Estado.Interfaces,
  Model.Entidade.Estado.Interfaces,
  Model.Conexao.Firedac.Interfaces,
  Model.Conexao.Query.Interfaces;

type
  TDAOEstado = class(TInterfacedObject, iDAOEstado)
    private
      FEstado : iEntidadeEstado<iDAOEstado>;
      FConexao   : iConexao;
      FQuery     : iQuery;
      FMSG       : TMensagens;

      FDataSet   : TDataSet;
   const
      FSQL=('select '+
            'e.id, '+
            'e.idestado, '+
            'e.idregiao, '+
            're.regiao, '+
            'e.estado, '+
            'e.uf '+
            'from estado e '+
            'inner join regiaoestado re on re.id = e.idregiao ');

      function LoopRegistro (Value : Integer): Integer;
    public
      constructor Create;
      destructor Destroy; override;
      class function New : iDAOEstado;

      function DataSet(DataSource : TDataSource) : iDAOEstado; overload;
      function DataSet                           : TDataSet;   overload;
      function GetAll                            : iDAOEstado;
      function GetbyId(Id : Variant)             : iDAOEstado;
      function GetbyParams                       : iDAOEstado;
      function Post                              : iDAOEstado;
      function Put                               : iDAOEstado;
      function Delete                            : iDAOEstado;
      function QuantidadeRegistro                : Integer;

      function This : iEntidadeEstado<iDAOEstado>;
  end;

implementation

uses
  Model.Entidade.Imp.Estado,
  Model.Conexao.Firedac.MySQL.Imp,
  Model.Conexao.Query.Imp;

constructor TDAOEstado.Create;
begin
  FEstado  := TEntidadeEstado<iDAOEstado>.New(Self);
  FConexao := TModelConexaoFiredacMySQL.New;
  FQuery   := TQuery.New;
  FMSG     := TMensagens.Create;
end;

destructor TDAOEstado.Destroy;
begin
  FreeAndNil(FMSG);
  inherited;
end;

class function TDAOEstado.New: iDAOEstado;
begin
  Result := Self.Create;
end;

function TDAOEstado.DataSet(DataSource: TDataSource): iDAOEstado;
begin
  Result := Self;
  if not Assigned(FDataset) then
    DataSource.DataSet := FQuery.DataSet
  else
    DataSource.DataSet := FDataSet;
end;

function TDAOEstado.DataSet: TDataSet;
begin
  Result := FDataSet;
end;

function TDAOEstado.GetAll: iDAOEstado;
begin
  Result := Self;
  try
    try
      FDataSet := FQuery
                    .SQL(FSQL)
                    .Open
                  .DataSet;
    except
      on E: Exception do
      raise Exception.Create(FMSG.MSGerroGet+E.Message);
    end;
  finally
   if not FDataSet.IsEmpty then
   begin
     FEstado.Id(FDataSet.FieldByName('e.id').AsInteger);
     QuantidadeRegistro;
   end
   else
     FEstado.Id(0);
  end;
end;

function TDAOEstado.GetbyId(Id: Variant): iDAOEstado;
begin
  Result := Self;
  try
    try
      FDataSet := FQuery
                    .SQL(FSQL)
                    .Add('where e.Id=:Id')
                    .Params('Id', Id)
                    .Open
                  .DataSet;
    except
      on E: Exception do
      raise Exception.Create(FMSG.MSGerroGet+E.Message);
    end;
  finally
    if not FDataSet.IsEmpty then
      FEstado.Id(FDataSet.FieldByName('e.id').AsInteger)
    else
      FEstado.Id(0);
  end;
end;

function TDAOEstado.GetbyParams: iDAOEstado;
begin
  Result := Self;
  try
   try
     FDataSet := FQuery
                   .SQL(FSQL)
                   .Add('where e.uf=:uf')
                   .Params('uf', FEstado.UF)
                   .Open
                 .DataSet;
    except
      on E: Exception do
      raise Exception.Create(FMSG.MSGerroGet+E.Message);
    end;
  finally
    if not FDataSet.IsEmpty then
    begin
      FEstado.Id(FDataSet.FieldByName('e.id').AsInteger);
      QuantidadeRegistro;
    end
    else
      FEstado.Id(0);
  end;
end;

function TDAOEstado.Post: iDAOEstado;
const
  LSQL=('insert into estado('+
                             'idestado, '+
                             'idregiao, '+
                             'estado, '+
                             'uf '+
                           ')'+
                             ' values '+
                           '('+
                             ':idestado, '+
                             ':idregiao, '+
                             ':estado, '+
                             ':uf '+
                            ')'
       );
begin
  Result := Self;

  FConexao.StartTransaction;
  try
    try
      FQuery
        .SQL(LSQL)
          .Params('idestado' , FEstado.IdEstado)
          .Params('idregiao' , FEstado.IdRegiao)
          .Params('estado'   , FEstado.Estado)
          .Params('uf'       , FEstado.UF)
        .ExecSQL;
    except
      on E: Exception do
      begin
        FConexao.Rollback;
        raise Exception.Create(FMSG.MSGerroPost+E.Message);
      end;
    end;
  finally
    FConexao.Commit;
    FDataSet := FQuery
                    .SQL('select LAST_INSERT_ID () as id')
                    .Open
                    .DataSet;
    FEstado.Id(FDataSet.FieldByName('id').AsInteger);
  end;
end;

function TDAOEstado.Put: iDAOEstado;
const
  LSQL=('update estado set '+
                        'idestado =:ibge, '+
                        'idregiao =:idestado, '+
                        'estado   =:estado, '+
                        'uf       =:uf '+
                        'where id=:id '
       );
begin
  Result := Self;

  FConexao.StartTransaction;
  try
    try
      FQuery
        .SQL(LSQL)
          .Params('id'       , FEstado.Id)
          .Params('idestado' , FEstado.IdEstado)
          .Params('idregiao' , FEstado.IdRegiao)
          .Params('estado'   , FEstado.Estado)
          .Params('uf'       , FEstado.UF)
        .ExecSQL;
    except
      on E: Exception do
      begin
        FConexao.Rollback;
        raise Exception.Create(FMSG.MSGerroPut+E.Message);
      end;
    end;
  finally
    FConexao.Commit;
  end;
end;

function TDAOEstado.Delete: iDAOEstado;
const
  LSQL=('delete from estado where id=:id ');
begin
  Result := self;
  FConexao.StartTransaction;
  try
    try
      FQuery.SQL(LSQL)
               .Params('id', FEstado.Id)
            .ExecSQL;
    except
      on E: Exception do
      begin
        FConexao.Rollback;
        raise Exception.Create(FMSG.MSGerroDelete+E.Message);
      end;
    end;
  finally
    FConexao.Commit;
  end;
end;

function TDAOEstado.LoopRegistro(Value : Integer): Integer;
begin
  FDataSet.First;
  try
    while not FDataSet.Eof do
    begin
      Value := Value + 1;
      FDataSet.Next;
    end;
  finally
    Result := Value;
  end;
end;

function TDAOEstado.QuantidadeRegistro : Integer;
begin
  Result := LoopRegistro(0);
end;

function TDAOEstado.This: iEntidadeEstado<iDAOEstado>;
begin
  Result := FEstado;
end;

end.