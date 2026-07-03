resource "google_essential_contacts_contact" "security" {
  parent                              = "organizations/748235834085"
  email                               = "chris@wozware.com"
  language_tag                        = "en"
  notification_category_subscriptions = ["SECURITY", "TECHNICAL", "SUSPENSION"]
}
