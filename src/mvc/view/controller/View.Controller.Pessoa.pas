{*******************************************************}
{                    API PDV - JSON                     }
{                      Be More Web                      }
{          In�cio do projeto 05/04/2024 15:27           }
{                 www.bemoreweb.com.br                  }
{                     (17)98169-5336                    }
{                        2003/2024                      }
{         Analista desenvolvedor (Eleandro Silva)       }
{*******************************************************}
unit View.Controller.Pessoa;

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
  TViewControllerPessoa = class
    private
      FIdEmpresa  : Integer;
      FIdEndereco : Integer;
      FIdPessoa   : Integer;

      FController : iController;

      FBody       : TJSONValue;
      FJSONObject : TJSONObject;
      FJSONArray  : TJSONArray;
      //Json Pessoa-->tabela pai
      FJSONObjectPessoa  : TJSONObject;
      FJSONArrayPessoa   : TJSONArray;
      //Json - endereco
      FJSONObjectEndereco : TJSONObject;
      FJSONArrayEndereco  : TJSONArray;
      //Json EMail
      FJSONObjectEMail    : TJSONObject;
      FJSONArrayEmail     : TJSONArray;
      //Json Telefone
      FJSONObjectTelefone : TJSONObject;
      FJSONArrayTelefone  : TJSONArray;
      //DataSource
      FDataSource         : TDataSource;
      FDSPessoa           : TDataSource;
      FDSEndereco         : TDataSource;
      FDSNumero           : TDataSource;
      FDSEnderecoPessoa   : TDataSource;
      FDSEmailPessoa      : TDataSource;
      FDSTelefonePessoa   : TDataSource;
      FQuantidadeRegistro : Integer;

      procedure LoopPessoa;

      //Inje��o de depend�ncia
      function LoopEnderecoPessoa : Boolean;
      function LoopEmailPessoa    : Boolean;
      function LoopTelefonePessoa : Boolean;

      //fa�o verifica��o se j� existe cadastrado em suas tabelas espec�ficas
      function BuscarCPFCNPJ       (aCPFCNPJ : String)                                 : Boolean;
      function BuscarEndereco      (aCEP  : String)                                    : Boolean;
      function BuscarNumero        (aIdEndereco : Integer; aNumeroPessoa : String)     : Boolean;
      function BuscarEnderecoPessoa(aIdEmpresa, aIdEndereco, aIdPessoa : Integer)                     : Boolean;
      function BuscarEmailPessoa   (aIdEmpresa, aIdPessoa : Integer; aEmail : String)                : Boolean;
      function BuscarTelefonePessoa(aIdEmpresa, aIdPessoa : Integer; aDDD, aNumeroTelefone : String) : Boolean;


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

constructor TViewControllerPessoa.Create;
begin
  FController       := TController.New;
  FDSPessoa         := TDataSource.Create(nil);
  FDSEndereco       := TDataSource.Create(nil);
  FDSNumero         := TDataSource.Create(nil);
  FDSEnderecoPessoa := TDataSource.Create(nil);
  FDSEmailPessoa    := TDataSource.Create(nil);
  FDSTelefonePessoa := TDataSource.Create(nil);
  Registry;
end;

destructor TViewControllerPessoa.Destroy;
begin
  inherited;
end;

//verifico se j� consta o cnpj cadastrado na tabela Pessoa
function TViewControllerPessoa.BuscarCPFCNPJ(aCPFCNPJ : String): Boolean;
begin
  Result := False;
  FController
    .FactoryDAO
      .DAOPessoa
        .GetbyParams(aCPFCNPJ)
      .DataSet(FDSPessoa);
  Result := not FDSPessoa.DataSet.IsEmpty;
end;

//verifico se j� consta o endereco cadastrado na tabela endereco-pelo cep
function TViewControllerPessoa.BuscarEndereco(aCEP: String): Boolean;
begin
  Result := False;
  FController
    .FactoryDAO
      .DAOEndereco
        .GetbyParams(aCEP)
      .DataSet(FDSEndereco);
  Result := not FDSEndereco.DataSet.IsEmpty;
