bool ConvertBoolen(String value){
  switch (value.toLowerCase())
  {
    case  "true":
      return true;
    case "t":
      return true;
    case "1":
      return true;
    case "0":
      return false;
    case "false":
      return false;
    case "f":
      return false;
    default:
      return false;
  }
}