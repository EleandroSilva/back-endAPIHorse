{*******************************************************}
{                    API PDV - JSON                     }
{                      Be More Web                      }
{          In�cio do projeto 26/04/2024 17:41           }
{                 www.bemoreweb.com.br                  }
{                     (17)98169-5336                    }
{                        2003/2024                      }
{         Analista desenvolvedor (Eleandro Silva)       }
{*******************************************************}
unit Model.Factory.Imp.Cadastrar;

interface

uses
  Model.Factory.Cadastrar.Interfaces,

  Model.Cadastrar.Empresa.Interfaces,
  Model.Cadastrar.Usuario.Interfaces,
  Model.Cadastrar.Endereco.Interfaces,
  Model.Cadastrar.Numero.Interfaces,
  Model.Cadastrar.Endereco.Empresa.Interfaces,
  Model.Cadastrar.Email.Empresa.Interfaces,
  Model.Cadastrar.Telefone.Empresa.Interfaces;

type
  TFactoryCadastrar = class(TInterfacedObject, iFactoryCadastrar)
    private
      FCadastrarEmpresa  : iCadastrarEmpresa;
      FCadastrarUsuario  : iCadastrarUsuario;
      FCadastrarEndereco : iCadastrarEndereco;
      FCadastrarNumero   : iCadastrarNumero;
      FCadastrarEnderecoEmpresa : iCadastrarEnderecoEmpresa;
      FCadastrarEmailEmpresa    : iCadastrarEmailEmpresa;
      FCadastrarTelefoneEmpresa : iCadastrarTelefoneEmpresa;
    public
      constructor Create;
      destructor Destroy; override;
      class function New : iFactoryCadastrar;

      function CadastrarEmpresa  : iCadastrarEmpresa;
      function CadastrarUsuario  : iCadastrarUsuario;
      function CadastrarEndereco : iCadastrarEndereco;
      function CadastrarNumero   : iCadastrarNumero;
      function CadastrarEnderecoEmpresa : iCadastrarEnderecoEmpresa;
      function CadastrarEmailEmpresa    : iCadastrarEmailEmpresa;
      function CadastrarTelefoneEmpresa : iCadastrarTelefoneEmpresa;
  end;

implementation

uses
  Model.Imp.Cadastrar.Empresa,
  Model.Imp.Cadastrar.Usuario,
  Model.Imp.Cadastrar.Endereco,
  Model.Imp.Cadastrar.Numero,
  Model.Imp.Cadastrar.Endereco.Empresa,
  Model.Imp.Cadastrar.Email.Empresa,
  Model.Imp.Cadastrar.Telefone.Empresa;

{ TViewFactory }

constructor TFactoryCadastrar.Create;
begin
  //
end;

destructor TFactoryCadastrar.Destroy;
begin
  inherited;
end;

class function TFactoryCadastrar.New: iFactoryCadastrar;
begin
  Result := Self.Create;
end;

function TFactoryCadastrar.CadastrarEmpresa: iCadastrarEmpresa;
begin
  if not Assigned(FCadastrarEmpresa) then
    FCadastrarEmpresa  := TCadastrarEmpresa.New;

  Result := FCadastrarEmpresa;
end;

function TFactoryCadastrar.CadastrarUsuario: iCadastrarUsuario;
begin
  if not Assigned(FCadastrarUsuario) then
    FCadastrarUsuario := TCadastrarUsuario.New;

  Result := FCadastrarUsuario;
end;

function TFactoryCadastrar.CadastrarEndereco: iCadastrarEndereco;
begin
  if not Assigned(FCadastrarEndereco) then
    FCadastrarEndereco := TCadastrarEndereco.New;

  Result := FCadastrarEndereco;
end;

function TFactoryCadastrar.CadastrarNumero: iCadastrarNumero;
begin
  if not Assigned(FCadastrarNumero) then
    FCadastrarNumero := TCadastrarNumero.New;

  Result := FCadastrarNumero;
end;

function TFactoryCadastrar.CadastrarTelefoneEmpresa: iCadastrarTelefoneEmpresa;
begin
  if not Assigned(FCadastrarTelefoneEmpresa) then
    FCadastrarTelefoneEmpresa := TCadastrarTelefoneEmpresa.New;

  Result := FCadastrarTelefoneEmpresa;
end;

function TFactoryCadastrar.CadastrarEmailEmpresa: iCadastrarEmailEmpresa;
begin
  if not Assigned(FCadastrarEmailEmpresa) then
    FCadastrarEmailEmpresa := TCadastrarEmailEmpresa.New;

  Result := FCadastrarEmailEmpresa;
end;

function TFactoryCadastrar.CadastrarEnderecoEmpresa: iCadastrarEnderecoEmpresa;
begin
  if not Assigned(FCadastrarEnderecoEmpresa) then
    FCadastrarEnderecoEmpresa := TCadastrarEnderecoEmpresa.New;

  Result := FCadastrarEnderecoEmpresa;
end;

end.
