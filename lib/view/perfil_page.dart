import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uniride/view/avaliacoes_page.dart';
import 'package:uniride/view/editar_cadastro_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class PerfilPage extends StatefulWidget {
  final Aluno aluno;
  final AuthService auth;
  const PerfilPage({required this.aluno, super.key, required this.auth});

  @override
  State<PerfilPage> createState() => _PerfilPage();
}

class _PerfilPage extends State<PerfilPage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  bool uploading = false;
  bool uploadingPDF = false;
  double total = 0;
  double totalPDF = 0;
  List<Reference> refs = [];
  ListResult? refPDFS;
  String? imagem;
  bool loading = true;
  String? imageUrl;
  bool pdfExiste = false;

  @override
  initState() {
    super.initState();
    if (mounted) loadImages(widget.aluno);
    if (mounted) loadPDF(widget.aluno);
  }

  loadImages(Aluno aluno) async {
    refs = (await storage.ref("images/profile").listAll()).items;
    for (var ref in refs) {
      if (ref.name == "${aluno.id}.jpg") {
        imagem = await ref.getDownloadURL();
        setState(
          () {
            imageUrl = imagem;
            loading = false;
          },
        );
        break;
      }
    }

    setState(
      () {
        loading = false;
      },
    );
  }

  Future<XFile?> getImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  Future<UploadTask> upload(String path, Aluno aluno) async {
    File file = File(path);
    try {
      String ref = 'images/profile/${aluno.id}.jpg';
      return storage.ref(ref).putFile(file);
    } on FirebaseException catch (e) {
      throw Exception("Erro no upload: ${e.code}");
    }
  }

  pickAndUploadImage(Aluno aluno) async {
    XFile? file = await getImage();
    if (file != null) {
      UploadTask task = await upload(file.path, aluno);

      task.snapshotEvents.listen(
        (TaskSnapshot snapshot) async {
          if (snapshot.state == TaskState.running) {
            setState(
              () {
                uploading = true;
                total = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
              },
            );
          } else if (snapshot.state == TaskState.success) {
            setState(
              () {
                uploading = false;
              },
            );
            imagemEnviada(context);
            loadImages(aluno);
          }
        },
      );
    }
  }

  Future<PlatformFile?> getPDFFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      return result.files.first;
    }

    return null;
  }

  pickAndUploadPDF(Aluno aluno) async {
    PlatformFile? pdfFile = await getPDFFile();
    if (pdfFile != null) {
      UploadTask task = await uploadPDF(pdfFile.path!, aluno);

      task.snapshotEvents.listen(
        (TaskSnapshot snapshot) async {
          if (snapshot.state == TaskState.running) {
            setState(() {
              uploadingPDF = true;
              totalPDF =
                  (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
            });
          } else if (snapshot.state == TaskState.success) {
            setState(() {
              uploadingPDF = false;
            });
            comprovanteEnviado(context);
            loadPDF(aluno);
          }
        },
      );
    }
  }

  Future<UploadTask> uploadPDF(String path, Aluno aluno) async {
    File file = File(path);
    try {
      String ref = 'comprovantes/${aluno.id}.pdf';
      return storage.ref(ref).putFile(file);
    } on FirebaseException catch (e) {
      throw Exception("Erro no upload do PDF: ${e.code}");
    }
  }

  loadPDF(Aluno aluno) async {
    try {
      String pdfPath = 'comprovantes';
      refPDFS = await storage.ref(pdfPath).listAll();
      for (var ref in refPDFS!.items) {
        if (ref.name == "${widget.aluno.id}.pdf") {
          setState(() {
            pdfExiste = true;
          });
          break;
        }
      }
    } on FirebaseException catch (e) {
      print("Erro ao pegar o pdf: $e");
    }

    setState(() {
      loading = false;
    });
  }

  XFile? comprovante;
  @override
  Widget build(BuildContext context) {
    final Aluno aluno = widget.aluno;
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Perfil')),
        backgroundColor: const Color(0xFF186A11),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 1.25,
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  (loading)
                      ? const CircularProgressIndicator()
                      : (imageUrl != null)
                          ? Column(
                              children: [
                                ClipOval(
                                  child: Image.network(
                                    imageUrl!,
                                    width: 125,
                                    height: 125,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    pickAndUploadImage(aluno);
                                  },
                                  style: TextButton.styleFrom(),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      (uploading)
                                          ? const Row(
                                              children: [
                                                Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                )
                                              ],
                                            )
                                          : const Icon(Icons.upload),
                                      (uploading)
                                          ? Text("${total.round()}% enviado")
                                          : const Text("Trocar imagem"),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: Column(
                                children: [
                                  Image.asset('assets/images/perfil_final.png',
                                      width: 125),
                                  TextButton(
                                    onPressed: () async {
                                      await pickAndUploadImage(aluno);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        (uploading)
                                            ? const Row(
                                                children: [
                                                  Center(
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 20,
                                                  )
                                                ],
                                              )
                                            : const Icon(Icons.upload),
                                        (uploading)
                                            ? Text("${total.round()}% enviado")
                                            : const Text(
                                                "Fazer upload de imagem"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    aluno.nome,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Número de matrícula:",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    aluno.numeroMatricula,
                    style: const TextStyle(
                      fontFamily: "Inter",
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () async {
                      await pickAndUploadPDF(aluno);
                    },
                    child: Row(
                      children: [
                        (uploadingPDF)
                            ? const Row(
                                children: [
                                  Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  )
                                ],
                              )
                            : const Icon(Icons.upload),
                        (uploadingPDF)
                            ? Text("${totalPDF.round()}% enviado")
                            : const Text("Upload de comprovante de matrícula"),
                      ],
                    ),
                  ),
                  (pdfExiste)
                      ? Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.picture_as_pdf),
                              title:
                                  const Text('Baixar comprovante de matrícula'),
                              onTap: () async {
                                String pdfPath =
                                    "comprovantes/${widget.aluno.id}.pdf";
                                String pdfUrl =
                                    await storage.ref(pdfPath).getDownloadURL();
                                var url = Uri.parse(pdfUrl);
                                await launchUrl(url);
                              },
                            ),
                            const Divider(
                              color: Colors.black,
                            ),
                          ],
                        )
                      : const Divider(
                          color: Colors.black,
                        ),
                  const SizedBox(height: 30),
                  Text(
                    (aluno.somaAvaliacoes == 0)
                        ? "Avaliação: 0"
                        : "Avaliação: ${(aluno.somaAvaliacoes / aluno.avaliacoes.length)}",
                    style: const TextStyle(
                      fontFamily: "Inter",
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AvaliacoesPage(aluno: aluno),
                        ),
                      );
                    },
                    child: const Text(
                      "Ver todas avaliações",
                      style: TextStyle(
                        fontFamily: 'InterLight',
                        fontSize: 20,
                        color: Color(0xFF186A11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Total de avaliações: ${aluno.avaliacoes.length}",
                    style: const TextStyle(
                      fontFamily: "Inter",
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(
                    color: Colors.black,
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    child: const Text(
                      "Ver informações novamente",
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () async {
                      await tutorial(context);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    child: const Text(
                      "Alterar cadastro",
                      style: TextStyle(
                        color: Color(0xFF186A11),
                        fontFamily: "Inter",
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditarCadastroPage(aluno: aluno),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    child: const Text(
                      "Deslogar",
                      style: TextStyle(
                        color: Colors.red,
                        fontFamily: "Inter",
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      context.read<AuthService>().logout();
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  selecionarComprovante() async {
    final ImagePicker picker = ImagePicker();
    try {
      XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) setState(() => comprovante = file);
    } catch (e) {
      print(e);
    }
  }
}

Future<void> tutorial(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          "Antes de usar...",
          style: TextStyle(
            fontFamily: "Inter",
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const SingleChildScrollView(
          child: Text(
            " - Esse é um aplicativo feito para estudantes de universidades dividerem custos de locomoção para suas instituições. \n\n"
            " - O preço das caronas é dividido entre os passageiros e o motorista.\n\n"
            " - Faça upload de seu comprovante de matrícula para comprovar sua identidade.\n\n"
            " - Para oferecer uma carona você deve ir na opção ''Oferecer carona'', colocar o horário que você irá começar o trajeto, horário de sua aula, seu local de partida e os dias que você irá para a instituição.\n\n"
            " - Para pedir uma carona, você deve ir na opção ''Solicitar carona'', colocar o local que você deseja pegar a carona, horário de aula e então escolher a melhor carona para você.",
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: 16,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Entendi",
              style: TextStyle(
                fontFamily: "Inter",
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

void imagemEnviada(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Imagem enviada"),
    ),
  );
}

void comprovanteEnviado(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Comprovante enviado"),
    ),
  );
}