end;

//verifico se j� consta este n�mero cadastrado na tabela numero
function TViewControllerPessoa.BuscarNumero(aIdEndereco : Integer; aNumeroPessoa : String): Boolean;
begin
  Result := False;
  FController
    .FactoryDAO
      .DAONumero
        .This
          .IdEndereco    (aIdEndereco)
          .NumeroEndereco(aNumeroPessoa)
        .&End
      .GetbyParams
      .DataSet(FDSNumero);
  Result := not FDSNumero.DataSet.IsEmpty;
end;

//verifico se j� consta este n�mero cadastrado na tabela enderecopessoa
function TViewControllerPessoa.BuscarEnderecoPessoa(aIdEmpresa, aIdEndereco, aIdPessoa : Integer): Boolean;
begin
  Result := False;
  FController
    .FactoryDAO
      .DAOEnderecoPessoa
        .This
          .IdEmpresa (aIdEmpresa)
          .IdEndereco(aIdEndereco)
          .IdPessoa  (aIdPessoa)
        .&End
        .GetbyParams
        .DataSet(FDSEnderecoPessoa);

  Result := not FDSEnderecoPessoa.DataSet.IsEmpty;
end;

//verifico se j� consta este EMail cadastrado na tabela emailpessoa
function TViewControllerPessoa.BuscarEmailPessoa(aIdEmpresa, aIdPessoa : Integer; aEmail : String): Boolean;
begin
  Result := False;
  FController
    .FactoryDAO
      .DAOEmailPessoa
        .This
          .IdEmpresa(aIdEmpresa)
          .IdPessoa (aIdPessoa)
          .Email    (aEmail)
        .&End
      .GetbyParams
      .DataSet(FDSEmailPessoa);
  Result := not FDSEmailPessoa.DataSet.IsEmpty;
end;

//verifico se j� consta este EMail esta cadastrado na tabela emailpessoa que se relaciona com a tabela pessoa
function TViewControllerPessoa.BuscarTelefonePessoa(aIdEmpresa, aIdPessoa : Integer; aDDD, aNumeroTelefone : String): Boolean;
begin
  Result := False;
  FController
    .FactoryDAO
      .DAOTelefonePessoa
        .This
          .IdEmpresa     (aIdEmpresa)
          .IdPessoa      (aIdPessoa)
          .DDD           (aDDD)
          .NumeroTelefone(aNumeroTelefone)
        .&End
      .GetbyParams
      .DataSet(FDSTelefonePessoa);
  Result := not FDSEmailPessoa.DataSet.IsEmpty;
end;

procedure TViewControllerPessoa.LoopPessoa;
begin
  FJSONArrayPessoa := TJSONArray.Create;//Jsonarray Geral
  FDSPessoa.DataSet.First;
  while not FDSPessoa.DataSet.Eof do
  begin
    FJSONObjectPessoa := TJSONObject.Create;//JSONObject(Tabela pai---> pessoa)
    try
      FJSONObjectPessoa := FDSPessoa.DataSet.ToJSONObject;
    except
      on E: Exception do
      begin
        WriteLn('Erro ao converter DataSet para JSONObject: ' + E.Message);
        Break;
      end;
    end;

    try
      if LoopEnderecoPessoa then
        if FQuantidadeRegistro > 1 then
          FJSONObjectPessoa.AddPair('endereco' , FJSONArrayEndereco) else//Json tabela endereco
          FJSONObjectPessoa.AddPair('endereco' , FJSONObjectEndereco);
    except
      on E: Exception do
      begin
        WriteLn('Erro durante o loop de endere�os da pessoa, verificar as instru��es SQL no DAOEnderecopessoa: ' + E.Message);
        Break;
      end;
    end;

    try
      if LoopEmailPessoa then
        if FQuantidadeRegistro > 1 then
          FJSONObjectPessoa.AddPair('emailPessoa' , FJSONArrayEmail) else //Json tabela emailPessoa
          FJSONObjectPessoa.AddPair('emailPessoa' , FJSONObjectEMail);
    except
      on E: Exception do
      begin
        WriteLn('Erro durante o loop de email da pessoa, verificar as instru��es SQL no DAOEmailpessoa: ' + E.Message);
        Break;
      end;
    end;

    try
      if LoopTelefonePessoa then
        if FQuantidadeRegistro > 1 then
          FJSONObjectPessoa.AddPair('telefonePessoa' , FJSONArrayTelefone) else//Json tabela telefonePessoa
          FJSONObjectPessoa.AddPair('telefonePessoa' , FJSONObjectTelefone);
      except
        on E: Exception do
        begin
          WriteLn('Erro durante o loop de telefone da pessoa, verificar as instru��es SQL no DAOEmailtelefone: ' + E.Message);
          Break;
        end;
    end;

    FJSONArrayPessoa.Add(FJSONObjectPessoa);

    FDSPessoa.DataSet.Next;
  end;
