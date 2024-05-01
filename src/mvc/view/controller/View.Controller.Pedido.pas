{*******************************************************}
{                    API PDV - JSON                     }
{                      Be More Web                      }
{          In�cio do projeto 26/04/2024 12:00           }
{                 www.bemoreweb.com.br                  }
{                     (17)98169-5336                    }
{                        2003/2024                      }
{         Analista desenvolvedor (Eleandro Silva)       }
{*******************************************************}
unit View.Controller.Pedido;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON,
  Vcl.StdCtrls,
  Data.DB,
  FireDAC.Comp.Client,
  DataSet.Serialize,
  Horse,
  Horse.BasicAuthentication,
  Controller.Interfaces;

type
  TViewControllerPedido= class
    private
      FController : iController;

      //Jsons
      FBody       : TJSONValue;
      FJSONObjectPedido    : TJSONObject;
      FJSONArrayPedido     : TJSONArray;
      FJSONObjectItem      : TJSONObject;
      FJSONArrayItem       : TJSONArray;
      FJSONObjectPagamento : TJSONObject;
      FJSONArrayPagamento : TJSONArray;

      //DataSource
      FDSPedido          : TDataSource;
      FDSPedidoItem      : TDataSource;
      FDSPedidoPagamento : TDataSource;

      FIdPedido  : Integer;
      FIdCaixa   : Integer;
      FIdEmpresa : Integer;
      FIdUsuario : Integer;
      FQuantidadeRegistro  : Integer;


      //function BuscarPorNome    (Value : String)  : Boolean;
      //function BuscarPorIdPedido(Value : Variant) : Boolean;
      //function BuscarPorIdItem  (Value : Variant) : Boolean;
      //Loop que monta o JSON
      procedure LoopPedido;
      function  LoopPedidoItem      : Boolean;
      function  LoopPedidoPagamento : Boolean;
      //Horse
      procedure GetAll (Req: THorseRequest; Res: THorseResponse; Next : TProc);
      procedure GetbyId(Req: THorseRequest; Res: THorseResponse; Next : TProc);
      procedure Post   (Req: THorseRequest; Res: THorseResponse; Next : TProc);
      procedure Put    (Req: THorseRequest; Res: THorseResponse; Next : TProc);
      procedure Delete (Req: THorseRequest; Res: THorseResponse; Next : TProc);
      procedure Registry;
    public
      constructor Create;
      destructor Destroy; override;
  end;

implementation

uses
  Imp.Controller;

{ TViewControllerPedido }
constructor TViewControllerPedido.Create;
begin
  FController   := TController.New;
  FDSPedido     := TDataSource.Create(nil);
  FDSPedidoItem := TDataSource.Create(nil);
  FDSPedidoPagamento := TDataSource.Create(nil);
  Registry;
end;

destructor TViewControllerPedido.Destroy;
begin
  inherited;
end;

procedure TViewControllerPedido.LoopPedido;
begin
  FJSONArrayPedido := TJSONArray.Create;//JSONArray tabela pai empresa
  FDSPedido.DataSet.First;
  while not FDSPedido.DataSet.Eof do
  begin
    FJSONObjectPedido := TJSONObject.Create;//JSONObject tabela pai empresa
    try
      FJSONObjectPedido := FDSPedido.DataSet.ToJSONObject;
    except
      on E: Exception do
      begin
        WriteLn('Erro ao converter DataSet para JSONObject: ' + E.Message);
        Break;
      end;
    end;

    try
      if LoopPedidoItem then
        if FQuantidadeRegistro > 1 then
          FJSONObjectPedido.AddPair('pedidoitem' , FJSONArrayItem) else
          FJSONObjectPedido.AddPair('pedidoitem' , FJSONObjectItem);
    except
      on E: Exception do
      begin
        WriteLn('Erro durante o loop de pedidoitem, verificar as instru��es SQL no DAOPedidoItem: ' + E.Message);
        Break;
      end;
    end;

    FJSONArrayPedido.Add(FJSONObjectPedido);
    FDSPedido.DataSet.Next;
  end;
