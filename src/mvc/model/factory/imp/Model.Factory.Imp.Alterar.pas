{*******************************************************}
{                    API PDV - JSON                     }
{                      Be More Web                      }
{          In�cio do projeto 30/04/2024 21:49           }
{                 www.bemoreweb.com.br                  }
{                     (17)98169-5336                    }
{                        2003/2024                      }
{         Analista desenvolvedor (Eleandro Silva)       }
{*******************************************************}
unit Model.Factory.Imp.Alterar;

interface

uses
  Model.Factory.Alterar.Interfaces,
  Model.Alterar.Empresa.Interfaces,
  Model.Alterar.Email.Empresa.Interfaces,
  Model.Alterar.Telefone.Empresa.Interfaces,
  Model.Alterar.Endereco.Interfaces,
  Model.Alterar.Numero.Interfaces;

type
  TFactoryAlterar = class(TInterfacedObject, iFactoryAlterar)
    private
      FAlterarEmpresa         : iAlterarEmpresa;
      FAlterarEmailEmpresa    : iAlterarEmailEmpresa;
      FAlterarTelefoneEmpresa : iAlterarTelefoneEmpresa;
      FAlterarEndereco        : iAlterarEndereco;
      FAlterarNumero          : iAlterarNumero;
    public
      constructor Create;
      destructor Destroy; override;
      class function New : iFactoryAlterar;

      function AlterarEmpresa         : iAlterarEmpresa;
      function AlterarEmailEmpresa    : iAlterarEmailEmpresa;
      function AlterarTelefoneEmpresa : iAlterarTelefoneEmpresa;
      function AlterarEndereco        : iAlterarEndereco;
      function AlterarNumero          : iAlterarNumero;
  end;

implementation

uses
  Model.Imp.Alterar.Empresa,
  Model.Imp.Alterar.Email.Empresa,
  Model.Imp.Alterar.Telefone.Empresa,
  Model.Imp.Alterar.Endereco,
  Model.Imp.Alterar.Numero;

{ TFactoryAlterar }

constructor TFactoryAlterar.Create;
begin
  //
end;

destructor TFactoryAlterar.Destroy;
begin
  inherited;
end;

class function TFactoryAlterar.New: iFactoryAlterar;
begin
  Result := Self.Create;
end;

function TFactoryAlterar.AlterarEmpresa: iAlterarEmpresa;
begin
  if not Assigned(FAlterarEmpresa) then
    FAlterarEmpresa := TAlterarEmpresa.New;

  Result := FAlterarEmpresa;
end;

function TFactoryAlterar.AlterarEmailEmpresa: iAlterarEmailEmpresa;
begin
  if not Assigned(FAlterarEmailEmpresa) then
    FAlterarEmailEmpresa := TAlterarEmailEmpresa.New;

  Result := FAlterarEmailEmpresa;
end;

function TFactoryAlterar.AlterarTelefoneEmpresa: iAlterarTelefoneEmpresa;
begin
  if not Assigned(FAlterarTelefoneEmpresa) then
    FAlterarTelefoneEmpresa := TAlterarTelefoneEmpresa.New;

  Result := FAlterarTelefoneEmpresa;
end;

function TFactoryAlterar.AlterarEndereco: iAlterarEndereco;
begin
  if not Assigned(FAlterarEndereco) then
    FAlterarEndereco := TAlterarEndereco.New;

  Result := FAlterarEndereco;
end;

function TFactoryAlterar.AlterarNumero: iAlterarNumero;
begin
  if not Assigned(FAlterarNumero) then
    FAlterarNumero := TAlterarNumero.New;

  Result := FAlterarNumero;
end;

end.