end;

//Endereco
function TViewControllerPessoa.LoopEnderecoPessoa : Boolean;
begin
  Result := False;
  FQuantidadeRegistro := FController
                           .FactoryDAO
                             .DAOEnderecoPessoa
                               .This
                                 .IdPessoa(FDSPessoa.DataSet.FieldByName('id').AsInteger)
                               .&End
                             .GetbyParams
                             .DataSet(FDSEndereco)
                             .QuantidadeRegistro;
   if not FDSEndereco.DataSet.IsEmpty then
   begin
     Result := True;
     FJSONArrayEndereco := TJSONArray.Create;
     FDSEndereco.DataSet.First;
     while not FDSEndereco.DataSet.Eof do
     begin
       FJSONObjectEndereco := TJSONObject.Create;
       FJSONObjectEndereco := FDSEndereco.DataSet.ToJSONObject;
       // Se tiver mais de um registro, adiciona ao array
       if FQuantidadeRegistro > 1 then
         FJSONArrayEndereco.Add(FJSONObjectEndereco);
       FDSEndereco.DataSet.Next;
     end;
   end;
end;

//Email
function TViewControllerPessoa.LoopEmailPessoa : Boolean;
begin
  Result := False;
  FQuantidadeRegistro := FController
                           .FactoryDAO
                             .DAOEmailPessoa
                               .This
                                 .IdPessoa(FDSPessoa.DataSet.FieldByName('id').AsInteger)
                               .&End
                             .GetbyParams
                             .DataSet(FDSEmailPessoa)
                             .QuantidadeRegistro;
   if not FDSEmailPessoa.DataSet.IsEmpty then
   begin
     Result := True;
     FJSONArrayEmail := TJSONArray.Create;
     FDSEmailPessoa.DataSet.First;
     while not FDSEmailPessoa.DataSet.Eof do
     begin
       FJSONObjectEMail := TJSONObject.Create;
       FJSONObjectEMail := FDSEmailPessoa.DataSet.ToJSONObject;
       if FQuantidadeRegistro > 1 then
         FJSONArrayEmail.Add(FJSONObjectEMail);

       FDSEmailPessoa.DataSet.Next;
     end;
   end;
end;

//Telefone
function TViewControllerPessoa.LoopTelefonePessoa: Boolean;
begin
  Result := False;
  FQuantidadeRegistro := FController
                          .FactoryDAO
                            .DAOTelefonePessoa
                              .This
                                .IdPessoa(FDSPessoa.DataSet.FieldByName('id').AsInteger)
                              .&End
                            .GetbyParams
                            .DataSet(FDSTelefonePessoa)
                            .QuantidadeRegistro;
   if not FDSTelefonePessoa.DataSet.IsEmpty then
   begin
     Result := True;
     FJSONArrayTelefone := TJSONArray.Create;//JSONArray
     FDSTelefonePessoa.DataSet.First;
     while not FDSTelefonePessoa.DataSet.Eof do
     begin
       FJSONObjectTelefone := TJSONObject.Create;//JSONObject
       FJSONObjectTelefone := FDSTelefonePessoa.DataSet.ToJSONObject;
       // Se tiver mais de um registro, adiciona ao array
       if FQuantidadeRegistro > 1 then
         FJSONArrayTelefone.Add(FJSONObjectTelefone);
        FDSTelefonePessoa.DataSet.Next;
     end;
   end;
