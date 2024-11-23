# Create Bucket
resource "google_storage_bucket" "website" {
  provider = google
  name = var.bucket_name
  location = "ASIA"
}

#Upload the index.html file 
resource "google_storage_bucket_object" "static_stite_src" {
  provider = google
  name = "index.html"
  source = "./website/index.html"
  bucket = google_storage_bucket.website.name
}

# Public Access to Bucket
resource "google_storage_object_access_control" "public_rule" {
    provider = google
  object = google_storage_bucket_object.static_stite_src.name
  bucket = google_storage_bucket.website.name
  role   = "READER"
  entity = "allUsers"
}

#Reserve a static external IP Address
resource "google_compute_global_address" "website_ip" {
  name = "website-lb-ip"
}

#Get managed zone of AWS
data "aws_route53_zone" "practiceaws" {
provider = aws
  name         = "practiceaws.click"
  private_zone = false       
}


#It will point to GCP Load Balancer
resource "aws_route53_record" "record-ns" {
    provider = aws
  zone_id = data.aws_route53_zone.practiceaws.id
#   name    = "terraform.practiceaws.click"
  name    = "terraform.${data.aws_route53_zone.practiceaws.name}"
  type    = "A"
  ttl     = "300"
  records = [google_compute_global_address.website_ip.address]
}

#Add The bucket as a CDN backup: we are using GCP loadbalancer which will need backend to serve the content which is our bucket
resource "google_compute_backend_bucket" "website-backend" {
    provider = google
    name = "website-backend-bucket" 
    bucket_name = google_storage_bucket.website.name
    description = "Contains files needed for the website."
    enable_cdn = true
}

#GCP URL Map
resource "google_compute_url_map" "website-url" {
  provider = google
  name = "website-url-map"
  default_service = google_compute_backend_bucket.website-backend.self_link
  host_rule {
    hosts = ["*"]
    path_matcher = "allpaths"
  }
    path_matcher{
    name = "allpaths"
    default_service= google_compute_backend_bucket.website-backend.self_link
    
    path_rule {
      paths   = ["/"]
      service = google_compute_backend_bucket.website-backend.self_link
    }
    }
}

#GCP HTTP Proxy
resource "google_compute_target_http_proxy" "http_proxy" {
  provider = google
  name = "website-target-proxy"
  url_map = google_compute_url_map.website-url.self_link
}

#GCP Forwarding Rules
resource "google_compute_global_forwarding_rule" "forwarding_rules" {
    provider = google
    name = "website-forwarding-rules"
    load_balancing_scheme = "EXTERNAL"
    ip_address = google_compute_global_address.website_ip.address
    ip_protocol = "TCP"
    port_range = "80"
    target = google_compute_target_http_proxy.http_proxy.self_link

}