end;

function TViewControllerPedido.LoopPedidoItem: Boolean;
begin
  Result := False;
  FQuantidadeRegistro := FController
                           .FactoryDAO
                             .DAOPedidoItem
                               .GetbyId(FDSPedido.DataSet.FieldByName('id').AsInteger)
                               .DataSet(FDSPedidoItem)
                             .QuantidadeRegistro;

  if not FDSPedidoItem.DataSet.IsEmpty then
  begin
    Result := True;
    FJSONArrayItem := TJSONArray.Create;

    FDSPedidoItem.DataSet.First;
    while not FDSPedidoItem.DataSet.Eof do
    begin
      FJSONObjectItem := TJSONObject.Create;
      FJSONObjectItem := FDSPedidoItem.DataSet.ToJSONObject;
      //tendo mais de um registro, adiciona ao array
      if FQuantidadeRegistro > 1 then
        FJSONArrayItem.Add(FJSONObjectItem);

      FDSPedidoItem.DataSet.Next;
    end;
  end;
end;

function TViewControllerPedido.LoopPedidoPagamento: Boolean;
begin
  Result := False;
  FQuantidadeRegistro := FController
                           .FactoryDAO
                             .DAOPedidoPagamento
                               .GetbyId(FDSPedido.DataSet.FieldByName('id').AsInteger)
                               .DataSet(FDSPedidoPagamento)
                             .QuantidadeRegistro;

  if not FDSPedidoPagamento.DataSet.IsEmpty then
  begin
    Result := True;
    FJSONArrayPagamento := TJSONArray.Create;

    FDSPedidoPagamento.DataSet.First;
    while not FDSPedidoPagamento.DataSet.Eof do
    begin
      FJSONObjectPagamento := TJSONObject.Create;
      FJSONObjectPagamento := FDSPedidoPagamento.DataSet.ToJSONObject;
      //tendo mais de um registro, adiciona ao array
      if FQuantidadeRegistro > 1 then
        FJSONArrayPagamento.Add(FJSONObjectPagamento);

      FDSPedidoPagamento.DataSet.Next;
    end;
  end;
end;

