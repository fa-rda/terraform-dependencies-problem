resource "time_sleep" "backend" {
  create_duration  = var.duration
  destroy_duration = var.duration
}
