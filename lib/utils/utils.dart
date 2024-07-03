class Utils {
  static String stringToDate(String data) {
    String newString = "";

    newString += data[0];
    newString += data[1];
    newString += "/";
    newString += data[2];
    newString += data[3];
    newString += "/";
    newString += data[4];
    newString += data[5];
    newString += data[6];
    newString += data[7];

    return newString;
  }

  static String tiraBarra(String data) {
    return data.replaceAll("/", "");
  }

  static String mostraDias(List<bool> dias) {
    String diasSemana = "";

    List<int> index = [];

    for (int i = 0; i < dias.length; i++) {
      if (dias[i]) {
        index.add(i);
      }
    }

    for (int i = 0; i < index.length; i++) {
      diasSemana += getDia(index[i]);
      if (i < (index.length - 1)) {
        diasSemana += " - ";
      }
    }

    return diasSemana;
  }

  static String getDia(int index) {
    switch (index) {
      case 0:
        return "SEG";
      case 1:
        return "TER";
      case 2:
        return "QUA";
      case 3:
        return "QUI";
      case 4:
        return "SEX";
      case 5:
        return "SAB";
      default:
        return "Dia Inválido";
    }
  }

  static String getDias(int index) {
    switch (index) {
      case 0:
        return "Segunda-feira";
      case 1:
        return "Terça-feira";
      case 2:
        return "Quarta-feira";
      case 3:
        return "Quinta-feira";
      case 4:
        return "Sexta-feira";
      case 5:
        return "Sábado";
      default:
        return "Dia Inválido";
    }
  }
}
