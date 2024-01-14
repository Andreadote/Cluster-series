import boto3

# Create an S3 client using default credentials and region
s3 = boto3.client('s3')

# Set the S3 bucket and object key
bucket_name = 'your_bucket_name'
object_key = 'your_object_key'

# Download the object from S3
try:
    response = s3.get_object(Bucket=bucket_name, Key=object_key)

    # Read and print the content of the object
    content = response['Body'].read().decode('utf-8')
    print(content)

except Exception as e:
    print(f"Error: {e}")