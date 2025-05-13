import 'package:CookEasy/constants/colors.dart';
import 'package:CookEasy/view/screen/second_upload_screen.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:CookEasy/view/widget/custom_button.dart';
import 'package:CookEasy/view/widget/custom_text_fild_in_upload.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';


class UploadTap extends StatefulWidget {
  const UploadTap({Key? key}) : super(key: key);

  @override
  State<UploadTap> createState() => _UploadTapState();
}

class _UploadTapState extends State<UploadTap> {
  XFile? _pickedFile;
  final picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController(); // Controlador para la descripción
  String? _preparationTime; // Nueva variable para el tiempo de preparación

  Future getImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    setState(() {
      _pickedFile = picked;
    });
  }

  Widget _addCoverPhoto() {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Seleccionar de la galería'),
                    onTap: () {
                      getImage(ImageSource.gallery);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Tomar una foto'),
                    onTap: () {
                      getImage(ImageSource.camera);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: DottedBorder(
        dashPattern: const [15, 5],
        color: outline,
        strokeWidth: 2,
        borderType: BorderType.RRect,
        radius: const Radius.circular(10),
        child: SizedBox(
          width: double.infinity,
          height: 160,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _pickedFile == null
                    ? const Icon(
                        Icons.photo,
                        size: 65,
                        color: Colors.grey,
                      )
                    : Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: kIsWeb
                              ? Image.network(
                                  _pickedFile!.path,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_pickedFile!.path),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                if (_pickedFile == null)
                  const Text(
                    "Añadir foto",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                if (_pickedFile == null)
                  const Text("Máximo 12 mpx "),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(77, 67, 58, 1),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancelar",
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium!
                            .copyWith(color: Secondary),
                      ),
                    ),
                    Text(
                      "1/2",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: SecondaryText),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _addCoverPhoto(),
                    const SizedBox(height: 20),
                    Text(
                      "Nombre de la receta",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 20),
                    CustomTextFildInUpload(
                      hint: "Pon el nombre",
                      radius: 30,
                      controller: _titleController,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Descripción",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 20),
                    CustomTextFildInUpload(
                      hint: "Cuenta un poco sobre la receta",
                      maxLines: 4,
                      controller: _descriptionController,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Tiempo de preparación (aproximado)",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: "Selecciona el tiempo de preparación",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: outline),
                        ),
                        filled: true,
                        fillColor: form,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      value: _preparationTime, // Variable para almacenar el valor seleccionado
                      items: <String>[
                        'Menos de 15 minutos',
                        '15 - 30 minutos',
                        '30 - 45 minutos',
                        '45 - 60 minutos',
                        'Más de 60 minutos',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _preparationTime = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SecondUploadScreen(
                              pickedFile: _pickedFile,
                              title: _titleController.text,
                              description: _descriptionController.text,
                              preparationTime: _preparationTime, // Pasamos el tiempo de preparación
                              // Puedes pasar más datos si es necesario
                            ),
                          ),
                        );
                      },
                      text: "Siguiente",
                    )
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