end;

procedure TViewControllerPessoa.GetAll(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lQuantidadeRegistro : Integer;
begin
  lQuantidadeRegistro := 0;
  try
      if Req.Query.Field('cpfcnpj').AsString<>'' then
        FQuantidadeRegistro := FController
                                .FactoryDAO
                                  .DAOPessoa
                                  .GetbyParams(Req.Query.Field('cpfcnpj').AsString)
                                  .DataSet(FDSPessoa)
                                  .QuantidadeRegistro
      else
      If Req.Query.Field('nomepessoa').AsString<>'' then
        FQuantidadeRegistro := FController
                                .FactoryDAO
                                  .DAOPessoa
                                  .GetbyParams(0, Req.Query.Field('nomepessoa').AsString)
                                  .DataSet(FDSPessoa)
                                  .QuantidadeRegistro
      else
        FQuantidadeRegistro := FController
                                .FactoryDAO
                                   .DAOPessoa
                                   .GetAll
                                   .DataSet(FDSPessoa)
                                   .QuantidadeRegistro;

    if not FDSPessoa.DataSet.IsEmpty  then
      lQuantidadeRegistro :=FQuantidadeRegistro;

  except
    on E: Exception do
    begin
      Res.Status(500).Send('Ocorreu um erro interno no servidor: '+ E.Message);
      Exit;
    end;
  end;

  if not FDSPessoa.DataSet.IsEmpty then
  begin
    LoopPessoa;
    if lQuantidadeRegistro > 1 then
      Res.Send<TJSONArray>(FJSONArrayPessoa)
    else
      Res.Send<TJSONObject>(FJSONObjectPessoa);

    Res.Status(201).Send('Registro encontrado com sucesso!');
  end
  else
    Res.Status(400).Send('Registro n�o encontrado!');
end;

procedure TViewControllerPessoa.GetbyId(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  Try
    FController
      .FactoryDAO
        .DAOPessoa
          .GetbyId(Req.Params['id'].ToInt64)
          .DataSet(FDSPessoa);

    FJSONObjectPessoa := FDSPessoa.DataSet.ToJSONObject();
    Res.Send<TJSONObject>(FJSONObjectPessoa);
  except
    on E: Exception do
    begin
      Res.Status(500).Send('Ocorreu um erro interno no servidor.');
      Exit;
    end;
  end;

  if not FDSPessoa.DataSet.IsEmpty then
  begin
    LoopPessoa;
    Res.Send<TJSONObject>(FJSONObjectPessoa);
    Res.Status(201).Send('Registro encontrado com sucesso!');
  end
  else
    Res.Status(400).Send('Registro n�o encontrado!')
end;

procedure TViewControllerPessoa.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
Var
  I : Integer;
  LNumero  : String;
  LCPFCNPJ : String;

  LObjectPessoa  : TJSONObject;//JSONObject-pessoa
  LArrayEndereco  : TJSONArray; //JSONArray -endereco
  LEnderecoObject : TJSONObject;//JSONObject-endereco
  LNumeroArray    : TJSONArray;//JSONArray-numero
  LNumeroObject   : TJSONObject;//JSONObject-numero
  LEmailArray     : TJSONArray; //JSONArray -email
  LEmailObject    : TJSONObject;//JSONObject-email
  LTelefoneArray  : TJSONArray; //JSONArray -telefone
  LTelefoneObject : TJSONObject;//JSONObject-telefone
begin
  //L� os dados JSON da requisi��o (tabela pai='pessoa')
  LObjectPessoa := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
  LCPFCNPJ      := LObjectPessoa.GetValue('cpfcnpj').Value;
  FController.FactoryDAO.Uteis.ValidaCnpjCeiCpf(LCPFCNPJ, True);
  FIdEmpresa    := LObjectPessoa.GetValue<Integer>('idempresa');
  try
    if BuscarCPFCNPJ(LCPFCNPJ) then
    begin
      Res.Status(400).Send('Este CPF ou CNPJ j� consta em nossa base de dados!');
      Exit;
    end;
  except
    on E: Exception do
    begin
      Res.Status(500).Send('Ocorreu um erro interno no servidor.');
      Exit;
    end;
  end;

  //tabela pai
  LObjectPessoa := Req.Body<TJSONObject>;
  try
    try
      try
        FController
          .FactoryDAO
            .DAOPessoa
              .This
                .IdEmpresa      (LObjectPessoa.GetValue<Integer>  ('idempresa'))
                .IdUsuario      (LObjectPessoa.GetValue<Integer>  ('idusuario'))
                .CPFCNPJ        (LObjectPessoa.GetValue<String>   ('cpfcnpj'))
                .RGIE           (LObjectPessoa.GetValue<String>   ('rgie'))
                .NomePessoa     (LObjectPessoa.GetValue<String>   ('nomepessoa'))
                .SobreNome      (LObjectPessoa.GetValue<String>   ('sobrenome'))
                .FisicaJuridica (LObjectPessoa.GetValue<String>   ('fisicajuridica'))
                .Sexo           (LObjectPessoa.GetValue<String>   ('sexo'))
                .TipoPessoa     (LObjectPessoa.GetValue<String>   ('tipopessoa'))
                .DataHoraEmissao(LObjectPessoa.GetValue<TDateTime>('dataemissao'))
                .DataNascimento (LObjectPessoa.GetValue<TDateTime>('datanascimento'))
                .Ativo          (1)
              .&End
            .Post
            .DataSet(FDSPessoa);
        FIdPessoa  := FDSPessoa.DataSet.FieldByName('id').AsInteger;
        FIdEmpresa := LObjectPessoa.GetValue<Integer>('idempresa');
      except
        on E: Exception do
        begin
          Res.Status(500).Send('Ocorreu um erro interno no servidor'+E.Message);
          Exit;
        end;
      end;
      //Obt�m os dados JSON do corpo da requisi��o da tabela('endereco')
      LArrayEndereco := LObjectPessoa.GetValue('endereco') as TJSONArray;
      try
        // Loop do(s) endere�o(s)
        for I := 0 to LArrayEndereco.Count - 1 do
        begin
          //Extraindo os dados do endere�o e salvando no banco de dados
          LEnderecoObject := LArrayEndereco.Items[I] as TJSONObject;
          //verificando se j� consta este cep cadastrado na tabela endereco(se n�o estiver insiro o mesmo)
          if not BuscarEndereco(LEnderecoObject.GetValue<String>('cep')) then
            FController
              .FactoryDAO
                .DAOEndereco
                  .This
                    .Cep           (LEnderecoObject.GetValue<String>('cep'))
                    .IBGE          (LEnderecoObject.GetValue<Integer>('ibge'))
                    .UF            (LEnderecoObject.GetValue<String>('uf'))
                    .TipoLogradouro(LEnderecoObject.GetValue<String>('tipologradouro'))
                    .Logradouro    (LEnderecoObject.GetValue<String>('logradouro'))
                    .Bairro        (LEnderecoObject.GetValue<String>('bairro'))
                    .GIA           (LEnderecoObject.GetValue<Integer>('gia'))
                    .DDD           (LEnderecoObject.GetValue<String>('ddd'))
                  .&End
                .Post
                .DataSet(FDSEndereco);
            FIdEndereco := FDSEndereco.DataSet.FieldByName('id').AsInteger;
            LNumeroArray  := LObjectPessoa.GetValue('numero') as TJSONArray;
            LNumeroObject :=  LNumeroArray.Items[I] as TJSONObject;
             //verificando se j� consta este n�mero cadastrado na tabela numero(se n�o estiver insiro o mesmo)
            if not BuscarNumero(FIdEndereco, LNumeroObject.GetValue<String>('numeroendereco')) then
              //Inserindo dados na tabela numero
              FController
                .FactoryDAO
                  .DAONumero
                    .This
                      .IdEndereco         (FIdEndereco)
                      .NumeroEndereco     (LNumeroObject.GetValue<String>('numeroendereco'))
                      .ComplementoEndereco(LNumeroObject.GetValue<String>('complementoendereco'))
                    .&End
                  .Post;
            //Inserindo dados na tabela enderecopessoa caso n�o existir
            if not BuscarEnderecoPessoa(FIdEmpresa, FIdEndereco, FIdPessoa) then
            FController
                    .FactoryDAO
                      .DAOEnderecoPessoa
                        .This
                          .IdEmpresa (FIdEmpresa)
                          .IdEndereco(FIdEndereco)
                          .IdPessoa  (FIdPessoa)
                        .&End
                     .Post;
        end;
      except
        Res.Status(500).Send('Ocorreu um erro interno no servidor.');
        Exit;
      end;
      //Obt�m os dados JSON do corpo da requisi��o da tabela('emailempresa')
      LEmailArray := LObjectPessoa.GetValue('emailpessoa') as TJSONArray;
      try
        //Loop emails
        for I := 0 to LEmailArray.Count - 1 do
        begin
          //Extraindo os dados do(s) emai(s)  e salvando no banco de dados
          LEmailObject :=  LEmailArray.Items[I] as TJSONObject;
          //verifico se consta o email que esta vindo no json. Na tabela emailempresa, se n�o existir insiro.
          if not BuscarEmailPessoa(FIdEmpresa, FIdPessoa, LEmailObject.GetValue<String>('email')) Then
            FController
              .FactoryDAO
                .DAOEmailPessoa
                  .This
                    .IdEmpresa(FIdEmpresa)
                    .IdPessoa (FIdPessoa)
                    .Email    (LEmailObject.GetValue<String>('email'))
                    .TipoEmail(LEmailObject.GetValue<String>('tipoemail'))
                    .Ativo    (1)
                  .&End
                .Post;
        end;
      except
        Res.Status(500).Send('Ocorreu um erro interno no servidor.');
        Exit;
      end;
      //Obt�m os dados JSON do corpo da requisi��o da tabela('telefonepessoa')
      LTelefoneArray := LObjectPessoa.GetValue('telefonepessoa') as TJSONArray;
      try
        //Loop telefone(s)
        for I := 0 to LTelefoneArray.Count - 1 do
        begin
          //Extraindo os dados do(s) telefone(s) e salvando no banco de dados
          LTelefoneObject := LTelefoneArray.Items[I] as TJSONObject;
          //verifico se consta o telefone que esta vindo no json. Na tabela telefoneempresa, se n�o existir insiro.
          if not BuscarTelefonePessoa(FIdEmpresa, FIdPessoa, LEmailObject.GetValue<String>('ddd'),LTelefoneObject.GetValue<String>('numerotelefone')) Then
            FController
              .FactoryDAO
                .DAOTelefonePessoa
                  .This
                    .IdEmpresa     (FIdEmpresa)
                    .IdPessoa      (FIdPessoa)
                    .Operadora     (LTelefoneObject.GetValue<String>('operadora'))
                    .DDD           (LTelefoneObject.GetValue<String>('ddd'))
                    .NumeroTelefone(LTelefoneObject.GetValue<String>('numerotelefone'))
                    .TipoTelefone  (LTelefoneObject.GetValue<String>('tipotelefone'))
                    .Ativo         (1)
                  .&End
                .Post;
        end;
      except
        on E: Exception do
        begin
          Res.Status(500).Send('Ocorreu um erro interno no servidor'+E.Message);
          Exit;
        end;
      end;
    except
      on E: Exception do
      begin
        Res.Status(500).Send('Ocorreu um  erro interno no servidor'+E.Message);
        FController.FactoryDAO.DAOPessoa.This.Id(FIdPessoa).&End.Delete;//exclu�ndo empresa lan�ada
        FController.FactoryDAO.DAOEndereco.This.Id(FIdEndereco).&End.Delete;//exclu�ndo o endere�o lancado
        //caso ocorrer algum erro neste final excluir todo os inserts
        Exit;
      end;
    end;
  finally
    Res.Status(204).Send('Registro inclu�do com sucesso!');
  end;
end;

procedure TViewControllerPessoa.Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  I : Integer;
  LObjectPessoa  : TJSONObject;//JSONObject-Pessoa
  LArrayEndereco  : TJSONArray; //JSONArray -endereco
  LObjectEndereco : TJSONObject;//JSONObject-endereco
  LArrayNumero   : TJSONArray;//JSONArray-numero
  LObjectNumero   : TJSONObject;//JSONObject-numero
  LArrayEmail     : TJSONArray; //JSONArray -email
  LObjectEmail    : TJSONObject;//JSONObject-email
  LArrayTelefone  : TJSONArray; //JSONArray -telefone
  LObjectTelefone : TJSONObject;//JSONObject-telefone
begin
  LObjectPessoa := Req.Body<TJSONObject>; //Tabela Pai Pessoa
  try
    try
      FController
        .FactoryDAO
          .DAOPessoa
            .This
              .Id             (LObjectPessoa.GetValue<Integer>  ('id'))
              .IdEmpresa      (LObjectPessoa.GetValue<Integer>  ('idempresa'))
              .IdUsuario      (LObjectPessoa.GetValue<Integer>  ('idusuario'))
              .CPFCNPJ        (LObjectPessoa.GetValue<String>   ('cpfcnpj'))
              .RGIE           (LObjectPessoa.GetValue<String>   ('rgie'))
              .NomePessoa     (LObjectPessoa.GetValue<String>   ('nomePessoa'))
              .SobreNome      (LObjectPessoa.GetValue<String>   ('sobrenome'))
              .FisicaJuridica (LObjectPessoa.GetValue<String>   ('fisicajuridica'))
              .Sexo           (LObjectPessoa.GetValue<String>   ('sexo'))
              .TipoPessoa     (LObjectPessoa.GetValue<String>   ('tipopessoa'))
              .DataHoraEmissao(LObjectPessoa.GetValue<TDateTime>('dataemissao'))
              .DataNascimento (LObjectPessoa.GetValue<TDateTime>('datanascimento'))
              .Ativo          (LObjectPessoa.GetValue<Integer>  ('ativo'))
            .&End
          .Put
          .DataSet(FDSPessoa);
    except
      on E: Exception do
      raise Res.Status(500).Send('Ocorreu um erro interno no servidor'+E.Message);
    end;
    //Obt�m os dados JSON do corpo da requisi��o da tabela('endereco')
    LArrayEndereco := LObjectPessoa.Get('endereco').JsonValue as TJSONArray;
    try
      // Loop do(s) endere�o(s)
      for I := 0 to LArrayEndereco.Count - 1 do
      begin
        LObjectEndereco := LArrayEndereco.Items[I] as TJSONObject;
        FController
          .FactoryDAO
            .DAOEndereco
              .This
                .Id            (LObjectEndereco.GetValue<Integer>('id'))
                .Cep           (LObjectEndereco.GetValue<String>('cep'))
                .IBGE          (LObjectEndereco.GetValue<Integer>('ibge'))
                .UF            (LObjectEndereco.GetValue<String>('uf'))
                .TipoLogradouro(LObjectEndereco.GetValue<String>('tipoLogradouro'))
                .Logradouro    (LObjectEndereco.GetValue<String>('Logradouro'))
                .Bairro        (LObjectEndereco.GetValue<String>('bairro'))
                .GIA           (LObjectEndereco.GetValue<Integer>('gia'))
                .DDD           (LObjectEndereco.GetValue<String>('ddd'))
              .&End
            .Put
            .DataSet(FDSEndereco);
        //Atualizando dados na tabela numero
        LObjectNumero := TJSONObject(LObjectEndereco.GetValue('numero'));
        FController
          .FactoryDAO
            .DAONumero
              .This
                .Id                 (LObjectNumero  .GetValue<Integer>('id'))
                .IdEndereco         (LObjectEndereco.GetValue<Integer>('id'))
                .NumeroEndereco     (LObjectNumero  .GetValue<String>('numeroendereco'))
                .ComplementoEndereco(LObjectNumero  .GetValue<String>('complementoendereco'))
              .&End
            .Put;
        //Atualizando dados na tabela enderecoPessoa
        FController
          .FactoryDAO
            .DAOEnderecoPessoa
              .This
                .IdEmpresa (FIdEmpresa)
                .IdEndereco(LObjectEndereco.GetValue<Integer>('id'))
                .IdPessoa  (LObjectPessoa .GetValue('id').Value.ToInteger)
              .&End
            .Put;
      end;
    except
      on E: Exception do
      raise Res.Status(500).Send('Ocorreu um erro interno no servidor'+E.Message);
    end;
    //Obt�m os dados JSON do corpo da requisi��o da tabela('emailPessoa')
    LArrayEmail := LObjectPessoa.Get('emailPessoa').JsonValue as TJSONArray;
    try
      //Loop emails
      for I := 0 to LArrayEmail.Count - 1 do
      begin
        //Extraindo os dados do(s) emai(s)  e salvando no banco de dados
        LObjectEmail :=  LArrayEmail.Items[I] as TJSONObject;
        FController
          .FactoryDAO
            .DAOEmailPessoa
              .This
                .Id       (LObjectEmail  .GetValue<Integer>('id'))
                .IdEmpresa(FIdEmpresa)
                .IdPessoa (LObjectPessoa.GetValue<Integer>('id'))
                .Email    (LObjectEmail  .GetValue<String> ('email'))
                .TipoEmail(LObjectEmail  .GetValue<String> ('tipoemail'))
                .Ativo    (LObjectEmail  .GetValue<Integer>('ativo'))
              .&End
            .Put;
      end;
    except
      on E: Exception do
      raise Res.Status(500).Send('Ocorreu um erro interno no servidor'+E.Message);
    end;
    //Obt�m os dados JSON do corpo da requisi��o da tabela('telefonePessoa')
    LArrayTelefone := LObjectPessoa.Get('telefonePessoa').JsonValue as TJSONArray;
    try
      //Loop telefone(s)
      for I := 0 to LArrayTelefone.Count - 1 do
      begin
        //Extraindo os dados do(s) telefone(s) e salvando no banco de dados
        LObjectTelefone := LArrayTelefone.Items[I] as TJSONObject;
        FController
          .FactoryDAO
            .DAOTelefonePessoa
              .This
                .Id            (LObjectTelefone.GetValue<Integer>('id'))
                .IdEmpresa     (FIdEmpresa)
                .IdPessoa      (LObjectPessoa .GetValue<Integer>('id'))
                .Operadora     (LObjectTelefone.GetValue<String> ('operadora'))
                .DDD           (LObjectTelefone.GetValue<String> ('ddd'))
                .NumeroTelefone(LObjectTelefone.GetValue<String> ('numerotelefone'))
                .TipoTelefone  (LObjectTelefone.GetValue<String> ('tipotelefone'))
                .Ativo         (LObjectTelefone.GetValue<Integer>('ativo'))
              .&End
            .Put;
      end;
    except
      on E: Exception do
      raise Res.Status(500).Send('Ocorreu um erro interno no servidor'+E.Message);
    end;
  finally
    Res.Status(204).Send('Registro alterado com sucesso!');
  end;
end;

procedure TViewControllerPessoa.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  try
    try
      FController
        .FactoryDAO
          .DAOPessoa
            .This
              .Id(Req.Params['id'].ToInt64)
            .&End
          .Delete
          .DataSet(FDSPessoa);
    except
      on E: Exception do
      raise Res.Status(500).Send('Ocorreu um erro interno no servidor'+E.Message);
    End;
  Finally
    Res.Status(204).Send('Registro exclu�do com sucesso!');
  End;
end;

procedure TViewControllerPessoa.Registry;
begin
  THorse
      .Group
        .Prefix  ('bmw')
          .Get   ('/pessoa/:id' , GetbyId)
          .Get   ('/pessoa'     , GetAll)
          .Post  ('pessoa'      , Post)
          .Put   ('pessoa/:id'  , Put)
          .Delete('pessoa/:id'  , Delete);
end;

end.
