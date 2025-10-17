
import 'package:flutter/material.dart';
import '../templates/custom_input_field.dart';
import '../templates/custom_button.dart';

class FarmDetailsForm extends StatefulWidget {
	const FarmDetailsForm({super.key});

	@override
	State<FarmDetailsForm> createState() => _FarmDetailsFormState();
}

class _FarmDetailsFormState extends State<FarmDetailsForm> {
	final _formKey = GlobalKey<FormState>();
	final TextEditingController farmNameController = TextEditingController();
	final TextEditingController locationController = TextEditingController();
	final TextEditingController sizeController = TextEditingController();
	final TextEditingController typeController = TextEditingController();

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Farm Details')),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: Form(
					key: _formKey,
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							CustomInputField(
								controller: farmNameController,
								labelText: 'Farm Name',
								hintText: 'Enter farm name',
								validator: (value) => value == null || value.isEmpty ? 'Required' : null,
							),
							const SizedBox(height: 16),
							CustomInputField(
								controller: locationController,
								labelText: 'Location',
								hintText: 'Enter farm location',
								validator: (value) => value == null || value.isEmpty ? 'Required' : null,
							),
							const SizedBox(height: 16),
							CustomInputField(
								controller: sizeController,
								labelText: 'Size (acres)',
								hintText: 'Enter farm size',
								keyboardType: TextInputType.number,
								validator: (value) => value == null || value.isEmpty ? 'Required' : null,
							),
							const SizedBox(height: 16),
							CustomInputField(
								controller: typeController,
								labelText: 'Farm Type',
								hintText: 'e.g. Crop, Livestock',
								validator: (value) => value == null || value.isEmpty ? 'Required' : null,
							),
							const SizedBox(height: 32),
							CustomButton(
								text: 'Submit',
								onPressed: () {
									if (_formKey.currentState!.validate()) {
										// Handle submission logic here
										ScaffoldMessenger.of(context).showSnackBar(
											const SnackBar(content: Text('Farm details submitted!')),
										);
									}
								},
							),
						],
					),
				),
			),
		);
	}
}
