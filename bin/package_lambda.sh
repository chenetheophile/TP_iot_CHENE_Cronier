rm lambda_function_payload.zip
mkdir lambda_package
pip install -r ac_control_lambda/requirements.txt --target lambda_package
cp ac_control_lambda/src/ac_control_lambda.py lambda_package/ac_control_lambda.py
cp ac_control_lambda/src/timestream_rp.py lambda_package/timestream_rp.py
cd lambda_package/
zip -r ../lambda_function_payload.zip *
cd ..
rm -rf lambda_package