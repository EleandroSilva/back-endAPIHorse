{*******************************************************}
{                    API PDV - JSON                     }
{                      Be More Web                      }
{          In�cio do projeto 03/05/2024 13:46           }
{                 www.bemoreweb.com.br                  }
{                     (17)98169-5336                    }
{                        2003/2024                      }
{         Analista desenvolvedor (Eleandro Silva)       }
{*******************************************************}
unit Model.Cadastrar.Pedido.Item.Interfaces;

interface

uses
  System.JSON,
  Model.Entidade.Pedido.Item.Interfaces;

type
  iCadastrarPedidoItem = Interface
    ['{0C89BB3C-025A-4B58-B6DC-3F8B78EE8E35}']
    function JSONObjectPai(Value : TJSONObject) : iCadastrarPedidoItem; overload;
    function JSONObjectPai                      : TJSONObject;          overload;
    function Post   : iCadastrarPedidoItem;
    function Error  : Boolean;
    //inje��o de depend�ncia
    function PedidoItem : iEntidadePedidoItem<iCadastrarPedidoItem>;
    function &End       : iCadastrarPedidoItem;
  End;

implementation

end.
