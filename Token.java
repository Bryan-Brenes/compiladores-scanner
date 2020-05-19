public class Token{
  private String _token;
  private int _linea;
  private int _columna;

  public Token(String pToken, int pLinea, int pColumna){
    this._token = pToken;
    this._linea = pLinea;
    this._columna = pColumna;
  }

  public void print(){
    System.out.printf("%25s\t línea: %d,\t columna: %d\n",this._token, this._linea, this._columna);
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
}
