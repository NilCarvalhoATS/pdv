unit uReceber;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, DBGrids, MaskEdit, ActnList, uClienteBusca, udmpdv, db, sqldb;

type

  { TfRecebimento }

  TfRecebimento = class(TForm)
    acDinheiro: TAction;
    acDebito: TAction;
    acCredito: TAction;
    ActionList1: TActionList;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    btnConfirma: TBitBtn;
    btnProcurar: TBitBtn;
    btnSair: TBitBtn;
    Button1: TButton;
    dsRec: TDataSource;
    DBGrid1: TDBGrid;
    edCodCliente: TEdit;
    edNomeCliente: TEdit;
    Cliente: TLabel;
    Label1: TLabel;
    edTotalGeral: TMaskEdit;
    Label2: TLabel;
    edPago: TMaskEdit;
    lblForma: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    rgSituacao: TRadioGroup;
    sqPagamento: TSQLQuery;
    sqPagamentoCAIXA: TSmallintField;
    sqPagamentoCAIXINHA: TFloatField;
    sqPagamentoCODFORMA: TLongintField;
    sqPagamentoCOD_VENDA: TLongintField;
    sqPagamentoDESCONTO: TFloatField;
    sqPagamentoFORMA_PGTO: TStringField;
    sqPagamentoID_ENTRADA: TLongintField;
    sqPagamentoN_DOC: TStringField;
    sqPagamentoSTATE: TSmallintField;
    sqPagamentoTROCO: TFloatField;
    sqPagamentoVALOR_PAGO: TFloatField;
    procedure acCreditoExecute(Sender: TObject);
    procedure acDebitoExecute(Sender: TObject);
    procedure acDinheiroExecute(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure btnConfirmaClick(Sender: TObject);
    procedure btnProcurarClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure edCodClienteExit(Sender: TObject);
    procedure edCodClienteKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    codClienteR : Integer;
    procedure enviar_caixa(valor_pago: Double; codRec: Integer);
  public

  end;

var
  fRecebimento: TfRecebimento;

implementation

{$R *.lfm}

{ TfRecebimento }

procedure TfRecebimento.Button1Click(Sender: TObject);
begin
  if (edCodCliente.Text <> '') then
    fClienteBusca.cCodCliente:=StrToInt(edCodCliente.Text);
  fClienteBusca.ShowModal;
  edNomeCliente.Text := fClienteBusca.cNomeCliente;
  codClienteR := fClienteBusca.cCodCliente;
  edCodCliente.Text := IntToStr(codClienteR);
end;

procedure TfRecebimento.edCodClienteExit(Sender: TObject);
begin
  if (edCodCliente.Text <> '') then
  begin
    fClienteBusca.cCodCliente := StrToInt(edCodCliente.Text);
    fClienteBusca.BuscaCliente;
    edNomeCliente.Text := fClienteBusca.cNomeCliente;
    btnProcurar.SetFocus;
  end;
end;

procedure TfRecebimento.edCodClienteKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  begin
    Key := #0;
    if (edCodCliente.Text <> '') then
    begin
      fClienteBusca.cCodCliente := StrToInt(edCodCliente.Text);
      fClienteBusca.BuscaCliente;
      edNomeCliente.Text := fClienteBusca.cNomeCliente;
      btnProcurar.SetFocus;
    end;
  end;
end;

procedure TfRecebimento.FormCreate(Sender: TObject);
begin
  DBGrid1.Columns[0].FieldName:='CODRECEBIMENTO';
  DBGrid1.Columns[1].FieldName:='TITULO';
  DBGrid1.Columns[2].FieldName:='EMISSAO';
  DBGrid1.Columns[3].FieldName:='DATAVENCIMENTO';
  DBGrid1.Columns[4].FieldName:='DATARECEBIMENTO';
  DBGrid1.Columns[5].FieldName:='NOMECLIENTE';
  DBGrid1.Columns[6].FieldName:='VALORTITULO';
  DBGrid1.Columns[7].FieldName:='VALOR_RESTO';
  DBGrid1.Columns[0].Title.Caption := 'Código';
  DBGrid1.Columns[1].Title.Caption := 'Título';
  DBGrid1.Columns[2].Title.Caption := 'Emissão';
  DBGrid1.Columns[3].Title.Caption := 'Vencimento';
  DBGrid1.Columns[5].Title.Caption := 'Recebido';
  DBGrid1.Columns[5].Title.Caption := 'Cliente';

  DBGrid1.Columns[6].DisplayFormat:=',##0.00';
  DBGrid1.Columns[7].DisplayFormat:=',##0.00';
end;

procedure TfRecebimento.FormShow(Sender: TObject);
begin
  lblForma.Caption := '...';
end;

procedure TfRecebimento.enviar_caixa(valor_pago: Double; codRec: Integer);
var rv_codForma: Integer;
begin
  codRec := codRec + 9000000;
  // enviando o recebimento para o CAIXA
  rv_codForma := dmPdv.busca_generator('GEN_FORMA');
  if (not sqPagamento.Active) then
    sqPagamento.Open;
  sqPagamento.Insert;
  sqPagamentoCODFORMA.AsInteger  := rv_codForma;
  sqPagamentoCAIXA.AsInteger     := StrToInt(dmPdv.idcaixa);
  sqPagamentoCOD_VENDA.AsInteger := codRec;
  sqPagamentoFORMA_PGTO.AsString := Copy(lblForma.Caption,1,1);
  sqPagamentoID_ENTRADA.AsInteger:= codRec;
  sqPagamentoN_DOC.AsString      := lblForma.Caption;
  sqPagamentoSTATE.AsInteger     := 1;
  sqPagamentoVALOR_PAGO.AsFloat  := valor_pago;
  sqPagamentoDESCONTO.AsFloat    := 0;
  sqPagamentoTROCO.AsFloat       := 0;
  sqPagamento.ApplyUpdates;
end;

procedure TfRecebimento.btnProcurarClick(Sender: TObject);
var
  sql_rec: String;
  total_rec : Double;
begin
  // buscar contas (recebimento)
  total_rec := 0;
  sql_rec := 'SELECT r.CODCLIENTE, r.CODRECEBIMENTO, r.TITULO, r.EMISSAO';
  sql_rec += ', r.DATAVENCIMENTO, r.DATARECEBIMENTO ';
  sql_rec += ', (CASE WHEN r.STATUS = ' + QuotedStr('5-') + ' THEN r.VALOR_RESTO';
  sql_rec += ' ELSE 0 END) AS VALOR_RESTO, r.VALORTITULO';
  sql_rec += ', c.NOMECLIENTE FROM RECEBIMENTO r, CLIENTES c ';
  sql_rec += ' WHERE r.CODCLIENTE = c.CODCLIENTE AND r.VALOR_RESTO > 0';
  if (edCodCliente.Text <> '') then
  begin
    sql_rec += ' AND r.CODCLIENTE = ' + edCodCliente.Text;
  end;
  Case rgSituacao.ItemIndex of
    0 : sql_rec += ' AND r.STATUS  = ' + QuotedStr('5-');
    1 : sql_rec += ' AND r.STATUS  = ' + QuotedStr('7-');
    2 : sql_rec += ' AND r.STATUS  IN (' +
       QuotedStr('5-') + ',' + QuotedStr('7-') + ')';
  end;
  sql_rec += ' ORDER BY r.DATAVENCIMENTO, r.EMISSAO, r.TITULO';
  dmPdv.busca_sql(sql_rec);
  While not dmPdv.sqBusca.EOF do
  begin
    total_rec += dmPdv.sqBusca.FieldByName('VALOR_RESTO').AsFloat;
    dmPdv.sqBusca.Next;
  end;
  dmPdv.sqBusca.First;
  edTotalGeral.Text := FormatFloat('#,,,0.00',total_rec);
end;

procedure TfRecebimento.btnConfirmaClick(Sender: TObject);
var
  vlr_pg: Double;
  vlr_rt: Double;
  str_rec : String;
  //vRec : TRecebimento;
  vr_formaRec: String;
begin
  // baixar pagamentos
  if (lblForma.Caption = '...') then
  begin
    ShowMessage('Informe a FORMA de pagamento.');
    Exit;
  end;
  if (lblForma.Caption = '1-Dinheiro') then
    vr_formaRec := '1';
  if (lblForma.Caption = '2-Debito') then
    vr_formaRec := '7';
  if (lblForma.Caption = '3-Credito') then
    vr_formaRec := '6';

  if (edPago.Text = '0,00') then
  begin
    ShowMessage('Informe o Valor Pago');
    Exit;
  end;
  dmPdv.sqBusca.First;
  str_rec := IntToStr(dmPdv.sqBusca.FieldByName('CODCLIENTE').AsInteger);
  While not dmPdv.sqBusca.EOF do
  begin
    if (str_rec <> IntToStr(dmPdv.sqBusca.FieldByName('CODCLIENTE').AsInteger)) then
    begin
      ShowMessage('Selecione um cliente para fazer a Baixa, não pode ter clientes diferentes');
      Exit;
    end;
    dmPdv.sqBusca.Next;
  end;
  vlr_pg := StrToFloat(edPago.Text);
  vlr_rt := vlr_pg;
  dmPdv.sqBusca.First;
  str_rec := '';
  DecimalSeparator:='.';
  While vlr_rt > 0 do
  begin
    While not dmPdv.sqBusca.EOF do
    begin
      if (vlr_rt > 0) then
      begin
        if (dmPdv.sqBusca.FieldByName('VALOR_RESTO').AsFloat > vlr_rt) then
        begin
          // duplico o lancamento na recebimento
          // este novo item o valor vai ser a diferenca do pago
          // um vai ficar em aberto o outro como pago
          str_rec := 'INSERT INTO RECEBIMENTO (  ' +
            ' CODRECEBIMENTO, TITULO, EMISSAO, CODCLIENTE, DATAVENCIMENTO' +
            ', CAIXA, STATUS, VIA, CODVENDA, CODALMOXARIFADO, CODVENDEDOR' +
            ', CODUSUARIO, DATASISTEMA, VALOR_PRIM_VIA, VALOR_RESTO, VALORTITULO' +
            ', PARCELAS, FORMARECEBIMENTO) SELECT ' +
            ' GEN_ID(COD_AREC, 1), TITULO, EMISSAO, CODCLIENTE, DATAVENCIMENTO' +
            ', CAIXA, STATUS, VIA, CODVENDA, CODALMOXARIFADO, CODVENDEDOR' +
            ', CODUSUARIO, DATASISTEMA, ';
          vlr_pg := dmPdv.sqBusca.FieldByName('VALOR_RESTO').AsFloat - vlr_rt;
          str_rec += FloatToStr(vlr_pg) + ', ' + FloatToStr(vlr_pg); //VALOR_PRIM_VIA, VALOR_RESTO
          str_rec += ', VALORTITULO, PARCELAS, FORMARECEBIMENTO ';
          str_rec += ' FROM RECEBIMENTO WHERE CODRECEBIMENTO = ';
          str_rec += IntToStr(dmPdv.sqBusca.FieldByName('CODRECEBIMENTO').AsInteger);
          dmPdv.executaSql(str_rec);
          vlr_pg := vlr_rt;
        end
        else begin
          vlr_pg := dmPdv.sqBusca.FieldByName('VALOR_RESTO').AsFloat;
        end;
        dmPdv.executaSql('UPDATE RECEBIMENTO SET STATUS = ' +
          QuotedStr('7-') + ', VALORRECEBIDO = ' + FloattoStr(vlr_pg) +
          ' , FORMARECEBIMENTO = ' + QuotedStr(vr_formaRec) +
          ' , DATARECEBIMENTO = ' + QuotedStr(FormatDateTime('mm/dd/yyyy', Now)) +
          ' , DATABAIXA = ' + QuotedStr(FormatDateTime('mm/dd/yyyy', Now)) +
          ' , CAIXA = ' + dmPdv.idcaixa +
          ' , CODUSUARIO = ' + dmPdv.varLogado +
          ' , HISTORICO = ' + QuotedStr('Pagamento Caixa PDV : ' +
            dmPdv.nomeLogado + ', ' + dmPdv.nomeCaixa) +
          ' WHERE CODRECEBIMENTO = ' +
          IntToStr(dmPdv.sqBusca.FieldByName('CODRECEBIMENTO').asInteger));
        enviar_caixa(vlr_pg, dmPdv.sqBusca.FieldByName('CODRECEBIMENTO').AsInteger);
        vlr_rt -= vlr_pg;
      end;
      dmPdv.sqBusca.Next;
    end;
  end;
  DecimalSeparator:=',';
  dmPdv.sTrans.Commit;
end;

procedure TfRecebimento.BitBtn1Click(Sender: TObject);
begin
  edCodCliente.Text := '';
  edNomeCliente.Text := '';
end;

procedure TfRecebimento.acDinheiroExecute(Sender: TObject);
begin
  lblForma.Caption := '1-Dinheiro';
end;

procedure TfRecebimento.acDebitoExecute(Sender: TObject);
begin
  lblForma.Caption := '2-Debito';
end;

procedure TfRecebimento.acCreditoExecute(Sender: TObject);
begin
  lblForma.Caption := '3-Credito';
end;

procedure TfRecebimento.btnSairClick(Sender: TObject);
begin
  Close;
end;

end.

