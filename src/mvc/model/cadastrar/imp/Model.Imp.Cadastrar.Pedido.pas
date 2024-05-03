{*******************************************************}
{                    API PDV - JSON                     }
{                      Be More Web                      }
{          In�cio do projeto 03/05/2024 10:13           }
{                 www.bemoreweb.com.br                  }
{                     (17)98169-5336                    }
{                        2003/2024                      }
{         Analista desenvolvedor (Eleandro Silva)       }
{*******************************************************}
unit Model.Imp.Cadastrar.Pedido;

interface

uses
  Data.DB,
  System.JSON,
  System.SysUtils,
  DataSet.Serialize,

  Model.Cadastrar.Pedido.Interfaces,
  Model.Entidade.Pedido.Interfaces,
  Controller.Interfaces;

type
  TCadastrarPedido = class(TInterfacedObject, iCadastrarPedido)
    private
      FController : iController;
      FPedido     : iEntidadePedido<iCadastrarPedido>;
      FDSPedido   : TDataSource;
      FIdPedido   : Integer;
      FIdEmpresa  : Integer;
      FIdCaixa    : Integer;
      FIdUsuario  : Integer;

      FError : Boolean;

      FJSONObjectPai : TJSONObject;
      FJSONArray     : TJSONArray;
      FJSONObject    : TJSONObject;

      function CadastrarPedidoItem : Boolean;
      function CadastrarPedidoPagamento : Boolean;
      function CadastrarCaixaPedido : Boolean;
    public
      constructor Create;
      destructor Destroy; override;
      class function New : iCadastrarPedido;

      function JSONObjectPai(Value : TJSONObject) : iCadastrarPedido; overload;
      function JSONObjectPai                      : TJSONObject;      overload;
      function Post   : iCadastrarPedido;
      function Error  : Boolean;
      //inje��o de depend�ncia
      function Pedido : iEntidadePedido<iCadastrarPedido>;
      function &End   : iCadastrarPedido;
  end;

implementation

uses
  Imp.Controller,
  Model.Entidade.Imp.Pedido;

{ TCadastrarPedido }

constructor TCadastrarPedido.Create;
begin
  FController := TController.New;
  FPedido     := TEntidadePedido<iCadastrarPedido>.New(Self);
  FDSPedido   := TDataSource.Create(nil);

  FError := False;
end;

destructor TCadastrarPedido.Destroy;
begin
  inherited;
end;

class function TCadastrarPedido.New: iCadastrarPedido;
begin
  Result := Self.Create;
end;

function TCadastrarPedido.JSONObjectPai(Value: TJSONObject): iCadastrarPedido;
begin
  Result := Self;
  FJSONObjectPai := Value;
end;

function TCadastrarPedido.JSONObjectPai: TJSONObject;
begin
  Result := FJSONObject;
end;

function TCadastrarPedido.Post: iCadastrarPedido;
begin
  //tabela pai(Pedido)
  FJSONObject := FJSONObjectPai;
  try
    FController
      .FactoryDAO
        .DAOPedido
          .This
            .IdEmpresa          (FJSONObject.GetValue<Integer>  ('idempresa'))
            .IdCaixa            (FJSONObject.GetValue<Integer>  ('idcaixa'))
            .IdPessoa           (FJSONObject.GetValue<Integer>  ('idpessoa'))
            .IdCondicaoPagamento(FJSONObject.GetValue<Integer>  ('idcondicaopagamento'))
            .IdUsuario          (FJSONObject.GetValue<Integer>  ('idusuario'))
            .ValorProduto       (FJSONObject.GetValue<Currency> ('valorproduto'))
            .ValorDesconto      (FJSONObject.GetValue<Currency> ('valordesconto'))
            .ValorReceber       (FJSONObject.GetValue<Currency> ('valorreceber'))
            .DataHoraEmissao    (FJSONObject.GetValue<TDateTime>('datahoraemissao'))
            .Status(0) //(CRIAR PARAMENTO DA EMPRESA, INFORMAR SE NA DIGITA��O TIPO DE INFORMA��O)0-Pedido como or�amento 1-Pedido faturado 3-Pedido Cancelado
            .Excluido(0)//0-Pedido estado normal; 1-Pedido exclu�do
          .&End
        .Post
        .DataSet(FDSPedido);
    //Pegando os id(s), necess�rios para inserir na tabela caixapedido
    FIdPedido  := FDSPedido.DataSet.FieldByName('id').AsInteger;
    FIdEmpresa := FJSONObject.GetValue<Integer>('idempresa');
    FIdCaixa   := FJSONObject.GetValue<Integer>('idcaixa');
    FIdUsuario := FJSONObject.GetValue<Integer>('idusuario');
  except
    on E: Exception do
    begin
      WriteLn('Erro ao tentar incluir pedido: ' + E.Message);
      FError := True;
    end;
  end;
end;


//cadastrar itens do pedido
function TCadastrarPedido.CadastrarPedidoItem: Boolean;
begin
  Result := False;
  Result := FController
              .FactoryCadastrar
                .CadastrarPedidoItem
                  .JSONObjectPai(FJSONObject)
                  .PedidoItem
                    .IdPedido(FIdPedido)
                  .&End
                .Post
                .Error;
end;

//cadastrar pagamento do pedido
function TCadastrarPedido.CadastrarPedidoPagamento: Boolean;
begin
  Result := False;
  Result := FController
              .FactoryCadastrar
                .CadastrarPedidoPagamento
                  .JSONObjectPai(FJSONObject)
                    .PedidoPagamento
                      .IdPedido(FIdPedido)
                    .&End
                .Post
                .Error;
end;

//cadastrar relacionamento caixa - pedido
function TCadastrarPedido.CadastrarCaixaPedido: Boolean;
begin
  Result := False;
  Result := FController
              .FactoryCadastrar
                .CadastrarCaixaPedido
                  .JSONObjectPai(FJSONObject)
                    .CaixaPedido
                      .IdEmpresa(FIdEmpresa)
                      .IdCaixa(FIdCaixa)
                      .IdPedido(FIdPedido)
                      .IdUsuario(FIdUsuario)
                    .&End
                  .Post
                  .Error;
end;

function TCadastrarPedido.Error: Boolean;
begin
  Result := FError;
end;

//Inje��o de depend�ncia
function TCadastrarPedido.Pedido: iEntidadePedido<iCadastrarPedido>;
begin
  Result := FPedido;
end;

function TCadastrarPedido.&End: iCadastrarPedido;
begin
  Result := Self;
end;

end.
