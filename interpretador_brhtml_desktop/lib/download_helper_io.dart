Future<void> downloadOrShowDoc(String doc, {required void Function() showDialogDesktop}) async {
  // No desktop, apenas mostra o popup
  showDialogDesktop();
}
