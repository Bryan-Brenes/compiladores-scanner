public class Token{
  private String _token;
  private int _linea;
  private int _columna;
  private String _tipo;

  public Token(String pToken, int pLinea, int pColumna, String pTipo){
    this._token = pToken;
    this._linea = pLinea;
    this._columna = pColumna;
    this._tipo = pTipo;
  }

  public void print(){
    System.out.printf("%25s\t línea: %d,\t columna: %d,\t tipo: %s\n",this._token, this._linea, this._columna, this._tipo);
  }

  public String getToken(){
    return this._token;
  }

  public int getLinea(){
    return this._linea;
  }

  public int getColumna(){
    return this._columna;
  }

  public String getTipo(){
    return this._tipo;
  }
}
