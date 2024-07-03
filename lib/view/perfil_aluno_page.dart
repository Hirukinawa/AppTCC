import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uniride/model/aluno.dart';
import 'package:uniride/view/avaliacoes_page.dart';
import 'package:url_launcher/url_launcher.dart';

class PerfilAlunoPage extends StatefulWidget {
  final Aluno alunoPerfil;
  const PerfilAlunoPage({Key? key, required this.alunoPerfil})
      : super(key: key);

  @override
  _PerfilAlunoPageState createState() => _PerfilAlunoPageState();
}

class _PerfilAlunoPageState extends State<PerfilAlunoPage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  bool uploading = false;
  List<Reference> refs = [];
  String? imagem;
  bool loading = true;
  String? imageUrl;
  ListResult? refPDFS;
  bool pdfExiste = false;

  loadImage() async {
    String imageName = "${widget.alunoPerfil.id}.jpg";
    try {
      final ref = storage.ref("images/profile/$imageName");
      bool exists = ref != "" ? true : false;
      if (exists) {
        imagem = await ref.getDownloadURL();
        setState(
          () {
            imageUrl = imagem;
            loading = false;
          },
        );
      } else {}
    } catch (e) {
      print("Erro ao carregar a imagem: $e");
    }
  }

  loadPDF() async {
    try {
      String pdfPath = 'comprovantes';
      refPDFS = await storage.ref(pdfPath).listAll();
      for (var ref in refPDFS!.items) {
        if (ref.name == "${widget.alunoPerfil.id}.pdf") {
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

  @override
  initState() {
    super.initState();
    if (mounted) loadImage();
    if (mounted) loadPDF();
  }

  @override
  Widget build(BuildContext context) {
    Aluno alunoPerfil = widget.alunoPerfil;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Usuário"),
        centerTitle: true,
        backgroundColor: const Color(0xFF186A11),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 1.25,
            child: Column(
              children: [
                const SizedBox(height: 30),
                Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          (imageUrl == null)
                              ? Image.asset(
                                  'assets/images/perfil_final.png',
                                  width: 100,
                                  height: 100,
                                )
                              : ClipOval(
                                  child: Image.network(
                                    imagem!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                          const SizedBox(width: 60),
                          (alunoPerfil.avaliacoes.isEmpty)
                              ? const Text("Nenhuma \n avaliação",
                                  style: TextStyle(
                                      fontSize: 16, fontFamily: "Inter"))
                              : Text(
                                  "Avaliação: ${(alunoPerfil.somaAvaliacoes / alunoPerfil.avaliacoes.length).toStringAsFixed(1)}",
                                  style: const TextStyle(
                                      fontFamily: 'Inter', fontSize: 20),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    Text(
                      alunoPerfil.nome,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      alunoPerfil.sexo,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    ),
                    const SizedBox(height: 30),
                    (pdfExiste)
                        ? Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.picture_as_pdf),
                                title: const Text(
                                    'Baixar comprovante de matrícula'),
                                onTap: () async {
                                  String pdfPath =
                                      "comprovantes/${widget.alunoPerfil.id}.pdf";
                                  String pdfUrl = await storage
                                      .ref(pdfPath)
                                      .getDownloadURL();
                                  var url = Uri.parse(pdfUrl);
                                  await launchUrl(url);
                                },
                              ),
                              const SizedBox(height: 30),
                            ],
                          )
                        : const SizedBox(),
                    const Text(
                      "Instituição de Ensino",
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      alunoPerfil.instituicao.descricao,
                      style: const TextStyle(
                        fontFamily: 'InterLight',
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Número de matrícula",
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      alunoPerfil.numeroMatricula,
                      style: const TextStyle(
                        fontFamily: 'InterLight',
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Número de telefone",
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      alunoPerfil.numeroTelefone,
                      style: const TextStyle(
                        fontFamily: 'InterLight',
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "E-mail",
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      alunoPerfil.email,
                      style: const TextStyle(
                        fontFamily: 'InterLight',
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        abrirWhatsApp(alunoPerfil.numeroTelefone, context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 19, 153, 10),
                        minimumSize: const Size(250, 70),
                        maximumSize: const Size(250, 140),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Image.asset(
                            'assets/images/whats.png',
                            width: 40,
                            height: 40,
                          ),
                          const Text(
                            "Abrir WhatsApp",
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(
                      color: Colors.black,
                    ),
                    const SizedBox(height: 30),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AvaliacoesPage(aluno: alunoPerfil),
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
                      "Total de avaliações: ${alunoPerfil.avaliacoes.length}",
                      style: const TextStyle(
                        fontFamily: 'InterLight',
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(color: Colors.black),
                    const SizedBox(height: 30),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void abrirWhatsApp(String telefone, BuildContext context) async {
  var whatsappUrl = Uri.parse("https://wa.me/55$telefone");

  try {
    await launchUrl(whatsappUrl);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Não foi possível abrir a conversa")));
  }
}
