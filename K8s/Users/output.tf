output "password" {
  value = aws_iam_user_login_profile.DB_user.*.encrypted_password
  # password | base64 --decode | keybase pgp decrypt
}