procedure TViewControllerPedido.GetAll(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lQuantidadeRegistro : Integer;
begin
  lQuantidadeRegistro := 0;
  try
    if Req.Query.Field('nomepessoa').AsString<>'' then
      lQuantidadeRegistro := FController
                               .FactoryDAO
                                 .DAOPedido
                                 .GetbyParams(Req.Query.Field('nomepessoa').AsString)
                                 .DataSet(FDSPedido)
                                 .QuantidadeRegistro
    else
    if Req.Query.Field('idpessoa').AsString<>'' then
      lQuantidadeRegistro := FController
                               .FactoryDAO
                                 .DAOPedido
                                 .GetbyParams(Req.Query.Field('idpessoa').AsInteger)
                                 .DataSet(FDSPedido)
                                 .QuantidadeRegistro
    else
    if Req.Query.Field('idusuario').AsString<>'' then
      lQuantidadeRegistro := FController
                               .FactoryDAO
                                 .DAOPedido
                                 .GetbyParams(Req.Query.Field('idusuario').AsString)
                                 .DataSet(FDSPedido)
                                 .QuantidadeRegistro
    else
      lQuantidadeRegistro := FController
                               .FactoryDAO
                                 .DAOPedido
                                   .GetAll
                                   .DataSet(FDSPedido)
                                   .QuantidadeRegistro;

  except
    on E: Exception do
    begin
      Res.Status(500).Send('Ocorreu um erro interno no servidor: '+ E.Message);
      Exit;
    end;
  end;

  if not FDSPedido.DataSet.IsEmpty then
  begin
    LoopPedido;

    if lQuantidadeRegistro > 1 then
      Res.Send<TJSONArray>(FJSONArrayPedido) else
      Res.Send<TJSONObject>(FJSONObjectPedido);

    Res.Status(201).Send('Registro encontrado com sucesso!');
  end
  else
    Res.Status(400).Send('Registro n�o encontrado!');

end;

procedure TViewControllerPedido.GetbyId(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  try
    FController
      .FactoryDAO
        .DAOPedido
          .GetbyId(Req.Params['id'].ToInt64)
          .DataSet(FDSPedido);

    FJSONObjectPedido := FDSPedido.DataSet.ToJSONObject();
    Res.Send<TJSONObject>(FJSONObjectPedido);
  except
    on E: Exception do
    begin
      Res.Status(500).Send('Ocorreu um erro interno no servidor'+E.Message);
      Exit;
    end;
  End;

  if not FDSPedido.DataSet.IsEmpty then
  begin
    LoopPedido;
    Res.Send<TJSONObject>(FJSONObjectPedido);
    Res.Status(201).Send('Registro encontrado com sucesso!');
  end
  else
    Res.Status(400).Send('Registro n�o encontrado!');
end;

procedure TViewControllerPedido.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
Var
  LJSONObjectPedido    : TJSONObject;//JSONObect->Pedido
  LJSONArrayItem       : TJSONArray; //JSONArray->PedidoItem
  LJSONObjectItem      : TJSONObject;//JSONObect->PedidoItem
  LJSONArrayPagamento  : TJSONArray; //JSONArray->PedidoPagemento
  LJSONObjectPagamento : TJSONObject;//JSONObect->PedidoPagamento
  I : Integer;
begin
  //tabela pai(Pedido)
  LJSONObjectPedido := Req.Body<TJSONObject>;
  try
    try
      FController
        .FactoryDAO
          .DAOPedido
            .This
              .IdEmpresa          (LJSONObjectPedido.GetValue<Integer>  ('idempresa'))
              .IdCaixa            (LJSONObjectPedido.GetValue<Integer>  ('idcaixa'))
              .IdPessoa           (LJSONObjectPedido.GetValue<Integer>  ('idpessoa'))
              .IdCondicaoPagamento(LJSONObjectPedido.GetValue<Integer>  ('idcondicaopagamento'))
              .IdUsuario          (LJSONObjectPedido.GetValue<Integer>  ('idusuario'))
              .ValorProduto       (LJSONObjectPedido.GetValue<Currency> ('valorproduto'))
              .ValorDesconto      (LJSONObjectPedido.GetValue<Currency> ('valordesconto'))
              .ValorReceber       (LJSONObjectPedido.GetValue<Currency> ('valorreceber'))
              .DataHoraEmissao    (LJSONObjectPedido.GetValue<TDateTime>('datahoraemissao'))
            .Status(0) //(CRIAR PARAMENTO DA EMPRESA, INFORMAR SE NA DIGITA��O TIPO DE INFORMA��O)0-Pedido como or�amento 1-Pedido faturado 3-Pedido Cancelado 4-Pedido Exclu�do
          .&End
          .Post
          .DataSet(FDSPedido);
          //Pegando os id(s), necess�rios para inserir na tabela caixapedido
          FIdPedido  := FDSPedido.DataSet.FieldByName('id').AsInteger;
          FIdEmpresa := LJSONObjectPedido.GetValue<Integer>('idempresa');
          FIdCaixa   := LJSONObjectPedido.GetValue<Integer>('idcaixa');
          FIdUsuario := LJSONObjectPedido.GetValue<Integer>('idusuario');
      except
        on E: Exception do
        begin
          Res.Status(500).Send('Ocorreu um erro interno no servidor'+E.Message);
          Exit;
        end;
      end;

      //Obt�m os dados JSON do corpo da requisi��o da tabela('pedidoitem')
      LJSONArrayItem := LJSONObjectPedido.GetValue('pedidoitem') as TJSONArray;
      // Loop inserindo pedidoitem(ns)
      for I := 0 to LJSONArrayItem.Count - 1 do
      begin
        //Extraindo os dados do pedidoitem e salvando na tabela
        LJSONObjectItem := LJSONArrayItem.Items[I] as TJSONObject;
        try
          FController
            .FactoryDAO
              .DAOPedidoItem
                .This
                  .IdPedido         (FIdPedido)
                  .IdProduto        (LJSONObjectItem.GetValue<Integer> ('idproduto'))
                  .Quantidade       (LJSONObjectItem.GetValue<Currency>('quantidade'))
                  .ValorUnitario    (LJSONObjectItem.GetValue<Currency>('valorunitario'))
                  .ValorProduto     (LJSONObjectItem.GetValue<Currency>('valorproduto'))
                  .ValorDescontoItem(LJSONObjectItem.GetValue<Currency>('valordescontoitem'))
                  .ValorFinalItem   (LJSONObjectItem.GetValue<Currency>('valorfinalitem'))
                .&End
              .Post;
          except
            on E: Exception do
            begin
              Res.Status(500).Send('Ocorreu um erro interno no servidor'+E.Message);
              FController
                .FactoryDAO
                  .DAOPessoa
                    .This
                      .Id(FIdPedido)
                    .&End
                  .Delete;
              Exit;
            end;
          end;
      end;

      //Obt�m os dados JSON do corpo da requisi��o da tabela('pedidopagamento')
      LJSONArrayPagamento := LJSONObjectPedido.GetValue('pedidopagamento') as TJSONArray;
      // Loop inserindo pedidopagamento(ns)
      for I := 0 to LJSONArrayPagamento.Count - 1 do
      begin
        //Extraindo os dados do pagamento do pedido e salvando os dados na tabela
        LJSONObjectPagamento := LJSONArrayPagamento.Items[I] as TJSONObject;
        try
          FController
            .FactoryDAO
              .DAOPedidoPagamento
                .This
                  .IdPedido      (FIdPedido)
                  .DataVencimento(LJSONObjectPagamento.GetValue<TDateTime> ('datavencimento'))
                  .ValorParcela  (LJSONObjectPagamento.GetValue<Currency>('valorparcela'))
                .&End
              .Post;
          except
            on E: Exception do
            begin
              Res.Status(500).Send('Ocorreu um erro interno no servidor'+E.Message);
              FController
                .FactoryDAO
                  .DAOPedidoPagamento
                    .This
                      .Id(FIdPedido)
                    .&End
                  .Delete;
              Exit;
            end;
          end;
      end;
      //inserindo caixa que este pedido pertence
      try
        FController
          .FactoryDAO
            .DAOCaixaPedido
              .This
                .IdEmpresa(FIdEmpresa)
                .IdCaixa(FIdCaixa)
                .IdPedido(FIdPedido)
                .IdUsuario(FIdUsuario)
                .DataHoraEmissao(Now)
              .&End
            .Post;
        except
          on E: Exception do
          begin
            Res.Status(500).Send('Ocorreu um erro interno no servidor'+E.Message);
            FController
              .FactoryDAO
                .DAOPessoa
                  .This
                    .Id(FIdPedido)
                  .&End
                .Delete;
            Exit;
        end;
      end;
  finally
    FJSONObjectPedido := FDSPedido.DataSet.ToJSONObject();
    Res.Send<TJSONObject>(FJSONObjectPedido);
    Res.Status(204).Send('Registro inclu�do com sucesso!');
  end;
end;

procedure TViewControllerPedido.Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
//
end;

procedure TViewControllerPedido.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  try
    FController
      .FactoryDAO
        .DAOCondicaoPagamento
          .This
            .Id(Req.Params['id'].ToInt64)
          .&End
          .Delete
          .DataSet(FDSPedido);
    except
      on E: Exception do
      raise Res.Status(500).Send('Ocorreu um erro interno no servidor.'+ E.Message);
  End;
    Res.Status(204).Send('Registro exclu�do com sucesso!');
end;

procedure TViewControllerPedido.Registry;
begin
  THorse
      .Group
        .Prefix  ('bmw')
          .Get   ('/pedido'     , GetAll)
          .Get   ('/pedido/:id' , GetbyId)
          .Post  ('pedido'      , Post)
          .Put   ('pedido/:id'  , Put)
          .Delete('pedido/:id'  , Delete);
end;

end.
