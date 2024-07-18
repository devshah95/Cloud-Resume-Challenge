This repository showcases my implementation of the Cloud Resume Challenge using Amazon Web Services (AWS). It includes a resume website written in HTML and CSS, deployed on Amazon S3 with HTTPS secured by CloudFront. A custom domain name points to the site, which features a JavaScript visitor counter connected to a DynamoDB database through an API built with API Gateway and Lambda functions in Python. The project employs infrastructure as code with Terraform, continuous integration and deployment with GitHub Actions.

Steps Taken:

1. Acquired the AWS Solutions Architect certificate.
2. Completed the HTML/CSS for the webpage.
3. Created the JS file to add dynamic data into the counter element.
4. Created an IAM role and user, set up the trust relationship, and added the necessary policies.
5. Added all files into an S3 bucket and made it public.
6. Bought a domain and used AWS Certificate Manager to request a certificate.
7. Configured DNS records in Cloudflare.
8. Configured CloudFront as my CDN with the validated certificate.
9. Created a DynamoDB table for the visitor count.
10. Created a Lambda function that increments the visitor count by 1 and returns a JSON response.
11. Created an API Gateway that invokes the Lambda function.
12. Rebuilt the entire infrastructure with Terraform to automate the process.
13. Created a GitHub repository for the project.
14. Wrote a Python test to ensure the visitor counter increments correctly.
15. Set up GitHub Actions to automatically update the S3 bucket with changes in the frontend folder when pushed.

Challenges Faced:

1. Wasn't aware that I had to invalidate the cache on Cloudfront with "/\*" so I had to add that step to my deploy.yaml file
2. My IAM knowledge wasn't as strong so I had to brush up on that.
3. Updating the DNS records on CloudFlare via Terraform. I had to dig through the API docs for Cloudflare for that.
4. Configuring CORS settings correctly on API Gateway to allow the frontend to communicate with the backend. Added the appropriate headers on the API.
   - Also kept putting "devarsh.net" for the origin instead of "https://devarsh.net"
