resource "aws_key_pair" "emr_kp" {
  key_name   = "mth-key"
  public_key = "${file("${var.key_pair_public_path}")}"
}
