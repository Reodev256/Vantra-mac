
import 'package:flutter/material.dart';
import '../templates/custom_input_field.dart';
import '../templates/custom_button.dart';

class CropsDetailsForm extends StatefulWidget {
	const CropsDetailsForm({super.key});

	@override
	State<CropsDetailsForm> createState() => _CropsDetailsFormState();
}

class _CropsDetailsFormState extends State<CropsDetailsForm> {
	final _formKey = GlobalKey<FormState>();
	final TextEditingController cropNameController = TextEditingController();
	final TextEditingController varietyController = TextEditingController();
	final TextEditingController areaController = TextEditingController();
	final TextEditingController seasonController = TextEditingController();

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Crops Details')),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: Form(
					key: _formKey,
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							CustomInputField(
								controller: cropNameController,
								labelText: 'Crop Name',
								hintText: 'Enter crop name',
								validator: (value) => value == null || value.isEmpty ? 'Required' : null,
							),
							const SizedBox(height: 16),
							CustomInputField(
								controller: varietyController,
								labelText: 'Variety',
								hintText: 'Enter crop variety',
								validator: (value) => value == null || value.isEmpty ? 'Required' : null,
							),
							const SizedBox(height: 16),
							CustomInputField(
								controller: areaController,
								labelText: 'Area (acres)',
								hintText: 'Enter area under crop',
								keyboardType: TextInputType.number,
								validator: (value) => value == null || value.isEmpty ? 'Required' : null,
							),
							const SizedBox(height: 16),
							CustomInputField(
								controller: seasonController,
								labelText: 'Season',
								hintText: 'Enter growing season',
								validator: (value) => value == null || value.isEmpty ? 'Required' : null,
							),
							const SizedBox(height: 32),
							CustomButton(
								text: 'Submit',
								onPressed: () {
									if (_formKey.currentState!.validate()) {
										// Handle submission logic here
										ScaffoldMessenger.of(context).showSnackBar(
											const SnackBar(content: Text('Crop details submitted!')),
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
