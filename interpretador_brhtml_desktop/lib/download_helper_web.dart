import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

Future<void> downloadOrShowDoc(String doc, {required void Function() showDialogDesktop}) async {
  final bytes = utf8.encode(doc);
  final blob = html.Blob([bytes], 'text/plain');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', 'DOCUMENTACAO_BRDart.txt')
    ..click();
  html.Url.revokeObjectUrl(url);
}

Future<void> downloadFileWeb(String conteudo, String nomeArquivo) async {
  final bytes = utf8.encode(conteudo);
  final blob = html.Blob([bytes], 'text/plain');
  final url = html.Url.createObjectUrlFromBlob(blob);
 //final anchor = html.AnchorElement(href: url)
  //  ..setAttribute('download', nomeArquivo)
  //  ..click();
  html.Url.revokeObjectUrl(url);
}

Future<String?> importarArquivoBrhtmlWeb() async {
  final uploadInput = html.FileUploadInputElement();
  uploadInput.accept = '.brhtml';
  uploadInput.click();
  await uploadInput.onChange.first;
  final file = uploadInput.files?.first;
  if (file != null) {
    final reader = html.FileReader();
    reader.readAsText(file);
    await reader.onLoad.first;
    return reader.result as String?;
  }
  return null;
}

Future<String?> importarArquivoBrdartWeb() async {
  final input = html.FileUploadInputElement();
  input.accept = '.brdart';
  input.click();
  final completer = Completer<String?>();
  input.onChange.listen((event) {
    final file = input.files?.first;
    if (file == null) {
      completer.complete(null);
      return;
    }
    final reader = html.FileReader();
    reader.onLoadEnd.listen((event) {
      completer.complete(reader.result as String?);
    });
    reader.readAsText(file);
  });
  return completer.future;
}
