terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

# Configure the GitHub Provider https://registry.terraform.io/providers/integrations/github/latest/docs
provider "github" {
  # auth https://registry.terraform.io/providers/integrations/github/latest/docs
  # To authenticate using OAuth tokens, ensure that the token argument or the GITHUB_TOKEN environment variable is set.
  # token = var.token # or `GITHUB_TOKEN`
  # Can also set GITHUB_OWNER env variable to name of the org
  owner = var.org-name
}



# read in csv file containing github ids of participants
locals {
  githubids = toset(split("\n", replace(file(var.githubidfile), "\r", "")))
  githubadmins = toset(split("\n", replace(file(var.adminidfile), "\r", "")))
}

# Add users to the organization
resource "github_membership" "org_user" {
  for_each = local.githubids
  username = each.key
  role     = "member"
}
# Add admins to the organization
resource "github_membership" "org_admin" {
  for_each = local.githubadmins
  username = each.key
  role     = "admin"
}

# Create team
resource "github_team" "participant_team" {
  name        = "ParticipantTeam"
  description = "Participant team"
  privacy     = "closed"
}

# Add users to the team
resource "github_team_membership" "participant_team_membership" {
  for_each = local.githubids
  team_id  = github_team.participant_team.id
  username = each.key
  role     = "member"
}



# Create repos
resource "github_repository" "devopsteam" {
  count       = var.teamcount
  name        = "OHTeam${format("%02d", count.index + 1)}"
  description = "OH Devops team ${format("%02d", count.index + 1)}"

  visibility = "public"
  auto_init  = true

}

# Assign team to all repos
resource "github_team_repository" "team_repo" {
  count      = var.teamcount
  team_id    = github_team.participant_team.id
  repository = github_repository.devopsteam[count.index].name
  permission = "admin"
}