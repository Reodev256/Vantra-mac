
import 'package:flutter/material.dart';
import '../templates/custom_input_field.dart';
import '../templates/custom_button.dart';

class FarmerDetailsForm extends StatefulWidget {
	const FarmerDetailsForm({super.key});

	@override
	State<FarmerDetailsForm> createState() => _FarmerDetailsFormState();
}

class _FarmerDetailsFormState extends State<FarmerDetailsForm> {
	final _formKey = GlobalKey<FormState>();
	final TextEditingController nameController = TextEditingController();
	final TextEditingController phoneController = TextEditingController();
	final TextEditingController emailController = TextEditingController();
	final TextEditingController addressController = TextEditingController();

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Farmer Details')),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: Form(
					key: _formKey,
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							CustomInputField(
								controller: nameController,
								labelText: 'Full Name',
								hintText: 'Enter your name',
								validator: (value) => value == null || value.isEmpty ? 'Required' : null,
							),
							const SizedBox(height: 16),
							CustomInputField(
								controller: phoneController,
								labelText: 'Phone Number',
								hintText: 'Enter your phone number',
								keyboardType: TextInputType.phone,
								validator: (value) => value == null || value.isEmpty ? 'Required' : null,
							),
							const SizedBox(height: 16),
							CustomInputField(
								controller: emailController,
								labelText: 'Email',
								hintText: 'Enter your email',
								keyboardType: TextInputType.emailAddress,
								validator: (value) => value == null || value.isEmpty ? 'Required' : null,
							),
							const SizedBox(height: 16),
							CustomInputField(
								controller: addressController,
								labelText: 'Address',
								hintText: 'Enter your address',
								validator: (value) => value == null || value.isEmpty ? 'Required' : null,
							),
							const SizedBox(height: 32),
							CustomButton(
								text: 'Submit',
								onPressed: () {
									if (_formKey.currentState!.validate()) {
										// Handle submission logic here
										ScaffoldMessenger.of(context).showSnackBar(
											const SnackBar(content: Text('Details submitted!')),
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
