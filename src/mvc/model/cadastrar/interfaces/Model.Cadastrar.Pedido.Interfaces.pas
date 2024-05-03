{*******************************************************}
{                    API PDV - JSON                     }
{                      Be More Web                      }
{          In�cio do projeto 03/05/2024 10:13           }
{                 www.bemoreweb.com.br                  }
{                     (17)98169-5336                    }
{                        2003/2024                      }
{         Analista desenvolvedor (Eleandro Silva)       }
{*******************************************************}
unit Model.Cadastrar.Pedido.Interfaces;

interface

uses
  System.JSON,
  Model.Entidade.Pedido.Interfaces;

type
  iCadastrarPedido = Interface
    ['{A901D5A6-47CF-4BC7-A0AA-9F5C4D27F57C}']
    function JSONObjectPai(Value : TJSONObject) : iCadastrarPedido; overload;
    function JSONObjectPai                      : TJSONObject;      overload;
    function Post   : iCadastrarPedido;
    function Error  : Boolean;
    //inje��o de depend�ncia
    function Pedido : iEntidadePedido<iCadastrarPedido>;
    function &End   : iCadastrarPedido;
  End;

implementation

end.
