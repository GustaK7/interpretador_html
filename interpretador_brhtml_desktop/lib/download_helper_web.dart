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
