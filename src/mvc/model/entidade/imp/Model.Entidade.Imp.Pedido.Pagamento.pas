{*******************************************************}
{                    API PDV - JSON                     }
{                      Be More Web                      }
{          In�cio do projeto 22/04/2024 14:28           }
{                 www.bemoreweb.com.br                  }
{                     (17)98169-5336                    }
{                        2003/2024                      }
{         Analista desenvolvedor (Eleandro Silva)       }
{*******************************************************}
unit Model.Entidade.Imp.Pedido.Pagamento;

interface

uses
  Model.Entidade.Pedido.Pagamento.Interfaces;

type
  TEntidadePedidoPagamento<T : iInterface> = class(TInterfacedObject, iEntidadePedidoPagamento<T>)
    private
      [weak]
      FParent         : T;
      FId             : Integer;
      FIdPedido       : Integer;
      FDataVencimento : TDateTime;
      FValorParcela   : Currency;
    public
      constructor Create(Parent : T);
      destructor Destroy; override;
      class function New(Parent : T): iEntidadePedidoPagamento<T>;

      function Id            (Value : Integer)   : iEntidadePedidoPagamento<T>; overload;
      function Id                                : Integer;                     overload;
      function IdPedido      (Value : Integer)   : iEntidadePedidoPagamento<T>; overload;
      function IdPedido                          : Integer;                     overload;
      function DataVencimento(Value : TDateTime) : iEntidadePedidoPagamento<T>; overload;
      function DataVencimento                    : TDateTime;                   overload;
      function ValorParcela  (Value : Currency)  : iEntidadePedidoPagamento<T>; overload;
      function ValorParcela                      : Currency;                    overload;

      function &End : T;
  end;


implementation

{ TEntidadePedidoPagamento<T> }

constructor TEntidadePedidoPagamento<T>.Create(Parent: T);
begin
  Parent := FParent;
end;

destructor TEntidadePedidoPagamento<T>.Destroy;
begin
  inherited;
end;

class function TEntidadePedidoPagamento<T>.New(Parent: T): iEntidadePedidoPagamento<T>;
begin
  Result := Self.Create(Parent);
end;

function TEntidadePedidoPagamento<T>.Id(Value: Integer): iEntidadePedidoPagamento<T>;
begin
  Result := Self;
  FId    := Value;
end;

function TEntidadePedidoPagamento<T>.Id: Integer;
begin
  Result := FId;
end;

function TEntidadePedidoPagamento<T>.IdPedido(Value: Integer): iEntidadePedidoPagamento<T>;
begin
  Result := Self;
  FIdPedido := Value;
end;

function TEntidadePedidoPagamento<T>.IdPedido: Integer;
begin
  Result := FIdPedido;
end;

function TEntidadePedidoPagamento<T>.DataVencimento(Value: TDateTime): iEntidadePedidoPagamento<T>;
begin
  Result := Self;
  FDataVencimento := Value;
end;

function TEntidadePedidoPagamento<T>.DataVencimento: TDateTime;
begin
  Result := FDataVencimento;
end;

function TEntidadePedidoPagamento<T>.ValorParcela(Value: Currency): iEntidadePedidoPagamento<T>;
begin
  Result := Self;
  FValorParcela := Value;
end;

function TEntidadePedidoPagamento<T>.ValorParcela: Currency;
begin
  Result:= FValorParcela;
end;

function TEntidadePedidoPagamento<T>.&End: T;
begin
  Result := FParent;
end;

end.
